/**
 * Sync Routes
 * Offline-first data synchronization
 */

import { Hono } from 'hono';
import { z } from 'zod';
import { generateId } from '../utils/id';
import { success, error, ErrorCodes } from '../utils/response';
import { authMiddleware } from '../middleware/auth';
import type { Env, SyncLog, Moment, Letter, Comment, CircleMember } from '../types';

const sync = new Hono<{ Bindings: Env }>();

// Validation schemas
const syncChangeSchema = z.object({
  entityType: z.enum(['moment', 'letter', 'comment', 'member']),
  entityId: z.string(),
  action: z.enum(['create', 'update', 'delete']),
  data: z.any(),
  timestamp: z.string(),
});

const syncPushSchema = z.object({
  circleId: z.string(),
  changes: z.array(syncChangeSchema),
  clientTimestamp: z.string(),
});

interface SyncChange {
  entityType: string;
  entityId: string;
  action: 'create' | 'update' | 'delete';
  data?: any;
  timestamp: string;
}

/**
 * GET /sync/changes
 * Get changes since a given timestamp for a circle
 */
sync.get('/changes', authMiddleware, async (c) => {
  const userId = c.get('userId');
  const circleId = c.req.query('circleId');
  const since = c.req.query('since'); // ISO timestamp
  const limit = Math.min(parseInt(c.req.query('limit') || '100'), 500);

  if (!circleId) {
    return c.json(error(ErrorCodes.INVALID_INPUT, 'circleId required'), 400);
  }

  // Verify user is member of circle
  const member = await c.env.DB.prepare(
    'SELECT 1 FROM circle_members WHERE circle_id = ? AND user_id = ?'
  )
    .bind(circleId, userId)
    .first();

  if (!member) {
    return c.json(error(ErrorCodes.FORBIDDEN, 'Not a member of this circle'), 403);
  }

  // Build query
  let query = `
    SELECT * FROM sync_log 
    WHERE circle_id = ?
  `;
  const bindings: (string | number)[] = [circleId];

  if (since) {
    query += ` AND timestamp > ?`;
    bindings.push(since);
  }

  query += ` ORDER BY timestamp ASC LIMIT ?`;
  bindings.push(limit + 1); // Fetch one extra to check if there's more

  const logs = await c.env.DB.prepare(query)
    .bind(...bindings)
    .all<SyncLog>();

  const hasMore = logs.results.length > limit;
  const results = hasMore ? logs.results.slice(0, limit) : logs.results;

  // Transform to sync changes
  const changes: SyncChange[] = results.map((log) => ({
    entityType: log.entity_type,
    entityId: log.entity_id,
    action: log.action,
    data: log.data ? JSON.parse(log.data) : null,
    timestamp: log.timestamp,
  }));

  // Get the latest timestamp
  const serverTimestamp = results.length > 0 
    ? results[results.length - 1].timestamp 
    : new Date().toISOString();

  return c.json(
    success({
      changes,
      serverTimestamp,
      hasMore,
    })
  );
});

/**
 * POST /sync/push
 * Push local changes to server
 */
sync.post('/push', authMiddleware, async (c) => {
  const userId = c.get('userId');
  const body = await c.req.json();

  // Validate input
  const result = syncPushSchema.safeParse(body);
  if (!result.success) {
    return c.json(
      error(ErrorCodes.VALIDATION_ERROR, result.error.errors[0].message),
      400
    );
  }

  const { circleId, changes, clientTimestamp } = result.data;

  // Verify user is member of circle
  const member = await c.env.DB.prepare(
    'SELECT role FROM circle_members WHERE circle_id = ? AND user_id = ?'
  )
    .bind(circleId, userId)
    .first<{ role: string }>();

  if (!member) {
    return c.json(error(ErrorCodes.FORBIDDEN, 'Not a member of this circle'), 403);
  }

  const results: { entityId: string; status: 'success' | 'conflict' | 'error'; message?: string }[] = [];
  const serverTimestamp = new Date().toISOString();

  // Process each change
  for (const change of changes) {
    try {
      const processed = await processChange(c.env.DB, userId, circleId, change, serverTimestamp);
      results.push({ entityId: change.entityId, status: processed.status, message: processed.message });
    } catch (err) {
      results.push({ 
        entityId: change.entityId, 
        status: 'error', 
        message: err instanceof Error ? err.message : 'Unknown error' 
      });
    }
  }

  return c.json(
    success({
      results,
      serverTimestamp,
      processed: results.filter((r) => r.status === 'success').length,
      conflicts: results.filter((r) => r.status === 'conflict').length,
      errors: results.filter((r) => r.status === 'error').length,
    })
  );
});

/**
 * Process a single sync change
 */
async function processChange(
  db: D1Database,
  userId: string,
  circleId: string,
  change: SyncChange,
  serverTimestamp: string
): Promise<{ status: 'success' | 'conflict' | 'error'; message?: string }> {
  const { entityType, entityId, action, data } = change;

  switch (entityType) {
    case 'moment':
      return processMomentChange(db, userId, circleId, entityId, action, data, serverTimestamp);
    case 'letter':
      return processLetterChange(db, userId, circleId, entityId, action, data, serverTimestamp);
    case 'comment':
      return processCommentChange(db, userId, circleId, entityId, action, data, serverTimestamp);
    default:
      return { status: 'error', message: `Unknown entity type: ${entityType}` };
  }
}

async function processMomentChange(
  db: D1Database,
  userId: string,
  circleId: string,
  entityId: string,
  action: string,
  data: any,
  serverTimestamp: string
): Promise<{ status: 'success' | 'conflict' | 'error'; message?: string }> {
  if (action === 'create') {
    // Check if already exists (conflict)
    const existing = await db.prepare('SELECT id FROM moments WHERE id = ?')
      .bind(entityId)
      .first();

    if (existing) {
      return { status: 'conflict', message: 'Moment already exists' };
    }

    await db.prepare(
      `INSERT INTO moments (id, circle_id, author_id, content, media_type, media_url, 
        timestamp, time_label, context_tags, location, future_message, created_at, updated_at)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`
    )
      .bind(
        entityId,
        circleId,
        userId,
        data.content,
        data.mediaType || 'text',
        data.mediaUrl || null,
        data.timestamp || serverTimestamp,
        data.timeLabel,
        data.contextTags ? JSON.stringify(data.contextTags) : null,
        data.location || null,
        data.futureMessage || null,
        serverTimestamp,
        serverTimestamp
      )
      .run();

    // Log the sync
    await logSyncChange(db, circleId, 'moment', entityId, 'create', serverTimestamp);

    return { status: 'success' };
  }

  if (action === 'update') {
    // Check ownership
    const moment = await db.prepare(
      'SELECT author_id, updated_at FROM moments WHERE id = ? AND circle_id = ?'
    )
      .bind(entityId, circleId)
      .first<{ author_id: string; updated_at: string }>();

    if (!moment) {
      return { status: 'error', message: 'Moment not found' };
    }

    if (moment.author_id !== userId) {
      return { status: 'error', message: 'Not authorized' };
    }

    await db.prepare(
      `UPDATE moments SET 
        content = COALESCE(?, content),
        media_url = COALESCE(?, media_url),
        time_label = COALESCE(?, time_label),
        context_tags = COALESCE(?, context_tags),
        location = COALESCE(?, location),
        is_favorite = COALESCE(?, is_favorite),
        future_message = COALESCE(?, future_message),
        updated_at = ?
       WHERE id = ?`
    )
      .bind(
        data.content || null,
        data.mediaUrl || null,
        data.timeLabel || null,
        data.contextTags ? JSON.stringify(data.contextTags) : null,
        data.location || null,
        data.isFavorite !== undefined ? (data.isFavorite ? 1 : 0) : null,
        data.futureMessage || null,
        serverTimestamp,
        entityId
      )
      .run();

    await logSyncChange(db, circleId, 'moment', entityId, 'update', serverTimestamp);

    return { status: 'success' };
  }

  if (action === 'delete') {
    const moment = await db.prepare(
      'SELECT author_id FROM moments WHERE id = ? AND circle_id = ?'
    )
      .bind(entityId, circleId)
      .first<{ author_id: string }>();

    if (!moment) {
      return { status: 'error', message: 'Moment not found' };
    }

    if (moment.author_id !== userId) {
      return { status: 'error', message: 'Not authorized' };
    }

    await db.prepare(
      `UPDATE moments SET deleted_at = ? WHERE id = ?`
    )
      .bind(serverTimestamp, entityId)
      .run();

    await logSyncChange(db, circleId, 'moment', entityId, 'delete', serverTimestamp);

    return { status: 'success' };
  }

  return { status: 'error', message: `Unknown action: ${action}` };
}

async function processLetterChange(
  db: D1Database,
  userId: string,
  circleId: string,
  entityId: string,
  action: string,
  data: any,
  serverTimestamp: string
): Promise<{ status: 'success' | 'conflict' | 'error'; message?: string }> {
  if (action === 'create') {
    const existing = await db.prepare('SELECT id FROM letters WHERE id = ?')
      .bind(entityId)
      .first();

    if (existing) {
      return { status: 'conflict', message: 'Letter already exists' };
    }

    await db.prepare(
      `INSERT INTO letters (id, circle_id, author_id, title, preview, content, 
        status, type, recipient, created_at, updated_at)
       VALUES (?, ?, ?, ?, ?, ?, 'draft', ?, ?, ?, ?)`
    )
      .bind(
        entityId,
        circleId,
        userId,
        data.title,
        data.preview || data.content?.substring(0, 100) || '',
        data.content || null,
        data.type || 'free',
        data.recipient || '',
        serverTimestamp,
        serverTimestamp
      )
      .run();

    await logSyncChange(db, circleId, 'letter', entityId, 'create', serverTimestamp);

    return { status: 'success' };
  }

  if (action === 'update') {
    const letter = await db.prepare(
      'SELECT author_id, status FROM letters WHERE id = ? AND circle_id = ?'
    )
      .bind(entityId, circleId)
      .first<{ author_id: string; status: string }>();

    if (!letter) {
      return { status: 'error', message: 'Letter not found' };
    }

    if (letter.author_id !== userId) {
      return { status: 'error', message: 'Not authorized' };
    }

    // Can only update drafts
    if (letter.status !== 'draft' && !data.unlockDate) {
      return { status: 'error', message: 'Cannot edit sealed letter' };
    }

    await db.prepare(
      `UPDATE letters SET 
        title = COALESCE(?, title),
        preview = COALESCE(?, preview),
        content = COALESCE(?, content),
        recipient = COALESCE(?, recipient),
        updated_at = ?
       WHERE id = ?`
    )
      .bind(
        data.title || null,
        data.preview || null,
        data.content || null,
        data.recipient || null,
        serverTimestamp,
        entityId
      )
      .run();

    await logSyncChange(db, circleId, 'letter', entityId, 'update', serverTimestamp);

    return { status: 'success' };
  }

  if (action === 'delete') {
    const letter = await db.prepare(
      'SELECT author_id FROM letters WHERE id = ? AND circle_id = ?'
    )
      .bind(entityId, circleId)
      .first<{ author_id: string }>();

    if (!letter) {
      return { status: 'error', message: 'Letter not found' };
    }

    if (letter.author_id !== userId) {
      return { status: 'error', message: 'Not authorized' };
    }

    await db.prepare(
      `UPDATE letters SET deleted_at = ? WHERE id = ?`
    )
      .bind(serverTimestamp, entityId)
      .run();

    await logSyncChange(db, circleId, 'letter', entityId, 'delete', serverTimestamp);

    return { status: 'success' };
  }

  return { status: 'error', message: `Unknown action: ${action}` };
}

async function processCommentChange(
  db: D1Database,
  userId: string,
  circleId: string,
  entityId: string,
  action: string,
  data: any,
  serverTimestamp: string
): Promise<{ status: 'success' | 'conflict' | 'error'; message?: string }> {
  if (action === 'create') {
    const existing = await db.prepare('SELECT id FROM comments WHERE id = ?')
      .bind(entityId)
      .first();

    if (existing) {
      return { status: 'conflict', message: 'Comment already exists' };
    }

    await db.prepare(
      `INSERT INTO comments (id, target_id, target_type, author_id, content, reply_to_id, created_at)
       VALUES (?, ?, ?, ?, ?, ?, ?)`
    )
      .bind(
        entityId,
        data.targetId,
        data.targetType || 'moment',
        userId,
        data.content,
        data.replyToId || null,
        serverTimestamp
      )
      .run();

    await logSyncChange(db, circleId, 'comment', entityId, 'create', serverTimestamp);

    return { status: 'success' };
  }

  if (action === 'delete') {
    const comment = await db.prepare(
      'SELECT author_id FROM comments WHERE id = ?'
    )
      .bind(entityId)
      .first<{ author_id: string }>();

    if (!comment) {
      return { status: 'error', message: 'Comment not found' };
    }

    if (comment.author_id !== userId) {
      return { status: 'error', message: 'Not authorized' };
    }

    await db.prepare(
      `UPDATE comments SET deleted_at = ? WHERE id = ?`
    )
      .bind(serverTimestamp, entityId)
      .run();

    await logSyncChange(db, circleId, 'comment', entityId, 'delete', serverTimestamp);

    return { status: 'success' };
  }

  return { status: 'error', message: `Unknown action: ${action}` };
}

async function logSyncChange(
  db: D1Database,
  circleId: string,
  entityType: string,
  entityId: string,
  action: string,
  timestamp: string
) {
  await db.prepare(
    `INSERT INTO sync_log (circle_id, entity_type, entity_id, action, timestamp)
     VALUES (?, ?, ?, ?, ?)`
  )
    .bind(circleId, entityType, entityId, action, timestamp)
    .run();
}

/**
 * GET /sync/full
 * Full sync - get all data for a circle
 */
sync.get('/full', authMiddleware, async (c) => {
  const userId = c.get('userId');
  const circleId = c.req.query('circleId');

  if (!circleId) {
    return c.json(error(ErrorCodes.INVALID_INPUT, 'circleId required'), 400);
  }

  // Verify user is member of circle
  const member = await c.env.DB.prepare(
    'SELECT 1 FROM circle_members WHERE circle_id = ? AND user_id = ?'
  )
    .bind(circleId, userId)
    .first();

  if (!member) {
    return c.json(error(ErrorCodes.FORBIDDEN, 'Not a member of this circle'), 403);
  }

  // Fetch all data in parallel
  const [circle, members, moments, letters] = await Promise.all([
    c.env.DB.prepare('SELECT * FROM circles WHERE id = ?')
      .bind(circleId)
      .first(),
    c.env.DB.prepare(
      `SELECT cm.*, u.name, u.email, u.avatar
       FROM circle_members cm
       JOIN users u ON cm.user_id = u.id
       WHERE cm.circle_id = ?`
    )
      .bind(circleId)
      .all(),
    c.env.DB.prepare(
      `SELECT * FROM moments WHERE circle_id = ? AND deleted_at IS NULL ORDER BY timestamp DESC`
    )
      .bind(circleId)
      .all<Moment>(),
    c.env.DB.prepare(
      `SELECT * FROM letters WHERE circle_id = ? AND deleted_at IS NULL ORDER BY created_at DESC`
    )
      .bind(circleId)
      .all<Letter>(),
  ]);

  // Get comments for all moments
  const momentIds = moments.results.map((m) => m.id);
  let commentsList: Comment[] = [];

  if (momentIds.length > 0) {
    // SQLite doesn't support array parameters, so we need to build the query
    const placeholders = momentIds.map(() => '?').join(',');
    const commentsResult = await c.env.DB.prepare(
      `SELECT c.*, u.name as author_name, u.avatar as author_avatar
       FROM comments c
       JOIN users u ON c.author_id = u.id
       WHERE c.target_id IN (${placeholders}) 
         AND c.target_type = 'moment' 
         AND c.deleted_at IS NULL`
    )
      .bind(...momentIds)
      .all<Comment>();
    commentsList = commentsResult.results;
  }

  const serverTimestamp = new Date().toISOString();

  return c.json(
    success({
      circle,
      members: members.results,
      moments: moments.results,
      letters: letters.results,
      comments: commentsList,
      serverTimestamp,
    })
  );
});

/**
 * GET /sync/status
 * Get sync status for user's circles
 */
sync.get('/status', authMiddleware, async (c) => {
  const userId = c.get('userId');

  // Get all circles user is member of
  const circles = await c.env.DB.prepare(
    `SELECT cm.circle_id, c.name, c.updated_at,
       (SELECT MAX(timestamp) FROM sync_log WHERE circle_id = cm.circle_id) as last_sync
     FROM circle_members cm
     JOIN circles c ON cm.circle_id = c.id
     WHERE cm.user_id = ?`
  )
    .bind(userId)
    .all<{ circle_id: string; name: string; updated_at: string; last_sync: string | null }>();

  return c.json(
    success({
      circles: circles.results,
      serverTimestamp: new Date().toISOString(),
    })
  );
});

export { sync as syncRoutes };

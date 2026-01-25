/**
 * Moments Routes
 */

import { Hono } from 'hono';
import { z } from 'zod';
import { generateId } from '../utils/id';
import { success, error, paginated, ErrorCodes } from '../utils/response';
import { authMiddleware, circleMemberMiddleware } from '../middleware/auth';
import type { Env, Moment } from '../types';

const moments = new Hono<{ Bindings: Env }>();

// All routes require authentication
moments.use('*', authMiddleware);

// Validation schemas
const createMomentSchema = z.object({
  content: z.string().min(1, 'Content is required'),
  mediaType: z.enum(['text', 'image', 'video', 'audio']),
  mediaUrl: z.string().optional(),
  timestamp: z.string().optional(),
  timeLabel: z.string().min(1, 'Time label is required'),
  contextTags: z.array(z.object({
    type: z.string(),
    label: z.string(),
    emoji: z.string(),
  })).optional(),
  location: z.string().optional(),
  futureMessage: z.string().optional(),
});

const updateMomentSchema = z.object({
  content: z.string().min(1).optional(),
  mediaUrl: z.string().optional(),
  timeLabel: z.string().optional(),
  contextTags: z.array(z.object({
    type: z.string(),
    label: z.string(),
    emoji: z.string(),
  })).optional(),
  location: z.string().nullable().optional(),
  futureMessage: z.string().nullable().optional(),
});

/**
 * GET /moments/:id
 * Get single moment
 */
moments.get('/:id', async (c) => {
  const momentId = c.req.param('id');
  const userId = c.get('userId');
  
  // Get moment with author info
  const moment = await c.env.DB.prepare(
    `SELECT m.*, u.name as author_name, u.avatar as author_avatar
     FROM moments m
     JOIN users u ON m.author_id = u.id
     WHERE m.id = ? AND m.deleted_at IS NULL`
  )
    .bind(momentId)
    .first();
  
  if (!moment) {
    return c.json(error(ErrorCodes.NOT_FOUND, 'Moment not found'), 404);
  }
  
  // Check if user is a member of the circle
  const isMember = await c.env.DB.prepare(
    'SELECT 1 FROM circle_members WHERE circle_id = ? AND user_id = ?'
  )
    .bind(moment.circle_id, userId)
    .first();
  
  if (!isMember) {
    return c.json(error(ErrorCodes.FORBIDDEN, 'Not a member of this circle'), 403);
  }
  
  // Get comment count
  const commentCount = await c.env.DB.prepare(
    `SELECT COUNT(*) as count FROM comments 
     WHERE target_id = ? AND target_type = 'moment' AND deleted_at IS NULL`
  )
    .bind(momentId)
    .first<{ count: number }>();
  
  return c.json(success({
    ...moment,
    context_tags: moment.context_tags ? JSON.parse(moment.context_tags as string) : [],
    comment_count: commentCount?.count || 0,
  }));
});

/**
 * PUT /moments/:id
 * Update moment (author only)
 */
moments.put('/:id', async (c) => {
  const momentId = c.req.param('id');
  const userId = c.get('userId');
  const body = await c.req.json();
  
  // Check ownership
  const moment = await c.env.DB.prepare(
    'SELECT circle_id, author_id FROM moments WHERE id = ? AND deleted_at IS NULL'
  )
    .bind(momentId)
    .first<{ circle_id: string; author_id: string }>();
  
  if (!moment) {
    return c.json(error(ErrorCodes.NOT_FOUND, 'Moment not found'), 404);
  }
  
  if (moment.author_id !== userId) {
    return c.json(error(ErrorCodes.FORBIDDEN, 'Cannot edit others\' moments'), 403);
  }
  
  const result = updateMomentSchema.safeParse(body);
  if (!result.success) {
    return c.json(
      error(ErrorCodes.VALIDATION_ERROR, result.error.errors[0].message),
      400
    );
  }
  
  const updates: string[] = [];
  const values: (string | null)[] = [];
  
  if (result.data.content !== undefined) {
    updates.push('content = ?');
    values.push(result.data.content);
  }
  
  if (result.data.mediaUrl !== undefined) {
    updates.push('media_url = ?');
    values.push(result.data.mediaUrl);
  }
  
  if (result.data.timeLabel !== undefined) {
    updates.push('time_label = ?');
    values.push(result.data.timeLabel);
  }
  
  if (result.data.contextTags !== undefined) {
    updates.push('context_tags = ?');
    values.push(JSON.stringify(result.data.contextTags));
  }
  
  if (result.data.location !== undefined) {
    updates.push('location = ?');
    values.push(result.data.location);
  }
  
  if (result.data.futureMessage !== undefined) {
    updates.push('future_message = ?');
    values.push(result.data.futureMessage);
  }
  
  if (updates.length === 0) {
    return c.json(error(ErrorCodes.INVALID_INPUT, 'No updates provided'), 400);
  }
  
  updates.push("updated_at = datetime('now')");
  values.push(momentId);
  
  await c.env.DB.prepare(
    `UPDATE moments SET ${updates.join(', ')} WHERE id = ?`
  )
    .bind(...values)
    .run();
  
  // Log sync event
  await c.env.DB.prepare(
    `INSERT INTO sync_log (circle_id, entity_type, entity_id, action)
     VALUES (?, 'moment', ?, 'update')`
  )
    .bind(moment.circle_id, momentId)
    .run();
  
  const updated = await c.env.DB.prepare(
    `SELECT m.*, u.name as author_name, u.avatar as author_avatar
     FROM moments m
     JOIN users u ON m.author_id = u.id
     WHERE m.id = ?`
  )
    .bind(momentId)
    .first();
  
  return c.json(success({
    ...updated,
    context_tags: updated?.context_tags ? JSON.parse(updated.context_tags as string) : [],
  }));
});

/**
 * DELETE /moments/:id
 * Soft delete moment (author only)
 */
moments.delete('/:id', async (c) => {
  const momentId = c.req.param('id');
  const userId = c.get('userId');
  
  // Check ownership
  const moment = await c.env.DB.prepare(
    'SELECT circle_id, author_id FROM moments WHERE id = ? AND deleted_at IS NULL'
  )
    .bind(momentId)
    .first<{ circle_id: string; author_id: string }>();
  
  if (!moment) {
    return c.json(error(ErrorCodes.NOT_FOUND, 'Moment not found'), 404);
  }
  
  if (moment.author_id !== userId) {
    // Check if admin
    const isAdmin = await c.env.DB.prepare(
      `SELECT 1 FROM circle_members WHERE circle_id = ? AND user_id = ? AND role = 'admin'`
    )
      .bind(moment.circle_id, userId)
      .first();
    
    if (!isAdmin) {
      return c.json(error(ErrorCodes.FORBIDDEN, 'Cannot delete others\' moments'), 403);
    }
  }
  
  // Soft delete
  await c.env.DB.prepare(
    `UPDATE moments SET deleted_at = datetime('now'), updated_at = datetime('now') WHERE id = ?`
  )
    .bind(momentId)
    .run();
  
  // Also delete any world post linked to this moment
  await c.env.DB.prepare(
    `UPDATE world_posts SET deleted_at = datetime('now') WHERE moment_id = ?`
  )
    .bind(momentId)
    .run();
  
  // Log sync event
  await c.env.DB.prepare(
    `INSERT INTO sync_log (circle_id, entity_type, entity_id, action)
     VALUES (?, 'moment', ?, 'delete')`
  )
    .bind(moment.circle_id, momentId)
    .run();
  
  return c.json(success({ message: 'Moment deleted' }));
});

/**
 * PUT /moments/:id/favorite
 * Toggle favorite
 */
moments.put('/:id/favorite', async (c) => {
  const momentId = c.req.param('id');
  const userId = c.get('userId');
  
  // Check membership
  const moment = await c.env.DB.prepare(
    'SELECT circle_id, is_favorite FROM moments WHERE id = ? AND deleted_at IS NULL'
  )
    .bind(momentId)
    .first<{ circle_id: string; is_favorite: number }>();
  
  if (!moment) {
    return c.json(error(ErrorCodes.NOT_FOUND, 'Moment not found'), 404);
  }
  
  const isMember = await c.env.DB.prepare(
    'SELECT 1 FROM circle_members WHERE circle_id = ? AND user_id = ?'
  )
    .bind(moment.circle_id, userId)
    .first();
  
  if (!isMember) {
    return c.json(error(ErrorCodes.FORBIDDEN, 'Not a member of this circle'), 403);
  }
  
  const newValue = moment.is_favorite ? 0 : 1;
  
  await c.env.DB.prepare(
    `UPDATE moments SET is_favorite = ?, updated_at = datetime('now') WHERE id = ?`
  )
    .bind(newValue, momentId)
    .run();
  
  // Log sync event
  await c.env.DB.prepare(
    `INSERT INTO sync_log (circle_id, entity_type, entity_id, action)
     VALUES (?, 'moment', ?, 'update')`
  )
    .bind(moment.circle_id, momentId)
    .run();
  
  return c.json(success({ is_favorite: newValue === 1 }));
});

/**
 * DELETE /moments/:id/world
 * Withdraw moment from world (remove associated world post)
 */
moments.delete('/:id/world', async (c) => {
  const momentId = c.req.param('id');
  const userId = c.get('userId');
  
  // Check ownership
  const moment = await c.env.DB.prepare(
    'SELECT author_id, is_shared_to_world FROM moments WHERE id = ? AND deleted_at IS NULL'
  )
    .bind(momentId)
    .first<{ author_id: string; is_shared_to_world: number }>();
  
  if (!moment) {
    return c.json(error(ErrorCodes.NOT_FOUND, 'Moment not found'), 404);
  }
  
  if (moment.author_id !== userId) {
    return c.json(error(ErrorCodes.FORBIDDEN, 'Cannot withdraw others\' moments'), 403);
  }
  
  if (!moment.is_shared_to_world) {
    return c.json(error(ErrorCodes.INVALID_INPUT, 'Moment is not shared to world'), 400);
  }
  
  // Find and soft delete the world post
  const worldPost = await c.env.DB.prepare(
    'SELECT id, tag FROM world_posts WHERE moment_id = ? AND deleted_at IS NULL'
  )
    .bind(momentId)
    .first<{ id: string; tag: string }>();
  
  if (worldPost) {
    // Soft delete the world post
    await c.env.DB.prepare(
      `UPDATE world_posts SET deleted_at = datetime('now') WHERE id = ?`
    )
      .bind(worldPost.id)
      .run();
    
    // Update channel post count
    await c.env.DB.prepare(
      `UPDATE world_channels SET post_count = MAX(0, post_count - 1) WHERE id = ?`
    )
      .bind(worldPost.tag)
      .run();
  }
  
  // Update moment
  await c.env.DB.prepare(
    `UPDATE moments SET is_shared_to_world = 0, world_topic = NULL, updated_at = datetime('now') WHERE id = ?`
  )
    .bind(momentId)
    .run();
  
  return c.json(success({ message: 'Withdrawn from world' }));
});

// ===== Circle-scoped routes =====

const circleMoments = new Hono<{ Bindings: Env }>();
circleMoments.use('*', authMiddleware);
circleMoments.use('*', circleMemberMiddleware);

/**
 * GET /circles/:circleId/moments
 * List moments in a circle
 */
circleMoments.get('/', async (c) => {
  const circleId = c.req.param('circleId')!;
  const page = parseInt(c.req.query('page') || '1');
  const limit = Math.min(parseInt(c.req.query('limit') || '20'), 100);
  const offset = (page - 1) * limit;
  
  // Filters
  const authorId = c.req.query('authorId');
  const mediaType = c.req.query('mediaType');
  const favorite = c.req.query('favorite');
  const startDate = c.req.query('startDate');
  const endDate = c.req.query('endDate');
  
  let whereClause = 'WHERE m.circle_id = ? AND m.deleted_at IS NULL';
  const params: (string | number)[] = [circleId];
  
  if (authorId) {
    whereClause += ' AND m.author_id = ?';
    params.push(authorId);
  }
  
  if (mediaType) {
    whereClause += ' AND m.media_type = ?';
    params.push(mediaType);
  }
  
  if (favorite === 'true') {
    whereClause += ' AND m.is_favorite = 1';
  }
  
  if (startDate) {
    whereClause += ' AND m.timestamp >= ?';
    params.push(startDate);
  }
  
  if (endDate) {
    whereClause += ' AND m.timestamp <= ?';
    params.push(endDate);
  }
  
  // Get total count
  const countResult = await c.env.DB.prepare(
    `SELECT COUNT(*) as total FROM moments m ${whereClause}`
  )
    .bind(...params)
    .first<{ total: number }>();
  
  const total = countResult?.total || 0;
  
  // Get moments
  const momentsResult = await c.env.DB.prepare(
    `SELECT m.*, u.name as author_name, u.avatar as author_avatar,
            (SELECT COUNT(*) FROM comments WHERE target_id = m.id AND target_type = 'moment' AND deleted_at IS NULL) as comment_count
     FROM moments m
     JOIN users u ON m.author_id = u.id
     ${whereClause}
     ORDER BY m.timestamp DESC
     LIMIT ? OFFSET ?`
  )
    .bind(...params, limit, offset)
    .all();
  
  const momentsWithParsedTags = momentsResult.results.map((m: any) => ({
    ...m,
    context_tags: m.context_tags ? JSON.parse(m.context_tags) : [],
  }));
  
  return c.json(paginated(momentsWithParsedTags, page, limit, total));
});

/**
 * POST /circles/:circleId/moments
 * Create a moment
 */
circleMoments.post('/', async (c) => {
  const circleId = c.req.param('circleId');
  const userId = c.get('userId');
  const body = await c.req.json();
  
  const result = createMomentSchema.safeParse(body);
  if (!result.success) {
    return c.json(
      error(ErrorCodes.VALIDATION_ERROR, result.error.errors[0].message),
      400
    );
  }
  
  const data = result.data;
  const momentId = generateId('mom');
  const now = new Date().toISOString();
  const timestamp = data.timestamp || now;
  
  await c.env.DB.prepare(
    `INSERT INTO moments (
      id, circle_id, author_id, content, media_type, media_url,
      timestamp, time_label, context_tags, location, future_message,
      created_at, updated_at
    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`
  )
    .bind(
      momentId,
      circleId,
      userId,
      data.content,
      data.mediaType,
      data.mediaUrl || null,
      timestamp,
      data.timeLabel,
      data.contextTags ? JSON.stringify(data.contextTags) : null,
      data.location || null,
      data.futureMessage || null,
      now,
      now
    )
    .run();
  
  // Log sync event
  await c.env.DB.prepare(
    `INSERT INTO sync_log (circle_id, entity_type, entity_id, action)
     VALUES (?, 'moment', ?, 'create')`
  )
    .bind(circleId, momentId)
    .run();
  
  // Get created moment with author info
  const moment = await c.env.DB.prepare(
    `SELECT m.*, u.name as author_name, u.avatar as author_avatar
     FROM moments m
     JOIN users u ON m.author_id = u.id
     WHERE m.id = ?`
  )
    .bind(momentId)
    .first();
  
  return c.json(
    success({
      ...moment,
      context_tags: data.contextTags || [],
      comment_count: 0,
    }),
    201
  );
});

export { moments as momentRoutes, circleMoments as circleMomentRoutes };

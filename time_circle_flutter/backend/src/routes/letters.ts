/**
 * Letters Routes
 */

import { Hono } from 'hono';
import { z } from 'zod';
import { generateId } from '../utils/id';
import { success, error, ErrorCodes } from '../utils/response';
import { authMiddleware, circleMemberMiddleware } from '../middleware/auth';
import type { Env, Letter } from '../types';

const letters = new Hono<{ Bindings: Env }>();

// All routes require authentication
letters.use('*', authMiddleware);

// Validation schemas
const createLetterSchema = z.object({
  title: z.string().min(1, 'Title is required').max(100),
  content: z.string().optional(),
  type: z.enum(['annual', 'milestone', 'free']),
  recipient: z.string().min(1, 'Recipient is required'),
});

const updateLetterSchema = z.object({
  title: z.string().min(1).max(100).optional(),
  content: z.string().nullable().optional(),
  recipient: z.string().optional(),
});

const sealLetterSchema = z.object({
  unlockDate: z.string().refine((date) => {
    const d = new Date(date);
    return d > new Date();
  }, 'Unlock date must be in the future'),
});

/**
 * GET /letters/:id
 * Get single letter
 */
letters.get('/:id', async (c) => {
  const letterId = c.req.param('id');
  const userId = c.get('userId');
  
  const letter = await c.env.DB.prepare(
    `SELECT l.*, u.name as author_name
     FROM letters l
     JOIN users u ON l.author_id = u.id
     WHERE l.id = ? AND l.deleted_at IS NULL`
  )
    .bind(letterId)
    .first<Letter & { author_name: string }>();
  
  if (!letter) {
    return c.json(error(ErrorCodes.NOT_FOUND, 'Letter not found'), 404);
  }
  
  // Check membership
  const isMember = await c.env.DB.prepare(
    'SELECT 1 FROM circle_members WHERE circle_id = ? AND user_id = ?'
  )
    .bind(letter.circle_id, userId)
    .first();
  
  if (!isMember) {
    return c.json(error(ErrorCodes.FORBIDDEN, 'Not a member of this circle'), 403);
  }
  
  // If sealed and not unlocked yet, hide content
  if (letter.status === 'sealed') {
    const unlockDate = letter.unlock_date ? new Date(letter.unlock_date) : null;
    
    // Check if it's time to unlock
    if (unlockDate && unlockDate <= new Date()) {
      // Auto-unlock
      await c.env.DB.prepare(
        `UPDATE letters SET status = 'unlocked', updated_at = datetime('now') WHERE id = ?`
      )
        .bind(letterId)
        .run();
      letter.status = 'unlocked';
    } else {
      // Hide content for sealed letters
      return c.json(success({
        ...letter,
        content: null,
        preview: letter.preview,
      }));
    }
  }
  
  return c.json(success(letter));
});

/**
 * PUT /letters/:id
 * Update letter (author only, draft only)
 */
letters.put('/:id', async (c) => {
  const letterId = c.req.param('id');
  const userId = c.get('userId');
  const body = await c.req.json();
  
  const letter = await c.env.DB.prepare(
    'SELECT circle_id, author_id, status FROM letters WHERE id = ? AND deleted_at IS NULL'
  )
    .bind(letterId)
    .first<{ circle_id: string; author_id: string; status: string }>();
  
  if (!letter) {
    return c.json(error(ErrorCodes.NOT_FOUND, 'Letter not found'), 404);
  }
  
  if (letter.author_id !== userId) {
    return c.json(error(ErrorCodes.FORBIDDEN, 'Cannot edit others\' letters'), 403);
  }
  
  if (letter.status !== 'draft') {
    return c.json(error(ErrorCodes.LETTER_SEALED, 'Cannot edit sealed or unlocked letters'), 400);
  }
  
  const result = updateLetterSchema.safeParse(body);
  if (!result.success) {
    return c.json(
      error(ErrorCodes.VALIDATION_ERROR, result.error.errors[0].message),
      400
    );
  }
  
  const updates: string[] = [];
  const values: (string | null)[] = [];
  
  if (result.data.title !== undefined) {
    updates.push('title = ?');
    values.push(result.data.title);
  }
  
  if (result.data.content !== undefined) {
    updates.push('content = ?');
    values.push(result.data.content);
    // Update preview (first 100 chars)
    updates.push('preview = ?');
    const preview = result.data.content 
      ? result.data.content.slice(0, 100) + (result.data.content.length > 100 ? '...' : '')
      : '';
    values.push(preview);
  }
  
  if (result.data.recipient !== undefined) {
    updates.push('recipient = ?');
    values.push(result.data.recipient);
  }
  
  if (updates.length === 0) {
    return c.json(error(ErrorCodes.INVALID_INPUT, 'No updates provided'), 400);
  }
  
  updates.push("updated_at = datetime('now')");
  values.push(letterId);
  
  await c.env.DB.prepare(
    `UPDATE letters SET ${updates.join(', ')} WHERE id = ?`
  )
    .bind(...values)
    .run();
  
  // Log sync event
  await c.env.DB.prepare(
    `INSERT INTO sync_log (circle_id, entity_type, entity_id, action)
     VALUES (?, 'letter', ?, 'update')`
  )
    .bind(letter.circle_id, letterId)
    .run();
  
  const updated = await c.env.DB.prepare('SELECT * FROM letters WHERE id = ?')
    .bind(letterId)
    .first();
  
  return c.json(success(updated));
});

/**
 * DELETE /letters/:id
 * Soft delete letter (author only)
 */
letters.delete('/:id', async (c) => {
  const letterId = c.req.param('id');
  const userId = c.get('userId');
  
  const letter = await c.env.DB.prepare(
    'SELECT circle_id, author_id FROM letters WHERE id = ? AND deleted_at IS NULL'
  )
    .bind(letterId)
    .first<{ circle_id: string; author_id: string }>();
  
  if (!letter) {
    return c.json(error(ErrorCodes.NOT_FOUND, 'Letter not found'), 404);
  }
  
  if (letter.author_id !== userId) {
    return c.json(error(ErrorCodes.FORBIDDEN, 'Cannot delete others\' letters'), 403);
  }
  
  await c.env.DB.prepare(
    `UPDATE letters SET deleted_at = datetime('now'), updated_at = datetime('now') WHERE id = ?`
  )
    .bind(letterId)
    .run();
  
  // Log sync event
  await c.env.DB.prepare(
    `INSERT INTO sync_log (circle_id, entity_type, entity_id, action)
     VALUES (?, 'letter', ?, 'delete')`
  )
    .bind(letter.circle_id, letterId)
    .run();
  
  return c.json(success({ message: 'Letter deleted' }));
});

/**
 * POST /letters/:id/seal
 * Seal a letter (set unlock date)
 */
letters.post('/:id/seal', async (c) => {
  const letterId = c.req.param('id');
  const userId = c.get('userId');
  const body = await c.req.json();
  
  const letter = await c.env.DB.prepare(
    'SELECT circle_id, author_id, status FROM letters WHERE id = ? AND deleted_at IS NULL'
  )
    .bind(letterId)
    .first<{ circle_id: string; author_id: string; status: string }>();
  
  if (!letter) {
    return c.json(error(ErrorCodes.NOT_FOUND, 'Letter not found'), 404);
  }
  
  if (letter.author_id !== userId) {
    return c.json(error(ErrorCodes.FORBIDDEN, 'Cannot seal others\' letters'), 403);
  }
  
  if (letter.status !== 'draft') {
    return c.json(error(ErrorCodes.LETTER_SEALED, 'Letter is already sealed'), 400);
  }
  
  const result = sealLetterSchema.safeParse(body);
  if (!result.success) {
    return c.json(
      error(ErrorCodes.VALIDATION_ERROR, result.error.errors[0].message),
      400
    );
  }
  
  const now = new Date().toISOString();
  
  await c.env.DB.prepare(
    `UPDATE letters SET 
      status = 'sealed', 
      unlock_date = ?, 
      sealed_at = ?,
      updated_at = ?
     WHERE id = ?`
  )
    .bind(result.data.unlockDate, now, now, letterId)
    .run();
  
  // Log sync event
  await c.env.DB.prepare(
    `INSERT INTO sync_log (circle_id, entity_type, entity_id, action)
     VALUES (?, 'letter', ?, 'update')`
  )
    .bind(letter.circle_id, letterId)
    .run();
  
  const updated = await c.env.DB.prepare('SELECT * FROM letters WHERE id = ?')
    .bind(letterId)
    .first();
  
  return c.json(success(updated));
});

/**
 * POST /letters/:id/unlock
 * Manually unlock a letter (if date has passed)
 */
letters.post('/:id/unlock', async (c) => {
  const letterId = c.req.param('id');
  const userId = c.get('userId');
  
  const letter = await c.env.DB.prepare(
    'SELECT * FROM letters WHERE id = ? AND deleted_at IS NULL'
  )
    .bind(letterId)
    .first<Letter>();
  
  if (!letter) {
    return c.json(error(ErrorCodes.NOT_FOUND, 'Letter not found'), 404);
  }
  
  // Check membership
  const isMember = await c.env.DB.prepare(
    'SELECT 1 FROM circle_members WHERE circle_id = ? AND user_id = ?'
  )
    .bind(letter.circle_id, userId)
    .first();
  
  if (!isMember) {
    return c.json(error(ErrorCodes.FORBIDDEN, 'Not a member of this circle'), 403);
  }
  
  if (letter.status !== 'sealed') {
    return c.json(error(ErrorCodes.INVALID_INPUT, 'Letter is not sealed'), 400);
  }
  
  // Check if unlock date has passed
  if (letter.unlock_date && new Date(letter.unlock_date) > new Date()) {
    return c.json(
      error(ErrorCodes.LETTER_NOT_READY, 'Letter cannot be unlocked until ' + letter.unlock_date),
      400
    );
  }
  
  await c.env.DB.prepare(
    `UPDATE letters SET status = 'unlocked', updated_at = datetime('now') WHERE id = ?`
  )
    .bind(letterId)
    .run();
  
  // Log sync event
  await c.env.DB.prepare(
    `INSERT INTO sync_log (circle_id, entity_type, entity_id, action)
     VALUES (?, 'letter', ?, 'update')`
  )
    .bind(letter.circle_id, letterId)
    .run();
  
  const updated = await c.env.DB.prepare('SELECT * FROM letters WHERE id = ?')
    .bind(letterId)
    .first();
  
  return c.json(success(updated));
});

// ===== Circle-scoped routes =====

const circleLetters = new Hono<{ Bindings: Env }>();
circleLetters.use('*', authMiddleware);
circleLetters.use('*', circleMemberMiddleware);

/**
 * GET /circles/:circleId/letters
 * List letters in a circle
 */
circleLetters.get('/', async (c) => {
  const circleId = c.req.param('circleId')!;
  const status = c.req.query('status'); // draft, sealed, unlocked
  const type = c.req.query('type'); // annual, milestone, free
  
  let whereClause = 'WHERE l.circle_id = ? AND l.deleted_at IS NULL';
  const params: string[] = [circleId];
  
  if (status) {
    whereClause += ' AND l.status = ?';
    params.push(status);
  }
  
  if (type) {
    whereClause += ' AND l.type = ?';
    params.push(type);
  }
  
  const letters = await c.env.DB.prepare(
    `SELECT l.*, u.name as author_name
     FROM letters l
     JOIN users u ON l.author_id = u.id
     ${whereClause}
     ORDER BY l.created_at DESC`
  )
    .bind(...params)
    .all();
  
  // Hide content for sealed letters
  const processed = letters.results.map((letter: any) => {
    if (letter.status === 'sealed') {
      // Check if it's time to auto-unlock
      if (letter.unlock_date && new Date(letter.unlock_date) <= new Date()) {
        letter.status = 'unlocked';
      } else {
        letter.content = null;
      }
    }
    return letter;
  });
  
  return c.json(success(processed));
});

/**
 * POST /circles/:circleId/letters
 * Create a new letter
 */
circleLetters.post('/', async (c) => {
  const circleId = c.req.param('circleId');
  const userId = c.get('userId');
  const body = await c.req.json();
  
  const result = createLetterSchema.safeParse(body);
  if (!result.success) {
    return c.json(
      error(ErrorCodes.VALIDATION_ERROR, result.error.errors[0].message),
      400
    );
  }
  
  const data = result.data;
  const letterId = generateId('let');
  const now = new Date().toISOString();
  const preview = data.content 
    ? data.content.slice(0, 100) + (data.content.length > 100 ? '...' : '')
    : '';
  
  await c.env.DB.prepare(
    `INSERT INTO letters (
      id, circle_id, author_id, title, preview, content,
      status, type, recipient, created_at, updated_at
    ) VALUES (?, ?, ?, ?, ?, ?, 'draft', ?, ?, ?, ?)`
  )
    .bind(
      letterId,
      circleId,
      userId,
      data.title,
      preview,
      data.content || null,
      data.type,
      data.recipient,
      now,
      now
    )
    .run();
  
  // Log sync event
  await c.env.DB.prepare(
    `INSERT INTO sync_log (circle_id, entity_type, entity_id, action)
     VALUES (?, 'letter', ?, 'create')`
  )
    .bind(circleId, letterId)
    .run();
  
  const letter = await c.env.DB.prepare(
    `SELECT l.*, u.name as author_name
     FROM letters l
     JOIN users u ON l.author_id = u.id
     WHERE l.id = ?`
  )
    .bind(letterId)
    .first();
  
  return c.json(success(letter), 201);
});

export { letters as letterRoutes, circleLetters as circleLetterRoutes };

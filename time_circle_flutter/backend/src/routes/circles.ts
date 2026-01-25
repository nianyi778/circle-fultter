/**
 * Circles Routes
 */

import { Hono } from 'hono';
import { z } from 'zod';
import { generateId, generateInviteCode } from '../utils/id';
import { success, error, ErrorCodes } from '../utils/response';
import { authMiddleware, circleMemberMiddleware, circleAdminMiddleware } from '../middleware/auth';
import type { Env, Circle, CircleMember, User } from '../types';

const circles = new Hono<{ Bindings: Env }>();

// All routes require authentication
circles.use('*', authMiddleware);

// Validation schemas
const createCircleSchema = z.object({
  name: z.string().min(1, 'Name is required').max(50),
  startDate: z.string().optional(),
});

const updateCircleSchema = z.object({
  name: z.string().min(1).max(50).optional(),
  startDate: z.string().nullable().optional(),
});

const joinCircleSchema = z.object({
  inviteCode: z.string().length(6, 'Invite code must be 6 characters'),
  roleLabel: z.string().max(20).optional(),
});

/**
 * GET /circles
 * List user's circles
 */
circles.get('/', async (c) => {
  const userId = c.get('userId');
  
  const result = await c.env.DB.prepare(
    `SELECT c.*, cm.role, cm.role_label, cm.joined_at, cm.joined_at as member_since,
            (SELECT COUNT(*) FROM circle_members WHERE circle_id = c.id) as member_count,
            (SELECT COUNT(*) FROM moments WHERE circle_id = c.id AND deleted_at IS NULL) as moment_count
     FROM circles c
     JOIN circle_members cm ON c.id = cm.circle_id
     WHERE cm.user_id = ?
     ORDER BY cm.joined_at DESC`
  )
    .bind(userId)
    .all();
  
  return c.json(success(result.results));
});

/**
 * POST /circles
 * Create a new circle
 */
circles.post('/', async (c) => {
  const userId = c.get('userId');
  const body = await c.req.json();
  
  const result = createCircleSchema.safeParse(body);
  if (!result.success) {
    return c.json(
      error(ErrorCodes.VALIDATION_ERROR, result.error.errors[0].message),
      400
    );
  }
  
  const { name, startDate } = result.data;
  const circleId = generateId('cir');
  const inviteCode = generateInviteCode();
  const now = new Date().toISOString();
  
  // Create circle
  await c.env.DB.prepare(
    `INSERT INTO circles (id, name, start_date, invite_code, created_by, created_at, updated_at)
     VALUES (?, ?, ?, ?, ?, ?, ?)`
  )
    .bind(circleId, name, startDate || null, inviteCode, userId, now, now)
    .run();
  
  // Add creator as admin
  await c.env.DB.prepare(
    `INSERT INTO circle_members (circle_id, user_id, role, joined_at)
     VALUES (?, ?, 'admin', ?)`
  )
    .bind(circleId, userId, now)
    .run();
  
  const circle = await c.env.DB.prepare('SELECT * FROM circles WHERE id = ?')
    .bind(circleId)
    .first<Circle>();
  
  return c.json(
    success({
      ...circle,
      role: 'admin',
      member_count: 1,
    }),
    201
  );
});

/**
 * GET /circles/:id
 * Get circle details
 */
circles.get('/:id', circleMemberMiddleware, async (c) => {
  const circleId = c.req.param('id');
  
  const circle = await c.env.DB.prepare(
    `SELECT c.*,
            (SELECT COUNT(*) FROM circle_members WHERE circle_id = c.id) as member_count,
            (SELECT COUNT(*) FROM moments WHERE circle_id = c.id AND deleted_at IS NULL) as moment_count,
            (SELECT COUNT(*) FROM letters WHERE circle_id = c.id AND deleted_at IS NULL) as letter_count
     FROM circles c
     WHERE c.id = ?`
  )
    .bind(circleId)
    .first();
  
  if (!circle) {
    return c.json(error(ErrorCodes.NOT_FOUND, 'Circle not found'), 404);
  }
  
  return c.json(success(circle));
});

/**
 * PUT /circles/:id
 * Update circle (admin only)
 */
circles.put('/:id', circleMemberMiddleware, circleAdminMiddleware, async (c) => {
  const circleId = c.req.param('id');
  const body = await c.req.json();
  
  const result = updateCircleSchema.safeParse(body);
  if (!result.success) {
    return c.json(
      error(ErrorCodes.VALIDATION_ERROR, result.error.errors[0].message),
      400
    );
  }
  
  const updates: string[] = [];
  const values: (string | null)[] = [];
  
  if (result.data.name !== undefined) {
    updates.push('name = ?');
    values.push(result.data.name);
  }
  
  if (result.data.startDate !== undefined) {
    updates.push('start_date = ?');
    values.push(result.data.startDate);
  }
  
  if (updates.length === 0) {
    return c.json(error(ErrorCodes.INVALID_INPUT, 'No updates provided'), 400);
  }
  
  updates.push("updated_at = datetime('now')");
  values.push(circleId);
  
  await c.env.DB.prepare(
    `UPDATE circles SET ${updates.join(', ')} WHERE id = ?`
  )
    .bind(...values)
    .run();
  
  // Log sync event
  await c.env.DB.prepare(
    `INSERT INTO sync_log (circle_id, entity_type, entity_id, action)
     VALUES (?, 'circle', ?, 'update')`
  )
    .bind(circleId, circleId)
    .run();
  
  const updated = await c.env.DB.prepare('SELECT * FROM circles WHERE id = ?')
    .bind(circleId)
    .first<Circle>();
  
  return c.json(success(updated));
});

/**
 * DELETE /circles/:id
 * Delete circle (admin only)
 */
circles.delete('/:id', circleMemberMiddleware, circleAdminMiddleware, async (c) => {
  const circleId = c.req.param('id');
  
  // Delete circle (cascade will delete members, moments, letters, etc.)
  await c.env.DB.prepare('DELETE FROM circles WHERE id = ?')
    .bind(circleId)
    .run();
  
  return c.json(success({ message: 'Circle deleted' }));
});

/**
 * POST /circles/:id/invite
 * Generate new invite code
 */
circles.post('/:id/invite', circleMemberMiddleware, circleAdminMiddleware, async (c) => {
  const circleId = c.req.param('id');
  const body = await c.req.json().catch(() => ({}));
  const { expiresInDays = 7 } = body as { expiresInDays?: number };
  
  const inviteCode = generateInviteCode();
  const expiresAt = new Date(Date.now() + expiresInDays * 24 * 60 * 60 * 1000).toISOString();
  
  await c.env.DB.prepare(
    `UPDATE circles SET invite_code = ?, invite_expires_at = ?, updated_at = datetime('now')
     WHERE id = ?`
  )
    .bind(inviteCode, expiresAt, circleId)
    .run();
  
  return c.json(
    success({
      inviteCode,
      expiresAt,
      expiresInDays,
    })
  );
});

/**
 * POST /circles/join
 * Join a circle using invite code
 */
circles.post('/join', async (c) => {
  const userId = c.get('userId');
  const body = await c.req.json();
  
  const result = joinCircleSchema.safeParse(body);
  if (!result.success) {
    return c.json(
      error(ErrorCodes.VALIDATION_ERROR, result.error.errors[0].message),
      400
    );
  }
  
  const { inviteCode, roleLabel } = result.data;
  
  // Find circle by invite code
  const circle = await c.env.DB.prepare(
    `SELECT * FROM circles WHERE invite_code = ?`
  )
    .bind(inviteCode.toUpperCase())
    .first<Circle>();
  
  if (!circle) {
    return c.json(error(ErrorCodes.INVALID_INVITE_CODE, 'Invalid invite code'), 400);
  }
  
  // Check if invite is expired
  if (circle.invite_expires_at && new Date(circle.invite_expires_at) < new Date()) {
    return c.json(error(ErrorCodes.INVITE_EXPIRED, 'Invite code has expired'), 400);
  }
  
  // Check if already a member
  const existing = await c.env.DB.prepare(
    'SELECT 1 FROM circle_members WHERE circle_id = ? AND user_id = ?'
  )
    .bind(circle.id, userId)
    .first();
  
  if (existing) {
    return c.json(error(ErrorCodes.ALREADY_MEMBER, 'Already a member of this circle'), 409);
  }
  
  // Add as member
  const now = new Date().toISOString();
  await c.env.DB.prepare(
    `INSERT INTO circle_members (circle_id, user_id, role, role_label, joined_at)
     VALUES (?, ?, 'member', ?, ?)`
  )
    .bind(circle.id, userId, roleLabel || null, now)
    .run();
  
  // Log sync event
  await c.env.DB.prepare(
    `INSERT INTO sync_log (circle_id, entity_type, entity_id, action)
     VALUES (?, 'member', ?, 'create')`
  )
    .bind(circle.id, userId)
    .run();
  
  return c.json(
    success({
      ...circle,
      role: 'member',
      role_label: roleLabel || null,
    })
  );
});

/**
 * GET /circles/:id/members
 * List circle members
 */
circles.get('/:id/members', circleMemberMiddleware, async (c) => {
  const circleId = c.req.param('id');
  
  const members = await c.env.DB.prepare(
    `SELECT u.id, u.name, u.email, u.avatar, cm.role, cm.role_label, cm.joined_at
     FROM circle_members cm
     JOIN users u ON cm.user_id = u.id
     WHERE cm.circle_id = ?
     ORDER BY cm.joined_at ASC`
  )
    .bind(circleId)
    .all();
  
  return c.json(success(members.results));
});

/**
 * PUT /circles/:id/members/:userId
 * Update member (role_label) - admin only
 */
circles.put('/:id/members/:userId', circleMemberMiddleware, circleAdminMiddleware, async (c) => {
  const circleId = c.req.param('id');
  const targetUserId = c.req.param('userId');
  const body = await c.req.json();
  const { roleLabel, role } = body as { roleLabel?: string; role?: 'admin' | 'member' };
  
  const updates: string[] = [];
  const values: (string | null)[] = [];
  
  if (roleLabel !== undefined) {
    updates.push('role_label = ?');
    values.push(roleLabel || null);
  }
  
  if (role !== undefined) {
    updates.push('role = ?');
    values.push(role);
  }
  
  if (updates.length === 0) {
    return c.json(error(ErrorCodes.INVALID_INPUT, 'No updates provided'), 400);
  }
  
  values.push(circleId, targetUserId);
  
  await c.env.DB.prepare(
    `UPDATE circle_members SET ${updates.join(', ')} WHERE circle_id = ? AND user_id = ?`
  )
    .bind(...values)
    .run();
  
  return c.json(success({ message: 'Member updated' }));
});

/**
 * DELETE /circles/:id/members/:userId
 * Remove member - admin only (or self)
 */
circles.delete('/:id/members/:userId', circleMemberMiddleware, async (c) => {
  const circleId = c.req.param('id');
  const targetUserId = c.req.param('userId');
  const currentUserId = c.get('userId');
  const currentRole = c.get('circleRole' as any);
  
  // Can remove self or (admin can remove anyone)
  if (targetUserId !== currentUserId && currentRole !== 'admin') {
    return c.json(error(ErrorCodes.FORBIDDEN, 'Cannot remove other members'), 403);
  }
  
  // Prevent removing the last admin
  if (currentRole === 'admin') {
    const adminCount = await c.env.DB.prepare(
      `SELECT COUNT(*) as count FROM circle_members WHERE circle_id = ? AND role = 'admin'`
    )
      .bind(circleId)
      .first<{ count: number }>();
    
    if (adminCount?.count === 1) {
      // Check if target is the admin
      const target = await c.env.DB.prepare(
        'SELECT role FROM circle_members WHERE circle_id = ? AND user_id = ?'
      )
        .bind(circleId, targetUserId)
        .first<{ role: string }>();
      
      if (target?.role === 'admin') {
        return c.json(
          error(ErrorCodes.FORBIDDEN, 'Cannot remove the last admin. Transfer ownership first.'),
          403
        );
      }
    }
  }
  
  await c.env.DB.prepare(
    'DELETE FROM circle_members WHERE circle_id = ? AND user_id = ?'
  )
    .bind(circleId, targetUserId)
    .run();
  
  // Log sync event
  await c.env.DB.prepare(
    `INSERT INTO sync_log (circle_id, entity_type, entity_id, action)
     VALUES (?, 'member', ?, 'delete')`
  )
    .bind(circleId, targetUserId)
    .run();
  
  return c.json(success({ message: 'Member removed' }));
});

export { circles as circleRoutes };

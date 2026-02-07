/**
 * Circles Routes (Refactored with Repository Pattern)
 */

import { Hono } from 'hono';
import { success, error, ErrorCodes } from '../utils/response';
import { authMiddleware, circleMemberMiddleware, circleAdminMiddleware } from '../middleware/auth';
import { CircleRepository } from '../repositories';
import {
  createCircleSchema,
  updateCircleSchema,
  joinCircleSchema,
  updateMemberRoleSchema,
} from '../schemas';
import type { Env } from '../types';

const circles = new Hono<{ Bindings: Env }>();

// All routes require authentication
circles.use('*', authMiddleware);

/**
 * GET /circles
 * List user's circles
 */
circles.get('/', async (c) => {
  const userId = c.get('userId');
  const circleRepo = new CircleRepository(c.env.DB);
  
  const userCircles = await circleRepo.findByUser(userId);
  
  return c.json(success(userCircles));
});

/**
 * POST /circles
 * Create a new circle
 */
circles.post('/', async (c) => {
  const userId = c.get('userId');
  const body = await c.req.json();
  
  // Validate input
  const result = createCircleSchema.safeParse(body);
  if (!result.success) {
    return c.json(
      error(ErrorCodes.VALIDATION_ERROR, result.error.errors[0].message),
      400
    );
  }
  
  const circleRepo = new CircleRepository(c.env.DB);
  
  const circle = await circleRepo.create({
    name: result.data.name,
    start_date: result.data.start_date,
    created_by: userId,
  });
  
  return c.json(success(circle), 201);
});

/**
 * GET /circles/:id
 * Get circle details
 */
circles.get('/:id', circleMemberMiddleware, async (c) => {
  const circleId = c.req.param('id');
  const circleRepo = new CircleRepository(c.env.DB);
  
  const circle = await circleRepo.findByIdWithStats(circleId);
  
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
  
  // Validate input
  const result = updateCircleSchema.safeParse(body);
  if (!result.success) {
    return c.json(
      error(ErrorCodes.VALIDATION_ERROR, result.error.errors[0].message),
      400
    );
  }
  
  // Check if there are updates
  if (Object.keys(result.data).length === 0) {
    return c.json(error(ErrorCodes.INVALID_INPUT, 'No updates provided'), 400);
  }
  
  const circleRepo = new CircleRepository(c.env.DB);
  
  const updated = await circleRepo.update(circleId, result.data);
  
  if (!updated) {
    return c.json(error(ErrorCodes.NOT_FOUND, 'Circle not found'), 404);
  }
  
  return c.json(success(updated));
});

/**
 * DELETE /circles/:id
 * Delete circle (admin only)
 */
circles.delete('/:id', circleMemberMiddleware, circleAdminMiddleware, async (c) => {
  const circleId = c.req.param('id');
  const circleRepo = new CircleRepository(c.env.DB);
  
  await circleRepo.delete(circleId);
  
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
  
  const circleRepo = new CircleRepository(c.env.DB);
  
  const result = await circleRepo.generateInviteCode(circleId, expiresInDays);
  
  return c.json(
    success({
      inviteCode: result.inviteCode,
      expiresAt: result.expiresAt,
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
  
  // Validate input
  const result = joinCircleSchema.safeParse({
    invite_code: body.inviteCode || body.invite_code,
  });
  
  if (!result.success) {
    return c.json(
      error(ErrorCodes.VALIDATION_ERROR, result.error.errors[0].message),
      400
    );
  }
  
  const { invite_code } = result.data;
  const circleRepo = new CircleRepository(c.env.DB);
  
  // Find and validate invite code
  const circle = await circleRepo.isInviteCodeValid(invite_code);
  
  if (!circle) {
    return c.json(error(ErrorCodes.INVALID_INVITE_CODE, 'Invalid or expired invite code'), 400);
  }
  
  // Check if already a member
  if (await circleRepo.isMember(circle.id, userId)) {
    return c.json(error(ErrorCodes.ALREADY_MEMBER, 'Already a member of this circle'), 409);
  }
  
  // Add as member
  const member = await circleRepo.addMember(circle.id, {
    user_id: userId,
    role_label: body.roleLabel,
  });
  
  return c.json(
    success({
      ...circle,
      role: member.role,
      role_label: member.role_label,
    })
  );
});

/**
 * GET /circles/:id/members
 * List circle members
 */
circles.get('/:id/members', circleMemberMiddleware, async (c) => {
  const circleId = c.req.param('id');
  const circleRepo = new CircleRepository(c.env.DB);
  
  const members = await circleRepo.getMembers(circleId);
  
  return c.json(success(members));
});

/**
 * PUT /circles/:id/members/:userId
 * Update member (role_label, role) - admin only
 */
circles.put('/:id/members/:userId', circleMemberMiddleware, circleAdminMiddleware, async (c) => {
  const circleId = c.req.param('id');
  const targetUserId = c.req.param('userId');
  const body = await c.req.json();
  
  // Validate input
  const result = updateMemberRoleSchema.safeParse(body);
  if (!result.success) {
    return c.json(
      error(ErrorCodes.VALIDATION_ERROR, result.error.errors[0].message),
      400
    );
  }
  
  const updates: { role?: 'admin' | 'member'; role_label?: string | null } = {};
  
  if (result.data.role_label !== undefined) {
    updates.role_label = result.data.role_label;
  }
  
  if (body.role !== undefined) {
    updates.role = body.role;
  }
  
  if (Object.keys(updates).length === 0) {
    return c.json(error(ErrorCodes.INVALID_INPUT, 'No updates provided'), 400);
  }
  
  const circleRepo = new CircleRepository(c.env.DB);
  
  await circleRepo.updateMember(circleId, targetUserId, updates);
  
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
  
  const circleRepo = new CircleRepository(c.env.DB);
  
  // Get current user's role
  const currentMember = await circleRepo.getMember(circleId, currentUserId);
  
  // Can remove self or (admin can remove anyone)
  if (targetUserId !== currentUserId && currentMember?.role !== 'admin') {
    return c.json(error(ErrorCodes.FORBIDDEN, 'Cannot remove other members'), 403);
  }
  
  // Prevent removing the last admin
  if (await circleRepo.isLastAdmin(circleId, targetUserId)) {
    return c.json(
      error(ErrorCodes.FORBIDDEN, 'Cannot remove the last admin. Transfer ownership first.'),
      403
    );
  }
  
  await circleRepo.removeMember(circleId, targetUserId);
  
  return c.json(success({ message: 'Member removed' }));
});

export { circles as circleRoutes };

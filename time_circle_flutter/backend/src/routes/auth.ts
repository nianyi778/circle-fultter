/**
 * Auth Routes (Refactored with Repository Pattern)
 */

import { Hono } from 'hono';
import { success, error, ErrorCodes } from '../utils/response';
import { authMiddleware } from '../middleware/auth';
import { verifyToken } from '../utils/jwt';
import { UserRepository } from '../repositories';
import {
  registerSchema,
  loginSchema,
  refreshTokenSchema,
  changePasswordSchema,
  updateUserSchema,
} from '../schemas';
import type { Env } from '../types';

const auth = new Hono<{ Bindings: Env }>();

/**
 * POST /auth/register
 * Register a new user
 */
auth.post('/register', async (c) => {
  const body = await c.req.json();
  
  // Validate input
  const result = registerSchema.safeParse(body);
  if (!result.success) {
    return c.json(
      error(ErrorCodes.VALIDATION_ERROR, result.error.errors[0].message),
      400
    );
  }
  
  const { email, password, name } = result.data;
  const userRepo = new UserRepository(c.env.DB);
  
  // Check if email exists
  if (await userRepo.emailExists(email)) {
    return c.json(error(ErrorCodes.EMAIL_EXISTS, 'Email already registered'), 409);
  }
  
  // Create user
  const user = await userRepo.create({ email, password, name });
  
  // Create tokens
  const tokens = await userRepo.createSession(user.id, user.email, c.env.JWT_SECRET);
  
  return c.json(
    success({
      user,
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
      expiresIn: tokens.expiresIn,
    }),
    201
  );
});

/**
 * POST /auth/login
 * Login with email and password
 */
auth.post('/login', async (c) => {
  const body = await c.req.json();
  
  // Validate input
  const result = loginSchema.safeParse(body);
  if (!result.success) {
    return c.json(
      error(ErrorCodes.VALIDATION_ERROR, result.error.errors[0].message),
      400
    );
  }
  
  const { email, password } = result.data;
  const userRepo = new UserRepository(c.env.DB);
  
  // Verify credentials
  const user = await userRepo.verifyPassword(email, password);
  if (!user) {
    return c.json(
      error(ErrorCodes.INVALID_CREDENTIALS, 'Invalid email or password'),
      401
    );
  }
  
  // Create tokens
  const tokens = await userRepo.createSession(user.id, user.email, c.env.JWT_SECRET);
  
  return c.json(
    success({
      user: userRepo.toResponse(user),
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
      expiresIn: tokens.expiresIn,
    })
  );
});

/**
 * POST /auth/refresh
 * Refresh access token using refresh token
 */
auth.post('/refresh', async (c) => {
  const body = await c.req.json();
  
  // Validate input
  const result = refreshTokenSchema.safeParse({
    refresh_token: body.refreshToken || body.refresh_token,
  });
  
  if (!result.success) {
    return c.json(error(ErrorCodes.INVALID_INPUT, 'Refresh token required'), 400);
  }
  
  const { refresh_token } = result.data;
  
  try {
    // Verify refresh token
    await verifyToken(refresh_token, c.env.JWT_SECRET);
    
    const userRepo = new UserRepository(c.env.DB);
    const refreshResult = await userRepo.refreshSession(refresh_token, c.env.JWT_SECRET);
    
    if (!refreshResult) {
      return c.json(error(ErrorCodes.INVALID_TOKEN, 'Invalid or expired refresh token'), 401);
    }
    
    return c.json(
      success({
        accessToken: refreshResult.tokens.accessToken,
        refreshToken: refreshResult.tokens.refreshToken,
        expiresIn: refreshResult.tokens.expiresIn,
      })
    );
  } catch {
    return c.json(error(ErrorCodes.INVALID_TOKEN, 'Invalid refresh token'), 401);
  }
});

/**
 * GET /auth/me
 * Get current user profile with circles
 */
auth.get('/me', authMiddleware, async (c) => {
  const userId = c.get('userId');
  const userRepo = new UserRepository(c.env.DB);
  
  const result = await userRepo.getUserWithCircles(userId);
  
  if (!result) {
    return c.json(error(ErrorCodes.NOT_FOUND, 'User not found'), 404);
  }
  
  return c.json(
    success({
      user: result.user,
      circles: result.circles,
    })
  );
});

/**
 * PUT /auth/me
 * Update current user profile
 */
auth.put('/me', authMiddleware, async (c) => {
  const userId = c.get('userId');
  const body = await c.req.json();
  
  // Validate input
  const result = updateUserSchema.safeParse(body);
  if (!result.success) {
    return c.json(
      error(ErrorCodes.VALIDATION_ERROR, result.error.errors[0].message),
      400
    );
  }
  
  const userRepo = new UserRepository(c.env.DB);
  const updates = result.data;
  
  // If nothing to update
  if (Object.keys(updates).length === 0 && !body.roleLabel) {
    return c.json(error(ErrorCodes.INVALID_INPUT, 'No fields to update'), 400);
  }
  
  // Update user
  const updatedUser = await userRepo.update(userId, updates);
  
  if (!updatedUser) {
    return c.json(error(ErrorCodes.NOT_FOUND, 'User not found'), 404);
  }
  
  // Also update role_label in circle_members if provided
  if (body.roleLabel !== undefined) {
    await userRepo.updateRoleLabel(userId, body.roleLabel || null);
  }
  
  return c.json(success({ user: updatedUser }));
});

/**
 * PUT /auth/password
 * Change password
 */
auth.put('/password', authMiddleware, async (c) => {
  const userId = c.get('userId');
  const body = await c.req.json();
  
  // Validate input
  const result = changePasswordSchema.safeParse({
    current_password: body.currentPassword || body.current_password,
    new_password: body.newPassword || body.new_password,
  });
  
  if (!result.success) {
    return c.json(
      error(ErrorCodes.VALIDATION_ERROR, result.error.errors[0].message),
      400
    );
  }
  
  const { current_password, new_password } = result.data;
  const userRepo = new UserRepository(c.env.DB);
  
  // Get current user
  const user = await userRepo.findById(userId);
  if (!user) {
    return c.json(error(ErrorCodes.NOT_FOUND, 'User not found'), 404);
  }
  
  // Verify current password
  const valid = await userRepo.verifyPassword(user.email, current_password);
  if (!valid) {
    return c.json(error(ErrorCodes.INVALID_CREDENTIALS, 'Current password is incorrect'), 401);
  }
  
  // Update password
  await userRepo.updatePassword(userId, new_password);
  
  // Invalidate all sessions
  await userRepo.deleteAllSessions(userId);
  
  return c.json(success({ message: 'Password updated successfully' }));
});

/**
 * POST /auth/logout
 * Logout (invalidate refresh token)
 */
auth.post('/logout', authMiddleware, async (c) => {
  const body = await c.req.json().catch(() => ({}));
  const refreshToken = body.refreshToken || body.refresh_token;
  
  if (refreshToken) {
    const userRepo = new UserRepository(c.env.DB);
    await userRepo.deleteSession(refreshToken);
  }
  
  return c.json(success({ message: 'Logged out successfully' }));
});

export { auth as authRoutes };

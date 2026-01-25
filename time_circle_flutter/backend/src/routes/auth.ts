/**
 * Auth Routes
 */

import { Hono } from 'hono';
import { z } from 'zod';
import { hashPassword, verifyPassword } from '../utils/password';
import { createTokenPair, verifyToken, REFRESH_TOKEN_EXPIRY } from '../utils/jwt';
import { generateId, generateToken } from '../utils/id';
import { success, error, ErrorCodes } from '../utils/response';
import { authMiddleware } from '../middleware/auth';
import type { Env, User, Session } from '../types';

const auth = new Hono<{ Bindings: Env }>();

// Validation schemas
const registerSchema = z.object({
  email: z.string().email('Invalid email format'),
  password: z.string().min(6, 'Password must be at least 6 characters'),
  name: z.string().min(1, 'Name is required').max(50),
});

const loginSchema = z.object({
  email: z.string().email(),
  password: z.string().min(1),
});

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
  
  // Check if email exists
  const existingUser = await c.env.DB.prepare(
    'SELECT id FROM users WHERE email = ?'
  )
    .bind(email.toLowerCase())
    .first();
  
  if (existingUser) {
    return c.json(error(ErrorCodes.EMAIL_EXISTS, 'Email already registered'), 409);
  }
  
  // Hash password
  const passwordHash = await hashPassword(password);
  
  // Create user
  const userId = generateId('u');
  const now = new Date().toISOString();
  
  await c.env.DB.prepare(
    `INSERT INTO users (id, email, password_hash, name, created_at, updated_at)
     VALUES (?, ?, ?, ?, ?, ?)`
  )
    .bind(userId, email.toLowerCase(), passwordHash, name, now, now)
    .run();
  
  // Create tokens
  const tokens = await createTokenPair(userId, email.toLowerCase(), c.env.JWT_SECRET);
  
  // Store refresh token session
  const sessionId = generateId('ses');
  const expiresAt = new Date(Date.now() + REFRESH_TOKEN_EXPIRY * 1000).toISOString();
  
  await c.env.DB.prepare(
    `INSERT INTO sessions (id, user_id, refresh_token, expires_at)
     VALUES (?, ?, ?, ?)`
  )
    .bind(sessionId, userId, tokens.refreshToken, expiresAt)
    .run();
  
  return c.json(
    success({
      user: {
        id: userId,
        email: email.toLowerCase(),
        name,
        avatar: null,
        created_at: now,
        updated_at: now,
      },
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
  
  // Find user
  const user = await c.env.DB.prepare(
    'SELECT * FROM users WHERE email = ?'
  )
    .bind(email.toLowerCase())
    .first<User>();
  
  if (!user) {
    return c.json(
      error(ErrorCodes.INVALID_CREDENTIALS, 'Invalid email or password'),
      401
    );
  }
  
  // Verify password
  const valid = await verifyPassword(password, user.password_hash);
  if (!valid) {
    return c.json(
      error(ErrorCodes.INVALID_CREDENTIALS, 'Invalid email or password'),
      401
    );
  }
  
  // Create tokens
  const tokens = await createTokenPair(user.id, user.email, c.env.JWT_SECRET);
  
  // Store refresh token session
  const sessionId = generateId('ses');
  const expiresAt = new Date(Date.now() + REFRESH_TOKEN_EXPIRY * 1000).toISOString();
  
  await c.env.DB.prepare(
    `INSERT INTO sessions (id, user_id, refresh_token, expires_at)
     VALUES (?, ?, ?, ?)`
  )
    .bind(sessionId, user.id, tokens.refreshToken, expiresAt)
    .run();
  
  // Remove password_hash from response
  const { password_hash, ...userWithoutPassword } = user;
  
  return c.json(
    success({
      user: userWithoutPassword,
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
  const { refreshToken } = body as { refreshToken?: string };
  
  if (!refreshToken) {
    return c.json(error(ErrorCodes.INVALID_INPUT, 'Refresh token required'), 400);
  }
  
  try {
    // Verify refresh token
    const payload = await verifyToken(refreshToken, c.env.JWT_SECRET);
    
    // Check if session exists and is valid
    const session = await c.env.DB.prepare(
      `SELECT s.*, u.email, u.name, u.avatar
       FROM sessions s
       JOIN users u ON s.user_id = u.id
       WHERE s.refresh_token = ? AND s.expires_at > datetime('now')`
    )
      .bind(refreshToken)
      .first<Session & { email: string; name: string; avatar: string | null }>();
    
    if (!session) {
      return c.json(error(ErrorCodes.INVALID_TOKEN, 'Invalid or expired refresh token'), 401);
    }
    
    // Create new tokens
    const tokens = await createTokenPair(session.user_id, session.email, c.env.JWT_SECRET);
    
    // Update session with new refresh token
    const expiresAt = new Date(Date.now() + REFRESH_TOKEN_EXPIRY * 1000).toISOString();
    
    await c.env.DB.prepare(
      `UPDATE sessions SET refresh_token = ?, expires_at = ? WHERE id = ?`
    )
      .bind(tokens.refreshToken, expiresAt, session.id)
      .run();
    
    return c.json(
      success({
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
        expiresIn: tokens.expiresIn,
      })
    );
  } catch {
    return c.json(error(ErrorCodes.INVALID_TOKEN, 'Invalid refresh token'), 401);
  }
});

/**
 * GET /auth/me
 * Get current user profile
 */
auth.get('/me', authMiddleware, async (c) => {
  const user = c.get('user');
  
  // Get user's circles
  const circles = await c.env.DB.prepare(
    `SELECT c.*, cm.role, cm.role_label
     FROM circles c
     JOIN circle_members cm ON c.id = cm.circle_id
     WHERE cm.user_id = ?
     ORDER BY cm.joined_at DESC`
  )
    .bind(user.id)
    .all();
  
  return c.json(
    success({
      user,
      circles: circles.results,
    })
  );
});

/**
 * PUT /auth/password
 * Change password
 */
auth.put('/password', authMiddleware, async (c) => {
  const userId = c.get('userId');
  const body = await c.req.json();
  const { currentPassword, newPassword } = body as {
    currentPassword?: string;
    newPassword?: string;
  };
  
  if (!currentPassword || !newPassword) {
    return c.json(
      error(ErrorCodes.INVALID_INPUT, 'Current password and new password required'),
      400
    );
  }
  
  if (newPassword.length < 6) {
    return c.json(
      error(ErrorCodes.VALIDATION_ERROR, 'New password must be at least 6 characters'),
      400
    );
  }
  
  // Get current user
  const user = await c.env.DB.prepare(
    'SELECT password_hash FROM users WHERE id = ?'
  )
    .bind(userId)
    .first<{ password_hash: string }>();
  
  if (!user) {
    return c.json(error(ErrorCodes.NOT_FOUND, 'User not found'), 404);
  }
  
  // Verify current password
  const valid = await verifyPassword(currentPassword, user.password_hash);
  if (!valid) {
    return c.json(error(ErrorCodes.INVALID_CREDENTIALS, 'Current password is incorrect'), 401);
  }
  
  // Hash new password
  const newPasswordHash = await hashPassword(newPassword);
  
  // Update password
  await c.env.DB.prepare(
    `UPDATE users SET password_hash = ?, updated_at = datetime('now') WHERE id = ?`
  )
    .bind(newPasswordHash, userId)
    .run();
  
  // Invalidate all sessions except current
  // (In production, you might want to keep current session)
  await c.env.DB.prepare('DELETE FROM sessions WHERE user_id = ?')
    .bind(userId)
    .run();
  
  return c.json(success({ message: 'Password updated successfully' }));
});

/**
 * POST /auth/logout
 * Logout (invalidate refresh token)
 */
auth.post('/logout', authMiddleware, async (c) => {
  const body = await c.req.json().catch(() => ({}));
  const { refreshToken } = body as { refreshToken?: string };
  
  if (refreshToken) {
    await c.env.DB.prepare('DELETE FROM sessions WHERE refresh_token = ?')
      .bind(refreshToken)
      .run();
  }
  
  return c.json(success({ message: 'Logged out successfully' }));
});

export { auth as authRoutes };

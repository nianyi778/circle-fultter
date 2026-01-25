/**
 * Authentication Middleware
 */

import { Context, Next } from 'hono';
import { verifyToken } from '../utils/jwt';
import { error, ErrorCodes } from '../utils/response';
import type { Env, AuthUser, User } from '../types';

// Extend Hono context with user
declare module 'hono' {
  interface ContextVariableMap {
    user: AuthUser;
    userId: string;
  }
}

/**
 * Authentication middleware - requires valid JWT
 */
export async function authMiddleware(c: Context<{ Bindings: Env }>, next: Next) {
  const authHeader = c.req.header('Authorization');
  
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return c.json(error(ErrorCodes.UNAUTHORIZED, 'Missing authorization header'), 401);
  }
  
  const token = authHeader.slice(7);
  
  try {
    const payload = await verifyToken(token, c.env.JWT_SECRET);
    
    // Get user from database
    const user = await c.env.DB.prepare(
      'SELECT id, email, name, avatar FROM users WHERE id = ?'
    )
      .bind(payload.sub)
      .first<Pick<User, 'id' | 'email' | 'name' | 'avatar'>>();
    
    if (!user) {
      return c.json(error(ErrorCodes.UNAUTHORIZED, 'User not found'), 401);
    }
    
    // Set user in context
    c.set('user', user);
    c.set('userId', user.id);
    
    await next();
  } catch (err) {
    if (err instanceof Error && err.message === 'Token expired') {
      return c.json(error(ErrorCodes.TOKEN_EXPIRED, 'Token expired'), 401);
    }
    return c.json(error(ErrorCodes.INVALID_TOKEN, 'Invalid token'), 401);
  }
}

/**
 * Optional authentication - sets user if token is valid, continues otherwise
 */
export async function optionalAuthMiddleware(c: Context<{ Bindings: Env }>, next: Next) {
  const authHeader = c.req.header('Authorization');
  
  if (authHeader && authHeader.startsWith('Bearer ')) {
    const token = authHeader.slice(7);
    
    try {
      const payload = await verifyToken(token, c.env.JWT_SECRET);
      
      const user = await c.env.DB.prepare(
        'SELECT id, email, name, avatar FROM users WHERE id = ?'
      )
        .bind(payload.sub)
        .first<Pick<User, 'id' | 'email' | 'name' | 'avatar'>>();
      
      if (user) {
        c.set('user', user);
        c.set('userId', user.id);
      }
    } catch {
      // Ignore token errors for optional auth
    }
  }
  
  await next();
}

/**
 * Circle membership middleware - checks if user is a member of the circle
 */
export async function circleMemberMiddleware(c: Context<{ Bindings: Env }>, next: Next) {
  const userId = c.get('userId');
  const circleId = c.req.param('circleId') || c.req.param('id');
  
  if (!circleId) {
    return c.json(error(ErrorCodes.INVALID_INPUT, 'Circle ID required'), 400);
  }
  
  const member = await c.env.DB.prepare(
    'SELECT role FROM circle_members WHERE circle_id = ? AND user_id = ?'
  )
    .bind(circleId, userId)
    .first<{ role: string }>();
  
  if (!member) {
    return c.json(error(ErrorCodes.FORBIDDEN, 'Not a member of this circle'), 403);
  }
  
  // Store role in context for permission checks
  c.set('circleRole' as any, member.role);
  
  await next();
}

/**
 * Circle admin middleware - checks if user is an admin of the circle
 */
export async function circleAdminMiddleware(c: Context<{ Bindings: Env }>, next: Next) {
  const role = c.get('circleRole' as any);
  
  if (role !== 'admin') {
    return c.json(error(ErrorCodes.FORBIDDEN, 'Admin access required'), 403);
  }
  
  await next();
}

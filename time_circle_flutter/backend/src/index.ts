/**
 * Aura API - Main Entry Point
 * Cloudflare Workers + Hono
 */

import { Hono } from 'hono';
import { cors } from 'hono/cors';
import { logger } from 'hono/logger';
import { secureHeaders } from 'hono/secure-headers';

import { authRoutes } from './routes/auth';
import { circleRoutes } from './routes/circles';
import { momentRoutes, circleMomentRoutes } from './routes/moments';
import { letterRoutes, circleLetterRoutes } from './routes/letters';
import { worldRoutes } from './routes/world';
import { commentsRoutes } from './routes/comments';
import { mediaRoutes } from './routes/media';
import { syncRoutes } from './routes/sync';
import { errorHandler } from './middleware/error';
import { requestIdMiddleware } from './middleware/request-id';
import type { Env } from './types';

const app = new Hono<{ Bindings: Env }>();

// Global middleware
app.use('*', logger());
app.use('*', secureHeaders());
app.use('*', requestIdMiddleware());
app.use(
  '*',
  cors({
    origin: '*', // In production, restrict to your domains
    allowMethods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
    allowHeaders: ['Content-Type', 'Authorization'],
    exposeHeaders: ['X-Request-Id'],
    maxAge: 86400,
  })
);

// Error handling
app.onError(errorHandler);

// Health check
app.get('/', (c) => {
  return c.json({
    name: 'Aura API',
    version: c.env.API_VERSION || '1.0.0',
    status: 'healthy',
    timestamp: new Date().toISOString(),
  });
});

app.get('/health', (c) => {
  return c.json({ status: 'ok' });
});

// API Routes
app.route('/auth', authRoutes);
app.route('/circles', circleRoutes);
app.route('/moments', momentRoutes);
app.route('/letters', letterRoutes);
app.route('/world', worldRoutes);
app.route('/comments', commentsRoutes);
app.route('/media', mediaRoutes);
app.route('/sync', syncRoutes);

// Circle-scoped routes (mounted under /circles/:circleId)
// These are already handled in circles.ts but we also mount them here for clarity
// GET/POST /circles/:circleId/moments
// GET/POST /circles/:circleId/letters

// 404 handler
app.notFound((c) => {
  return c.json(
    {
      success: false,
      error: {
        code: 'NOT_FOUND',
        message: `Route ${c.req.method} ${c.req.path} not found`,
      },
    },
    404
  );
});

export default app;

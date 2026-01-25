/**
 * World Channel Routes
 * Public social features with anonymous sharing
 */

import { Hono } from 'hono';
import { z } from 'zod';
import { generateId } from '../utils/id';
import { success, error, ErrorCodes, paginate } from '../utils/response';
import { authMiddleware, optionalAuthMiddleware } from '../middleware/auth';
import type { Env, WorldPost, WorldChannel, Resonance } from '../types';

const world = new Hono<{ Bindings: Env }>();

// Validation schemas
const createPostSchema = z.object({
  content: z.string().min(1).max(500),
  tag: z.string().min(1).max(50),
  bgGradient: z.string(),
  momentId: z.string().optional(),
});

// Background gradient presets
const BG_GRADIENTS = [
  'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
  'linear-gradient(135deg, #f093fb 0%, #f5576c 100%)',
  'linear-gradient(135deg, #4facfe 0%, #00f2fe 100%)',
  'linear-gradient(135deg, #43e97b 0%, #38f9d7 100%)',
  'linear-gradient(135deg, #fa709a 0%, #fee140 100%)',
  'linear-gradient(135deg, #a8edea 0%, #fed6e3 100%)',
  'linear-gradient(135deg, #d299c2 0%, #fef9d7 100%)',
  'linear-gradient(135deg, #89f7fe 0%, #66a6ff 100%)',
];

/**
 * GET /world/channels
 * Get all available channels/tags
 */
world.get('/channels', async (c) => {
  const channels = await c.env.DB.prepare(
    `SELECT * FROM world_channels ORDER BY post_count DESC`
  ).all<WorldChannel>();

  return c.json(success(channels.results));
});

/**
 * GET /world/posts
 * Get world posts with optional tag filter
 */
world.get('/posts', optionalAuthMiddleware, async (c) => {
  const tag = c.req.query('tag');
  const page = parseInt(c.req.query('page') || '1');
  const limit = Math.min(parseInt(c.req.query('limit') || '20'), 50);
  const offset = (page - 1) * limit;
  const userId = c.get('userId');

  let query: string;
  let countQuery: string;
  const bindings: (string | number)[] = [];

  if (tag) {
    query = `
      SELECT 
        wp.*,
        u.name as author_name,
        u.avatar as author_avatar
        ${userId ? ', (SELECT 1 FROM resonances WHERE user_id = ? AND post_id = wp.id) as has_resonated' : ''}
      FROM world_posts wp
      LEFT JOIN users u ON wp.author_id = u.id
      WHERE wp.tag = ? AND wp.deleted_at IS NULL
      ORDER BY wp.created_at DESC
      LIMIT ? OFFSET ?
    `;
    countQuery = `SELECT COUNT(*) as total FROM world_posts WHERE tag = ? AND deleted_at IS NULL`;
    
    if (userId) bindings.push(userId);
    bindings.push(tag, limit, offset);
  } else {
    query = `
      SELECT 
        wp.*,
        u.name as author_name,
        u.avatar as author_avatar
        ${userId ? ', (SELECT 1 FROM resonances WHERE user_id = ? AND post_id = wp.id) as has_resonated' : ''}
      FROM world_posts wp
      LEFT JOIN users u ON wp.author_id = u.id
      WHERE wp.deleted_at IS NULL
      ORDER BY wp.created_at DESC
      LIMIT ? OFFSET ?
    `;
    countQuery = `SELECT COUNT(*) as total FROM world_posts WHERE deleted_at IS NULL`;
    
    if (userId) bindings.push(userId);
    bindings.push(limit, offset);
  }

  const [posts, countResult] = await Promise.all([
    c.env.DB.prepare(query).bind(...bindings).all<WorldPost & { 
      author_name: string; 
      author_avatar: string | null;
      has_resonated?: number;
    }>(),
    c.env.DB.prepare(countQuery).bind(...(tag ? [tag] : [])).first<{ total: number }>(),
  ]);

  const total = countResult?.total || 0;

  // Transform posts - anonymize author info for world posts
  const transformedPosts = posts.results.map((post) => ({
    ...post,
    // Use anonymous display for world posts
    authorName: post.author_name?.charAt(0) + '***',
    authorAvatar: post.author_avatar,
    hasResonated: Boolean(post.has_resonated),
  }));

  return c.json(
    success(transformedPosts, paginate(page, limit, total))
  );
});

/**
 * POST /world/posts
 * Create a new world post
 */
world.post('/posts', authMiddleware, async (c) => {
  const userId = c.get('userId');
  const body = await c.req.json();

  // Validate input
  const result = createPostSchema.safeParse(body);
  if (!result.success) {
    return c.json(
      error(ErrorCodes.VALIDATION_ERROR, result.error.errors[0].message),
      400
    );
  }

  const { content, tag, bgGradient, momentId } = result.data;

  // If momentId is provided, verify user owns it
  if (momentId) {
    const moment = await c.env.DB.prepare(
      'SELECT author_id FROM moments WHERE id = ? AND deleted_at IS NULL'
    )
      .bind(momentId)
      .first<{ author_id: string }>();

    if (!moment) {
      return c.json(error(ErrorCodes.NOT_FOUND, 'Moment not found'), 404);
    }

    if (moment.author_id !== userId) {
      return c.json(error(ErrorCodes.FORBIDDEN, 'You can only share your own moments'), 403);
    }
  }

  // Create post
  const postId = generateId('wp');
  const now = new Date().toISOString();

  await c.env.DB.prepare(
    `INSERT INTO world_posts (id, author_id, moment_id, content, tag, bg_gradient, created_at)
     VALUES (?, ?, ?, ?, ?, ?, ?)`
  )
    .bind(postId, userId, momentId || null, content, tag, bgGradient, now)
    .run();

  // Update channel post count
  await c.env.DB.prepare(
    `INSERT INTO world_channels (id, name, description, post_count)
     VALUES (?, ?, ?, 1)
     ON CONFLICT(id) DO UPDATE SET post_count = post_count + 1`
  )
    .bind(tag, tag, `Posts about ${tag}`, 1)
    .run();

  // If linked to a moment, update the moment
  if (momentId) {
    await c.env.DB.prepare(
      `UPDATE moments SET is_shared_to_world = 1, world_topic = ? WHERE id = ?`
    )
      .bind(tag, momentId)
      .run();
  }

  const post = await c.env.DB.prepare(
    'SELECT * FROM world_posts WHERE id = ?'
  )
    .bind(postId)
    .first<WorldPost>();

  return c.json(success(post), 201);
});

/**
 * DELETE /world/posts/:id
 * Delete a world post (author only)
 */
world.delete('/posts/:id', authMiddleware, async (c) => {
  const userId = c.get('userId');
  const postId = c.req.param('id');

  const post = await c.env.DB.prepare(
    'SELECT * FROM world_posts WHERE id = ? AND deleted_at IS NULL'
  )
    .bind(postId)
    .first<WorldPost>();

  if (!post) {
    return c.json(error(ErrorCodes.NOT_FOUND, 'Post not found'), 404);
  }

  if (post.author_id !== userId) {
    return c.json(error(ErrorCodes.FORBIDDEN, 'Not your post'), 403);
  }

  // Soft delete
  await c.env.DB.prepare(
    `UPDATE world_posts SET deleted_at = datetime('now') WHERE id = ?`
  )
    .bind(postId)
    .run();

  // Update channel post count
  await c.env.DB.prepare(
    `UPDATE world_channels SET post_count = post_count - 1 WHERE id = ?`
  )
    .bind(post.tag)
    .run();

  // If linked to a moment, update the moment
  if (post.moment_id) {
    await c.env.DB.prepare(
      `UPDATE moments SET is_shared_to_world = 0, world_topic = NULL WHERE id = ?`
    )
      .bind(post.moment_id)
      .run();
  }

  return c.json(success({ message: 'Post deleted' }));
});

/**
 * POST /world/posts/:id/resonate
 * Add resonance (like) to a post
 */
world.post('/posts/:id/resonate', authMiddleware, async (c) => {
  const userId = c.get('userId');
  const postId = c.req.param('id');

  // Check if post exists
  const post = await c.env.DB.prepare(
    'SELECT id FROM world_posts WHERE id = ? AND deleted_at IS NULL'
  )
    .bind(postId)
    .first<{ id: string }>();

  if (!post) {
    return c.json(error(ErrorCodes.NOT_FOUND, 'Post not found'), 404);
  }

  // Check if already resonated
  const existing = await c.env.DB.prepare(
    'SELECT 1 FROM resonances WHERE user_id = ? AND post_id = ?'
  )
    .bind(userId, postId)
    .first();

  if (existing) {
    return c.json(error(ErrorCodes.ALREADY_EXISTS, 'Already resonated'), 409);
  }

  // Add resonance
  await c.env.DB.prepare(
    `INSERT INTO resonances (user_id, post_id) VALUES (?, ?)`
  )
    .bind(userId, postId)
    .run();

  // Update resonance count
  await c.env.DB.prepare(
    `UPDATE world_posts SET resonance_count = resonance_count + 1 WHERE id = ?`
  )
    .bind(postId)
    .run();

  const updatedPost = await c.env.DB.prepare(
    'SELECT resonance_count FROM world_posts WHERE id = ?'
  )
    .bind(postId)
    .first<{ resonance_count: number }>();

  return c.json(
    success({
      resonanceCount: updatedPost?.resonance_count || 0,
      hasResonated: true,
    })
  );
});

/**
 * DELETE /world/posts/:id/resonate
 * Remove resonance from a post
 */
world.delete('/posts/:id/resonate', authMiddleware, async (c) => {
  const userId = c.get('userId');
  const postId = c.req.param('id');

  // Check if resonance exists
  const existing = await c.env.DB.prepare(
    'SELECT 1 FROM resonances WHERE user_id = ? AND post_id = ?'
  )
    .bind(userId, postId)
    .first();

  if (!existing) {
    return c.json(error(ErrorCodes.NOT_FOUND, 'Resonance not found'), 404);
  }

  // Remove resonance
  await c.env.DB.prepare(
    'DELETE FROM resonances WHERE user_id = ? AND post_id = ?'
  )
    .bind(userId, postId)
    .run();

  // Update resonance count
  await c.env.DB.prepare(
    `UPDATE world_posts SET resonance_count = MAX(0, resonance_count - 1) WHERE id = ?`
  )
    .bind(postId)
    .run();

  const updatedPost = await c.env.DB.prepare(
    'SELECT resonance_count FROM world_posts WHERE id = ?'
  )
    .bind(postId)
    .first<{ resonance_count: number }>();

  return c.json(
    success({
      resonanceCount: updatedPost?.resonance_count || 0,
      hasResonated: false,
    })
  );
});

/**
 * GET /world/gradients
 * Get available background gradients
 */
world.get('/gradients', (c) => {
  return c.json(success(BG_GRADIENTS));
});

export { world as worldRoutes };

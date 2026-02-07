/**
 * World Channel Routes (Refactored with Repository Pattern)
 * Public social features with anonymous sharing
 */

import { Hono } from 'hono';
import { success, error, ErrorCodes } from '../utils/response';
import { authMiddleware, optionalAuthMiddleware } from '../middleware/auth';
import { WorldRepository, MomentRepository } from '../repositories';
import { createWorldPostSchema, worldPostFilterSchema, paginationSchema } from '../schemas';
import type { Env } from '../types';

const world = new Hono<{ Bindings: Env }>();

/**
 * GET /world/channels
 * Get all available channels/tags
 */
world.get('/channels', async (c) => {
  const worldRepo = new WorldRepository(c.env.DB);
  
  const channels = await worldRepo.getChannels();
  
  return c.json(success(channels));
});

/**
 * GET /world/posts
 * Get world posts with optional tag filter
 */
world.get('/posts', optionalAuthMiddleware, async (c) => {
  const userId = c.get('userId');
  
  // Parse pagination
  const paginationResult = paginationSchema.safeParse({
    page: c.req.query('page'),
    limit: c.req.query('limit'),
  });
  
  const pagination = paginationResult.success
    ? paginationResult.data
    : { page: 1, limit: 20 };
  
  // Limit max to 50
  pagination.limit = Math.min(pagination.limit, 50);
  
  // Parse filter
  const filterResult = worldPostFilterSchema.safeParse({
    tag: c.req.query('tag'),
  });
  
  const filter = filterResult.success ? filterResult.data : undefined;
  
  const worldRepo = new WorldRepository(c.env.DB);
  
  const result = await worldRepo.getPosts(pagination, filter, userId);
  
  return c.json(
    success({
      data: worldRepo.processForList(result.data),
      meta: result.meta,
    })
  );
});

/**
 * POST /world/posts
 * Create a new world post
 */
world.post('/posts', authMiddleware, async (c) => {
  const userId = c.get('userId');
  const body = await c.req.json();
  
  // Validate input - support both formats
  const result = createWorldPostSchema.safeParse({
    content: body.content,
    tag: body.tag,
    bg_gradient: body.bgGradient || body.bg_gradient,
  });
  
  if (!result.success) {
    return c.json(
      error(ErrorCodes.VALIDATION_ERROR, result.error.errors[0].message),
      400
    );
  }
  
  const momentId = body.momentId || body.moment_id;
  
  // If momentId is provided, verify user owns it
  if (momentId) {
    const momentRepo = new MomentRepository(c.env.DB);
    
    if (!(await momentRepo.isAuthor(momentId, userId))) {
      const moment = await momentRepo.findById(momentId);
      if (!moment) {
        return c.json(error(ErrorCodes.NOT_FOUND, 'Moment not found'), 404);
      }
      return c.json(error(ErrorCodes.FORBIDDEN, 'You can only share your own moments'), 403);
    }
  }
  
  const worldRepo = new WorldRepository(c.env.DB);
  
  const post = await worldRepo.createPost({
    author_id: userId,
    content: result.data.content,
    tag: result.data.tag,
    bg_gradient: result.data.bg_gradient,
    moment_id: momentId,
  });
  
  return c.json(success(worldRepo.toResponse(post)), 201);
});

/**
 * DELETE /world/posts/:id
 * Delete a world post (author only)
 */
world.delete('/posts/:id', authMiddleware, async (c) => {
  const userId = c.get('userId');
  const postId = c.req.param('id');
  
  const worldRepo = new WorldRepository(c.env.DB);
  
  // Check ownership
  if (!(await worldRepo.isAuthor(postId, userId))) {
    const post = await worldRepo.findPostById(postId);
    if (!post) {
      return c.json(error(ErrorCodes.NOT_FOUND, 'Post not found'), 404);
    }
    return c.json(error(ErrorCodes.FORBIDDEN, 'Not your post'), 403);
  }
  
  await worldRepo.deletePost(postId);
  
  return c.json(success({ message: 'Post deleted' }));
});

/**
 * POST /world/posts/:id/resonate
 * Add resonance (like) to a post
 */
world.post('/posts/:id/resonate', authMiddleware, async (c) => {
  const userId = c.get('userId');
  const postId = c.req.param('id');
  
  const worldRepo = new WorldRepository(c.env.DB);
  
  try {
    const resonanceCount = await worldRepo.addResonance(userId, postId);
    
    return c.json(
      success({
        resonance_count: resonanceCount,
        has_resonated: true,
      })
    );
  } catch (err) {
    const message = err instanceof Error ? err.message : 'Unknown error';
    
    if (message === 'Post not found') {
      return c.json(error(ErrorCodes.NOT_FOUND, 'Post not found'), 404);
    }
    
    if (message === 'Already resonated') {
      return c.json(error(ErrorCodes.ALREADY_EXISTS, 'Already resonated'), 409);
    }
    
    throw err;
  }
});

/**
 * DELETE /world/posts/:id/resonate
 * Remove resonance from a post
 */
world.delete('/posts/:id/resonate', authMiddleware, async (c) => {
  const userId = c.get('userId');
  const postId = c.req.param('id');
  
  const worldRepo = new WorldRepository(c.env.DB);
  
  try {
    const resonanceCount = await worldRepo.removeResonance(userId, postId);
    
    return c.json(
      success({
        resonance_count: resonanceCount,
        has_resonated: false,
      })
    );
  } catch (err) {
    const message = err instanceof Error ? err.message : 'Unknown error';
    
    if (message === 'Resonance not found') {
      return c.json(error(ErrorCodes.NOT_FOUND, 'Resonance not found'), 404);
    }
    
    throw err;
  }
});

/**
 * GET /world/gradients
 * Get available background gradients
 */
world.get('/gradients', (c) => {
  const worldRepo = new WorldRepository(c.env.DB);
  
  return c.json(success(worldRepo.getGradients()));
});

export { world as worldRoutes };

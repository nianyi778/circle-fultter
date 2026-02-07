/**
 * Comments Routes (Refactored with Repository Pattern)
 * Comments for moments and world posts
 */

import { Hono } from 'hono';
import { success, error, ErrorCodes } from '../utils/response';
import { authMiddleware } from '../middleware/auth';
import { CommentRepository, MomentRepository, WorldRepository, CircleRepository } from '../repositories';
import { createCommentSchema, paginationSchema } from '../schemas';
import type { Env } from '../types';

const comments = new Hono<{ Bindings: Env }>();

/**
 * GET /comments/moment/:momentId
 * Get comments for a moment
 */
comments.get('/moment/:momentId', authMiddleware, async (c) => {
  const momentId = c.req.param('momentId');
  const userId = c.get('userId');
  
  // Parse pagination
  const paginationResult = paginationSchema.safeParse({
    page: c.req.query('page'),
    limit: c.req.query('limit'),
  });
  
  const pagination = paginationResult.success
    ? paginationResult.data
    : { page: 1, limit: 20 };
  
  pagination.limit = Math.min(pagination.limit, 50);
  
  const momentRepo = new MomentRepository(c.env.DB);
  const circleRepo = new CircleRepository(c.env.DB);
  const commentRepo = new CommentRepository(c.env.DB);
  
  // Get moment and verify access
  const circleId = await momentRepo.getCircleId(momentId);
  
  if (!circleId) {
    return c.json(error(ErrorCodes.NOT_FOUND, 'Moment not found'), 404);
  }
  
  if (!(await circleRepo.isMember(circleId, userId))) {
    return c.json(error(ErrorCodes.FORBIDDEN, 'Not a member of this circle'), 403);
  }
  
  // Get all comments and build tree structure
  const allComments = await commentRepo.getAllForTarget(momentId, 'moment');
  const tree = commentRepo.processAsTree(allComments, false);
  
  // For simple pagination, return flat list
  const result = await commentRepo.getForMoment(momentId, pagination);
  
  return c.json(
    success({
      data: tree, // Return tree structure
      meta: result.meta,
    })
  );
});

/**
 * GET /comments/world/:postId
 * Get comments for a world post
 */
comments.get('/world/:postId', authMiddleware, async (c) => {
  const postId = c.req.param('postId');
  
  // Parse pagination
  const paginationResult = paginationSchema.safeParse({
    page: c.req.query('page'),
    limit: c.req.query('limit'),
  });
  
  const pagination = paginationResult.success
    ? paginationResult.data
    : { page: 1, limit: 20 };
  
  pagination.limit = Math.min(pagination.limit, 50);
  
  const worldRepo = new WorldRepository(c.env.DB);
  const commentRepo = new CommentRepository(c.env.DB);
  
  // Verify post exists
  const post = await worldRepo.findPostById(postId);
  
  if (!post) {
    return c.json(error(ErrorCodes.NOT_FOUND, 'Post not found'), 404);
  }
  
  // Get comments - anonymize for world posts
  const result = await commentRepo.getForWorldPost(postId, pagination);
  
  return c.json(
    success({
      data: commentRepo.processForList(result.data, true), // Anonymize
      meta: result.meta,
    })
  );
});

/**
 * POST /comments/moment/:momentId
 * Add comment to a moment
 */
comments.post('/moment/:momentId', authMiddleware, async (c) => {
  const momentId = c.req.param('momentId');
  const userId = c.get('userId');
  const body = await c.req.json();
  
  // Validate input - support both formats
  const result = createCommentSchema.safeParse({
    content: body.content,
    reply_to_id: body.replyToId || body.reply_to_id,
  });
  
  if (!result.success) {
    return c.json(
      error(ErrorCodes.VALIDATION_ERROR, result.error.errors[0].message),
      400
    );
  }
  
  const momentRepo = new MomentRepository(c.env.DB);
  const circleRepo = new CircleRepository(c.env.DB);
  const commentRepo = new CommentRepository(c.env.DB);
  
  // Get moment and verify access
  const circleId = await momentRepo.getCircleId(momentId);
  
  if (!circleId) {
    return c.json(error(ErrorCodes.NOT_FOUND, 'Moment not found'), 404);
  }
  
  if (!(await circleRepo.isMember(circleId, userId))) {
    return c.json(error(ErrorCodes.FORBIDDEN, 'Not a member of this circle'), 403);
  }
  
  // If replying, verify parent exists
  if (result.data.reply_to_id) {
    const parentExists = await commentRepo.parentExists(
      result.data.reply_to_id,
      momentId,
      'moment'
    );
    
    if (!parentExists) {
      return c.json(error(ErrorCodes.NOT_FOUND, 'Parent comment not found'), 404);
    }
  }
  
  const comment = await commentRepo.createForMoment(
    momentId,
    userId,
    result.data.content,
    result.data.reply_to_id,
    circleId
  );
  
  return c.json(success(commentRepo.toResponse(comment)), 201);
});

/**
 * POST /comments/world/:postId
 * Add comment to a world post
 */
comments.post('/world/:postId', authMiddleware, async (c) => {
  const postId = c.req.param('postId');
  const userId = c.get('userId');
  const body = await c.req.json();
  
  // Validate input
  const result = createCommentSchema.safeParse({
    content: body.content,
    reply_to_id: body.replyToId || body.reply_to_id,
  });
  
  if (!result.success) {
    return c.json(
      error(ErrorCodes.VALIDATION_ERROR, result.error.errors[0].message),
      400
    );
  }
  
  const worldRepo = new WorldRepository(c.env.DB);
  const commentRepo = new CommentRepository(c.env.DB);
  
  // Verify post exists
  const post = await worldRepo.findPostById(postId);
  
  if (!post) {
    return c.json(error(ErrorCodes.NOT_FOUND, 'Post not found'), 404);
  }
  
  // If replying, verify parent exists
  if (result.data.reply_to_id) {
    const parentExists = await commentRepo.parentExists(
      result.data.reply_to_id,
      postId,
      'world_post'
    );
    
    if (!parentExists) {
      return c.json(error(ErrorCodes.NOT_FOUND, 'Parent comment not found'), 404);
    }
  }
  
  const comment = await commentRepo.createForWorldPost(
    postId,
    userId,
    result.data.content,
    result.data.reply_to_id
  );
  
  // Anonymize response for world posts
  return c.json(success(commentRepo.toResponse(comment, true)), 201);
});

/**
 * DELETE /comments/:id
 * Delete a comment (author only)
 */
comments.delete('/:id', authMiddleware, async (c) => {
  const commentId = c.req.param('id');
  const userId = c.get('userId');
  
  const commentRepo = new CommentRepository(c.env.DB);
  
  // Check ownership
  if (!(await commentRepo.isAuthor(commentId, userId))) {
    const comment = await commentRepo.findByIdBasic(commentId);
    if (!comment) {
      return c.json(error(ErrorCodes.NOT_FOUND, 'Comment not found'), 404);
    }
    return c.json(error(ErrorCodes.FORBIDDEN, 'Not your comment'), 403);
  }
  
  const result = await commentRepo.delete(commentId);
  
  if (!result.success) {
    return c.json(error(ErrorCodes.NOT_FOUND, 'Comment not found'), 404);
  }
  
  return c.json(success({ message: 'Comment deleted' }));
});

/**
 * POST /comments/:id/like
 * Like a comment
 */
comments.post('/:id/like', authMiddleware, async (c) => {
  const commentId = c.req.param('id');
  
  const commentRepo = new CommentRepository(c.env.DB);
  
  try {
    const likes = await commentRepo.like(commentId);
    
    return c.json(success({ likes }));
  } catch (err) {
    const message = err instanceof Error ? err.message : 'Unknown error';
    
    if (message === 'Comment not found') {
      return c.json(error(ErrorCodes.NOT_FOUND, 'Comment not found'), 404);
    }
    
    throw err;
  }
});

export { comments as commentsRoutes };

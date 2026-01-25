/**
 * Comments Routes
 * Comments for moments and world posts
 */

import { Hono } from 'hono';
import { z } from 'zod';
import { generateId } from '../utils/id';
import { success, error, ErrorCodes, paginate } from '../utils/response';
import { authMiddleware } from '../middleware/auth';
import type { Env, Comment } from '../types';

const comments = new Hono<{ Bindings: Env }>();

// Validation schemas
const createCommentSchema = z.object({
  content: z.string().min(1).max(500),
  replyToId: z.string().optional(),
});

type CommentWithAuthor = Comment & {
  author_name: string;
  author_avatar: string | null;
};

/**
 * GET /comments/moment/:momentId
 * Get comments for a moment
 */
comments.get('/moment/:momentId', authMiddleware, async (c) => {
  const momentId = c.req.param('momentId');
  const userId = c.get('userId');
  const page = parseInt(c.req.query('page') || '1');
  const limit = Math.min(parseInt(c.req.query('limit') || '20'), 50);
  const offset = (page - 1) * limit;

  // Verify user has access to the moment (is in the same circle)
  const moment = await c.env.DB.prepare(
    `SELECT m.circle_id FROM moments m
     JOIN circle_members cm ON m.circle_id = cm.circle_id
     WHERE m.id = ? AND cm.user_id = ? AND m.deleted_at IS NULL`
  )
    .bind(momentId, userId)
    .first<{ circle_id: string }>();

  if (!moment) {
    return c.json(error(ErrorCodes.NOT_FOUND, 'Moment not found or access denied'), 404);
  }

  const [commentsResult, countResult] = await Promise.all([
    c.env.DB.prepare(
      `SELECT c.*, u.name as author_name, u.avatar as author_avatar
       FROM comments c
       JOIN users u ON c.author_id = u.id
       WHERE c.target_id = ? AND c.target_type = 'moment' AND c.deleted_at IS NULL
       ORDER BY c.created_at ASC
       LIMIT ? OFFSET ?`
    )
      .bind(momentId, limit, offset)
      .all<CommentWithAuthor>(),
    c.env.DB.prepare(
      `SELECT COUNT(*) as total FROM comments 
       WHERE target_id = ? AND target_type = 'moment' AND deleted_at IS NULL`
    )
      .bind(momentId)
      .first<{ total: number }>(),
  ]);

  const total = countResult?.total || 0;

  // Build nested replies structure
  const commentMap = new Map<string, CommentWithAuthor & { replies: CommentWithAuthor[] }>();
  const rootComments: (CommentWithAuthor & { replies: CommentWithAuthor[] })[] = [];

  for (const comment of commentsResult.results) {
    const commentWithReplies = { ...comment, replies: [] };
    commentMap.set(comment.id, commentWithReplies);

    if (!comment.reply_to_id) {
      rootComments.push(commentWithReplies);
    }
  }

  // Link replies to parents
  for (const comment of commentsResult.results) {
    if (comment.reply_to_id) {
      const parent = commentMap.get(comment.reply_to_id);
      if (parent) {
        parent.replies.push(commentMap.get(comment.id)!);
      }
    }
  }

  return c.json(success(rootComments, paginate(page, limit, total)));
});

/**
 * GET /comments/world/:postId
 * Get comments for a world post
 */
comments.get('/world/:postId', authMiddleware, async (c) => {
  const postId = c.req.param('postId');
  const page = parseInt(c.req.query('page') || '1');
  const limit = Math.min(parseInt(c.req.query('limit') || '20'), 50);
  const offset = (page - 1) * limit;

  // Verify post exists
  const post = await c.env.DB.prepare(
    'SELECT id FROM world_posts WHERE id = ? AND deleted_at IS NULL'
  )
    .bind(postId)
    .first<{ id: string }>();

  if (!post) {
    return c.json(error(ErrorCodes.NOT_FOUND, 'Post not found'), 404);
  }

  const [commentsResult, countResult] = await Promise.all([
    c.env.DB.prepare(
      `SELECT c.*, u.name as author_name, u.avatar as author_avatar
       FROM comments c
       JOIN users u ON c.author_id = u.id
       WHERE c.target_id = ? AND c.target_type = 'world_post' AND c.deleted_at IS NULL
       ORDER BY c.created_at ASC
       LIMIT ? OFFSET ?`
    )
      .bind(postId, limit, offset)
      .all<CommentWithAuthor>(),
    c.env.DB.prepare(
      `SELECT COUNT(*) as total FROM comments 
       WHERE target_id = ? AND target_type = 'world_post' AND deleted_at IS NULL`
    )
      .bind(postId)
      .first<{ total: number }>(),
  ]);

  const total = countResult?.total || 0;

  // Anonymize for world posts (show first char only)
  const anonymizedComments = commentsResult.results.map((comment) => ({
    ...comment,
    author_name: comment.author_name?.charAt(0) + '***',
  }));

  return c.json(success(anonymizedComments, paginate(page, limit, total)));
});

/**
 * POST /comments/moment/:momentId
 * Add comment to a moment
 */
comments.post('/moment/:momentId', authMiddleware, async (c) => {
  const momentId = c.req.param('momentId');
  const userId = c.get('userId');
  const body = await c.req.json();

  // Validate input
  const result = createCommentSchema.safeParse(body);
  if (!result.success) {
    return c.json(
      error(ErrorCodes.VALIDATION_ERROR, result.error.errors[0].message),
      400
    );
  }

  const { content, replyToId } = result.data;

  // Verify user has access to the moment (is in the same circle)
  const moment = await c.env.DB.prepare(
    `SELECT m.circle_id FROM moments m
     JOIN circle_members cm ON m.circle_id = cm.circle_id
     WHERE m.id = ? AND cm.user_id = ? AND m.deleted_at IS NULL`
  )
    .bind(momentId, userId)
    .first<{ circle_id: string }>();

  if (!moment) {
    return c.json(error(ErrorCodes.NOT_FOUND, 'Moment not found or access denied'), 404);
  }

  // If replying, verify parent comment exists
  if (replyToId) {
    const parentComment = await c.env.DB.prepare(
      `SELECT id FROM comments 
       WHERE id = ? AND target_id = ? AND target_type = 'moment' AND deleted_at IS NULL`
    )
      .bind(replyToId, momentId)
      .first<{ id: string }>();

    if (!parentComment) {
      return c.json(error(ErrorCodes.NOT_FOUND, 'Parent comment not found'), 404);
    }
  }

  // Create comment
  const commentId = generateId('cmt');
  const now = new Date().toISOString();

  await c.env.DB.prepare(
    `INSERT INTO comments (id, target_id, target_type, author_id, content, reply_to_id, created_at)
     VALUES (?, ?, 'moment', ?, ?, ?, ?)`
  )
    .bind(commentId, momentId, userId, content, replyToId || null, now)
    .run();

  // Log for sync
  await c.env.DB.prepare(
    `INSERT INTO sync_log (circle_id, entity_type, entity_id, action, data, timestamp)
     VALUES (?, 'comment', ?, 'create', ?, ?)`
  )
    .bind(moment.circle_id, commentId, JSON.stringify({ momentId }), now)
    .run();

  // Get created comment with author info
  const comment = await c.env.DB.prepare(
    `SELECT c.*, u.name as author_name, u.avatar as author_avatar
     FROM comments c
     JOIN users u ON c.author_id = u.id
     WHERE c.id = ?`
  )
    .bind(commentId)
    .first<CommentWithAuthor>();

  return c.json(success(comment), 201);
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
  const result = createCommentSchema.safeParse(body);
  if (!result.success) {
    return c.json(
      error(ErrorCodes.VALIDATION_ERROR, result.error.errors[0].message),
      400
    );
  }

  const { content, replyToId } = result.data;

  // Verify post exists
  const post = await c.env.DB.prepare(
    'SELECT id FROM world_posts WHERE id = ? AND deleted_at IS NULL'
  )
    .bind(postId)
    .first<{ id: string }>();

  if (!post) {
    return c.json(error(ErrorCodes.NOT_FOUND, 'Post not found'), 404);
  }

  // If replying, verify parent comment exists
  if (replyToId) {
    const parentComment = await c.env.DB.prepare(
      `SELECT id FROM comments 
       WHERE id = ? AND target_id = ? AND target_type = 'world_post' AND deleted_at IS NULL`
    )
      .bind(replyToId, postId)
      .first<{ id: string }>();

    if (!parentComment) {
      return c.json(error(ErrorCodes.NOT_FOUND, 'Parent comment not found'), 404);
    }
  }

  // Create comment
  const commentId = generateId('cmt');
  const now = new Date().toISOString();

  await c.env.DB.prepare(
    `INSERT INTO comments (id, target_id, target_type, author_id, content, reply_to_id, created_at)
     VALUES (?, ?, 'world_post', ?, ?, ?, ?)`
  )
    .bind(commentId, postId, userId, content, replyToId || null, now)
    .run();

  // Get created comment with author info (anonymized)
  const comment = await c.env.DB.prepare(
    `SELECT c.*, u.name as author_name, u.avatar as author_avatar
     FROM comments c
     JOIN users u ON c.author_id = u.id
     WHERE c.id = ?`
  )
    .bind(commentId)
    .first<CommentWithAuthor>();

  // Anonymize
  if (comment) {
    comment.author_name = comment.author_name?.charAt(0) + '***';
  }

  return c.json(success(comment), 201);
});

/**
 * DELETE /comments/:id
 * Delete a comment (author only)
 */
comments.delete('/:id', authMiddleware, async (c) => {
  const commentId = c.req.param('id');
  const userId = c.get('userId');

  const comment = await c.env.DB.prepare(
    'SELECT * FROM comments WHERE id = ? AND deleted_at IS NULL'
  )
    .bind(commentId)
    .first<Comment>();

  if (!comment) {
    return c.json(error(ErrorCodes.NOT_FOUND, 'Comment not found'), 404);
  }

  if (comment.author_id !== userId) {
    return c.json(error(ErrorCodes.FORBIDDEN, 'Not your comment'), 403);
  }

  // Soft delete
  await c.env.DB.prepare(
    `UPDATE comments SET deleted_at = datetime('now') WHERE id = ?`
  )
    .bind(commentId)
    .run();

  // If it's a moment comment, log for sync
  if (comment.target_type === 'moment') {
    const moment = await c.env.DB.prepare(
      'SELECT circle_id FROM moments WHERE id = ?'
    )
      .bind(comment.target_id)
      .first<{ circle_id: string }>();

    if (moment) {
      await c.env.DB.prepare(
        `INSERT INTO sync_log (circle_id, entity_type, entity_id, action, timestamp)
         VALUES (?, 'comment', ?, 'delete', datetime('now'))`
      )
        .bind(moment.circle_id, commentId)
        .run();
    }
  }

  return c.json(success({ message: 'Comment deleted' }));
});

/**
 * POST /comments/:id/like
 * Like a comment
 */
comments.post('/:id/like', authMiddleware, async (c) => {
  const commentId = c.req.param('id');

  const comment = await c.env.DB.prepare(
    'SELECT id FROM comments WHERE id = ? AND deleted_at IS NULL'
  )
    .bind(commentId)
    .first<{ id: string }>();

  if (!comment) {
    return c.json(error(ErrorCodes.NOT_FOUND, 'Comment not found'), 404);
  }

  await c.env.DB.prepare(
    'UPDATE comments SET likes = likes + 1 WHERE id = ?'
  )
    .bind(commentId)
    .run();

  const updated = await c.env.DB.prepare(
    'SELECT likes FROM comments WHERE id = ?'
  )
    .bind(commentId)
    .first<{ likes: number }>();

  return c.json(success({ likes: updated?.likes || 0 }));
});

export { comments as commentsRoutes };

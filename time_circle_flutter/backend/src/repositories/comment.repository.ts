/**
 * Comment Repository
 * Handles all comment-related database operations for moments and world posts
 */

import { BaseRepository, type PaginationParams, type PaginatedResult } from './base.repository';
import { generateId } from '../utils/id';

export type CommentTargetType = 'moment' | 'world_post';

export interface CommentRow {
  id: string;
  target_id: string;
  target_type: CommentTargetType;
  author_id: string;
  content: string;
  likes: number;
  reply_to_id: string | null;
  created_at: string;
  deleted_at: string | null;
  // Joined fields
  author_name?: string;
  author_avatar?: string | null;
  reply_to_name?: string | null;
}

export interface CommentWithReplies extends CommentRow {
  replies: CommentWithReplies[];
}

export interface CreateCommentInput {
  target_id: string;
  target_type: CommentTargetType;
  author_id: string;
  content: string;
  reply_to_id?: string;
}

export class CommentRepository extends BaseRepository {
  /**
   * Find comment by ID
   */
  async findById(id: string): Promise<CommentRow | null> {
    return this.queryOne<CommentRow>(
      `SELECT c.*, u.name as author_name, u.avatar as author_avatar
       FROM comments c
       JOIN users u ON c.author_id = u.id
       WHERE c.id = ? AND c.deleted_at IS NULL`,
      id
    );
  }

  /**
   * Find comment by ID (basic, no join)
   */
  async findByIdBasic(id: string): Promise<CommentRow | null> {
    return this.queryOne<CommentRow>(
      'SELECT * FROM comments WHERE id = ? AND deleted_at IS NULL',
      id
    );
  }

  /**
   * Get comments for a moment with pagination
   */
  async getForMoment(
    momentId: string,
    pagination: PaginationParams
  ): Promise<PaginatedResult<CommentRow>> {
    const { limit, offset } = this.buildPagination(pagination);

    // Get total count
    const total = await this.count(
      `SELECT COUNT(*) as count FROM comments 
       WHERE target_id = ? AND target_type = 'moment' AND deleted_at IS NULL`,
      momentId
    );

    // Get comments
    const comments = await this.query<CommentRow>(
      `SELECT c.*, u.name as author_name, u.avatar as author_avatar
       FROM comments c
       JOIN users u ON c.author_id = u.id
       WHERE c.target_id = ? AND c.target_type = 'moment' AND c.deleted_at IS NULL
       ORDER BY c.created_at ASC
       LIMIT ? OFFSET ?`,
      momentId,
      limit,
      offset
    );

    return this.buildPaginatedResult(comments, total, pagination);
  }

  /**
   * Get comments for a world post with pagination
   */
  async getForWorldPost(
    postId: string,
    pagination: PaginationParams
  ): Promise<PaginatedResult<CommentRow>> {
    const { limit, offset } = this.buildPagination(pagination);

    // Get total count
    const total = await this.count(
      `SELECT COUNT(*) as count FROM comments 
       WHERE target_id = ? AND target_type = 'world_post' AND deleted_at IS NULL`,
      postId
    );

    // Get comments
    const comments = await this.query<CommentRow>(
      `SELECT c.*, u.name as author_name, u.avatar as author_avatar
       FROM comments c
       JOIN users u ON c.author_id = u.id
       WHERE c.target_id = ? AND c.target_type = 'world_post' AND c.deleted_at IS NULL
       ORDER BY c.created_at ASC
       LIMIT ? OFFSET ?`,
      postId,
      limit,
      offset
    );

    return this.buildPaginatedResult(comments, total, pagination);
  }

  /**
   * Get all comments for a target (no pagination, for building tree)
   */
  async getAllForTarget(
    targetId: string,
    targetType: CommentTargetType
  ): Promise<CommentRow[]> {
    return this.query<CommentRow>(
      `SELECT c.*, u.name as author_name, u.avatar as author_avatar
       FROM comments c
       JOIN users u ON c.author_id = u.id
       WHERE c.target_id = ? AND c.target_type = ? AND c.deleted_at IS NULL
       ORDER BY c.created_at ASC`,
      targetId,
      targetType
    );
  }

  /**
   * Get comment count for a target
   */
  async getCount(targetId: string, targetType: CommentTargetType): Promise<number> {
    return this.count(
      `SELECT COUNT(*) as count FROM comments 
       WHERE target_id = ? AND target_type = ? AND deleted_at IS NULL`,
      targetId,
      targetType
    );
  }

  /**
   * Create a new comment
   */
  async create(input: CreateCommentInput): Promise<CommentRow> {
    const id = generateId('cmt');
    const now = new Date().toISOString();

    await this.execute(
      `INSERT INTO comments (id, target_id, target_type, author_id, content, reply_to_id, created_at)
       VALUES (?, ?, ?, ?, ?, ?, ?)`,
      id,
      input.target_id,
      input.target_type,
      input.author_id,
      input.content,
      input.reply_to_id || null,
      now
    );

    return (await this.findById(id))!;
  }

  /**
   * Create comment for a moment (with sync logging)
   */
  async createForMoment(
    momentId: string,
    authorId: string,
    content: string,
    replyToId?: string,
    circleId?: string
  ): Promise<CommentRow> {
    const comment = await this.create({
      target_id: momentId,
      target_type: 'moment',
      author_id: authorId,
      content,
      reply_to_id: replyToId,
    });

    // Log for sync if circle ID provided
    if (circleId) {
      await this.logSyncEvent(circleId, 'comment', comment.id, 'create', { momentId });
    }

    return comment;
  }

  /**
   * Create comment for a world post
   */
  async createForWorldPost(
    postId: string,
    authorId: string,
    content: string,
    replyToId?: string
  ): Promise<CommentRow> {
    return this.create({
      target_id: postId,
      target_type: 'world_post',
      author_id: authorId,
      content,
      reply_to_id: replyToId,
    });
  }

  /**
   * Soft delete a comment
   */
  async delete(id: string): Promise<{ success: boolean; circleId?: string }> {
    const comment = await this.findByIdBasic(id);
    if (!comment) return { success: false };

    await this.execute(
      `UPDATE comments SET deleted_at = datetime('now') WHERE id = ?`,
      id
    );

    // If it's a moment comment, get circle ID for sync logging
    let circleId: string | undefined;
    if (comment.target_type === 'moment') {
      const moment = await this.queryOne<{ circle_id: string }>(
        'SELECT circle_id FROM moments WHERE id = ?',
        comment.target_id
      );
      
      if (moment) {
        circleId = moment.circle_id;
        await this.logSyncEvent(circleId, 'comment', id, 'delete');
      }
    }

    return { success: true, circleId };
  }

  /**
   * Like a comment
   */
  async like(id: string): Promise<number> {
    const comment = await this.findByIdBasic(id);
    if (!comment) throw new Error('Comment not found');

    await this.execute(
      'UPDATE comments SET likes = likes + 1 WHERE id = ?',
      id
    );

    const updated = await this.queryOne<{ likes: number }>(
      'SELECT likes FROM comments WHERE id = ?',
      id
    );

    return updated?.likes || 0;
  }

  /**
   * Check if user is author of comment
   */
  async isAuthor(commentId: string, userId: string): Promise<boolean> {
    const comment = await this.findByIdBasic(commentId);
    return comment?.author_id === userId;
  }

  /**
   * Check if parent comment exists for reply
   */
  async parentExists(
    parentId: string,
    targetId: string,
    targetType: CommentTargetType
  ): Promise<boolean> {
    const parent = await this.queryOne<{ id: string }>(
      `SELECT id FROM comments 
       WHERE id = ? AND target_id = ? AND target_type = ? AND deleted_at IS NULL`,
      parentId,
      targetId,
      targetType
    );
    return parent !== null;
  }

  /**
   * Build nested comment tree from flat list
   */
  buildTree(comments: CommentRow[]): CommentWithReplies[] {
    const commentMap = new Map<string, CommentWithReplies>();
    const rootComments: CommentWithReplies[] = [];

    // First pass: create map with empty replies array
    for (const comment of comments) {
      commentMap.set(comment.id, { ...comment, replies: [] });
    }

    // Second pass: build tree structure
    for (const comment of comments) {
      const commentWithReplies = commentMap.get(comment.id)!;

      if (!comment.reply_to_id) {
        rootComments.push(commentWithReplies);
      } else {
        const parent = commentMap.get(comment.reply_to_id);
        if (parent) {
          parent.replies.push(commentWithReplies);
        } else {
          // Parent not in current page, treat as root
          rootComments.push(commentWithReplies);
        }
      }
    }

    return rootComments;
  }

  /**
   * Log sync event for offline sync
   */
  private async logSyncEvent(
    circleId: string,
    entityType: string,
    entityId: string,
    action: string,
    data?: Record<string, unknown>
  ): Promise<void> {
    const now = new Date().toISOString();
    await this.execute(
      `INSERT INTO sync_log (circle_id, entity_type, entity_id, action, data, timestamp)
       VALUES (?, ?, ?, ?, ?, ?)`,
      circleId,
      entityType,
      entityId,
      action,
      data ? JSON.stringify(data) : null,
      now
    );
  }

  /**
   * Transform comment for response
   */
  toResponse(row: CommentRow, anonymize: boolean = false): Record<string, unknown> {
    return {
      id: row.id,
      target_id: row.target_id,
      target_type: row.target_type,
      author_id: row.author_id,
      content: row.content,
      likes: row.likes,
      reply_to_id: row.reply_to_id,
      created_at: row.created_at,
      author: {
        id: row.author_id,
        name: anonymize && row.author_name
          ? row.author_name.charAt(0) + '***'
          : row.author_name,
        avatar: row.author_avatar,
      },
      reply_to_name: row.reply_to_name,
    };
  }

  /**
   * Process comments for list response
   */
  processForList(comments: CommentRow[], anonymize: boolean = false): Record<string, unknown>[] {
    return comments.map((comment) => this.toResponse(comment, anonymize));
  }

  /**
   * Process comments as tree for response
   */
  processAsTree(comments: CommentRow[], anonymize: boolean = false): Record<string, unknown>[] {
    const tree = this.buildTree(comments);
    
    const transformWithReplies = (comment: CommentWithReplies): Record<string, unknown> => ({
      ...this.toResponse(comment, anonymize),
      replies: comment.replies.map(transformWithReplies),
    });

    return tree.map(transformWithReplies);
  }
}

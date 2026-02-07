/**
 * World Repository
 * Handles all world post and channel related database operations
 */

import { BaseRepository, type PaginationParams, type PaginatedResult } from './base.repository';
import { generateId } from '../utils/id';

export interface WorldPostRow {
  id: string;
  author_id: string;
  moment_id: string | null;
  content: string;
  tag: string;
  resonance_count: number;
  bg_gradient: string;
  created_at: string;
  deleted_at: string | null;
  // Joined fields
  author_name?: string;
  author_avatar?: string | null;
  has_resonated?: number;
}

export interface WorldChannelRow {
  id: string;
  name: string;
  description: string | null;
  post_count: number;
}

export interface CreateWorldPostInput {
  author_id: string;
  content: string;
  tag: string;
  bg_gradient: string;
  moment_id?: string;
}

export interface WorldPostFilter {
  tag?: string;
}

// Background gradient presets
export const BG_GRADIENTS = [
  'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
  'linear-gradient(135deg, #f093fb 0%, #f5576c 100%)',
  'linear-gradient(135deg, #4facfe 0%, #00f2fe 100%)',
  'linear-gradient(135deg, #43e97b 0%, #38f9d7 100%)',
  'linear-gradient(135deg, #fa709a 0%, #fee140 100%)',
  'linear-gradient(135deg, #a8edea 0%, #fed6e3 100%)',
  'linear-gradient(135deg, #d299c2 0%, #fef9d7 100%)',
  'linear-gradient(135deg, #89f7fe 0%, #66a6ff 100%)',
];

export class WorldRepository extends BaseRepository {
  // ===== Channel Operations =====

  /**
   * Get all channels
   */
  async getChannels(): Promise<WorldChannelRow[]> {
    return this.query<WorldChannelRow>(
      'SELECT * FROM world_channels ORDER BY post_count DESC'
    );
  }

  /**
   * Get channel by ID
   */
  async getChannel(id: string): Promise<WorldChannelRow | null> {
    return this.queryOne<WorldChannelRow>(
      'SELECT * FROM world_channels WHERE id = ?',
      id
    );
  }

  /**
   * Create or get channel (upsert for post count)
   * First tries to find existing channel by name, then updates or creates
   */
  async ensureChannel(tagName: string): Promise<void> {
    // First, try to find existing channel by name
    const existing = await this.queryOne<WorldChannelRow>(
      'SELECT * FROM world_channels WHERE name = ?',
      tagName
    );

    if (existing) {
      // Update post count for existing channel
      await this.execute(
        'UPDATE world_channels SET post_count = post_count + 1 WHERE id = ?',
        existing.id
      );
    } else {
      // Create new channel with tag name as both id and name
      const channelId = `ch_${Date.now()}`;
      await this.execute(
        `INSERT INTO world_channels (id, name, description, post_count)
         VALUES (?, ?, ?, 1)`,
        channelId,
        tagName,
        `Posts about ${tagName}`
      );
    }
  }

  /**
   * Decrement channel post count by name
   */
  async decrementChannelCount(tagName: string): Promise<void> {
    await this.execute(
      `UPDATE world_channels SET post_count = MAX(0, post_count - 1) WHERE name = ?`,
      tagName
    );
  }

  // ===== Post Operations =====

  /**
   * Find post by ID
   */
  async findPostById(id: string): Promise<WorldPostRow | null> {
    return this.queryOne<WorldPostRow>(
      'SELECT * FROM world_posts WHERE id = ? AND deleted_at IS NULL',
      id
    );
  }

  /**
   * Find post by ID with author info
   */
  async findPostByIdWithAuthor(id: string, userId?: string): Promise<WorldPostRow | null> {
    const hasResonatedSelect = userId
      ? ', (SELECT 1 FROM resonances WHERE user_id = ? AND post_id = wp.id) as has_resonated'
      : '';
    const params: unknown[] = userId ? [userId, id] : [id];

    return this.queryOne<WorldPostRow>(
      `SELECT wp.*, u.name as author_name, u.avatar as author_avatar
              ${hasResonatedSelect}
       FROM world_posts wp
       LEFT JOIN users u ON wp.author_id = u.id
       WHERE wp.id = ? AND wp.deleted_at IS NULL`,
      ...params
    );
  }

  /**
   * Get posts with optional tag filter and pagination
   */
  async getPosts(
    pagination: PaginationParams,
    filter?: WorldPostFilter,
    userId?: string
  ): Promise<PaginatedResult<WorldPostRow>> {
    const { limit, offset } = this.buildPagination(pagination);
    const conditions: string[] = ['wp.deleted_at IS NULL'];
    const params: unknown[] = [];
    const countParams: unknown[] = [];

    // Add user ID for has_resonated check
    if (userId) {
      params.push(userId);
    }

    if (filter?.tag) {
      conditions.push('wp.tag = ?');
      params.push(filter.tag);
      countParams.push(filter.tag);
    }

    const whereClause = `WHERE ${conditions.join(' AND ')}`;
    const hasResonatedSelect = userId
      ? ', (SELECT 1 FROM resonances WHERE user_id = ? AND post_id = wp.id) as has_resonated'
      : '';

    // Get total count
    const total = await this.count(
      `SELECT COUNT(*) as count FROM world_posts wp ${whereClause}`,
      ...countParams
    );

    // Get posts
    params.push(limit, offset);
    const posts = await this.query<WorldPostRow>(
      `SELECT wp.*, u.name as author_name, u.avatar as author_avatar
              ${hasResonatedSelect}
       FROM world_posts wp
       LEFT JOIN users u ON wp.author_id = u.id
       ${whereClause}
       ORDER BY wp.created_at DESC
       LIMIT ? OFFSET ?`,
      ...params
    );

    return this.buildPaginatedResult(posts, total, pagination);
  }

  /**
   * Create a new world post
   */
  async createPost(input: CreateWorldPostInput): Promise<WorldPostRow> {
    const id = generateId('wp');
    const now = new Date().toISOString();

    await this.execute(
      `INSERT INTO world_posts (id, author_id, moment_id, content, tag, bg_gradient, created_at)
       VALUES (?, ?, ?, ?, ?, ?, ?)`,
      id,
      input.author_id,
      input.moment_id || null,
      input.content,
      input.tag,
      input.bg_gradient,
      now
    );

    // Update channel post count
    await this.ensureChannel(input.tag);

    // If linked to a moment, update the moment
    if (input.moment_id) {
      await this.execute(
        `UPDATE moments SET is_shared_to_world = 1, world_topic = ? WHERE id = ?`,
        input.tag,
        input.moment_id
      );
    }

    return (await this.findPostById(id))!;
  }

  /**
   * Soft delete a world post
   */
  async deletePost(id: string): Promise<boolean> {
    const post = await this.findPostById(id);
    if (!post) return false;

    // Soft delete
    await this.execute(
      `UPDATE world_posts SET deleted_at = datetime('now') WHERE id = ?`,
      id
    );

    // Update channel post count
    await this.decrementChannelCount(post.tag);

    // If linked to a moment, update the moment
    if (post.moment_id) {
      await this.execute(
        `UPDATE moments SET is_shared_to_world = 0, world_topic = NULL WHERE id = ?`,
        post.moment_id
      );
    }

    return true;
  }

  /**
   * Check if user is author of post
   */
  async isAuthor(postId: string, userId: string): Promise<boolean> {
    const post = await this.findPostById(postId);
    return post?.author_id === userId;
  }

  // ===== Resonance (Like) Operations =====

  /**
   * Check if user has resonated with a post
   */
  async hasResonated(userId: string, postId: string): Promise<boolean> {
    const result = await this.queryOne<{ id: number }>(
      'SELECT 1 as id FROM resonances WHERE user_id = ? AND post_id = ?',
      userId,
      postId
    );
    return result !== null;
  }

  /**
   * Add resonance to a post
   */
  async addResonance(userId: string, postId: string): Promise<number> {
    // Check if post exists
    const post = await this.findPostById(postId);
    if (!post) throw new Error('Post not found');

    // Check if already resonated
    if (await this.hasResonated(userId, postId)) {
      throw new Error('Already resonated');
    }

    // Add resonance
    await this.execute(
      'INSERT INTO resonances (user_id, post_id) VALUES (?, ?)',
      userId,
      postId
    );

    // Update resonance count
    await this.execute(
      `UPDATE world_posts SET resonance_count = resonance_count + 1 WHERE id = ?`,
      postId
    );

    // Get updated count
    const updated = await this.queryOne<{ resonance_count: number }>(
      'SELECT resonance_count FROM world_posts WHERE id = ?',
      postId
    );

    return updated?.resonance_count || 0;
  }

  /**
   * Remove resonance from a post
   */
  async removeResonance(userId: string, postId: string): Promise<number> {
    // Check if resonance exists
    if (!(await this.hasResonated(userId, postId))) {
      throw new Error('Resonance not found');
    }

    // Remove resonance
    await this.execute(
      'DELETE FROM resonances WHERE user_id = ? AND post_id = ?',
      userId,
      postId
    );

    // Update resonance count
    await this.execute(
      `UPDATE world_posts SET resonance_count = MAX(0, resonance_count - 1) WHERE id = ?`,
      postId
    );

    // Get updated count
    const updated = await this.queryOne<{ resonance_count: number }>(
      'SELECT resonance_count FROM world_posts WHERE id = ?',
      postId
    );

    return updated?.resonance_count || 0;
  }

  /**
   * Get available background gradients
   */
  getGradients(): string[] {
    return BG_GRADIENTS;
  }

  /**
   * Transform post for response (with anonymization)
   */
  toResponse(row: WorldPostRow): Record<string, unknown> {
    return {
      id: row.id,
      author_id: row.author_id,
      moment_id: row.moment_id,
      content: row.content,
      tag: row.tag,
      resonance_count: row.resonance_count,
      bg_gradient: row.bg_gradient,
      created_at: row.created_at,
      // Anonymize author name for world posts
      author_name: row.author_name ? row.author_name.charAt(0) + '***' : null,
      author_avatar: row.author_avatar,
      has_resonated: Boolean(row.has_resonated),
    };
  }

  /**
   * Process posts for list response
   */
  processForList(posts: WorldPostRow[]): Record<string, unknown>[] {
    return posts.map((post) => this.toResponse(post));
  }
}

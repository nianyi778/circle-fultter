/**
 * Moment Repository
 * Handles all moment-related database operations
 */

import { BaseRepository, type PaginationParams, type PaginatedResult } from './base.repository';
import { generateId } from '../utils/id';
import type { Moment, ContextTag, MediaType } from '../schemas';

export interface MomentRow {
  id: string;
  circle_id: string;
  author_id: string;
  content: string;
  media_type: string;
  media_urls: string | null;
  timestamp: string;
  context_tags: string | null;
  location: string | null;
  is_favorite: number;
  future_message: string | null;
  is_shared_to_world: number;
  world_topic: string | null;
  created_at: string;
  updated_at: string;
  deleted_at: string | null;
  // Joined fields
  author_name?: string;
  author_avatar?: string;
  comment_count?: number;
}

export interface CreateMomentInput {
  circle_id: string;
  author_id: string;
  content: string;
  media_type: MediaType;
  media_urls?: string[];
  timestamp?: string;
  context_tags?: ContextTag[];
  location?: string;
  future_message?: string;
}

export interface UpdateMomentInput {
  content?: string;
  media_urls?: string[];
  context_tags?: ContextTag[];
  location?: string | null;
  future_message?: string | null;
}

export interface MomentFilter {
  author_id?: string;
  media_type?: MediaType;
  favorite?: boolean;
  start_date?: string;
  end_date?: string;
  year?: number;
}

export class MomentRepository extends BaseRepository {
  /**
   * Find moment by ID with author info
   */
  async findById(id: string): Promise<MomentRow | null> {
    return this.queryOne<MomentRow>(
      `SELECT m.*, u.name as author_name, u.avatar as author_avatar,
              (SELECT COUNT(*) FROM comments WHERE target_id = m.id AND target_type = 'moment' AND deleted_at IS NULL) as comment_count
       FROM moments m
       JOIN users u ON m.author_id = u.id
       WHERE m.id = ? AND m.deleted_at IS NULL`,
      id
    );
  }

  /**
   * Find all moments in a circle with pagination and filters
   */
  async findByCircle(
    circleId: string,
    pagination: PaginationParams,
    filter?: MomentFilter
  ): Promise<PaginatedResult<MomentRow>> {
    const { limit, offset } = this.buildPagination(pagination);

    // Build WHERE conditions
    const conditions: string[] = ['m.circle_id = ?', 'm.deleted_at IS NULL'];
    const params: unknown[] = [circleId];

    if (filter?.author_id) {
      conditions.push('m.author_id = ?');
      params.push(filter.author_id);
    }

    if (filter?.media_type) {
      conditions.push('m.media_type = ?');
      params.push(filter.media_type);
    }

    if (filter?.favorite) {
      conditions.push('m.is_favorite = 1');
    }

    if (filter?.start_date) {
      conditions.push('m.timestamp >= ?');
      params.push(filter.start_date);
    }

    if (filter?.end_date) {
      conditions.push('m.timestamp <= ?');
      params.push(filter.end_date);
    }

    if (filter?.year) {
      conditions.push("strftime('%Y', m.timestamp) = ?");
      params.push(String(filter.year));
    }

    const whereClause = `WHERE ${conditions.join(' AND ')}`;

    // Get total count
    const total = await this.count(
      `SELECT COUNT(*) as count FROM moments m ${whereClause}`,
      ...params
    );

    // Get moments
    const moments = await this.query<MomentRow>(
      `SELECT m.*, u.name as author_name, u.avatar as author_avatar,
              (SELECT COUNT(*) FROM comments WHERE target_id = m.id AND target_type = 'moment' AND deleted_at IS NULL) as comment_count
       FROM moments m
       JOIN users u ON m.author_id = u.id
       ${whereClause}
       ORDER BY m.timestamp DESC
       LIMIT ? OFFSET ?`,
      ...params,
      limit,
      offset
    );

    return this.buildPaginatedResult(moments, total, pagination);
  }

  /**
   * Find moments from same day in previous years (memory feature)
   */
  async findLastYearToday(circleId: string, limit: number = 10): Promise<MomentRow[]> {
    const today = new Date();
    const month = String(today.getMonth() + 1).padStart(2, '0');
    const day = String(today.getDate()).padStart(2, '0');
    const currentYear = today.getFullYear();

    return this.query<MomentRow>(
      `SELECT m.*, u.name as author_name, u.avatar as author_avatar
       FROM moments m
       JOIN users u ON m.author_id = u.id
       WHERE m.circle_id = ?
         AND m.deleted_at IS NULL
         AND strftime('%m-%d', m.timestamp) = ?
         AND strftime('%Y', m.timestamp) < ?
       ORDER BY m.timestamp DESC
       LIMIT ?`,
      circleId,
      `${month}-${day}`,
      String(currentYear),
      limit
    );
  }

  /**
   * Find random moments for memory roaming
   */
  async findRandom(circleId: string, count: number = 5): Promise<MomentRow[]> {
    return this.query<MomentRow>(
      `SELECT m.*, u.name as author_name, u.avatar as author_avatar
       FROM moments m
       JOIN users u ON m.author_id = u.id
       WHERE m.circle_id = ? AND m.deleted_at IS NULL
       ORDER BY RANDOM()
       LIMIT ?`,
      circleId,
      count
    );
  }

  /**
   * Get available years for filtering
   */
  async getAvailableYears(circleId: string): Promise<number[]> {
    const rows = await this.query<{ year: string }>(
      `SELECT DISTINCT strftime('%Y', timestamp) as year
       FROM moments
       WHERE circle_id = ? AND deleted_at IS NULL
       ORDER BY year DESC`,
      circleId
    );
    return rows.map((r) => parseInt(r.year, 10));
  }

  /**
   * Get moment count by author
   */
  async getCountByAuthor(
    circleId: string
  ): Promise<Array<{ author_id: string; author_name: string; count: number }>> {
    return this.query(
      `SELECT m.author_id, u.name as author_name, COUNT(*) as count
       FROM moments m
       JOIN users u ON m.author_id = u.id
       WHERE m.circle_id = ? AND m.deleted_at IS NULL
       GROUP BY m.author_id
       ORDER BY count DESC`,
      circleId
    );
  }

  /**
   * Create a new moment
   */
  async create(input: CreateMomentInput): Promise<MomentRow> {
    const id = generateId('mom');
    const now = new Date().toISOString();
    const timestamp = input.timestamp || now;

    await this.execute(
      `INSERT INTO moments (
        id, circle_id, author_id, content, media_type, media_urls,
        timestamp, context_tags, location, future_message,
        created_at, updated_at
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      id,
      input.circle_id,
      input.author_id,
      input.content,
      input.media_type,
      JSON.stringify(input.media_urls ?? []),
      timestamp,
      input.context_tags ? JSON.stringify(input.context_tags) : null,
      input.location ?? null,
      input.future_message ?? null,
      now,
      now
    );

    // Log sync event
    await this.logSyncEvent(input.circle_id, 'moment', id, 'create');

    return (await this.findById(id))!;
  }

  /**
   * Update a moment
   */
  async update(id: string, input: UpdateMomentInput): Promise<MomentRow | null> {
    const moment = await this.findById(id);
    if (!moment) return null;

    const updates: string[] = [];
    const values: unknown[] = [];

    if (input.content !== undefined) {
      updates.push('content = ?');
      values.push(input.content);
    }

    if (input.media_urls !== undefined) {
      updates.push('media_urls = ?');
      values.push(JSON.stringify(input.media_urls));
    }

    if (input.context_tags !== undefined) {
      updates.push('context_tags = ?');
      values.push(JSON.stringify(input.context_tags));
    }

    if (input.location !== undefined) {
      updates.push('location = ?');
      values.push(input.location);
    }

    if (input.future_message !== undefined) {
      updates.push('future_message = ?');
      values.push(input.future_message);
    }

    if (updates.length === 0) return moment;

    updates.push("updated_at = datetime('now')");
    values.push(id);

    await this.execute(
      `UPDATE moments SET ${updates.join(', ')} WHERE id = ?`,
      ...values
    );

    // Log sync event
    await this.logSyncEvent(moment.circle_id, 'moment', id, 'update');

    return this.findById(id);
  }

  /**
   * Soft delete a moment
   */
  async delete(id: string): Promise<boolean> {
    const moment = await this.findById(id);
    if (!moment) return false;

    await this.execute(
      `UPDATE moments SET deleted_at = datetime('now'), updated_at = datetime('now') WHERE id = ?`,
      id
    );

    // Also soft delete any linked world post
    await this.execute(
      `UPDATE world_posts SET deleted_at = datetime('now') WHERE moment_id = ?`,
      id
    );

    // Log sync event
    await this.logSyncEvent(moment.circle_id, 'moment', id, 'delete');

    return true;
  }

  /**
   * Toggle favorite status
   */
  async toggleFavorite(id: string): Promise<boolean | null> {
    const moment = await this.queryOne<{ circle_id: string; is_favorite: number }>(
      'SELECT circle_id, is_favorite FROM moments WHERE id = ? AND deleted_at IS NULL',
      id
    );

    if (!moment) return null;

    const newValue = moment.is_favorite ? 0 : 1;

    await this.execute(
      `UPDATE moments SET is_favorite = ?, updated_at = datetime('now') WHERE id = ?`,
      newValue,
      id
    );

    // Log sync event
    await this.logSyncEvent(moment.circle_id, 'moment', id, 'update');

    return newValue === 1;
  }

  /**
   * Share moment to world
   */
  async shareToWorld(
    id: string,
    tag: string,
    bgGradient: string = 'default'
  ): Promise<string | null> {
    const moment = await this.findById(id);
    if (!moment) return null;

    const worldPostId = generateId('wld');
    const now = new Date().toISOString();

    await this.batch([
      // Create world post
      {
        sql: `INSERT INTO world_posts (id, author_id, moment_id, content, tag, bg_gradient, created_at)
              VALUES (?, ?, ?, ?, ?, ?, ?)`,
        params: [worldPostId, moment.author_id, id, moment.content, tag, bgGradient, now],
      },
      // Update moment
      {
        sql: `UPDATE moments SET is_shared_to_world = 1, world_topic = ?, updated_at = datetime('now') WHERE id = ?`,
        params: [tag, id],
      },
      // Update channel post count
      {
        sql: `UPDATE world_channels SET post_count = post_count + 1 WHERE id = ?`,
        params: [tag],
      },
    ]);

    return worldPostId;
  }

  /**
   * Withdraw moment from world
   */
  async withdrawFromWorld(id: string): Promise<boolean> {
    const moment = await this.queryOne<{ is_shared_to_world: number }>(
      'SELECT is_shared_to_world FROM moments WHERE id = ? AND deleted_at IS NULL',
      id
    );

    if (!moment || !moment.is_shared_to_world) return false;

    const worldPost = await this.queryOne<{ id: string; tag: string }>(
      'SELECT id, tag FROM world_posts WHERE moment_id = ? AND deleted_at IS NULL',
      id
    );

    if (worldPost) {
      await this.batch([
        // Soft delete world post
        {
          sql: `UPDATE world_posts SET deleted_at = datetime('now') WHERE id = ?`,
          params: [worldPost.id],
        },
        // Update channel post count
        {
          sql: `UPDATE world_channels SET post_count = MAX(0, post_count - 1) WHERE id = ?`,
          params: [worldPost.tag],
        },
      ]);
    }

    // Update moment
    await this.execute(
      `UPDATE moments SET is_shared_to_world = 0, world_topic = NULL, updated_at = datetime('now') WHERE id = ?`,
      id
    );

    return true;
  }

  /**
   * Check if user is author of moment
   */
  async isAuthor(momentId: string, userId: string): Promise<boolean> {
    const result = await this.queryOne<{ author_id: string }>(
      'SELECT author_id FROM moments WHERE id = ? AND deleted_at IS NULL',
      momentId
    );
    return result?.author_id === userId;
  }

  /**
   * Get circle ID for a moment
   */
  async getCircleId(momentId: string): Promise<string | null> {
    const result = await this.queryOne<{ circle_id: string }>(
      'SELECT circle_id FROM moments WHERE id = ?',
      momentId
    );
    return result?.circle_id ?? null;
  }

  /**
   * Log sync event for offline sync
   */
  private async logSyncEvent(
    circleId: string,
    entityType: string,
    entityId: string,
    action: string
  ): Promise<void> {
    await this.execute(
      `INSERT INTO sync_log (circle_id, entity_type, entity_id, action)
       VALUES (?, ?, ?, ?)`,
      circleId,
      entityType,
      entityId,
      action
    );
  }

  /**
   * Transform database row to API response format
   */
  toResponse(row: MomentRow): Record<string, unknown> {
    return {
      id: row.id,
      circle_id: row.circle_id,
      author_id: row.author_id,
      content: row.content,
      media_type: row.media_type,
      media_urls: this.parseJson<string[]>(row.media_urls, []),
      timestamp: row.timestamp,
      context_tags: this.parseJson<ContextTag[]>(row.context_tags, []),
      location: row.location,
      is_favorite: row.is_favorite === 1,
      future_message: row.future_message,
      is_shared_to_world: row.is_shared_to_world === 1,
      world_topic: row.world_topic,
      created_at: row.created_at,
      updated_at: row.updated_at,
      author: row.author_name
        ? {
            id: row.author_id,
            name: row.author_name,
            avatar: row.author_avatar,
          }
        : undefined,
      comment_count: row.comment_count ?? 0,
    };
  }
}

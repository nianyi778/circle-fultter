/**
 * Letter Repository
 * Handles all letter-related database operations
 */

import { BaseRepository, type PaginationParams, type PaginatedResult } from './base.repository';
import { generateId } from '../utils/id';
import type { LetterStatus, LetterType } from '../schemas';

export interface LetterRow {
  id: string;
  circle_id: string;
  author_id: string;
  title: string;
  preview: string;
  content: string | null;
  status: 'draft' | 'sealed' | 'unlocked';
  type: 'annual' | 'milestone' | 'free';
  recipient: string;
  unlock_date: string | null;
  created_at: string;
  sealed_at: string | null;
  updated_at: string;
  deleted_at: string | null;
  // Joined fields
  author_name?: string;
  author_avatar?: string;
}

export interface CreateLetterInput {
  circle_id: string;
  author_id: string;
  title: string;
  content?: string;
  type: 'annual' | 'milestone' | 'free';
  recipient: string;
}

export interface UpdateLetterInput {
  title?: string;
  content?: string | null;
  recipient?: string;
}

export interface LetterFilter {
  status?: 'draft' | 'sealed' | 'unlocked';
  type?: 'annual' | 'milestone' | 'free';
  author_id?: string;
}

export class LetterRepository extends BaseRepository {
  /**
   * Find letter by ID with author info
   */
  async findById(id: string): Promise<LetterRow | null> {
    return this.queryOne<LetterRow>(
      `SELECT l.*, u.name as author_name, u.avatar as author_avatar
       FROM letters l
       JOIN users u ON l.author_id = u.id
       WHERE l.id = ? AND l.deleted_at IS NULL`,
      id
    );
  }

  /**
   * Find letter by ID (basic, no join)
   */
  async findByIdBasic(id: string): Promise<LetterRow | null> {
    return this.queryOne<LetterRow>(
      'SELECT * FROM letters WHERE id = ? AND deleted_at IS NULL',
      id
    );
  }

  /**
   * Find letters by circle with filters
   */
  async findByCircle(
    circleId: string,
    filter?: LetterFilter
  ): Promise<LetterRow[]> {
    const conditions: string[] = ['l.circle_id = ?', 'l.deleted_at IS NULL'];
    const params: unknown[] = [circleId];

    if (filter?.status) {
      conditions.push('l.status = ?');
      params.push(filter.status);
    }

    if (filter?.type) {
      conditions.push('l.type = ?');
      params.push(filter.type);
    }

    if (filter?.author_id) {
      conditions.push('l.author_id = ?');
      params.push(filter.author_id);
    }

    const whereClause = `WHERE ${conditions.join(' AND ')}`;

    return this.query<LetterRow>(
      `SELECT l.*, u.name as author_name, u.avatar as author_avatar
       FROM letters l
       JOIN users u ON l.author_id = u.id
       ${whereClause}
       ORDER BY l.created_at DESC`,
      ...params
    );
  }

  /**
   * Find letters by circle with pagination
   */
  async findByCirclePaginated(
    circleId: string,
    pagination: PaginationParams,
    filter?: LetterFilter
  ): Promise<PaginatedResult<LetterRow>> {
    const { limit, offset } = this.buildPagination(pagination);
    const conditions: string[] = ['l.circle_id = ?', 'l.deleted_at IS NULL'];
    const params: unknown[] = [circleId];

    if (filter?.status) {
      conditions.push('l.status = ?');
      params.push(filter.status);
    }

    if (filter?.type) {
      conditions.push('l.type = ?');
      params.push(filter.type);
    }

    if (filter?.author_id) {
      conditions.push('l.author_id = ?');
      params.push(filter.author_id);
    }

    const whereClause = `WHERE ${conditions.join(' AND ')}`;

    // Get total count
    const total = await this.count(
      `SELECT COUNT(*) as count FROM letters l ${whereClause}`,
      ...params
    );

    // Get letters
    const letters = await this.query<LetterRow>(
      `SELECT l.*, u.name as author_name, u.avatar as author_avatar
       FROM letters l
       JOIN users u ON l.author_id = u.id
       ${whereClause}
       ORDER BY l.created_at DESC
       LIMIT ? OFFSET ?`,
      ...params,
      limit,
      offset
    );

    return this.buildPaginatedResult(letters, total, pagination);
  }

  /**
   * Create a new letter
   */
  async create(input: CreateLetterInput): Promise<LetterRow> {
    const id = generateId('let');
    const now = new Date().toISOString();
    const preview = input.content
      ? input.content.slice(0, 100) + (input.content.length > 100 ? '...' : '')
      : '';

    await this.execute(
      `INSERT INTO letters (
        id, circle_id, author_id, title, preview, content,
        status, type, recipient, created_at, updated_at
      ) VALUES (?, ?, ?, ?, ?, ?, 'draft', ?, ?, ?, ?)`,
      id,
      input.circle_id,
      input.author_id,
      input.title,
      preview,
      input.content || null,
      input.type,
      input.recipient,
      now,
      now
    );

    // Log sync event
    await this.logSyncEvent(input.circle_id, 'letter', id, 'create');

    return (await this.findById(id))!;
  }

  /**
   * Update letter (only for drafts)
   */
  async update(id: string, input: UpdateLetterInput): Promise<LetterRow | null> {
    const letter = await this.findByIdBasic(id);
    if (!letter) return null;

    // Only drafts can be edited
    if (letter.status !== 'draft') return null;

    const updates: string[] = [];
    const values: unknown[] = [];

    if (input.title !== undefined) {
      updates.push('title = ?');
      values.push(input.title);
    }

    if (input.content !== undefined) {
      updates.push('content = ?');
      values.push(input.content);
      // Update preview
      updates.push('preview = ?');
      const preview = input.content
        ? input.content.slice(0, 100) + (input.content.length > 100 ? '...' : '')
        : '';
      values.push(preview);
    }

    if (input.recipient !== undefined) {
      updates.push('recipient = ?');
      values.push(input.recipient);
    }

    if (updates.length === 0) return letter;

    updates.push("updated_at = datetime('now')");
    values.push(id);

    await this.execute(
      `UPDATE letters SET ${updates.join(', ')} WHERE id = ?`,
      ...values
    );

    // Log sync event
    await this.logSyncEvent(letter.circle_id, 'letter', id, 'update');

    return this.findById(id);
  }

  /**
   * Soft delete letter
   */
  async delete(id: string): Promise<boolean> {
    const letter = await this.findByIdBasic(id);
    if (!letter) return false;

    await this.execute(
      `UPDATE letters SET deleted_at = datetime('now'), updated_at = datetime('now') WHERE id = ?`,
      id
    );

    // Log sync event
    await this.logSyncEvent(letter.circle_id, 'letter', id, 'delete');

    return true;
  }

  /**
   * Seal a letter (set unlock date)
   */
  async seal(id: string, unlockDate: string): Promise<LetterRow | null> {
    const letter = await this.findByIdBasic(id);
    if (!letter || letter.status !== 'draft') return null;

    const now = new Date().toISOString();

    await this.execute(
      `UPDATE letters SET 
        status = 'sealed', 
        unlock_date = ?, 
        sealed_at = ?,
        updated_at = ?
       WHERE id = ?`,
      unlockDate,
      now,
      now,
      id
    );

    // Log sync event
    await this.logSyncEvent(letter.circle_id, 'letter', id, 'update');

    return this.findById(id);
  }

  /**
   * Unlock a sealed letter (if date has passed)
   */
  async unlock(id: string): Promise<LetterRow | null> {
    const letter = await this.findByIdBasic(id);
    if (!letter || letter.status !== 'sealed') return null;

    // Check if unlock date has passed
    if (letter.unlock_date && new Date(letter.unlock_date) > new Date()) {
      return null; // Not ready to unlock yet
    }

    await this.execute(
      `UPDATE letters SET status = 'unlocked', updated_at = datetime('now') WHERE id = ?`,
      id
    );

    // Log sync event
    await this.logSyncEvent(letter.circle_id, 'letter', id, 'update');

    return this.findById(id);
  }

  /**
   * Auto-unlock all letters that have passed their unlock date
   * Can be called by a scheduled worker
   */
  async autoUnlockDueLetters(): Promise<number> {
    const result = await this.execute(
      `UPDATE letters 
       SET status = 'unlocked', updated_at = datetime('now')
       WHERE status = 'sealed' 
         AND unlock_date IS NOT NULL 
         AND unlock_date <= datetime('now')
         AND deleted_at IS NULL`
    );

    return result.meta.changes || 0;
  }

  /**
   * Check if user is the author of the letter
   */
  async isAuthor(letterId: string, userId: string): Promise<boolean> {
    const result = await this.queryOne<{ author_id: string }>(
      'SELECT author_id FROM letters WHERE id = ? AND deleted_at IS NULL',
      letterId
    );
    return result?.author_id === userId;
  }

  /**
   * Get circle ID for a letter
   */
  async getCircleId(letterId: string): Promise<string | null> {
    const result = await this.queryOne<{ circle_id: string }>(
      'SELECT circle_id FROM letters WHERE id = ?',
      letterId
    );
    return result?.circle_id ?? null;
  }

  /**
   * Get letter stats for a circle
   */
  async getStats(circleId: string): Promise<{
    total: number;
    draft: number;
    sealed: number;
    unlocked: number;
  }> {
    const result = await this.queryOne<{
      total: number;
      draft: number;
      sealed: number;
      unlocked: number;
    }>(
      `SELECT 
         COUNT(*) as total,
         SUM(CASE WHEN status = 'draft' THEN 1 ELSE 0 END) as draft,
         SUM(CASE WHEN status = 'sealed' THEN 1 ELSE 0 END) as sealed,
         SUM(CASE WHEN status = 'unlocked' THEN 1 ELSE 0 END) as unlocked
       FROM letters
       WHERE circle_id = ? AND deleted_at IS NULL`,
      circleId
    );

    return result || { total: 0, draft: 0, sealed: 0, unlocked: 0 };
  }

  /**
   * Get upcoming letters (sealed, to be unlocked)
   */
  async getUpcoming(circleId: string, limit: number = 5): Promise<LetterRow[]> {
    return this.query<LetterRow>(
      `SELECT l.*, u.name as author_name
       FROM letters l
       JOIN users u ON l.author_id = u.id
       WHERE l.circle_id = ?
         AND l.status = 'sealed'
         AND l.unlock_date IS NOT NULL
         AND l.deleted_at IS NULL
       ORDER BY l.unlock_date ASC
       LIMIT ?`,
      circleId,
      limit
    );
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
   * Transform letter for response
   * Hides content for sealed letters that aren't ready to unlock
   */
  toResponse(row: LetterRow, hideContent: boolean = false): Record<string, unknown> {
    return {
      id: row.id,
      circle_id: row.circle_id,
      author_id: row.author_id,
      title: row.title,
      preview: row.preview,
      content: hideContent ? null : row.content,
      status: row.status,
      type: row.type,
      recipient: row.recipient,
      unlock_date: row.unlock_date,
      created_at: row.created_at,
      sealed_at: row.sealed_at,
      updated_at: row.updated_at,
      author: row.author_name
        ? {
            id: row.author_id,
            name: row.author_name,
            avatar: row.author_avatar,
          }
        : undefined,
    };
  }

  /**
   * Process letters for list response - handles auto-unlock and content hiding
   */
  processForList(letters: LetterRow[]): Record<string, unknown>[] {
    return letters.map((letter) => {
      // Check for auto-unlock condition
      if (letter.status === 'sealed' && letter.unlock_date) {
        if (new Date(letter.unlock_date) <= new Date()) {
          // Would be unlocked - but don't modify DB here, just show as unlocked
          return this.toResponse({ ...letter, status: 'unlocked' }, false);
        } else {
          // Still sealed - hide content
          return this.toResponse(letter, true);
        }
      }

      return this.toResponse(letter, false);
    });
  }
}

/**
 * Circle Repository
 * Handles all circle-related database operations
 */

import { BaseRepository, type PaginationParams, type PaginatedResult } from './base.repository';
import { generateId, generateInviteCode } from '../utils/id';

export interface CircleRow {
  id: string;
  name: string;
  start_date: string | null;
  invite_code: string | null;
  invite_expires_at: string | null;
  created_by: string;
  created_at: string;
  updated_at: string;
}

export interface CircleWithStats extends CircleRow {
  member_count: number;
  moment_count: number;
  letter_count?: number;
  role?: string;
  role_label?: string | null;
  joined_at?: string;
}

export interface CircleMemberRow {
  circle_id: string;
  user_id: string;
  role: 'admin' | 'member';
  role_label: string | null;
  joined_at: string;
}

export interface MemberWithUser {
  id: string;
  name: string;
  email: string;
  avatar: string | null;
  role: 'admin' | 'member';
  role_label: string | null;
  joined_at: string;
}

export interface CreateCircleInput {
  name: string;
  start_date?: string;
  created_by: string;
}

export interface UpdateCircleInput {
  name?: string;
  start_date?: string | null;
}

export interface JoinCircleInput {
  user_id: string;
  role_label?: string;
}

export interface UpdateMemberInput {
  role?: 'admin' | 'member';
  role_label?: string | null;
}

export class CircleRepository extends BaseRepository {
  /**
   * Find circle by ID
   */
  async findById(id: string): Promise<CircleRow | null> {
    return this.queryOne<CircleRow>(
      'SELECT * FROM circles WHERE id = ?',
      id
    );
  }

  /**
   * Find circle by ID with stats
   */
  async findByIdWithStats(id: string): Promise<CircleWithStats | null> {
    return this.queryOne<CircleWithStats>(
      `SELECT c.*,
              (SELECT COUNT(*) FROM circle_members WHERE circle_id = c.id) as member_count,
              (SELECT COUNT(*) FROM moments WHERE circle_id = c.id AND deleted_at IS NULL) as moment_count,
              (SELECT COUNT(*) FROM letters WHERE circle_id = c.id AND deleted_at IS NULL) as letter_count
       FROM circles c
       WHERE c.id = ?`,
      id
    );
  }

  /**
   * Find circle by invite code
   */
  async findByInviteCode(inviteCode: string): Promise<CircleRow | null> {
    return this.queryOne<CircleRow>(
      'SELECT * FROM circles WHERE invite_code = ?',
      inviteCode.toUpperCase()
    );
  }

  /**
   * Get circles for a user
   */
  async findByUser(userId: string): Promise<CircleWithStats[]> {
    return this.query<CircleWithStats>(
      `SELECT c.*, cm.role, cm.role_label, cm.joined_at, cm.joined_at as member_since,
              (SELECT COUNT(*) FROM circle_members WHERE circle_id = c.id) as member_count,
              (SELECT COUNT(*) FROM moments WHERE circle_id = c.id AND deleted_at IS NULL) as moment_count
       FROM circles c
       JOIN circle_members cm ON c.id = cm.circle_id
       WHERE cm.user_id = ?
       ORDER BY cm.joined_at DESC`,
      userId
    );
  }

  /**
   * Create a new circle
   */
  async create(input: CreateCircleInput): Promise<CircleWithStats> {
    const id = generateId('cir');
    const inviteCode = generateInviteCode();
    const now = new Date().toISOString();

    // Create circle
    await this.execute(
      `INSERT INTO circles (id, name, start_date, invite_code, created_by, created_at, updated_at)
       VALUES (?, ?, ?, ?, ?, ?, ?)`,
      id,
      input.name,
      input.start_date || null,
      inviteCode,
      input.created_by,
      now,
      now
    );

    // Add creator as admin
    await this.execute(
      `INSERT INTO circle_members (circle_id, user_id, role, joined_at)
       VALUES (?, ?, 'admin', ?)`,
      id,
      input.created_by,
      now
    );

    return {
      id,
      name: input.name,
      start_date: input.start_date || null,
      invite_code: inviteCode,
      invite_expires_at: null,
      created_by: input.created_by,
      created_at: now,
      updated_at: now,
      member_count: 1,
      moment_count: 0,
      role: 'admin',
    };
  }

  /**
   * Update circle
   */
  async update(id: string, input: UpdateCircleInput): Promise<CircleRow | null> {
    const circle = await this.findById(id);
    if (!circle) return null;

    const { clause, params } = this.buildUpdateClause(input);
    if (!clause) return circle;

    await this.execute(
      `UPDATE circles ${clause} WHERE id = ?`,
      ...params,
      id
    );

    // Log sync event
    await this.logSyncEvent(id, 'circle', id, 'update');

    return this.findById(id);
  }

  /**
   * Delete circle (hard delete - cascades to members, etc.)
   */
  async delete(id: string): Promise<boolean> {
    await this.execute('DELETE FROM circles WHERE id = ?', id);
    return true;
  }

  /**
   * Generate new invite code
   */
  async generateInviteCode(id: string, expiresInDays: number = 7): Promise<{
    inviteCode: string;
    expiresAt: string;
  }> {
    const inviteCode = generateInviteCode();
    const expiresAt = new Date(Date.now() + expiresInDays * 24 * 60 * 60 * 1000).toISOString();

    await this.execute(
      `UPDATE circles SET invite_code = ?, invite_expires_at = ?, updated_at = datetime('now')
       WHERE id = ?`,
      inviteCode,
      expiresAt,
      id
    );

    return { inviteCode, expiresAt };
  }

  /**
   * Check if invite code is valid
   */
  async isInviteCodeValid(inviteCode: string): Promise<CircleRow | null> {
    const circle = await this.findByInviteCode(inviteCode);
    if (!circle) return null;

    // Check if expired
    if (circle.invite_expires_at && new Date(circle.invite_expires_at) < new Date()) {
      return null;
    }

    return circle;
  }

  // ===== Member Operations =====

  /**
   * Get circle member
   */
  async getMember(circleId: string, userId: string): Promise<CircleMemberRow | null> {
    return this.queryOne<CircleMemberRow>(
      'SELECT * FROM circle_members WHERE circle_id = ? AND user_id = ?',
      circleId,
      userId
    );
  }

  /**
   * Check if user is member of circle
   */
  async isMember(circleId: string, userId: string): Promise<boolean> {
    const member = await this.getMember(circleId, userId);
    return member !== null;
  }

  /**
   * Check if user is admin of circle
   */
  async isAdmin(circleId: string, userId: string): Promise<boolean> {
    const member = await this.getMember(circleId, userId);
    return member?.role === 'admin';
  }

  /**
   * Get all members of a circle
   */
  async getMembers(circleId: string): Promise<MemberWithUser[]> {
    return this.query<MemberWithUser>(
      `SELECT u.id, u.name, u.email, u.avatar, cm.role, cm.role_label, cm.joined_at
       FROM circle_members cm
       JOIN users u ON cm.user_id = u.id
       WHERE cm.circle_id = ?
       ORDER BY cm.joined_at ASC`,
      circleId
    );
  }

  /**
   * Add member to circle
   */
  async addMember(
    circleId: string,
    input: JoinCircleInput
  ): Promise<CircleMemberRow> {
    const now = new Date().toISOString();

    await this.execute(
      `INSERT INTO circle_members (circle_id, user_id, role, role_label, joined_at)
       VALUES (?, ?, 'member', ?, ?)`,
      circleId,
      input.user_id,
      input.role_label || null,
      now
    );

    // Log sync event
    await this.logSyncEvent(circleId, 'member', input.user_id, 'create');

    return {
      circle_id: circleId,
      user_id: input.user_id,
      role: 'member',
      role_label: input.role_label || null,
      joined_at: now,
    };
  }

  /**
   * Update member
   */
  async updateMember(
    circleId: string,
    userId: string,
    input: UpdateMemberInput
  ): Promise<CircleMemberRow | null> {
    const updates: string[] = [];
    const values: (string | null)[] = [];

    if (input.role !== undefined) {
      updates.push('role = ?');
      values.push(input.role);
    }

    if (input.role_label !== undefined) {
      updates.push('role_label = ?');
      values.push(input.role_label);
    }

    if (updates.length === 0) {
      return this.getMember(circleId, userId);
    }

    values.push(circleId, userId);

    await this.execute(
      `UPDATE circle_members SET ${updates.join(', ')} WHERE circle_id = ? AND user_id = ?`,
      ...values
    );

    return this.getMember(circleId, userId);
  }

  /**
   * Remove member from circle
   */
  async removeMember(circleId: string, userId: string): Promise<boolean> {
    await this.execute(
      'DELETE FROM circle_members WHERE circle_id = ? AND user_id = ?',
      circleId,
      userId
    );

    // Log sync event
    await this.logSyncEvent(circleId, 'member', userId, 'delete');

    return true;
  }

  /**
   * Get admin count for circle
   */
  async getAdminCount(circleId: string): Promise<number> {
    return this.count(
      `SELECT COUNT(*) as count FROM circle_members WHERE circle_id = ? AND role = 'admin'`,
      circleId
    );
  }

  /**
   * Check if member is the last admin
   */
  async isLastAdmin(circleId: string, userId: string): Promise<boolean> {
    const member = await this.getMember(circleId, userId);
    if (member?.role !== 'admin') return false;

    const adminCount = await this.getAdminCount(circleId);
    return adminCount === 1;
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
   * Transform circle to response format
   */
  toResponse(row: CircleRow): Record<string, unknown> {
    return {
      id: row.id,
      name: row.name,
      start_date: row.start_date,
      invite_code: row.invite_code,
      invite_expires_at: row.invite_expires_at,
      created_by: row.created_by,
      created_at: row.created_at,
      updated_at: row.updated_at,
    };
  }
}

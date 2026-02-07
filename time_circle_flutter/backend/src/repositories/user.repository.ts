/**
 * User Repository
 * Handles all user-related database operations
 */

import { BaseRepository } from './base.repository';
import { generateId, generateToken } from '../utils/id';
import { hashPassword, verifyPassword } from '../utils/password';
import { createTokenPair, REFRESH_TOKEN_EXPIRY } from '../utils/jwt';

export interface UserRow {
  id: string;
  email: string;
  password_hash: string;
  name: string;
  avatar: string | null;
  created_at: string;
  updated_at: string;
}

export interface UserResponse {
  id: string;
  email: string;
  name: string;
  avatar: string | null;
  created_at: string;
  updated_at: string;
}

export interface SessionRow {
  id: string;
  user_id: string;
  refresh_token: string;
  expires_at: string;
}

export interface CreateUserInput {
  email: string;
  password: string;
  name: string;
}

export interface UpdateUserInput {
  name?: string;
  avatar?: string | null;
}

export interface TokenPair {
  accessToken: string;
  refreshToken: string;
  expiresIn: number;
}

export interface AuthResult {
  user: UserResponse;
  tokens: TokenPair;
}

export class UserRepository extends BaseRepository {
  /**
   * Find user by ID
   */
  async findById(id: string): Promise<UserRow | null> {
    return this.queryOne<UserRow>(
      'SELECT * FROM users WHERE id = ?',
      id
    );
  }

  /**
   * Find user by ID (safe, without password)
   */
  async findByIdSafe(id: string): Promise<UserResponse | null> {
    return this.queryOne<UserResponse>(
      'SELECT id, email, name, avatar, created_at, updated_at FROM users WHERE id = ?',
      id
    );
  }

  /**
   * Find user by email
   */
  async findByEmail(email: string): Promise<UserRow | null> {
    return this.queryOne<UserRow>(
      'SELECT * FROM users WHERE email = ?',
      email.toLowerCase()
    );
  }

  /**
   * Check if email exists
   */
  async emailExists(email: string): Promise<boolean> {
    const result = await this.queryOne<{ id: string }>(
      'SELECT id FROM users WHERE email = ?',
      email.toLowerCase()
    );
    return result !== null;
  }

  /**
   * Create a new user
   */
  async create(input: CreateUserInput): Promise<UserResponse> {
    const id = generateId('u');
    const now = new Date().toISOString();
    const passwordHash = await hashPassword(input.password);

    await this.execute(
      `INSERT INTO users (id, email, password_hash, name, created_at, updated_at)
       VALUES (?, ?, ?, ?, ?, ?)`,
      id,
      input.email.toLowerCase(),
      passwordHash,
      input.name,
      now,
      now
    );

    return {
      id,
      email: input.email.toLowerCase(),
      name: input.name,
      avatar: null,
      created_at: now,
      updated_at: now,
    };
  }

  /**
   * Update user profile
   */
  async update(id: string, input: UpdateUserInput): Promise<UserResponse | null> {
    const { clause, params } = this.buildUpdateClause(input);
    
    if (!clause) return this.findByIdSafe(id);

    await this.execute(
      `UPDATE users ${clause} WHERE id = ?`,
      ...params,
      id
    );

    return this.findByIdSafe(id);
  }

  /**
   * Update password
   */
  async updatePassword(id: string, newPassword: string): Promise<boolean> {
    const passwordHash = await hashPassword(newPassword);
    
    await this.execute(
      `UPDATE users SET password_hash = ?, updated_at = datetime('now') WHERE id = ?`,
      passwordHash,
      id
    );

    return true;
  }

  /**
   * Verify password for user
   */
  async verifyPassword(email: string, password: string): Promise<UserRow | null> {
    const user = await this.findByEmail(email);
    if (!user) return null;

    const valid = await verifyPassword(password, user.password_hash);
    return valid ? user : null;
  }

  /**
   * Create session with tokens
   */
  async createSession(userId: string, email: string, jwtSecret: string): Promise<TokenPair> {
    const tokens = await createTokenPair(userId, email, jwtSecret);
    const sessionId = generateId('ses');
    const expiresAt = new Date(Date.now() + REFRESH_TOKEN_EXPIRY * 1000).toISOString();

    await this.execute(
      `INSERT INTO sessions (id, user_id, refresh_token, expires_at)
       VALUES (?, ?, ?, ?)`,
      sessionId,
      userId,
      tokens.refreshToken,
      expiresAt
    );

    return {
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
      expiresIn: tokens.expiresIn,
    };
  }

  /**
   * Refresh session tokens
   */
  async refreshSession(
    refreshToken: string,
    jwtSecret: string
  ): Promise<{ session: SessionRow & { email: string }; tokens: TokenPair } | null> {
    const session = await this.queryOne<SessionRow & { email: string; name: string }>(
      `SELECT s.*, u.email, u.name
       FROM sessions s
       JOIN users u ON s.user_id = u.id
       WHERE s.refresh_token = ? AND s.expires_at > datetime('now')`,
      refreshToken
    );

    if (!session) return null;

    // Create new tokens
    const tokens = await createTokenPair(session.user_id, session.email, jwtSecret);
    const expiresAt = new Date(Date.now() + REFRESH_TOKEN_EXPIRY * 1000).toISOString();

    // Update session with new refresh token
    await this.execute(
      `UPDATE sessions SET refresh_token = ?, expires_at = ? WHERE id = ?`,
      tokens.refreshToken,
      expiresAt,
      session.id
    );

    return {
      session,
      tokens: {
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
        expiresIn: tokens.expiresIn,
      },
    };
  }

  /**
   * Delete session (logout)
   */
  async deleteSession(refreshToken: string): Promise<boolean> {
    await this.execute(
      'DELETE FROM sessions WHERE refresh_token = ?',
      refreshToken
    );
    return true;
  }

  /**
   * Delete all sessions for user
   */
  async deleteAllSessions(userId: string): Promise<boolean> {
    await this.execute(
      'DELETE FROM sessions WHERE user_id = ?',
      userId
    );
    return true;
  }

  /**
   * Get user with their circles
   */
  async getUserWithCircles(userId: string): Promise<{
    user: UserResponse;
    circles: Array<{
      id: string;
      name: string;
      role: string;
      role_label: string | null;
      joined_at: string;
    }>;
  } | null> {
    const user = await this.findByIdSafe(userId);
    if (!user) return null;

    const circles = await this.query<{
      id: string;
      name: string;
      start_date: string | null;
      role: string;
      role_label: string | null;
      joined_at: string;
    }>(
      `SELECT c.*, cm.role, cm.role_label, cm.joined_at
       FROM circles c
       JOIN circle_members cm ON c.id = cm.circle_id
       WHERE cm.user_id = ?
       ORDER BY cm.joined_at DESC`,
      userId
    );

    return { user, circles };
  }

  /**
   * Update user role label across all circles
   */
  async updateRoleLabel(userId: string, roleLabel: string | null): Promise<void> {
    await this.execute(
      `UPDATE circle_members SET role_label = ? WHERE user_id = ?`,
      roleLabel,
      userId
    );
  }

  /**
   * Transform user row to safe response (no password)
   */
  toResponse(row: UserRow): UserResponse {
    return {
      id: row.id,
      email: row.email,
      name: row.name,
      avatar: row.avatar,
      created_at: row.created_at,
      updated_at: row.updated_at,
    };
  }
}

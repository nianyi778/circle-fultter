/**
 * Base Repository
 * Provides common database operations
 */

import type { D1Database, D1Result } from '@cloudflare/workers-types';

export interface PaginationParams {
  page: number;
  limit: number;
}

export interface PaginatedResult<T> {
  data: T[];
  meta: {
    page: number;
    limit: number;
    total: number;
    total_pages: number;
    has_more: boolean;
  };
}

export abstract class BaseRepository {
  protected db: D1Database;

  constructor(db: D1Database) {
    this.db = db;
  }

  /**
   * Execute a query and return all results
   */
  protected async query<T>(sql: string, ...params: unknown[]): Promise<T[]> {
    const result = await this.db.prepare(sql).bind(...params).all();
    return result.results as T[];
  }

  /**
   * Execute a query and return the first result
   */
  protected async queryOne<T>(sql: string, ...params: unknown[]): Promise<T | null> {
    const result = await this.db.prepare(sql).bind(...params).first();
    return result as T | null;
  }

  /**
   * Execute a query and return the count
   */
  protected async count(sql: string, ...params: unknown[]): Promise<number> {
    const result = await this.db.prepare(sql).bind(...params).first<{ count: number }>();
    return result?.count ?? 0;
  }

  /**
   * Execute an insert/update/delete and return the result
   */
  protected async execute(sql: string, ...params: unknown[]): Promise<D1Result> {
    return this.db.prepare(sql).bind(...params).run();
  }

  /**
   * Execute a batch of statements
   */
  protected async batch(statements: { sql: string; params: unknown[] }[]): Promise<D1Result[]> {
    const prepared = statements.map(({ sql, params }) =>
      this.db.prepare(sql).bind(...params)
    );
    return this.db.batch(prepared);
  }

  /**
   * Build pagination query parts
   */
  protected buildPagination(params: PaginationParams): { limit: number; offset: number } {
    return {
      limit: params.limit,
      offset: (params.page - 1) * params.limit,
    };
  }

  /**
   * Build paginated response
   */
  protected buildPaginatedResult<T>(
    data: T[],
    total: number,
    params: PaginationParams
  ): PaginatedResult<T> {
    const totalPages = Math.ceil(total / params.limit);
    return {
      data,
      meta: {
        page: params.page,
        limit: params.limit,
        total,
        total_pages: totalPages,
        has_more: params.page < totalPages,
      },
    };
  }

  /**
   * Parse JSON field safely
   */
  protected parseJson<T>(value: unknown, fallback: T): T {
    if (typeof value === 'string') {
      try {
        return JSON.parse(value) as T;
      } catch {
        return fallback;
      }
    }
    return fallback;
  }

  /**
   * Build dynamic WHERE clause
   */
  protected buildWhereClause(
    conditions: Array<{ field: string; value: unknown; operator?: string }>
  ): { clause: string; params: unknown[] } {
    const validConditions = conditions.filter((c) => c.value !== undefined && c.value !== null);

    if (validConditions.length === 0) {
      return { clause: '', params: [] };
    }

    const clauses = validConditions.map((c) => {
      const op = c.operator ?? '=';
      return `${c.field} ${op} ?`;
    });

    return {
      clause: `WHERE ${clauses.join(' AND ')}`,
      params: validConditions.map((c) => c.value),
    };
  }

  /**
   * Build dynamic UPDATE SET clause
   */
  protected buildUpdateClause<T extends object>(
    updates: T
  ): { clause: string; params: unknown[] } {
    const entries = Object.entries(updates).filter(
      ([, value]) => value !== undefined
    );

    if (entries.length === 0) {
      return { clause: '', params: [] };
    }

    const setClauses = entries.map(([key]) => `${key} = ?`);
    setClauses.push("updated_at = datetime('now')");

    return {
      clause: `SET ${setClauses.join(', ')}`,
      params: entries.map(([, value]) => value),
    };
  }
}

/**
 * API Response Utilities
 */

import type { ApiResponse } from '../types';

/**
 * Success response
 */
export function success<T>(
  data: T,
  meta?: ApiResponse['meta'],
  requestId?: string
): ApiResponse<T> {
  return {
    success: true,
    data,
    ...(meta && { meta }),
    ...(requestId && { requestId }),
  };
}

/**
 * Error response
 */
export function error(
  code: string,
  message: string,
  requestId?: string
): ApiResponse {
  return {
    success: false,
    error: { code, message },
    ...(requestId && { requestId }),
  };
}

/**
 * Paginated response
 */
export function paginated<T>(
  data: T[],
  page: number,
  limit: number,
  total: number
): ApiResponse<T[]> {
  return {
    success: true,
    data,
    meta: {
      page,
      limit,
      total,
      hasMore: page * limit < total,
    },
  };
}

/**
 * Create pagination meta object
 */
export function paginate(page: number, limit: number, total: number): ApiResponse['meta'] {
  return {
    page,
    limit,
    total,
    hasMore: page * limit < total,
  };
}

// Common error codes
export const ErrorCodes = {
  // Auth errors
  INVALID_CREDENTIALS: 'INVALID_CREDENTIALS',
  EMAIL_EXISTS: 'EMAIL_EXISTS',
  UNAUTHORIZED: 'UNAUTHORIZED',
  TOKEN_EXPIRED: 'TOKEN_EXPIRED',
  INVALID_TOKEN: 'INVALID_TOKEN',
  
  // Validation errors
  VALIDATION_ERROR: 'VALIDATION_ERROR',
  INVALID_INPUT: 'INVALID_INPUT',
  
  // Resource errors
  NOT_FOUND: 'NOT_FOUND',
  FORBIDDEN: 'FORBIDDEN',
  CONFLICT: 'CONFLICT',
  
  // Circle errors
  INVALID_INVITE_CODE: 'INVALID_INVITE_CODE',
  INVITE_EXPIRED: 'INVITE_EXPIRED',
  ALREADY_MEMBER: 'ALREADY_MEMBER',
  ALREADY_EXISTS: 'ALREADY_EXISTS',
  
  // Letter errors
  LETTER_SEALED: 'LETTER_SEALED',
  LETTER_NOT_READY: 'LETTER_NOT_READY',
  
  // Server errors
  INTERNAL_ERROR: 'INTERNAL_ERROR',
  DATABASE_ERROR: 'DATABASE_ERROR',
} as const;

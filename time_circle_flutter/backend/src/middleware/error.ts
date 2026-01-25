/**
 * Error Handling Middleware
 */

import { Context } from 'hono';
import { HTTPException } from 'hono/http-exception';
import { error, ErrorCodes } from '../utils/response';
import type { Env } from '../types';

export function errorHandler(err: Error, c: Context<{ Bindings: Env }>) {
  const requestId = c.get('requestId' as never) as string | undefined;
  console.error('Error:', err);

  if (err instanceof HTTPException) {
    const status = err.status;
    let code: string = ErrorCodes.INTERNAL_ERROR;

    switch (status) {
      case 400:
        code = ErrorCodes.INVALID_INPUT;
        break;
      case 401:
        code = ErrorCodes.UNAUTHORIZED;
        break;
      case 403:
        code = ErrorCodes.FORBIDDEN;
        break;
      case 404:
        code = ErrorCodes.NOT_FOUND;
        break;
      case 409:
        code = ErrorCodes.CONFLICT;
        break;
    }

    return c.json(error(code, err.message, requestId), status);
  }

  if (err instanceof Error) {
    // Check for specific error types
    if (err.message.includes('UNIQUE constraint failed')) {
      return c.json(
        error(ErrorCodes.CONFLICT, 'Resource already exists', requestId),
        409
      );
    }

    if (err.message.includes('FOREIGN KEY constraint failed')) {
      return c.json(
        error(
          ErrorCodes.INVALID_INPUT,
          'Referenced resource not found',
          requestId
        ),
        400
      );
    }

    // Development: return full error message
    if (c.env.ENVIRONMENT === 'development') {
      return c.json(error(ErrorCodes.INTERNAL_ERROR, err.message, requestId), 500);
    }
  }

  return c.json(
    error(ErrorCodes.INTERNAL_ERROR, 'Internal server error', requestId),
    500
  );
}

/**
 * Custom HTTP Exception for API errors
 */
export class ApiError extends Error {
  constructor(
    public status: number,
    public code: string,
    message: string
  ) {
    super(message);
    this.name = 'ApiError';
  }
}

/**
 * Throw a 400 Bad Request error
 */
export function badRequest(message: string, code: string = ErrorCodes.INVALID_INPUT): never {
  throw new ApiError(400, code, message);
}

/**
 * Throw a 401 Unauthorized error
 */
export function unauthorized(message: string = 'Unauthorized'): never {
  throw new ApiError(401, ErrorCodes.UNAUTHORIZED, message);
}

/**
 * Throw a 403 Forbidden error
 */
export function forbidden(message: string = 'Forbidden'): never {
  throw new ApiError(403, ErrorCodes.FORBIDDEN, message);
}

/**
 * Throw a 404 Not Found error
 */
export function notFound(message: string = 'Resource not found'): never {
  throw new ApiError(404, ErrorCodes.NOT_FOUND, message);
}

/**
 * Throw a 409 Conflict error
 */
export function conflict(message: string, code: string = ErrorCodes.CONFLICT): never {
  throw new ApiError(409, code, message);
}

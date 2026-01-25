import { Context, Next } from 'hono';

import type { Env } from '../types';

export function requestIdMiddleware() {
  return async (c: Context<{ Bindings: Env }>, next: Next) => {
    const headerId = c.req.header('X-Request-Id');
    // Cloudflare Workers 使用全局 crypto API
    const requestId = headerId?.trim() || crypto.randomUUID();

    c.set('requestId' as never, requestId);
    c.header('X-Request-Id', requestId);

    await next();
  };
}

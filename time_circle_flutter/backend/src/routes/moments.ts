/**
 * Moments Routes (Refactored with Repository Pattern)
 */

import { Hono } from 'hono';
import { success, error, ErrorCodes } from '../utils/response';
import { authMiddleware, circleMemberMiddleware } from '../middleware/auth';
import { MomentRepository, CircleRepository } from '../repositories';
import {
  createMomentSchema,
  updateMomentSchema,
  momentFilterSchema,
  paginationSchema,
  shareToWorldSchema,
} from '../schemas';
import type { Env } from '../types';

const moments = new Hono<{ Bindings: Env }>();

// All routes require authentication
moments.use('*', authMiddleware);

/**
 * GET /moments/:id
 * Get single moment
 */
moments.get('/:id', async (c) => {
  const momentId = c.req.param('id');
  const userId = c.get('userId');
  
  const momentRepo = new MomentRepository(c.env.DB);
  const circleRepo = new CircleRepository(c.env.DB);
  
  // Get moment with author info
  const moment = await momentRepo.findById(momentId);
  
  if (!moment) {
    return c.json(error(ErrorCodes.NOT_FOUND, 'Moment not found'), 404);
  }
  
  // Check if user is a member of the circle
  if (!(await circleRepo.isMember(moment.circle_id, userId))) {
    return c.json(error(ErrorCodes.FORBIDDEN, 'Not a member of this circle'), 403);
  }
  
  return c.json(success(momentRepo.toResponse(moment)));
});

/**
 * PUT /moments/:id
 * Update moment (author only)
 */
moments.put('/:id', async (c) => {
  const momentId = c.req.param('id');
  const userId = c.get('userId');
  const body = await c.req.json();
  
  const momentRepo = new MomentRepository(c.env.DB);
  
  // Check ownership
  if (!(await momentRepo.isAuthor(momentId, userId))) {
    const moment = await momentRepo.findById(momentId);
    if (!moment) {
      return c.json(error(ErrorCodes.NOT_FOUND, 'Moment not found'), 404);
    }
    return c.json(error(ErrorCodes.FORBIDDEN, "Cannot edit others' moments"), 403);
  }
  
  // Validate input - convert camelCase to snake_case
  const result = updateMomentSchema.safeParse({
    content: body.content,
    media_urls: body.mediaUrls || body.media_urls,
    context_tags: body.contextTags || body.context_tags,
    location: body.location,
    future_message: body.futureMessage || body.future_message,
  });
  
  if (!result.success) {
    return c.json(
      error(ErrorCodes.VALIDATION_ERROR, result.error.errors[0].message),
      400
    );
  }
  
  // Check if there are updates
  const updates = {
    content: result.data.content,
    media_urls: result.data.media_urls,
    context_tags: result.data.context_tags,
    location: result.data.location,
    future_message: result.data.future_message,
  };
  
  // Filter out undefined values
  const cleanUpdates = Object.fromEntries(
    Object.entries(updates).filter(([, v]) => v !== undefined)
  );
  
  if (Object.keys(cleanUpdates).length === 0) {
    return c.json(error(ErrorCodes.INVALID_INPUT, 'No updates provided'), 400);
  }
  
  const updated = await momentRepo.update(momentId, cleanUpdates);
  
  if (!updated) {
    return c.json(error(ErrorCodes.NOT_FOUND, 'Moment not found'), 404);
  }
  
  return c.json(success(momentRepo.toResponse(updated)));
});

/**
 * DELETE /moments/:id
 * Soft delete moment (author only or admin)
 */
moments.delete('/:id', async (c) => {
  const momentId = c.req.param('id');
  const userId = c.get('userId');
  
  const momentRepo = new MomentRepository(c.env.DB);
  const circleRepo = new CircleRepository(c.env.DB);
  
  // Get moment first
  const moment = await momentRepo.findById(momentId);
  
  if (!moment) {
    return c.json(error(ErrorCodes.NOT_FOUND, 'Moment not found'), 404);
  }
  
  // Check if author or admin
  const isAuthor = moment.author_id === userId;
  const isAdmin = await circleRepo.isAdmin(moment.circle_id, userId);
  
  if (!isAuthor && !isAdmin) {
    return c.json(error(ErrorCodes.FORBIDDEN, "Cannot delete others' moments"), 403);
  }
  
  await momentRepo.delete(momentId);
  
  return c.json(success({ message: 'Moment deleted' }));
});

/**
 * PUT /moments/:id/favorite
 * Toggle favorite
 */
moments.put('/:id/favorite', async (c) => {
  const momentId = c.req.param('id');
  const userId = c.get('userId');
  
  const momentRepo = new MomentRepository(c.env.DB);
  const circleRepo = new CircleRepository(c.env.DB);
  
  // Get moment and check membership
  const circleId = await momentRepo.getCircleId(momentId);
  
  if (!circleId) {
    return c.json(error(ErrorCodes.NOT_FOUND, 'Moment not found'), 404);
  }
  
  if (!(await circleRepo.isMember(circleId, userId))) {
    return c.json(error(ErrorCodes.FORBIDDEN, 'Not a member of this circle'), 403);
  }
  
  const isFavorite = await momentRepo.toggleFavorite(momentId);
  
  if (isFavorite === null) {
    return c.json(error(ErrorCodes.NOT_FOUND, 'Moment not found'), 404);
  }
  
  return c.json(success({ is_favorite: isFavorite }));
});

/**
 * POST /moments/:id/share
 * Share moment to world
 */
moments.post('/:id/share', async (c) => {
  const momentId = c.req.param('id');
  const userId = c.get('userId');
  const body = await c.req.json();
  
  // Validate input
  const result = shareToWorldSchema.safeParse(body);
  if (!result.success) {
    return c.json(
      error(ErrorCodes.VALIDATION_ERROR, result.error.errors[0].message),
      400
    );
  }
  
  const momentRepo = new MomentRepository(c.env.DB);
  
  // Check ownership
  if (!(await momentRepo.isAuthor(momentId, userId))) {
    return c.json(error(ErrorCodes.FORBIDDEN, 'Can only share your own moments'), 403);
  }
  
  const worldPostId = await momentRepo.shareToWorld(
    momentId,
    result.data.tag,
    result.data.bg_gradient
  );
  
  if (!worldPostId) {
    return c.json(error(ErrorCodes.NOT_FOUND, 'Moment not found'), 404);
  }
  
  return c.json(success({ world_post_id: worldPostId }));
});

/**
 * DELETE /moments/:id/world
 * Withdraw moment from world
 */
moments.delete('/:id/world', async (c) => {
  const momentId = c.req.param('id');
  const userId = c.get('userId');
  
  const momentRepo = new MomentRepository(c.env.DB);
  
  // Check ownership
  if (!(await momentRepo.isAuthor(momentId, userId))) {
    return c.json(error(ErrorCodes.FORBIDDEN, "Cannot withdraw others' moments"), 403);
  }
  
  const success_ = await momentRepo.withdrawFromWorld(momentId);
  
  if (!success_) {
    return c.json(error(ErrorCodes.INVALID_INPUT, 'Moment is not shared to world'), 400);
  }
  
  return c.json(success({ message: 'Withdrawn from world' }));
});

// ===== Circle-scoped routes =====

const circleMoments = new Hono<{ Bindings: Env }>();
circleMoments.use('*', authMiddleware);
circleMoments.use('*', circleMemberMiddleware);

/**
 * GET /circles/:circleId/moments
 * List moments in a circle with filters
 */
circleMoments.get('/', async (c) => {
  const circleId = c.req.param('circleId')!;
  
  // Parse pagination
  const paginationResult = paginationSchema.safeParse({
    page: c.req.query('page'),
    limit: c.req.query('limit'),
  });
  
  const pagination = paginationResult.success
    ? paginationResult.data
    : { page: 1, limit: 20 };
  
  // Parse filters - support both camelCase and snake_case
  const filterResult = momentFilterSchema.safeParse({
    author_id: c.req.query('authorId') || c.req.query('author_id'),
    media_type: c.req.query('mediaType') || c.req.query('media_type'),
    favorite: c.req.query('favorite'),
    start_date: c.req.query('startDate') || c.req.query('start_date'),
    end_date: c.req.query('endDate') || c.req.query('end_date'),
    year: c.req.query('year'),
  });
  
  const filter = filterResult.success ? {
    author_id: filterResult.data.author_id,
    media_type: filterResult.data.media_type,
    favorite: filterResult.data.favorite === 'true',
    start_date: filterResult.data.start_date,
    end_date: filterResult.data.end_date,
    year: filterResult.data.year,
  } : undefined;
  
  const momentRepo = new MomentRepository(c.env.DB);
  
  const result = await momentRepo.findByCircle(circleId, pagination, filter);
  
  return c.json(
    success({
      data: result.data.map((m) => momentRepo.toResponse(m)),
      meta: result.meta,
    })
  );
});

/**
 * POST /circles/:circleId/moments
 * Create a moment
 */
circleMoments.post('/', async (c) => {
  const circleId = c.req.param('circleId')!;
  const userId = c.get('userId');
  const body = await c.req.json();
  
  // Validate input - support both camelCase and snake_case
  const result = createMomentSchema.safeParse({
    content: body.content,
    media_type: body.mediaType || body.media_type,
    media_urls: body.mediaUrls || body.media_urls,
    timestamp: body.timestamp,
    context_tags: body.contextTags || body.context_tags,
    location: body.location,
    future_message: body.futureMessage || body.future_message,
  });
  
  if (!result.success) {
    return c.json(
      error(ErrorCodes.VALIDATION_ERROR, result.error.errors[0].message),
      400
    );
  }
  
  const momentRepo = new MomentRepository(c.env.DB);
  
  const moment = await momentRepo.create({
    circle_id: circleId,
    author_id: userId,
    content: result.data.content,
    media_type: result.data.media_type,
    media_urls: result.data.media_urls,
    timestamp: result.data.timestamp,
    context_tags: result.data.context_tags,
    location: result.data.location,
    future_message: result.data.future_message,
  });
  
  return c.json(success(momentRepo.toResponse(moment)), 201);
});

/**
 * GET /circles/:circleId/moments/memory
 * Get "this day in history" moments
 */
circleMoments.get('/memory', async (c) => {
  const circleId = c.req.param('circleId')!;
  const limit = Math.min(parseInt(c.req.query('limit') || '10'), 50);
  
  const momentRepo = new MomentRepository(c.env.DB);
  
  const moments = await momentRepo.findLastYearToday(circleId, limit);
  
  return c.json(success(moments.map((m) => momentRepo.toResponse(m))));
});

/**
 * GET /circles/:circleId/moments/random
 * Get random moments for memory roaming
 */
circleMoments.get('/random', async (c) => {
  const circleId = c.req.param('circleId')!;
  const count = Math.min(parseInt(c.req.query('count') || '5'), 20);
  
  const momentRepo = new MomentRepository(c.env.DB);
  
  const moments = await momentRepo.findRandom(circleId, count);
  
  return c.json(success(moments.map((m) => momentRepo.toResponse(m))));
});

/**
 * GET /circles/:circleId/moments/years
 * Get available years for filtering
 */
circleMoments.get('/years', async (c) => {
  const circleId = c.req.param('circleId')!;
  
  const momentRepo = new MomentRepository(c.env.DB);
  
  const years = await momentRepo.getAvailableYears(circleId);
  
  return c.json(success(years));
});

/**
 * GET /circles/:circleId/moments/stats
 * Get moment stats by author
 */
circleMoments.get('/stats', async (c) => {
  const circleId = c.req.param('circleId')!;
  
  const momentRepo = new MomentRepository(c.env.DB);
  
  const stats = await momentRepo.getCountByAuthor(circleId);
  
  return c.json(success(stats));
});

export { moments as momentRoutes, circleMoments as circleMomentRoutes };

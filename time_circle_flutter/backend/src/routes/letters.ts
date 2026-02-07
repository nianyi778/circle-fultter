/**
 * Letters Routes (Refactored with Repository Pattern)
 */

import { Hono } from 'hono';
import { success, error, ErrorCodes } from '../utils/response';
import { authMiddleware, circleMemberMiddleware } from '../middleware/auth';
import { LetterRepository, CircleRepository } from '../repositories';
import {
  createLetterSchema,
  updateLetterSchema,
  sealLetterSchema,
} from '../schemas';
import type { Env } from '../types';

const letters = new Hono<{ Bindings: Env }>();

// All routes require authentication
letters.use('*', authMiddleware);

/**
 * GET /letters/:id
 * Get single letter
 */
letters.get('/:id', async (c) => {
  const letterId = c.req.param('id');
  const userId = c.get('userId');
  
  const letterRepo = new LetterRepository(c.env.DB);
  const circleRepo = new CircleRepository(c.env.DB);
  
  const letter = await letterRepo.findById(letterId);
  
  if (!letter) {
    return c.json(error(ErrorCodes.NOT_FOUND, 'Letter not found'), 404);
  }
  
  // Check membership
  if (!(await circleRepo.isMember(letter.circle_id, userId))) {
    return c.json(error(ErrorCodes.FORBIDDEN, 'Not a member of this circle'), 403);
  }
  
  // Handle sealed letters - check for auto-unlock
  if (letter.status === 'sealed') {
    const unlockDate = letter.unlock_date ? new Date(letter.unlock_date) : null;
    
    if (unlockDate && unlockDate <= new Date()) {
      // Auto-unlock
      const unlocked = await letterRepo.unlock(letterId);
      if (unlocked) {
        return c.json(success(letterRepo.toResponse(unlocked)));
      }
    }
    
    // Still sealed - hide content
    return c.json(success(letterRepo.toResponse(letter, true)));
  }
  
  return c.json(success(letterRepo.toResponse(letter)));
});

/**
 * PUT /letters/:id
 * Update letter (author only, draft only)
 */
letters.put('/:id', async (c) => {
  const letterId = c.req.param('id');
  const userId = c.get('userId');
  const body = await c.req.json();
  
  const letterRepo = new LetterRepository(c.env.DB);
  
  // Check ownership
  if (!(await letterRepo.isAuthor(letterId, userId))) {
    const letter = await letterRepo.findByIdBasic(letterId);
    if (!letter) {
      return c.json(error(ErrorCodes.NOT_FOUND, 'Letter not found'), 404);
    }
    return c.json(error(ErrorCodes.FORBIDDEN, "Cannot edit others' letters"), 403);
  }
  
  // Check if letter is draft
  const letter = await letterRepo.findByIdBasic(letterId);
  if (letter?.status !== 'draft') {
    return c.json(error(ErrorCodes.LETTER_SEALED, 'Cannot edit sealed or unlocked letters'), 400);
  }
  
  // Validate input
  const result = updateLetterSchema.safeParse(body);
  if (!result.success) {
    return c.json(
      error(ErrorCodes.VALIDATION_ERROR, result.error.errors[0].message),
      400
    );
  }
  
  // Check if there are updates
  if (Object.keys(result.data).length === 0) {
    return c.json(error(ErrorCodes.INVALID_INPUT, 'No updates provided'), 400);
  }
  
  const updated = await letterRepo.update(letterId, result.data);
  
  if (!updated) {
    return c.json(error(ErrorCodes.NOT_FOUND, 'Letter not found or not editable'), 404);
  }
  
  return c.json(success(letterRepo.toResponse(updated)));
});

/**
 * DELETE /letters/:id
 * Soft delete letter (author only)
 */
letters.delete('/:id', async (c) => {
  const letterId = c.req.param('id');
  const userId = c.get('userId');
  
  const letterRepo = new LetterRepository(c.env.DB);
  
  // Check ownership
  if (!(await letterRepo.isAuthor(letterId, userId))) {
    const letter = await letterRepo.findByIdBasic(letterId);
    if (!letter) {
      return c.json(error(ErrorCodes.NOT_FOUND, 'Letter not found'), 404);
    }
    return c.json(error(ErrorCodes.FORBIDDEN, "Cannot delete others' letters"), 403);
  }
  
  await letterRepo.delete(letterId);
  
  return c.json(success({ message: 'Letter deleted' }));
});

/**
 * POST /letters/:id/seal
 * Seal a letter (set unlock date)
 */
letters.post('/:id/seal', async (c) => {
  const letterId = c.req.param('id');
  const userId = c.get('userId');
  const body = await c.req.json();
  
  const letterRepo = new LetterRepository(c.env.DB);
  
  // Check ownership
  if (!(await letterRepo.isAuthor(letterId, userId))) {
    const letter = await letterRepo.findByIdBasic(letterId);
    if (!letter) {
      return c.json(error(ErrorCodes.NOT_FOUND, 'Letter not found'), 404);
    }
    return c.json(error(ErrorCodes.FORBIDDEN, "Cannot seal others' letters"), 403);
  }
  
  // Check if letter is draft
  const letter = await letterRepo.findByIdBasic(letterId);
  if (letter?.status !== 'draft') {
    return c.json(error(ErrorCodes.LETTER_SEALED, 'Letter is already sealed'), 400);
  }
  
  // Validate input - support both formats
  const result = sealLetterSchema.safeParse({
    unlock_date: body.unlockDate || body.unlock_date,
  });
  
  if (!result.success) {
    return c.json(
      error(ErrorCodes.VALIDATION_ERROR, result.error.errors[0].message),
      400
    );
  }
  
  const sealed = await letterRepo.seal(letterId, result.data.unlock_date);
  
  if (!sealed) {
    return c.json(error(ErrorCodes.NOT_FOUND, 'Letter not found or not in draft status'), 404);
  }
  
  return c.json(success(letterRepo.toResponse(sealed)));
});

/**
 * POST /letters/:id/unlock
 * Manually unlock a letter (if date has passed)
 */
letters.post('/:id/unlock', async (c) => {
  const letterId = c.req.param('id');
  const userId = c.get('userId');
  
  const letterRepo = new LetterRepository(c.env.DB);
  const circleRepo = new CircleRepository(c.env.DB);
  
  const letter = await letterRepo.findByIdBasic(letterId);
  
  if (!letter) {
    return c.json(error(ErrorCodes.NOT_FOUND, 'Letter not found'), 404);
  }
  
  // Check membership
  if (!(await circleRepo.isMember(letter.circle_id, userId))) {
    return c.json(error(ErrorCodes.FORBIDDEN, 'Not a member of this circle'), 403);
  }
  
  if (letter.status !== 'sealed') {
    return c.json(error(ErrorCodes.INVALID_INPUT, 'Letter is not sealed'), 400);
  }
  
  // Check if unlock date has passed
  if (letter.unlock_date && new Date(letter.unlock_date) > new Date()) {
    return c.json(
      error(ErrorCodes.LETTER_NOT_READY, 'Letter cannot be unlocked until ' + letter.unlock_date),
      400
    );
  }
  
  const unlocked = await letterRepo.unlock(letterId);
  
  if (!unlocked) {
    return c.json(error(ErrorCodes.INVALID_INPUT, 'Cannot unlock letter yet'), 400);
  }
  
  return c.json(success(letterRepo.toResponse(unlocked)));
});

// ===== Circle-scoped routes =====

const circleLetters = new Hono<{ Bindings: Env }>();
circleLetters.use('*', authMiddleware);
circleLetters.use('*', circleMemberMiddleware);

/**
 * GET /circles/:circleId/letters
 * List letters in a circle
 */
circleLetters.get('/', async (c) => {
  const circleId = c.req.param('circleId')!;
  const status = c.req.query('status') as 'draft' | 'sealed' | 'unlocked' | undefined;
  const type = c.req.query('type') as 'annual' | 'milestone' | 'free' | undefined;
  
  const letterRepo = new LetterRepository(c.env.DB);
  
  const letters = await letterRepo.findByCircle(circleId, { status, type });
  
  // Process letters - handles auto-unlock check and content hiding
  const processed = letterRepo.processForList(letters);
  
  return c.json(success(processed));
});

/**
 * POST /circles/:circleId/letters
 * Create a new letter
 */
circleLetters.post('/', async (c) => {
  const circleId = c.req.param('circleId')!;
  const userId = c.get('userId');
  const body = await c.req.json();
  
  // Validate input
  const result = createLetterSchema.safeParse(body);
  if (!result.success) {
    return c.json(
      error(ErrorCodes.VALIDATION_ERROR, result.error.errors[0].message),
      400
    );
  }
  
  const letterRepo = new LetterRepository(c.env.DB);
  
  const letter = await letterRepo.create({
    circle_id: circleId,
    author_id: userId,
    title: result.data.title,
    content: result.data.content,
    type: result.data.type,
    recipient: result.data.recipient,
  });
  
  return c.json(success(letterRepo.toResponse(letter)), 201);
});

/**
 * GET /circles/:circleId/letters/stats
 * Get letter stats for circle
 */
circleLetters.get('/stats', async (c) => {
  const circleId = c.req.param('circleId')!;
  
  const letterRepo = new LetterRepository(c.env.DB);
  
  const stats = await letterRepo.getStats(circleId);
  
  return c.json(success(stats));
});

/**
 * GET /circles/:circleId/letters/upcoming
 * Get upcoming letters (sealed, to be unlocked)
 */
circleLetters.get('/upcoming', async (c) => {
  const circleId = c.req.param('circleId')!;
  const limit = Math.min(parseInt(c.req.query('limit') || '5'), 20);
  
  const letterRepo = new LetterRepository(c.env.DB);
  
  const letters = await letterRepo.getUpcoming(circleId, limit);
  
  // Don't hide content for upcoming list - it's a preview
  return c.json(success(letters.map((l) => letterRepo.toResponse(l, true))));
});

export { letters as letterRoutes, circleLetters as circleLetterRoutes };

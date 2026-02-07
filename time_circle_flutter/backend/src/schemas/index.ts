/**
 * Centralized Zod Schemas
 * All validation schemas in one place for reuse and OpenAPI generation
 */

import { z } from 'zod';

// ============ Common Schemas ============

export const paginationSchema = z.object({
  page: z.coerce.number().int().min(1).default(1),
  limit: z.coerce.number().int().min(1).max(100).default(20),
});

export const idSchema = z.string().min(1, 'ID is required');

export const timestampSchema = z.string().datetime().optional();

// ============ User Schemas ============

export const userSchema = z.object({
  id: z.string(),
  email: z.string().email(),
  name: z.string().min(1),
  avatar: z.string().nullable(),
  created_at: z.string(),
  updated_at: z.string(),
});

export const userResponseSchema = userSchema.omit({});

export const updateUserSchema = z.object({
  name: z.string().min(1).max(50).optional(),
  avatar: z.string().url().nullable().optional(),
});

// ============ Auth Schemas ============

export const registerSchema = z.object({
  email: z.string().email('Invalid email address'),
  password: z.string().min(6, 'Password must be at least 6 characters'),
  name: z.string().min(1, 'Name is required').max(50),
});

export const loginSchema = z.object({
  email: z.string().email('Invalid email address'),
  password: z.string().min(1, 'Password is required'),
});

export const refreshTokenSchema = z.object({
  refresh_token: z.string().min(1, 'Refresh token is required'),
});

export const changePasswordSchema = z.object({
  current_password: z.string().min(1, 'Current password is required'),
  new_password: z.string().min(6, 'New password must be at least 6 characters'),
});

export const authResponseSchema = z.object({
  user: userResponseSchema,
  tokens: z.object({
    access_token: z.string(),
    refresh_token: z.string(),
    expires_in: z.number(),
  }),
});

// ============ Circle Schemas ============

export const circleSchema = z.object({
  id: z.string(),
  name: z.string(),
  start_date: z.string().nullable(),
  invite_code: z.string().nullable(),
  invite_expires_at: z.string().nullable(),
  created_by: z.string(),
  created_at: z.string(),
  updated_at: z.string(),
});

export const createCircleSchema = z.object({
  name: z.string().min(1, 'Circle name is required').max(50),
  start_date: z.string().optional(),
});

export const updateCircleSchema = z.object({
  name: z.string().min(1).max(50).optional(),
  start_date: z.string().nullable().optional(),
});

export const joinCircleSchema = z.object({
  invite_code: z.string().min(1, 'Invite code is required'),
});

export const updateMemberRoleSchema = z.object({
  role_label: z.string().max(20).nullable().optional(),
});

// ============ Moment Schemas ============

export const mediaTypeSchema = z.enum(['text', 'image', 'video', 'audio']);

export const contextTagSchema = z.object({
  type: z.string(),
  label: z.string(),
  emoji: z.string(),
});

export const momentSchema = z.object({
  id: z.string(),
  circle_id: z.string(),
  author_id: z.string(),
  content: z.string(),
  media_type: mediaTypeSchema,
  media_urls: z.array(z.string()),
  timestamp: z.string(),
  context_tags: z.array(contextTagSchema),
  location: z.string().nullable(),
  is_favorite: z.boolean(),
  future_message: z.string().nullable(),
  is_shared_to_world: z.boolean(),
  world_topic: z.string().nullable(),
  created_at: z.string(),
  updated_at: z.string(),
  deleted_at: z.string().nullable(),
});

export const createMomentSchema = z.object({
  content: z.string().min(1, 'Content is required').max(5000),
  media_type: mediaTypeSchema.default('text'),
  media_urls: z.array(z.string().url()).max(9).default([]),
  timestamp: z.string().datetime().optional(),
  context_tags: z.array(contextTagSchema).max(5).optional(),
  location: z.string().max(100).optional(),
  future_message: z.string().max(500).optional(),
});

export const updateMomentSchema = z.object({
  content: z.string().min(1).max(5000).optional(),
  media_urls: z.array(z.string().url()).max(9).optional(),
  context_tags: z.array(contextTagSchema).max(5).optional(),
  location: z.string().max(100).nullable().optional(),
  future_message: z.string().max(500).nullable().optional(),
});

export const momentFilterSchema = z.object({
  author_id: z.string().optional(),
  media_type: mediaTypeSchema.optional(),
  favorite: z.enum(['true', 'false']).optional(),
  start_date: z.string().datetime().optional(),
  end_date: z.string().datetime().optional(),
  year: z.coerce.number().int().min(2000).max(2100).optional(),
});

export const shareToWorldSchema = z.object({
  tag: z.string().min(1, 'Tag is required'),
  bg_gradient: z.string().optional(),
});

// ============ Letter Schemas ============

export const letterStatusSchema = z.enum(['draft', 'sealed', 'unlocked']);
export const letterTypeSchema = z.enum(['annual', 'milestone', 'free']);

export const letterSchema = z.object({
  id: z.string(),
  circle_id: z.string(),
  author_id: z.string(),
  title: z.string(),
  preview: z.string(),
  content: z.string().nullable(),
  status: letterStatusSchema,
  type: letterTypeSchema,
  recipient: z.string(),
  unlock_date: z.string().nullable(),
  created_at: z.string(),
  sealed_at: z.string().nullable(),
  updated_at: z.string(),
  deleted_at: z.string().nullable(),
});

export const createLetterSchema = z.object({
  title: z.string().min(1, 'Title is required').max(100),
  content: z.string().min(1, 'Content is required').max(10000),
  type: letterTypeSchema.default('free'),
  recipient: z.string().min(1, 'Recipient is required').max(50),
  unlock_date: z.string().datetime().optional(),
});

export const updateLetterSchema = z.object({
  title: z.string().min(1).max(100).optional(),
  content: z.string().min(1).max(10000).optional(),
  recipient: z.string().min(1).max(50).optional(),
  unlock_date: z.string().datetime().nullable().optional(),
});

export const sealLetterSchema = z.object({
  unlock_date: z.string().datetime({ message: 'Valid unlock date is required' }),
});

// ============ World Post Schemas ============

export const worldPostSchema = z.object({
  id: z.string(),
  author_id: z.string(),
  moment_id: z.string().nullable(),
  content: z.string(),
  tag: z.string(),
  resonance_count: z.number(),
  bg_gradient: z.string(),
  created_at: z.string(),
  has_resonated: z.boolean().optional(),
});

export const createWorldPostSchema = z.object({
  content: z.string().min(1, 'Content is required').max(1000),
  tag: z.string().min(1, 'Tag is required'),
  bg_gradient: z.string().default('default'),
});

export const worldPostFilterSchema = z.object({
  tag: z.string().optional(),
});

// ============ Comment Schemas ============

export const commentTargetTypeSchema = z.enum(['moment', 'world']);

export const commentSchema = z.object({
  id: z.string(),
  target_id: z.string(),
  target_type: commentTargetTypeSchema,
  author_id: z.string(),
  content: z.string(),
  likes: z.number(),
  reply_to_id: z.string().nullable(),
  created_at: z.string(),
  author_name: z.string().optional(),
  author_avatar: z.string().nullable().optional(),
  reply_to_name: z.string().nullable().optional(),
});

export const createCommentSchema = z.object({
  content: z.string().min(1, 'Content is required').max(500),
  reply_to_id: z.string().optional(),
});

// ============ Sync Schemas ============

export const syncChangesQuerySchema = z.object({
  since: z.string().datetime({ message: 'Valid timestamp required' }),
  circle_id: z.string().min(1, 'Circle ID required'),
});

export const syncPushSchema = z.object({
  circle_id: z.string().min(1),
  changes: z.array(z.object({
    entity_type: z.enum(['moment', 'letter', 'comment']),
    entity_id: z.string(),
    action: z.enum(['create', 'update', 'delete']),
    data: z.record(z.unknown()).optional(),
    client_timestamp: z.string().datetime(),
  })),
});

// ============ Media Schemas ============

export const uploadUrlRequestSchema = z.object({
  filename: z.string().min(1),
  content_type: z.string().min(1),
  circle_id: z.string().optional(),
});

export const completeUploadSchema = z.object({
  key: z.string().min(1),
  filename: z.string().optional(),
  content_type: z.string().optional(),
  size: z.number().int().positive().optional(),
});

// ============ Response Schemas ============

export const apiErrorSchema = z.object({
  success: z.literal(false),
  error: z.object({
    code: z.string(),
    message: z.string(),
    details: z.record(z.unknown()).optional(),
  }),
});

export const apiSuccessSchema = <T extends z.ZodTypeAny>(dataSchema: T) =>
  z.object({
    success: z.literal(true),
    data: dataSchema,
  });

export const paginatedResponseSchema = <T extends z.ZodTypeAny>(itemSchema: T) =>
  z.object({
    success: z.literal(true),
    data: z.object({
      data: z.array(itemSchema),
      meta: z.object({
        page: z.number(),
        limit: z.number(),
        total: z.number(),
        total_pages: z.number(),
        has_more: z.boolean(),
      }),
    }),
  });

// ============ Type Exports ============

export type User = z.infer<typeof userSchema>;
export type Circle = z.infer<typeof circleSchema>;
export type Moment = z.infer<typeof momentSchema>;
export type Letter = z.infer<typeof letterSchema>;
export type WorldPost = z.infer<typeof worldPostSchema>;
export type Comment = z.infer<typeof commentSchema>;
export type ContextTag = z.infer<typeof contextTagSchema>;
export type MediaType = z.infer<typeof mediaTypeSchema>;
export type LetterStatus = z.infer<typeof letterStatusSchema>;
export type LetterType = z.infer<typeof letterTypeSchema>;

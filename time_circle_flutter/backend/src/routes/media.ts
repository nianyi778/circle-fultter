/**
 * Media Routes
 * R2 file upload/download with presigned URLs
 */

import { Hono } from 'hono';
import { z } from 'zod';
import { generateId } from '../utils/id';
import { success, error, ErrorCodes } from '../utils/response';
import { authMiddleware } from '../middleware/auth';
import type { Env, MediaFile } from '../types';

const media = new Hono<{ Bindings: Env }>();

// Allowed content types
const ALLOWED_TYPES = {
  image: ['image/jpeg', 'image/png', 'image/gif', 'image/webp', 'image/heic', 'image/heif'],
  video: ['video/mp4', 'video/quicktime', 'video/webm'],
  audio: ['audio/mpeg', 'audio/mp4', 'audio/wav', 'audio/ogg', 'audio/aac'],
};

const ALL_ALLOWED_TYPES = [
  ...ALLOWED_TYPES.image,
  ...ALLOWED_TYPES.video,
  ...ALLOWED_TYPES.audio,
];

// Max file sizes (in bytes)
const MAX_SIZES = {
  image: 10 * 1024 * 1024, // 10MB
  video: 100 * 1024 * 1024, // 100MB
  audio: 20 * 1024 * 1024, // 20MB
};

// Validation schemas
const uploadUrlSchema = z.object({
  filename: z.string().min(1).max(255),
  contentType: z.string().refine((type) => ALL_ALLOWED_TYPES.includes(type), {
    message: 'Unsupported file type',
  }),
  size: z.number().positive(),
  circleId: z.string().optional(),
});

const completeUploadSchema = z.object({
  key: z.string().min(1),
  filename: z.string().optional(),
});

/**
 * Determine media type from content type
 */
function getMediaType(contentType: string): 'image' | 'video' | 'audio' | null {
  if (ALLOWED_TYPES.image.includes(contentType)) return 'image';
  if (ALLOWED_TYPES.video.includes(contentType)) return 'video';
  if (ALLOWED_TYPES.audio.includes(contentType)) return 'audio';
  return null;
}

/**
 * Generate a unique storage key
 */
function generateStorageKey(userId: string, filename: string, circleId?: string): string {
  const ext = filename.split('.').pop() || '';
  const id = generateId('m');
  const prefix = circleId ? `circles/${circleId}` : `users/${userId}`;
  return `${prefix}/${id}.${ext}`;
}

/**
 * POST /media/upload-url
 * Get a presigned URL for uploading a file
 */
media.post('/upload-url', authMiddleware, async (c) => {
  const userId = c.get('userId');
  const body = await c.req.json();

  // Validate input
  const result = uploadUrlSchema.safeParse(body);
  if (!result.success) {
    return c.json(
      error(ErrorCodes.VALIDATION_ERROR, result.error.errors[0].message),
      400
    );
  }

  const { filename, contentType, size, circleId } = result.data;

  // Check media type
  const mediaType = getMediaType(contentType);
  if (!mediaType) {
    return c.json(error(ErrorCodes.INVALID_INPUT, 'Unsupported file type'), 400);
  }

  // Check file size
  const maxSize = MAX_SIZES[mediaType];
  if (size > maxSize) {
    return c.json(
      error(ErrorCodes.INVALID_INPUT, `File too large. Max size: ${maxSize / 1024 / 1024}MB`),
      400
    );
  }

  // If circleId provided, verify user is a member
  if (circleId) {
    const member = await c.env.DB.prepare(
      'SELECT 1 FROM circle_members WHERE circle_id = ? AND user_id = ?'
    )
      .bind(circleId, userId)
      .first();

    if (!member) {
      return c.json(error(ErrorCodes.FORBIDDEN, 'Not a member of this circle'), 403);
    }
  }

  // Generate storage key
  const key = generateStorageKey(userId, filename, circleId);

  // Create media file record (pending upload)
  const mediaId = generateId('mf');
  const now = new Date().toISOString();

  await c.env.DB.prepare(
    `INSERT INTO media_files (id, user_id, circle_id, key, filename, content_type, size, created_at)
     VALUES (?, ?, ?, ?, ?, ?, ?, ?)`
  )
    .bind(mediaId, userId, circleId || null, key, filename, contentType, size, now)
    .run();

  // Generate presigned URL using R2's multipart upload
  // Note: In a real implementation, you'd use R2's createMultipartUpload API
  // For simplicity, we'll use a direct upload approach with a signed URL

  // Since Cloudflare R2 doesn't support presigned PUT URLs natively in Workers,
  // we'll return the key and let the client upload directly through our API
  const uploadUrl = `/media/upload/${key}`;

  return c.json(
    success({
      uploadUrl,
      key,
      mediaId,
      expiresIn: 3600, // 1 hour
    })
  );
});

/**
 * PUT /media/upload/:key{.*}
 * Direct upload endpoint (alternative to presigned URLs)
 */
media.put('/upload/*', authMiddleware, async (c) => {
  const userId = c.get('userId');
  const key = c.req.path.replace('/media/upload/', '');

  // Verify the media file record exists and belongs to user
  const mediaFile = await c.env.DB.prepare(
    'SELECT * FROM media_files WHERE key = ? AND user_id = ?'
  )
    .bind(key, userId)
    .first<MediaFile>();

  if (!mediaFile) {
    return c.json(error(ErrorCodes.NOT_FOUND, 'Upload session not found'), 404);
  }

  // Get the file content
  const body = await c.req.arrayBuffer();
  
  if (body.byteLength === 0) {
    return c.json(error(ErrorCodes.INVALID_INPUT, 'Empty file'), 400);
  }

  // Check size matches
  if (mediaFile.size && body.byteLength !== mediaFile.size) {
    return c.json(
      error(ErrorCodes.INVALID_INPUT, `File size mismatch. Expected ${mediaFile.size}, got ${body.byteLength}`),
      400
    );
  }

  // Upload to R2
  await c.env.MEDIA.put(key, body, {
    httpMetadata: {
      contentType: mediaFile.content_type || 'application/octet-stream',
    },
    customMetadata: {
      userId,
      circleId: mediaFile.circle_id || '',
      uploadedAt: new Date().toISOString(),
    },
  });

  // Build public URL
  // In production, you'd use your custom domain or Cloudflare R2 public bucket URL
  const publicUrl = `/media/${key}`;

  return c.json(
    success({
      key,
      url: publicUrl,
      size: body.byteLength,
    })
  );
});

/**
 * POST /media/complete
 * Mark an upload as complete and get the final URL
 */
media.post('/complete', authMiddleware, async (c) => {
  const userId = c.get('userId');
  const body = await c.req.json();

  // Validate input
  const result = completeUploadSchema.safeParse(body);
  if (!result.success) {
    return c.json(
      error(ErrorCodes.VALIDATION_ERROR, result.error.errors[0].message),
      400
    );
  }

  const { key } = result.data;

  // Verify the media file record exists and belongs to user
  const mediaFile = await c.env.DB.prepare(
    'SELECT * FROM media_files WHERE key = ? AND user_id = ?'
  )
    .bind(key, userId)
    .first<MediaFile>();

  if (!mediaFile) {
    return c.json(error(ErrorCodes.NOT_FOUND, 'Media file not found'), 404);
  }

  // Verify file exists in R2
  const object = await c.env.MEDIA.head(key);
  if (!object) {
    return c.json(error(ErrorCodes.NOT_FOUND, 'File not uploaded'), 404);
  }

  // Return the public URL
  const publicUrl = `/media/${key}`;

  return c.json(
    success({
      key,
      url: publicUrl,
      size: object.size,
      contentType: mediaFile.content_type,
    })
  );
});

/**
 * GET /media/:key{.*}
 * Get a media file (with caching)
 */
media.get('/*', async (c) => {
  const key = c.req.path.replace('/media/', '');

  if (!key) {
    return c.json(error(ErrorCodes.INVALID_INPUT, 'Key required'), 400);
  }

  // Try to get from R2
  const object = await c.env.MEDIA.get(key);

  if (!object) {
    return c.json(error(ErrorCodes.NOT_FOUND, 'File not found'), 404);
  }

  const headers = new Headers();
  headers.set('Content-Type', object.httpMetadata?.contentType || 'application/octet-stream');
  headers.set('Content-Length', object.size.toString());
  headers.set('Cache-Control', 'public, max-age=31536000, immutable');
  headers.set('ETag', object.httpEtag);

  // Handle conditional requests
  const ifNoneMatch = c.req.header('If-None-Match');
  if (ifNoneMatch === object.httpEtag) {
    return new Response(null, { status: 304, headers });
  }

  return new Response(object.body, { headers });
});

/**
 * DELETE /media/:key{.*}
 * Delete a media file
 */
media.delete('/*', authMiddleware, async (c) => {
  const userId = c.get('userId');
  const key = c.req.path.replace('/media/', '');

  if (!key) {
    return c.json(error(ErrorCodes.INVALID_INPUT, 'Key required'), 400);
  }

  // Verify ownership
  const mediaFile = await c.env.DB.prepare(
    'SELECT * FROM media_files WHERE key = ? AND user_id = ?'
  )
    .bind(key, userId)
    .first<MediaFile>();

  if (!mediaFile) {
    return c.json(error(ErrorCodes.NOT_FOUND, 'Media file not found or access denied'), 404);
  }

  // Delete from R2
  await c.env.MEDIA.delete(key);

  // Delete from database
  await c.env.DB.prepare('DELETE FROM media_files WHERE key = ?')
    .bind(key)
    .run();

  return c.json(success({ message: 'File deleted' }));
});

/**
 * GET /media/info/:key{.*}
 * Get media file info without downloading
 */
media.get('/info/*', authMiddleware, async (c) => {
  const key = c.req.path.replace('/media/info/', '');

  if (!key) {
    return c.json(error(ErrorCodes.INVALID_INPUT, 'Key required'), 400);
  }

  const [mediaFile, object] = await Promise.all([
    c.env.DB.prepare('SELECT * FROM media_files WHERE key = ?')
      .bind(key)
      .first<MediaFile>(),
    c.env.MEDIA.head(key),
  ]);

  if (!mediaFile) {
    return c.json(error(ErrorCodes.NOT_FOUND, 'Media file not found'), 404);
  }

  return c.json(
    success({
      ...mediaFile,
      exists: Boolean(object),
      r2Size: object?.size,
      url: `/media/${key}`,
    })
  );
});

export { media as mediaRoutes };

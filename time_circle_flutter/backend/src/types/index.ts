/**
 * Aura API - Type Definitions
 */

// Cloudflare Bindings
export interface Env {
  DB: D1Database;
  MEDIA: R2Bucket;
  CACHE: KVNamespace;
  JWT_SECRET: string;
  ENVIRONMENT: string;
  API_VERSION: string;
}

// Auth Types
export interface JwtPayload {
  sub: string; // user id
  email: string;
  iat: number;
  exp: number;
}

export interface AuthUser {
  id: string;
  email: string;
  name: string;
  avatar: string | null;
}

// Database Models
export interface User {
  id: string;
  email: string;
  password_hash: string;
  name: string;
  avatar: string | null;
  created_at: string;
  updated_at: string;
}

export interface Circle {
  id: string;
  name: string;
  start_date: string | null;
  invite_code: string | null;
  invite_expires_at: string | null;
  created_by: string;
  created_at: string;
  updated_at: string;
}

export interface CircleMember {
  circle_id: string;
  user_id: string;
  role: 'admin' | 'member';
  role_label: string | null;
  joined_at: string;
}

export interface Moment {
  id: string;
  circle_id: string;
  author_id: string;
  content: string;
  media_type: 'text' | 'image' | 'video' | 'audio';
  media_url: string | null;
  timestamp: string;
  time_label: string;
  context_tags: string | null; // JSON string
  location: string | null;
  is_favorite: number;
  future_message: string | null;
  is_shared_to_world: number;
  world_topic: string | null;
  created_at: string;
  updated_at: string;
  deleted_at: string | null;
}

export interface Letter {
  id: string;
  circle_id: string;
  author_id: string;
  title: string;
  preview: string;
  content: string | null;
  status: 'draft' | 'sealed' | 'unlocked';
  type: 'annual' | 'milestone' | 'free';
  recipient: string;
  unlock_date: string | null;
  created_at: string;
  sealed_at: string | null;
  updated_at: string;
  deleted_at: string | null;
}

export interface WorldPost {
  id: string;
  author_id: string;
  moment_id: string | null;
  content: string;
  tag: string;
  resonance_count: number;
  bg_gradient: string;
  created_at: string;
  deleted_at: string | null;
}

export interface WorldChannel {
  id: string;
  name: string;
  description: string;
  post_count: number;
}

export interface Resonance {
  user_id: string;
  post_id: string;
  created_at: string;
}

export interface Comment {
  id: string;
  target_id: string;
  target_type: 'moment' | 'world_post';
  author_id: string;
  content: string;
  likes: number;
  reply_to_id: string | null;
  created_at: string;
  deleted_at: string | null;
}

export interface Session {
  id: string;
  user_id: string;
  refresh_token: string;
  expires_at: string;
  created_at: string;
}

export interface MediaFile {
  id: string;
  user_id: string;
  circle_id: string | null;
  key: string;
  filename: string | null;
  content_type: string | null;
  size: number | null;
  created_at: string;
}

export interface SyncLog {
  id: number;
  circle_id: string;
  entity_type: 'moment' | 'letter' | 'comment' | 'member';
  entity_id: string;
  action: 'create' | 'update' | 'delete';
  data: string | null;
  timestamp: string;
}

// API Request/Response Types
export interface ApiResponse<T = unknown> {
  success: boolean;
  data?: T;
  error?: {
    code: string;
    message: string;
  };
  meta?: {
    page?: number;
    limit?: number;
    total?: number;
    hasMore?: boolean;
  };
  requestId?: string;
}

export interface PaginationParams {
  page?: number;
  limit?: number;
}

// Auth Request Types
export interface RegisterRequest {
  email: string;
  password: string;
  name: string;
}

export interface LoginRequest {
  email: string;
  password: string;
}

export interface AuthResponse {
  user: Omit<User, 'password_hash'>;
  accessToken: string;
  refreshToken: string;
  expiresIn: number;
}

// Circle Request Types
export interface CreateCircleRequest {
  name: string;
  startDate?: string;
}

export interface JoinCircleRequest {
  inviteCode: string;
  roleLabel?: string;
}

// Moment Request Types
export interface CreateMomentRequest {
  content: string;
  mediaType: 'text' | 'image' | 'video' | 'audio';
  mediaUrl?: string;
  timestamp?: string;
  timeLabel: string;
  contextTags?: Array<{ type: string; label: string; emoji: string }>;
  location?: string;
  futureMessage?: string;
}

// Letter Request Types
export interface CreateLetterRequest {
  title: string;
  content?: string;
  type: 'annual' | 'milestone' | 'free';
  recipient: string;
}

export interface SealLetterRequest {
  unlockDate: string;
}

// World Request Types
export interface CreateWorldPostRequest {
  content: string;
  tag: string;
  bgGradient: string;
  momentId?: string;
}

// Comment Request Types
export interface CreateCommentRequest {
  content: string;
  replyToId?: string;
}

// Media Request Types
export interface UploadUrlRequest {
  filename: string;
  contentType: string;
  size: number;
  circleId?: string;
}

export interface UploadUrlResponse {
  uploadUrl: string;
  key: string;
  expiresIn: number;
}

// Sync Types
export interface SyncChange {
  entityType: string;
  entityId: string;
  action: 'create' | 'update' | 'delete';
  data: unknown;
  timestamp: string;
}

export interface SyncPushRequest {
  circleId: string;
  changes: SyncChange[];
  clientTimestamp: string;
}

export interface SyncChangesResponse {
  changes: SyncChange[];
  serverTimestamp: string;
  hasMore: boolean;
}

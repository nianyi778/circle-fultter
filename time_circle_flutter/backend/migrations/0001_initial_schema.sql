-- Aura 拾光 - Database Schema
-- Migration: 0001_initial_schema.sql

-- 用户表
CREATE TABLE IF NOT EXISTS users (
  id TEXT PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,
  password_hash TEXT NOT NULL,
  name TEXT NOT NULL,
  avatar TEXT,
  created_at TEXT DEFAULT (datetime('now')),
  updated_at TEXT DEFAULT (datetime('now'))
);
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);

-- 圈子表
CREATE TABLE IF NOT EXISTS circles (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  start_date TEXT,
  invite_code TEXT UNIQUE,
  invite_expires_at TEXT,
  created_by TEXT NOT NULL,
  created_at TEXT DEFAULT (datetime('now')),
  updated_at TEXT DEFAULT (datetime('now')),
  FOREIGN KEY (created_by) REFERENCES users(id)
);
CREATE INDEX IF NOT EXISTS idx_circles_invite ON circles(invite_code);

-- 圈子成员表
CREATE TABLE IF NOT EXISTS circle_members (
  circle_id TEXT NOT NULL,
  user_id TEXT NOT NULL,
  role TEXT DEFAULT 'member',
  role_label TEXT,
  joined_at TEXT DEFAULT (datetime('now')),
  PRIMARY KEY (circle_id, user_id),
  FOREIGN KEY (circle_id) REFERENCES circles(id) ON DELETE CASCADE,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);
CREATE INDEX IF NOT EXISTS idx_circle_members_user ON circle_members(user_id);

-- 时刻表
CREATE TABLE IF NOT EXISTS moments (
  id TEXT PRIMARY KEY,
  circle_id TEXT NOT NULL,
  author_id TEXT NOT NULL,
  content TEXT NOT NULL,
  media_type TEXT NOT NULL,
  media_url TEXT,
  timestamp TEXT NOT NULL,
  time_label TEXT NOT NULL,
  context_tags TEXT,
  location TEXT,
  is_favorite INTEGER DEFAULT 0,
  future_message TEXT,
  is_shared_to_world INTEGER DEFAULT 0,
  world_topic TEXT,
  created_at TEXT DEFAULT (datetime('now')),
  updated_at TEXT DEFAULT (datetime('now')),
  deleted_at TEXT,
  FOREIGN KEY (circle_id) REFERENCES circles(id) ON DELETE CASCADE,
  FOREIGN KEY (author_id) REFERENCES users(id)
);
CREATE INDEX IF NOT EXISTS idx_moments_circle ON moments(circle_id, timestamp DESC);
CREATE INDEX IF NOT EXISTS idx_moments_author ON moments(author_id);
CREATE INDEX IF NOT EXISTS idx_moments_deleted ON moments(deleted_at);

-- 信件表
CREATE TABLE IF NOT EXISTS letters (
  id TEXT PRIMARY KEY,
  circle_id TEXT NOT NULL,
  author_id TEXT NOT NULL,
  title TEXT NOT NULL,
  preview TEXT NOT NULL,
  content TEXT,
  status TEXT NOT NULL DEFAULT 'draft',
  type TEXT NOT NULL,
  recipient TEXT NOT NULL,
  unlock_date TEXT,
  created_at TEXT DEFAULT (datetime('now')),
  sealed_at TEXT,
  updated_at TEXT DEFAULT (datetime('now')),
  deleted_at TEXT,
  FOREIGN KEY (circle_id) REFERENCES circles(id) ON DELETE CASCADE,
  FOREIGN KEY (author_id) REFERENCES users(id)
);
CREATE INDEX IF NOT EXISTS idx_letters_circle ON letters(circle_id);
CREATE INDEX IF NOT EXISTS idx_letters_status ON letters(status);

-- 世界帖子表（全局公共）
CREATE TABLE IF NOT EXISTS world_posts (
  id TEXT PRIMARY KEY,
  author_id TEXT NOT NULL,
  moment_id TEXT,
  content TEXT NOT NULL,
  tag TEXT NOT NULL,
  resonance_count INTEGER DEFAULT 0,
  bg_gradient TEXT NOT NULL,
  created_at TEXT DEFAULT (datetime('now')),
  deleted_at TEXT,
  FOREIGN KEY (author_id) REFERENCES users(id)
);
CREATE INDEX IF NOT EXISTS idx_world_posts_tag ON world_posts(tag, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_world_posts_created ON world_posts(created_at DESC);

-- 世界频道表
CREATE TABLE IF NOT EXISTS world_channels (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT NOT NULL,
  post_count INTEGER DEFAULT 0
);

-- 共鸣记录表
CREATE TABLE IF NOT EXISTS resonances (
  user_id TEXT NOT NULL,
  post_id TEXT NOT NULL,
  created_at TEXT DEFAULT (datetime('now')),
  PRIMARY KEY (user_id, post_id),
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (post_id) REFERENCES world_posts(id) ON DELETE CASCADE
);

-- 评论表
CREATE TABLE IF NOT EXISTS comments (
  id TEXT PRIMARY KEY,
  target_id TEXT NOT NULL,
  target_type TEXT NOT NULL,
  author_id TEXT NOT NULL,
  content TEXT NOT NULL,
  likes INTEGER DEFAULT 0,
  reply_to_id TEXT,
  created_at TEXT DEFAULT (datetime('now')),
  deleted_at TEXT,
  FOREIGN KEY (author_id) REFERENCES users(id),
  FOREIGN KEY (reply_to_id) REFERENCES comments(id)
);
CREATE INDEX IF NOT EXISTS idx_comments_target ON comments(target_id, target_type);
CREATE INDEX IF NOT EXISTS idx_comments_author ON comments(author_id);

-- Session 表
CREATE TABLE IF NOT EXISTS sessions (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  refresh_token TEXT UNIQUE NOT NULL,
  expires_at TEXT NOT NULL,
  created_at TEXT DEFAULT (datetime('now')),
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);
CREATE INDEX IF NOT EXISTS idx_sessions_refresh ON sessions(refresh_token);
CREATE INDEX IF NOT EXISTS idx_sessions_user ON sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_sessions_expires ON sessions(expires_at);

-- 媒体文件表
CREATE TABLE IF NOT EXISTS media_files (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  circle_id TEXT,
  key TEXT UNIQUE NOT NULL,
  filename TEXT,
  content_type TEXT,
  size INTEGER,
  created_at TEXT DEFAULT (datetime('now')),
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (circle_id) REFERENCES circles(id) ON DELETE SET NULL
);
CREATE INDEX IF NOT EXISTS idx_media_key ON media_files(key);
CREATE INDEX IF NOT EXISTS idx_media_circle ON media_files(circle_id);

-- 同步日志表（用于增量同步）
CREATE TABLE IF NOT EXISTS sync_log (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  circle_id TEXT NOT NULL,
  entity_type TEXT NOT NULL,
  entity_id TEXT NOT NULL,
  action TEXT NOT NULL,
  data TEXT,
  timestamp TEXT DEFAULT (datetime('now')),
  FOREIGN KEY (circle_id) REFERENCES circles(id) ON DELETE CASCADE
);
CREATE INDEX IF NOT EXISTS idx_sync_log_circle ON sync_log(circle_id, timestamp);
CREATE INDEX IF NOT EXISTS idx_sync_log_entity ON sync_log(entity_type, entity_id);

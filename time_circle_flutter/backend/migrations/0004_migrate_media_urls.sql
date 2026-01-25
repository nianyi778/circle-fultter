-- Migration: 0004_migrate_media_urls.sql

-- Rebuild moments table to replace media_url with media_urls
CREATE TABLE IF NOT EXISTS moments_new (
  id TEXT PRIMARY KEY,
  circle_id TEXT NOT NULL,
  author_id TEXT NOT NULL,
  content TEXT NOT NULL,
  media_type TEXT NOT NULL,
  media_urls TEXT,
  timestamp TEXT NOT NULL,
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

INSERT INTO moments_new (
  id,
  circle_id,
  author_id,
  content,
  media_type,
  media_urls,
  timestamp,
  context_tags,
  location,
  is_favorite,
  future_message,
  is_shared_to_world,
  world_topic,
  created_at,
  updated_at,
  deleted_at
)
SELECT
  id,
  circle_id,
  author_id,
  content,
  media_type,
  CASE
    WHEN media_url IS NOT NULL AND media_url != '' THEN json_array(media_url)
    ELSE json_array()
  END AS media_urls,
  timestamp,
  context_tags,
  location,
  is_favorite,
  future_message,
  is_shared_to_world,
  world_topic,
  created_at,
  updated_at,
  deleted_at
FROM moments;

DROP TABLE moments;
ALTER TABLE moments_new RENAME TO moments;

CREATE INDEX IF NOT EXISTS idx_moments_circle ON moments(circle_id, timestamp DESC);
CREATE INDEX IF NOT EXISTS idx_moments_author ON moments(author_id);
CREATE INDEX IF NOT EXISTS idx_moments_deleted ON moments(deleted_at);

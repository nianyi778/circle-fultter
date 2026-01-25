-- Aura 拾光 - Seed Data
-- Migration: 0002_seed_data.sql

-- 默认世界频道
INSERT OR IGNORE INTO world_channels (id, name, description, post_count) VALUES
  ('c1', '写给未来', '写下你现在说不出口，但希望未来能被理解的话。', 0),
  ('c2', '今天很累', '如果你觉得累，可以在这里停一会儿。', 0),
  ('c3', '第一次', '那些让你惊喜或感动的第一次。', 0),
  ('c4', '只是爱', '不需要理由，只是想说爱你。', 0),
  ('c5', '深夜碎语', '睡不着的夜晚，写下此刻的心情。', 0),
  ('c6', '小确幸', '生活中那些微小但确定的幸福。', 0);

import 'user.dart';

/// 评论目标类型
enum CommentTargetType { moment, worldPost }

/// 留言/评论模型
class Comment {
  final String id;
  final String targetId; // 关联的目标 ID（moment 或 world_post）
  final CommentTargetType targetType; // 目标类型
  final User author; // 留言者
  final String content; // 留言内容
  final DateTime timestamp; // 留言时间
  final int likes; // 点赞数
  final User? replyTo; // 回复的目标用户（可选）

  const Comment({
    required this.id,
    required this.targetId,
    this.targetType = CommentTargetType.moment,
    required this.author,
    required this.content,
    required this.timestamp,
    this.likes = 0,
    this.replyTo,
  });

  /// 兼容旧代码的别名
  String get momentId => targetId;

  Comment copyWith({
    String? id,
    String? targetId,
    CommentTargetType? targetType,
    User? author,
    String? content,
    DateTime? timestamp,
    int? likes,
    User? replyTo,
  }) {
    return Comment(
      id: id ?? this.id,
      targetId: targetId ?? this.targetId,
      targetType: targetType ?? this.targetType,
      author: author ?? this.author,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      likes: likes ?? this.likes,
      replyTo: replyTo ?? this.replyTo,
    );
  }

  /// 相对时间显示
  String get relativeTime {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inMinutes < 1) {
      return '刚刚';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes} 分钟前';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} 小时前';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} 天前';
    } else {
      return '${timestamp.month}月${timestamp.day}日';
    }
  }
}

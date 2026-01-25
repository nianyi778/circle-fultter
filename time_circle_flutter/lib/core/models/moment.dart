import 'user.dart';

/// 媒体类型
enum MediaType { text, image, video, audio }

/// 语境标签类型
///
/// 泛化设计：
/// - myMood: 我当时的心情
/// - atmosphere: 当时的氛围/TA的状态
enum ContextTagType { myMood, atmosphere }

/// 语境标签
class ContextTag {
  final ContextTagType type;
  final String label;
  final String emoji;

  const ContextTag({
    required this.type,
    required this.label,
    required this.emoji,
  });

  /// 预设的心情标签
  static const List<ContextTag> myMoodTags = [
    ContextTag(type: ContextTagType.myMood, label: '平静', emoji: '😌'),
    ContextTag(type: ContextTagType.myMood, label: '开心', emoji: '😊'),
    ContextTag(type: ContextTagType.myMood, label: '累', emoji: '😵‍💫'),
    ContextTag(type: ContextTagType.myMood, label: '担心', emoji: '😟'),
    ContextTag(type: ContextTagType.myMood, label: '想哭', emoji: '🥹'),
    ContextTag(type: ContextTagType.myMood, label: '感动', emoji: '🥲'),
  ];

  /// 预设的氛围/状态标签
  static const List<ContextTag> atmosphereTags = [
    ContextTag(type: ContextTagType.atmosphere, label: '温馨', emoji: '🫂'),
    ContextTag(type: ContextTagType.atmosphere, label: '热闹', emoji: '⚡️'),
    ContextTag(type: ContextTagType.atmosphere, label: '安静', emoji: '🤫'),
    ContextTag(type: ContextTagType.atmosphere, label: '日常', emoji: '☕️'),
    ContextTag(type: ContextTagType.atmosphere, label: '特别', emoji: '✨'),
    ContextTag(type: ContextTagType.atmosphere, label: '治愈', emoji: '🌿'),
  ];

  String get display => '$emoji $label';
}

/// 记录/时刻 模型
class Moment {
  final String id;
  final String? circleId;
  final User author;
  final String content;
  final MediaType mediaType;
  final String? mediaUrl;
  final DateTime timestamp;
  final String timeLabel; // 时间标签（如"第3年"或"3岁2个月"）
  final List<ContextTag> contextTags;
  final String? location;
  final bool isFavorite;
  final String? futureMessage; // 对未来说一句
  final bool isSharedToWorld; // 是否已分享到世界
  final String? worldTopic; // 世界频道话题
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  const Moment({
    required this.id,
    this.circleId,
    required this.author,
    required this.content,
    required this.mediaType,
    this.mediaUrl,
    required this.timestamp,
    required this.timeLabel,
    this.contextTags = const [],
    this.location,
    this.isFavorite = false,
    this.futureMessage,
    this.isSharedToWorld = false,
    this.worldTopic,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  /// 向后兼容的别名
  String get childAgeLabel => timeLabel;

  Moment copyWith({
    String? id,
    String? circleId,
    User? author,
    String? content,
    MediaType? mediaType,
    String? mediaUrl,
    DateTime? timestamp,
    String? timeLabel,
    List<ContextTag>? contextTags,
    String? location,
    bool? isFavorite,
    String? futureMessage,
    bool? isSharedToWorld,
    String? worldTopic,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return Moment(
      id: id ?? this.id,
      circleId: circleId ?? this.circleId,
      author: author ?? this.author,
      content: content ?? this.content,
      mediaType: mediaType ?? this.mediaType,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      timestamp: timestamp ?? this.timestamp,
      timeLabel: timeLabel ?? this.timeLabel,
      contextTags: contextTags ?? this.contextTags,
      location: location ?? this.location,
      isFavorite: isFavorite ?? this.isFavorite,
      futureMessage: futureMessage ?? this.futureMessage,
      isSharedToWorld: isSharedToWorld ?? this.isSharedToWorld,
      worldTopic: worldTopic ?? this.worldTopic,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
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
    } else if (diff.inDays < 30) {
      return '${diff.inDays ~/ 7} 周前';
    } else if (diff.inDays < 365) {
      return '${diff.inDays ~/ 30} 个月前';
    } else {
      return '${diff.inDays ~/ 365} 年前';
    }
  }

  /// 生成时间叙事句
  String get timeNarrative {
    if (timeLabel.isEmpty) {
      return '这是你留下的这一刻。';
    }
    return '这是 $timeLabel 时留下的这一刻。';
  }
}

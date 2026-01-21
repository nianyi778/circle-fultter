import 'user.dart';

/// 媒体类型
enum MediaType { text, image, video, audio }

/// 语境标签类型
enum ContextTagType { parentMood, childState }

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

  /// 预设的父母情绪标签
  static const List<ContextTag> parentMoodTags = [
    ContextTag(type: ContextTagType.parentMood, label: '平静', emoji: '😌'),
    ContextTag(type: ContextTagType.parentMood, label: '开心', emoji: '😊'),
    ContextTag(type: ContextTagType.parentMood, label: '累', emoji: '😵‍💫'),
    ContextTag(type: ContextTagType.parentMood, label: '担心', emoji: '😟'),
    ContextTag(type: ContextTagType.parentMood, label: '想哭', emoji: '🥹'),
    ContextTag(type: ContextTagType.parentMood, label: '骄傲', emoji: '🥲'),
  ];

  /// 预设的孩子状态标签
  static const List<ContextTag> childStateTags = [
    ContextTag(type: ContextTagType.childState, label: '黏人', emoji: '🐨'),
    ContextTag(type: ContextTagType.childState, label: '闹腾', emoji: '⚡️'),
    ContextTag(type: ContextTagType.childState, label: '在进步', emoji: '🧠'),
    ContextTag(type: ContextTagType.childState, label: '安静', emoji: '🤫'),
    ContextTag(type: ContextTagType.childState, label: '生病', emoji: '🤒'),
    ContextTag(type: ContextTagType.childState, label: '专注', emoji: '🧐'),
  ];

  String get display => '$emoji $label';
}

/// 记录/时刻 模型
class Moment {
  final String id;
  final User author;
  final String content;
  final MediaType mediaType;
  final String? mediaUrl;
  final DateTime timestamp;
  final String childAgeLabel;
  final List<ContextTag> contextTags;
  final String? location;
  final bool isFavorite;
  final String? futureMessage; // 对未来说一句

  const Moment({
    required this.id,
    required this.author,
    required this.content,
    required this.mediaType,
    this.mediaUrl,
    required this.timestamp,
    required this.childAgeLabel,
    this.contextTags = const [],
    this.location,
    this.isFavorite = false,
    this.futureMessage,
  });

  Moment copyWith({
    String? id,
    User? author,
    String? content,
    MediaType? mediaType,
    String? mediaUrl,
    DateTime? timestamp,
    String? childAgeLabel,
    List<ContextTag>? contextTags,
    String? location,
    bool? isFavorite,
    String? futureMessage,
  }) {
    return Moment(
      id: id ?? this.id,
      author: author ?? this.author,
      content: content ?? this.content,
      mediaType: mediaType ?? this.mediaType,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      timestamp: timestamp ?? this.timestamp,
      childAgeLabel: childAgeLabel ?? this.childAgeLabel,
      contextTags: contextTags ?? this.contextTags,
      location: location ?? this.location,
      isFavorite: isFavorite ?? this.isFavorite,
      futureMessage: futureMessage ?? this.futureMessage,
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
    return '这是你在 TA $childAgeLabel 时留下的这一刻。';
  }
}

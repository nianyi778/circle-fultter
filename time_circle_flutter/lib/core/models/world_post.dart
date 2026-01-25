/// 世界频道帖子
class WorldPost {
  final String id;
  final String? momentId; // 关联的 Moment ID（用于撤回，匿名分享时不显示）
  final String content;
  final String tag;
  final int resonanceCount; // 共鸣数（不显示给用户）
  final String bgGradient;
  final DateTime timestamp;
  final bool hasResonated; // 当前用户是否已共鸣

  const WorldPost({
    required this.id,
    this.momentId,
    required this.content,
    required this.tag,
    this.resonanceCount = 0,
    required this.bgGradient,
    required this.timestamp,
    this.hasResonated = false,
  });

  WorldPost copyWith({
    String? id,
    String? momentId,
    String? content,
    String? tag,
    int? resonanceCount,
    String? bgGradient,
    DateTime? timestamp,
    bool? hasResonated,
  }) {
    return WorldPost(
      id: id ?? this.id,
      momentId: momentId ?? this.momentId,
      content: content ?? this.content,
      tag: tag ?? this.tag,
      resonanceCount: resonanceCount ?? this.resonanceCount,
      bgGradient: bgGradient ?? this.bgGradient,
      timestamp: timestamp ?? this.timestamp,
      hasResonated: hasResonated ?? this.hasResonated,
    );
  }
}

/// 频道主题
class WorldChannel {
  final String id;
  final String name;
  final String description;
  final int postCount;

  const WorldChannel({
    required this.id,
    required this.name,
    required this.description,
    this.postCount = 0,
  });
}

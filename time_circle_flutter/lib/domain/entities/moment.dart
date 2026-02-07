import 'package:equatable/equatable.dart';

import 'user.dart';

/// Media type for moments
enum MediaType {
  text,
  image,
  video,
  audio;

  /// Get display name in Chinese
  String get displayName {
    switch (this) {
      case MediaType.text:
        return '文字';
      case MediaType.image:
        return '图片';
      case MediaType.video:
        return '视频';
      case MediaType.audio:
        return '语音';
    }
  }

  /// Parse from string
  static MediaType fromString(String value) {
    return MediaType.values.firstWhere(
      (e) => e.name == value.toLowerCase(),
      orElse: () => MediaType.text,
    );
  }
}

/// Context tag for moment's emotional/situational context
class ContextTag extends Equatable {
  final String? myMood;
  final String? atmosphere;

  const ContextTag({this.myMood, this.atmosphere});

  factory ContextTag.empty() => const ContextTag();

  bool get isEmpty => myMood == null && atmosphere == null;
  bool get isNotEmpty => !isEmpty;

  ContextTag copyWith({String? myMood, String? atmosphere}) {
    return ContextTag(
      myMood: myMood ?? this.myMood,
      atmosphere: atmosphere ?? this.atmosphere,
    );
  }

  /// Convert to JSON map
  Map<String, dynamic> toJson() => {
    if (myMood != null) 'myMood': myMood,
    if (atmosphere != null) 'atmosphere': atmosphere,
  };

  /// Create from JSON map
  factory ContextTag.fromJson(Map<String, dynamic> json) => ContextTag(
    myMood: json['myMood'] as String?,
    atmosphere: json['atmosphere'] as String?,
  );

  @override
  List<Object?> get props => [myMood, atmosphere];
}

/// Predefined mood options
class MoodOptions {
  static const List<MoodOption> moods = [
    MoodOption(label: '平静', emoji: '😌'),
    MoodOption(label: '开心', emoji: '😊'),
    MoodOption(label: '累', emoji: '😵‍💫'),
    MoodOption(label: '担心', emoji: '😟'),
    MoodOption(label: '想哭', emoji: '🥹'),
    MoodOption(label: '感动', emoji: '🥲'),
  ];

  static const List<MoodOption> atmospheres = [
    MoodOption(label: '温馨', emoji: '🫂'),
    MoodOption(label: '热闹', emoji: '⚡️'),
    MoodOption(label: '安静', emoji: '🤫'),
    MoodOption(label: '日常', emoji: '☕️'),
    MoodOption(label: '特别', emoji: '✨'),
    MoodOption(label: '治愈', emoji: '🌿'),
  ];
}

class MoodOption extends Equatable {
  final String label;
  final String emoji;

  const MoodOption({required this.label, required this.emoji});

  String get display => '$emoji $label';

  @override
  List<Object?> get props => [label, emoji];
}

/// Moment entity - represents a memory/moment in the timeline
class Moment extends Equatable {
  final String id;
  final String circleId;
  final User author;
  final String content;
  final MediaType mediaType;
  final List<String> mediaUrls;
  final DateTime timestamp;
  final ContextTag contextTags;
  final String? location;
  final bool isFavorite;
  final String? futureMessage;
  final bool isSharedToWorld;
  final String? worldTopic;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  final SyncStatus syncStatus;

  const Moment({
    required this.id,
    required this.circleId,
    required this.author,
    required this.content,
    required this.mediaType,
    required this.mediaUrls,
    required this.timestamp,
    required this.contextTags,
    this.location,
    this.isFavorite = false,
    this.futureMessage,
    this.isSharedToWorld = false,
    this.worldTopic,
    required this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.syncStatus = SyncStatus.synced,
  });

  /// Empty moment for initialization
  factory Moment.empty() => Moment(
    id: '',
    circleId: '',
    author: User.empty(),
    content: '',
    mediaType: MediaType.text,
    mediaUrls: const [],
    timestamp: DateTime.now(),
    contextTags: const ContextTag(),
    createdAt: DateTime.now(),
  );

  /// Check if moment is valid
  bool get isValid => id.isNotEmpty && content.isNotEmpty;

  /// Check if moment has media
  bool get hasMedia => mediaUrls.isNotEmpty;

  /// Check if moment is text-only
  bool get isTextOnly => mediaType == MediaType.text && !hasMedia;

  /// Check if moment is deleted (soft delete)
  bool get isDeleted => deletedAt != null;

  /// Check if moment needs sync
  bool get needsSync => syncStatus != SyncStatus.synced;

  /// Relative time display (e.g., "3 minutes ago")
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

  /// Formatted date for display
  String get formattedDate {
    return '${timestamp.year}年${timestamp.month}月${timestamp.day}日';
  }

  /// Short formatted date
  String get shortDate {
    return '${timestamp.month}月${timestamp.day}日';
  }

  Moment copyWith({
    String? id,
    String? circleId,
    User? author,
    String? content,
    MediaType? mediaType,
    List<String>? mediaUrls,
    DateTime? timestamp,
    ContextTag? contextTags,
    String? location,
    bool? isFavorite,
    String? futureMessage,
    bool? isSharedToWorld,
    String? worldTopic,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    SyncStatus? syncStatus,
  }) {
    return Moment(
      id: id ?? this.id,
      circleId: circleId ?? this.circleId,
      author: author ?? this.author,
      content: content ?? this.content,
      mediaType: mediaType ?? this.mediaType,
      mediaUrls: mediaUrls ?? this.mediaUrls,
      timestamp: timestamp ?? this.timestamp,
      contextTags: contextTags ?? this.contextTags,
      location: location ?? this.location,
      isFavorite: isFavorite ?? this.isFavorite,
      futureMessage: futureMessage ?? this.futureMessage,
      isSharedToWorld: isSharedToWorld ?? this.isSharedToWorld,
      worldTopic: worldTopic ?? this.worldTopic,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  @override
  List<Object?> get props => [
    id,
    circleId,
    author,
    content,
    mediaType,
    mediaUrls,
    timestamp,
    contextTags,
    location,
    isFavorite,
    futureMessage,
    isSharedToWorld,
    worldTopic,
    createdAt,
    updatedAt,
    deletedAt,
    syncStatus,
  ];
}

/// Sync status for offline-first architecture
enum SyncStatus {
  /// Fully synced with server
  synced,

  /// Created locally, pending upload
  pendingCreate,

  /// Updated locally, pending sync
  pendingUpdate,

  /// Deleted locally, pending sync
  pendingDelete,

  /// Sync failed, will retry
  failed;

  bool get isPending =>
      this == SyncStatus.pendingCreate ||
      this == SyncStatus.pendingUpdate ||
      this == SyncStatus.pendingDelete;
}

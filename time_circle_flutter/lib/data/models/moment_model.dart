import '../../domain/entities/moment.dart';
import '../../domain/entities/user.dart';
import 'user_model.dart';

/// Data Transfer Object for Moment
/// Handles JSON serialization/deserialization
class MomentModel {
  final String id;
  final String circleId;
  final String authorId;
  final String content;
  final String mediaType;
  final List<String> mediaUrls;
  final DateTime timestamp;
  final List<ContextTagModel> contextTags;
  final String? location;
  final bool isFavorite;
  final String? futureMessage;
  final bool isSharedToWorld;
  final String? worldTopic;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int commentCount;
  final AuthorModel? author;

  const MomentModel({
    required this.id,
    required this.circleId,
    required this.authorId,
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
    this.commentCount = 0,
    this.author,
  });

  /// Create from JSON (API response)
  factory MomentModel.fromJson(Map<String, dynamic> json) {
    return MomentModel(
      id: json['id'] as String,
      circleId: json['circle_id'] as String,
      authorId: json['author_id'] as String,
      content: json['content'] as String,
      mediaType: json['media_type'] as String? ?? 'text',
      mediaUrls: _parseMediaUrls(json['media_urls']),
      timestamp: _parseDateTime(json['timestamp']),
      contextTags: _parseContextTags(json['context_tags']),
      location: json['location'] as String?,
      isFavorite: json['is_favorite'] as bool? ?? false,
      futureMessage: json['future_message'] as String?,
      isSharedToWorld: json['is_shared_to_world'] as bool? ?? false,
      worldTopic: json['world_topic'] as String?,
      createdAt: _parseDateTime(json['created_at']),
      updatedAt:
          json['updated_at'] != null
              ? _parseDateTime(json['updated_at'])
              : null,
      commentCount: json['comment_count'] as int? ?? 0,
      author:
          json['author'] != null
              ? AuthorModel.fromJson(json['author'] as Map<String, dynamic>)
              : null,
    );
  }

  /// Convert to JSON (for API requests)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'circle_id': circleId,
      'author_id': authorId,
      'content': content,
      'media_type': mediaType,
      'media_urls': mediaUrls,
      'timestamp': timestamp.toIso8601String(),
      'context_tags': contextTags.map((t) => t.toJson()).toList(),
      if (location != null) 'location': location,
      'is_favorite': isFavorite,
      if (futureMessage != null) 'future_message': futureMessage,
      'is_shared_to_world': isSharedToWorld,
      if (worldTopic != null) 'world_topic': worldTopic,
    };
  }

  /// Convert to Domain Entity
  Moment toEntity() {
    return Moment(
      id: id,
      circleId: circleId,
      author:
          author?.toEntity() ??
          User(
            id: authorId,
            name: '未知用户',
            avatar: '',
            email: '',
            createdAt: DateTime.now(),
          ),
      content: content,
      mediaType: MediaType.fromString(mediaType),
      mediaUrls: mediaUrls,
      timestamp: timestamp,
      contextTags: _contextTagsToEntity(),
      location: location,
      isFavorite: isFavorite,
      futureMessage: futureMessage,
      isSharedToWorld: isSharedToWorld,
      worldTopic: worldTopic,
      createdAt: createdAt,
      updatedAt: updatedAt,
      syncStatus: SyncStatus.synced,
    );
  }

  /// Create from Domain Entity
  factory MomentModel.fromEntity(Moment entity) {
    return MomentModel(
      id: entity.id,
      circleId: entity.circleId,
      authorId: entity.author.id,
      content: entity.content,
      mediaType: entity.mediaType.name,
      mediaUrls: entity.mediaUrls,
      timestamp: entity.timestamp,
      contextTags: _contextTagsFromEntity(entity.contextTags),
      location: entity.location,
      isFavorite: entity.isFavorite,
      futureMessage: entity.futureMessage,
      isSharedToWorld: entity.isSharedToWorld,
      worldTopic: entity.worldTopic,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      author: AuthorModel.fromEntity(entity.author),
    );
  }

  // Helper methods
  static List<String> _parseMediaUrls(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    return [];
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value is DateTime) return value;
    if (value is String) return DateTime.parse(value);
    return DateTime.now();
  }

  static List<ContextTagModel> _parseContextTags(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value
          .map((e) => ContextTagModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  ContextTag _contextTagsToEntity() {
    String? myMood;
    String? atmosphere;

    for (final tag in contextTags) {
      if (tag.type == 'mood') {
        myMood = '${tag.emoji} ${tag.label}';
      } else if (tag.type == 'atmosphere') {
        atmosphere = '${tag.emoji} ${tag.label}';
      }
    }

    return ContextTag(myMood: myMood, atmosphere: atmosphere);
  }

  static List<ContextTagModel> _contextTagsFromEntity(ContextTag tags) {
    final result = <ContextTagModel>[];

    if (tags.myMood != null) {
      final parts = tags.myMood!.split(' ');
      if (parts.length >= 2) {
        result.add(
          ContextTagModel(
            type: 'mood',
            label: parts.sublist(1).join(' '),
            emoji: parts[0],
          ),
        );
      }
    }

    if (tags.atmosphere != null) {
      final parts = tags.atmosphere!.split(' ');
      if (parts.length >= 2) {
        result.add(
          ContextTagModel(
            type: 'atmosphere',
            label: parts.sublist(1).join(' '),
            emoji: parts[0],
          ),
        );
      }
    }

    return result;
  }
}

/// Context Tag Model
class ContextTagModel {
  final String type;
  final String label;
  final String emoji;

  const ContextTagModel({
    required this.type,
    required this.label,
    required this.emoji,
  });

  factory ContextTagModel.fromJson(Map<String, dynamic> json) {
    return ContextTagModel(
      type: json['type'] as String? ?? '',
      label: json['label'] as String? ?? '',
      emoji: json['emoji'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'type': type,
    'label': label,
    'emoji': emoji,
  };
}

/// Create Moment Request DTO
class CreateMomentRequest {
  final String content;
  final String mediaType;
  final List<String> mediaUrls;
  final DateTime? timestamp;
  final List<ContextTagModel>? contextTags;
  final String? location;
  final String? futureMessage;

  const CreateMomentRequest({
    required this.content,
    this.mediaType = 'text',
    this.mediaUrls = const [],
    this.timestamp,
    this.contextTags,
    this.location,
    this.futureMessage,
  });

  Map<String, dynamic> toJson() => {
    'content': content,
    'media_type': mediaType,
    'media_urls': mediaUrls,
    if (timestamp != null) 'timestamp': timestamp!.toIso8601String(),
    if (contextTags != null)
      'context_tags': contextTags!.map((t) => t.toJson()).toList(),
    if (location != null) 'location': location,
    if (futureMessage != null) 'future_message': futureMessage,
  };
}

/// Update Moment Request DTO
class UpdateMomentRequest {
  final String? content;
  final List<String>? mediaUrls;
  final List<ContextTagModel>? contextTags;
  final String? location;
  final String? futureMessage;

  const UpdateMomentRequest({
    this.content,
    this.mediaUrls,
    this.contextTags,
    this.location,
    this.futureMessage,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (content != null) map['content'] = content;
    if (mediaUrls != null) map['media_urls'] = mediaUrls;
    if (contextTags != null) {
      map['context_tags'] = contextTags!.map((t) => t.toJson()).toList();
    }
    if (location != null) map['location'] = location;
    if (futureMessage != null) map['future_message'] = futureMessage;
    return map;
  }
}

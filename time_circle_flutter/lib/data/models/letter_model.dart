import '../../domain/entities/letter.dart';
import 'user_model.dart';

/// Letter status enum
enum LetterStatusModel {
  draft,
  sealed,
  unlocked;

  static LetterStatusModel fromString(String value) {
    return LetterStatusModel.values.firstWhere(
      (e) => e.name == value.toLowerCase(),
      orElse: () => LetterStatusModel.draft,
    );
  }

  LetterStatus toEntity() {
    switch (this) {
      case LetterStatusModel.draft:
        return LetterStatus.draft;
      case LetterStatusModel.sealed:
        return LetterStatus.sealed;
      case LetterStatusModel.unlocked:
        return LetterStatus.unlocked;
    }
  }
}

/// Letter type enum
enum LetterTypeModel {
  annual,
  milestone,
  free;

  static LetterTypeModel fromString(String value) {
    return LetterTypeModel.values.firstWhere(
      (e) => e.name == value.toLowerCase(),
      orElse: () => LetterTypeModel.free,
    );
  }

  LetterType toEntity() {
    switch (this) {
      case LetterTypeModel.annual:
        return LetterType.annual;
      case LetterTypeModel.milestone:
        return LetterType.milestone;
      case LetterTypeModel.free:
        return LetterType.free;
    }
  }
}

/// Data Transfer Object for Letter
class LetterModel {
  final String id;
  final String circleId;
  final String authorId;
  final String title;
  final String preview;
  final String? content;
  final LetterStatusModel status;
  final LetterTypeModel type;
  final String recipient;
  final DateTime? unlockDate;
  final DateTime createdAt;
  final DateTime? sealedAt;
  final DateTime? updatedAt;
  final AuthorModel? author;

  const LetterModel({
    required this.id,
    required this.circleId,
    required this.authorId,
    required this.title,
    required this.preview,
    this.content,
    required this.status,
    required this.type,
    required this.recipient,
    this.unlockDate,
    required this.createdAt,
    this.sealedAt,
    this.updatedAt,
    this.author,
  });

  factory LetterModel.fromJson(Map<String, dynamic> json) {
    return LetterModel(
      id: json['id'] as String,
      circleId: json['circle_id'] as String,
      authorId: json['author_id'] as String,
      title: json['title'] as String,
      preview: json['preview'] as String? ?? '',
      content: json['content'] as String?,
      status: LetterStatusModel.fromString(
        json['status'] as String? ?? 'draft',
      ),
      type: LetterTypeModel.fromString(json['type'] as String? ?? 'free'),
      recipient: json['recipient'] as String? ?? '',
      unlockDate:
          json['unlock_date'] != null
              ? DateTime.parse(json['unlock_date'] as String)
              : null,
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'] as String)
              : DateTime.now(),
      sealedAt:
          json['sealed_at'] != null
              ? DateTime.parse(json['sealed_at'] as String)
              : null,
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'] as String)
              : null,
      author:
          json['author'] != null
              ? AuthorModel.fromJson(json['author'] as Map<String, dynamic>)
              : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'circle_id': circleId,
    'author_id': authorId,
    'title': title,
    'preview': preview,
    if (content != null) 'content': content,
    'status': status.name,
    'type': type.name,
    'recipient': recipient,
    if (unlockDate != null) 'unlock_date': unlockDate!.toIso8601String(),
    'created_at': createdAt.toIso8601String(),
    if (sealedAt != null) 'sealed_at': sealedAt!.toIso8601String(),
    if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
  };

  Letter toEntity() {
    return Letter(
      id: id,
      circleId: circleId,
      author: author?.toEntity(),
      title: title,
      preview: preview,
      content: content,
      status: status.toEntity(),
      type: type.toEntity(),
      recipient: recipient,
      unlockDate: unlockDate,
      createdAt: createdAt,
      sealedAt: sealedAt,
    );
  }
}

/// Create Letter Request
class CreateLetterRequest {
  final String title;
  final String? content;
  final String type;
  final String recipient;

  const CreateLetterRequest({
    required this.title,
    this.content,
    this.type = 'free',
    required this.recipient,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    if (content != null) 'content': content,
    'type': type,
    'recipient': recipient,
  };
}

/// Update Letter Request
class UpdateLetterRequest {
  final String? title;
  final String? content;
  final String? recipient;

  const UpdateLetterRequest({this.title, this.content, this.recipient});

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (title != null) map['title'] = title;
    if (content != null) map['content'] = content;
    if (recipient != null) map['recipient'] = recipient;
    return map;
  }
}

/// Seal Letter Request
class SealLetterRequest {
  final DateTime unlockDate;

  const SealLetterRequest({required this.unlockDate});

  Map<String, dynamic> toJson() => {
    'unlock_date': unlockDate.toIso8601String(),
  };
}

/// Letter Stats
class LetterStatsModel {
  final int total;
  final int draft;
  final int sealed;
  final int unlocked;

  const LetterStatsModel({
    this.total = 0,
    this.draft = 0,
    this.sealed = 0,
    this.unlocked = 0,
  });

  factory LetterStatsModel.fromJson(Map<String, dynamic> json) {
    return LetterStatsModel(
      total: json['total'] as int? ?? 0,
      draft: json['draft'] as int? ?? 0,
      sealed: json['sealed'] as int? ?? 0,
      unlocked: json['unlocked'] as int? ?? 0,
    );
  }
}

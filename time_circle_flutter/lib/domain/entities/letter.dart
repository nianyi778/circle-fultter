import 'package:equatable/equatable.dart';

import 'user.dart';

/// Letter status
enum LetterStatus {
  /// Draft - can be edited
  draft,

  /// Sealed - encrypted and locked until unlock date
  sealed,

  /// Unlocked - can be read
  unlocked;

  String get displayName {
    switch (this) {
      case LetterStatus.draft:
        return '草稿';
      case LetterStatus.sealed:
        return '已封存';
      case LetterStatus.unlocked:
        return '已解锁';
    }
  }

  static LetterStatus fromString(String value) {
    return LetterStatus.values.firstWhere(
      (e) => e.name == value.toLowerCase(),
      orElse: () => LetterStatus.draft,
    );
  }
}

/// Letter type
enum LetterType {
  /// Annual letter - year-end reflection
  annual,

  /// Milestone letter - for special occasions
  milestone,

  /// Free letter - any time
  free;

  String get displayName {
    switch (this) {
      case LetterType.annual:
        return '年度信';
      case LetterType.milestone:
        return '里程碑';
      case LetterType.free:
        return '自由信';
    }
  }

  static LetterType fromString(String value) {
    return LetterType.values.firstWhere(
      (e) => e.name == value.toLowerCase(),
      orElse: () => LetterType.free,
    );
  }
}

/// Letter entity - time capsule letter
class Letter extends Equatable {
  final String id;
  final String circleId;
  final User? author;
  final String title;
  final String? content;
  final String? preview;
  final LetterStatus status;
  final DateTime? unlockDate;
  final String? recipient;
  final LetterType type;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? sealedAt;
  final DateTime? unlockedAt;

  const Letter({
    required this.id,
    required this.circleId,
    this.author,
    required this.title,
    this.content,
    this.preview,
    this.status = LetterStatus.draft,
    this.unlockDate,
    this.recipient,
    this.type = LetterType.free,
    required this.createdAt,
    this.updatedAt,
    this.sealedAt,
    this.unlockedAt,
  });

  /// Empty letter for initialization
  factory Letter.empty() =>
      Letter(id: '', circleId: '', title: '', createdAt: DateTime.now());

  /// Check if letter is valid
  bool get isValid => id.isNotEmpty && title.isNotEmpty;

  /// Check if letter is editable (only drafts)
  bool get isEditable => status == LetterStatus.draft;

  /// Check if letter is readable (only unlocked)
  bool get isReadable => status == LetterStatus.unlocked;

  /// Check if letter is sealed
  bool get isSealed => status == LetterStatus.sealed;

  /// Check if letter can be unlocked (past unlock date)
  bool get canUnlock {
    if (status != LetterStatus.sealed) return false;
    if (unlockDate == null) return false;
    return DateTime.now().isAfter(unlockDate!);
  }

  /// Days until unlock
  int? get daysUntilUnlock {
    if (unlockDate == null) return null;
    final diff = unlockDate!.difference(DateTime.now());
    return diff.inDays > 0 ? diff.inDays : 0;
  }

  /// Formatted unlock date
  String? get formattedUnlockDate {
    if (unlockDate == null) return null;
    return '${unlockDate!.year}年${unlockDate!.month}月${unlockDate!.day}日';
  }

  /// Get status badge color
  String get statusColor {
    switch (status) {
      case LetterStatus.draft:
        return 'warning';
      case LetterStatus.sealed:
        return 'primary';
      case LetterStatus.unlocked:
        return 'success';
    }
  }

  Letter copyWith({
    String? id,
    String? circleId,
    User? author,
    String? title,
    String? content,
    String? preview,
    LetterStatus? status,
    DateTime? unlockDate,
    String? recipient,
    LetterType? type,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? sealedAt,
    DateTime? unlockedAt,
  }) {
    return Letter(
      id: id ?? this.id,
      circleId: circleId ?? this.circleId,
      author: author ?? this.author,
      title: title ?? this.title,
      content: content ?? this.content,
      preview: preview ?? this.preview,
      status: status ?? this.status,
      unlockDate: unlockDate ?? this.unlockDate,
      recipient: recipient ?? this.recipient,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      sealedAt: sealedAt ?? this.sealedAt,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    circleId,
    author,
    title,
    content,
    preview,
    status,
    unlockDate,
    recipient,
    type,
    createdAt,
    updatedAt,
    sealedAt,
    unlockedAt,
  ];
}

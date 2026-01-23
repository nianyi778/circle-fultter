/// 信的状态
enum LetterStatus { draft, sealed, unlocked }

/// 信的类型
enum LetterType { annual, milestone, free }

/// 信 模型
class Letter {
  final String id;
  final String title;
  final String preview;
  final LetterStatus status;
  final DateTime? unlockDate;
  final String recipient;
  final LetterType type;
  final String? content;
  final DateTime? createdAt;
  final DateTime? sealedAt;

  const Letter({
    required this.id,
    required this.title,
    required this.preview,
    required this.status,
    this.unlockDate,
    required this.recipient,
    required this.type,
    this.content,
    this.createdAt,
    this.sealedAt,
  });

  Letter copyWith({
    String? id,
    String? title,
    String? preview,
    LetterStatus? status,
    DateTime? unlockDate,
    String? recipient,
    LetterType? type,
    String? content,
    DateTime? createdAt,
    DateTime? sealedAt,
  }) {
    return Letter(
      id: id ?? this.id,
      title: title ?? this.title,
      preview: preview ?? this.preview,
      status: status ?? this.status,
      unlockDate: unlockDate ?? this.unlockDate,
      recipient: recipient ?? this.recipient,
      type: type ?? this.type,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      sealedAt: sealedAt ?? this.sealedAt,
    );
  }

  /// 状态标签
  String get statusLabel {
    switch (status) {
      case LetterStatus.draft:
        return '草稿';
      case LetterStatus.sealed:
        return '已封存';
      case LetterStatus.unlocked:
        return '已解锁';
    }
  }

  /// 类型标签
  String get typeLabel {
    switch (type) {
      case LetterType.annual:
        return '年度信';
      case LetterType.milestone:
        return '节点信';
      case LetterType.free:
        return '自由信';
    }
  }

  /// 是否可编辑
  bool get canEdit => status == LetterStatus.draft;

  /// 是否可阅读
  bool get canRead => status == LetterStatus.unlocked;

  /// 是否已锁定
  bool get isLocked => status == LetterStatus.sealed;

  /// 距离解锁的时间描述
  String? get unlockTimeDescription {
    if (unlockDate == null) return null;
    final now = DateTime.now();
    final diff = unlockDate!.difference(now);

    if (diff.isNegative) {
      return '可以解锁了';
    }

    final years = diff.inDays ~/ 365;
    if (years > 0) {
      return '$years年后解锁';
    }

    final months = diff.inDays ~/ 30;
    if (months > 0) {
      return '$months个月后解锁';
    }

    return '${diff.inDays}天后解锁';
  }
}

import 'package:equatable/equatable.dart';

/// User entity - represents a user in the domain layer
///
/// This is a pure domain entity with no external dependencies.
/// Used across the application for user-related operations.
class User extends Equatable {
  final String id;
  final String name;
  final String avatar;
  final String? email;
  final String? roleLabel;
  final DateTime? joinedAt;
  final DateTime? createdAt;

  const User({
    required this.id,
    required this.name,
    required this.avatar,
    this.email,
    this.roleLabel,
    this.joinedAt,
    this.createdAt,
  });

  /// Empty user for initialization
  factory User.empty() => const User(id: '', name: '', avatar: '');

  /// Check if user is valid (has required fields)
  bool get isValid => id.isNotEmpty && name.isNotEmpty;

  /// Get display name (fallback to email if name is empty)
  String get displayName => name.isNotEmpty ? name : (email ?? 'Unknown');

  /// Get initials for avatar fallback
  String get initials {
    if (name.isEmpty) return '?';
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  User copyWith({
    String? id,
    String? name,
    String? avatar,
    String? email,
    String? roleLabel,
    DateTime? joinedAt,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      email: email ?? this.email,
      roleLabel: roleLabel ?? this.roleLabel,
      joinedAt: joinedAt ?? this.joinedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    avatar,
    email,
    roleLabel,
    joinedAt,
    createdAt,
  ];
}

/// Circle information for the current user
class CircleInfo extends Equatable {
  final String id;
  final String name;
  final DateTime? startDate;
  final DateTime? joinedAt;
  final int memberCount;
  final String? inviteCode;

  const CircleInfo({
    required this.id,
    required this.name,
    this.startDate,
    this.joinedAt,
    this.memberCount = 0,
    this.inviteCode,
  });

  /// Empty circle for initialization
  factory CircleInfo.empty() => const CircleInfo(id: '', name: '');

  /// Check if circle info is valid
  bool get isValid => id.isNotEmpty && name.isNotEmpty;

  /// Calculate days since circle started
  int? get daysSinceStart {
    if (startDate == null) return null;
    return DateTime.now().difference(startDate!).inDays;
  }

  /// Get formatted duration label (e.g., "365 days")
  String get durationLabel {
    final days = daysSinceStart;
    if (days == null) return '';
    if (days < 30) return '$days days';
    if (days < 365) return '${days ~/ 30} months';
    final years = days ~/ 365;
    final remainingMonths = (days % 365) ~/ 30;
    if (remainingMonths == 0) return '$years years';
    return '$years years $remainingMonths months';
  }

  /// Get season-based label
  String get seasonLabel {
    final now = DateTime.now();
    final month = now.month;
    if (month >= 3 && month <= 5) return 'Spring';
    if (month >= 6 && month <= 8) return 'Summer';
    if (month >= 9 && month <= 11) return 'Autumn';
    return 'Winter';
  }

  CircleInfo copyWith({
    String? id,
    String? name,
    DateTime? startDate,
    DateTime? joinedAt,
    int? memberCount,
    String? inviteCode,
  }) {
    return CircleInfo(
      id: id ?? this.id,
      name: name ?? this.name,
      startDate: startDate ?? this.startDate,
      joinedAt: joinedAt ?? this.joinedAt,
      memberCount: memberCount ?? this.memberCount,
      inviteCode: inviteCode ?? this.inviteCode,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    startDate,
    joinedAt,
    memberCount,
    inviteCode,
  ];
}

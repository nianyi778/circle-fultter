import '../../domain/entities/user.dart';

/// Data Transfer Object for User
class UserModel {
  final String id;
  final String email;
  final String name;
  final String? avatar;
  final String? roleLabel;
  final DateTime? joinedAt;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.avatar,
    this.roleLabel,
    this.joinedAt,
    required this.createdAt,
    this.updatedAt,
  });

  /// Create from JSON (API response)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String? ?? '',
      name: json['name'] as String? ?? '',
      avatar: json['avatar'] as String?,
      roleLabel: json['role_label'] as String?,
      joinedAt:
          json['joined_at'] != null
              ? DateTime.parse(json['joined_at'] as String)
              : null,
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'] as String)
              : DateTime.now(),
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'] as String)
              : null,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'name': name,
    if (avatar != null) 'avatar': avatar,
    if (roleLabel != null) 'role_label': roleLabel,
    if (joinedAt != null) 'joined_at': joinedAt!.toIso8601String(),
    'created_at': createdAt.toIso8601String(),
    if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
  };

  /// Convert to Domain Entity
  User toEntity() {
    return User(
      id: id,
      name: name,
      avatar: avatar ?? '',
      email: email,
      roleLabel: roleLabel,
      joinedAt: joinedAt,
      createdAt: createdAt,
    );
  }

  /// Create from Domain Entity
  factory UserModel.fromEntity(User entity) {
    return UserModel(
      id: entity.id,
      email: entity.email ?? '',
      name: entity.name,
      avatar: entity.avatar.isNotEmpty ? entity.avatar : null,
      roleLabel: entity.roleLabel,
      joinedAt: entity.joinedAt,
      createdAt: entity.createdAt ?? DateTime.now(),
    );
  }
}

/// Simplified Author Model for embedded author info
class AuthorModel {
  final String id;
  final String name;
  final String? avatar;

  const AuthorModel({required this.id, required this.name, this.avatar});

  factory AuthorModel.fromJson(Map<String, dynamic> json) {
    return AuthorModel(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      avatar: json['avatar'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    if (avatar != null) 'avatar': avatar,
  };

  User toEntity() {
    return User(id: id, name: name, avatar: avatar ?? '');
  }

  factory AuthorModel.fromEntity(User entity) {
    return AuthorModel(
      id: entity.id,
      name: entity.name,
      avatar: entity.avatar.isNotEmpty ? entity.avatar : null,
    );
  }
}

/// Circle Model
class CircleModel {
  final String id;
  final String name;
  final DateTime? startDate;
  final String? inviteCode;
  final DateTime? inviteExpiresAt;
  final String createdBy;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? role;
  final String? roleLabel;
  final DateTime? joinedAt;
  final int memberCount;
  final int momentCount;
  final int? letterCount;

  const CircleModel({
    required this.id,
    required this.name,
    this.startDate,
    this.inviteCode,
    this.inviteExpiresAt,
    required this.createdBy,
    required this.createdAt,
    this.updatedAt,
    this.role,
    this.roleLabel,
    this.joinedAt,
    this.memberCount = 0,
    this.momentCount = 0,
    this.letterCount,
  });

  factory CircleModel.fromJson(Map<String, dynamic> json) {
    return CircleModel(
      id: json['id'] as String,
      name: json['name'] as String,
      startDate:
          json['start_date'] != null
              ? DateTime.parse(json['start_date'] as String)
              : null,
      inviteCode: json['invite_code'] as String?,
      inviteExpiresAt:
          json['invite_expires_at'] != null
              ? DateTime.parse(json['invite_expires_at'] as String)
              : null,
      createdBy: json['created_by'] as String? ?? '',
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'] as String)
              : DateTime.now(),
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'] as String)
              : null,
      role: json['role'] as String?,
      roleLabel: json['role_label'] as String?,
      joinedAt:
          json['joined_at'] != null
              ? DateTime.parse(json['joined_at'] as String)
              : null,
      memberCount: json['member_count'] as int? ?? 0,
      momentCount: json['moment_count'] as int? ?? 0,
      letterCount: json['letter_count'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    if (startDate != null) 'start_date': startDate!.toIso8601String(),
    if (inviteCode != null) 'invite_code': inviteCode,
    if (inviteExpiresAt != null)
      'invite_expires_at': inviteExpiresAt!.toIso8601String(),
    'created_by': createdBy,
    'created_at': createdAt.toIso8601String(),
    if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    if (role != null) 'role': role,
    if (roleLabel != null) 'role_label': roleLabel,
    if (joinedAt != null) 'joined_at': joinedAt!.toIso8601String(),
    'member_count': memberCount,
    'moment_count': momentCount,
    if (letterCount != null) 'letter_count': letterCount,
  };

  CircleInfo toEntity() {
    return CircleInfo(
      id: id,
      name: name,
      startDate: startDate,
      joinedAt: joinedAt,
      memberCount: memberCount,
      inviteCode: inviteCode,
    );
  }
}

/// Auth Response Model
class AuthResponseModel {
  final UserModel user;
  final String accessToken;
  final String refreshToken;
  final int expiresIn;

  const AuthResponseModel({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      accessToken:
          json['accessToken'] as String? ?? json['access_token'] as String,
      refreshToken:
          json['refreshToken'] as String? ?? json['refresh_token'] as String,
      expiresIn:
          json['expiresIn'] as int? ?? json['expires_in'] as int? ?? 3600,
    );
  }
}

/// Login Request
class LoginRequest {
  final String email;
  final String password;

  const LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() => {'email': email, 'password': password};
}

/// Register Request
class RegisterRequest {
  final String email;
  final String password;
  final String name;

  const RegisterRequest({
    required this.email,
    required this.password,
    required this.name,
  });

  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
    'name': name,
  };
}

/// Update User Request
class UpdateUserRequest {
  final String? name;
  final String? avatar;
  final String? roleLabel;

  const UpdateUserRequest({this.name, this.avatar, this.roleLabel});

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (name != null) map['name'] = name;
    if (avatar != null) map['avatar'] = avatar;
    if (roleLabel != null) map['roleLabel'] = roleLabel;
    return map;
  }
}

/// Circle Member Model
class CircleMemberModel {
  final String id;
  final String name;
  final String email;
  final String? avatar;
  final String role;
  final String? roleLabel;
  final DateTime joinedAt;

  const CircleMemberModel({
    required this.id,
    required this.name,
    required this.email,
    this.avatar,
    required this.role,
    this.roleLabel,
    required this.joinedAt,
  });

  factory CircleMemberModel.fromJson(Map<String, dynamic> json) {
    return CircleMemberModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String? ?? '',
      avatar: json['avatar'] as String?,
      role: json['role'] as String? ?? 'member',
      roleLabel: json['role_label'] as String?,
      joinedAt:
          json['joined_at'] != null
              ? DateTime.parse(json['joined_at'] as String)
              : DateTime.now(),
    );
  }

  User toEntity() {
    return User(
      id: id,
      name: name,
      avatar: avatar ?? '',
      email: email,
      roleLabel: roleLabel,
      joinedAt: joinedAt,
    );
  }
}

import 'package:flutter/foundation.dart';

import '../config/api_config.dart';
import '../models/user.dart';
import 'api_service.dart';

/// 认证用户信息
class AuthUser {
  final String id;
  final String email;
  final String name;
  final String? avatar;
  final DateTime? createdAt;

  const AuthUser({
    required this.id,
    required this.email,
    required this.name,
    this.avatar,
    this.createdAt,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      avatar: json['avatar'] as String?,
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'] as String)
              : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'name': name,
    'avatar': avatar,
    if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
  };

  /// 转换为本地 User 模型
  User toUser({String? roleLabel}) =>
      User(id: id, name: name, avatar: avatar ?? '', roleLabel: roleLabel);
}

/// 认证响应
class AuthResponse {
  final AuthUser user;
  final String accessToken;
  final String refreshToken;
  final int expiresIn;

  const AuthResponse({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      user: AuthUser.fromJson(json['user'] as Map<String, dynamic>),
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      expiresIn: json['expiresIn'] as int,
    );
  }
}

/// 圈子信息（来自服务器）
class RemoteCircle {
  final String id;
  final String name;
  final DateTime? startDate;
  final String? inviteCode;
  final DateTime? inviteExpiresAt;
  final String createdBy;
  final String? role;
  final String? roleLabel;

  const RemoteCircle({
    required this.id,
    required this.name,
    this.startDate,
    this.inviteCode,
    this.inviteExpiresAt,
    required this.createdBy,
    this.role,
    this.roleLabel,
  });

  factory RemoteCircle.fromJson(Map<String, dynamic> json) {
    return RemoteCircle(
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
      createdBy: json['created_by'] as String,
      role: json['role'] as String?,
      roleLabel: json['role_label'] as String?,
    );
  }

  /// 转换为本地 CircleInfo 模型
  CircleInfo toCircleInfo() =>
      CircleInfo(id: id, name: name, startDate: startDate);

  bool get isAdmin => role == 'admin';
}

/// 认证服务
///
/// 处理用户认证相关的业务逻辑
class AuthService {
  static AuthService? _instance;
  static AuthService get instance => _instance ??= AuthService._();

  final ApiService _api = ApiService.instance;

  AuthUser? _currentUser;
  List<RemoteCircle>? _userCircles;

  AuthService._();

  /// 当前用户
  AuthUser? get currentUser => _currentUser;

  /// 用户圈子列表
  List<RemoteCircle>? get userCircles => _userCircles;

  /// 是否已登录
  Future<bool> isLoggedIn() => _api.isLoggedIn();

  /// 注册
  Future<AuthResponse> register({
    required String email,
    required String password,
    required String name,
  }) async {
    final response = await _api.post<Map<String, dynamic>>(
      ApiConfig.authRegister,
      data: {'email': email, 'password': password, 'name': name},
      requiresAuth: false,
      fromData: (data) => data as Map<String, dynamic>,
    );

    if (!response.success || response.data == null) {
      throw ApiException(
        code: response.error?.code ?? 'REGISTER_FAILED',
        message: response.error?.message ?? '注册失败',
      );
    }

    final authResponse = AuthResponse.fromJson(response.data!);

    // 保存 tokens
    await _api.saveTokens(
      accessToken: authResponse.accessToken,
      refreshToken: authResponse.refreshToken,
      userId: authResponse.user.id,
      email: authResponse.user.email,
    );

    _currentUser = authResponse.user;

    return authResponse;
  }

  /// 登录
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final response = await _api.post<Map<String, dynamic>>(
      ApiConfig.authLogin,
      data: {'email': email, 'password': password},
      requiresAuth: false,
      fromData: (data) => data as Map<String, dynamic>,
    );

    if (!response.success || response.data == null) {
      throw ApiException(
        code: response.error?.code ?? 'LOGIN_FAILED',
        message: response.error?.message ?? '登录失败',
      );
    }

    final authResponse = AuthResponse.fromJson(response.data!);

    // 保存 tokens
    await _api.saveTokens(
      accessToken: authResponse.accessToken,
      refreshToken: authResponse.refreshToken,
      userId: authResponse.user.id,
      email: authResponse.user.email,
    );

    _currentUser = authResponse.user;

    return authResponse;
  }

  /// 登出
  Future<void> logout() async {
    try {
      await _api.post(ApiConfig.authLogout, requiresAuth: true);
    } catch (e) {
      debugPrint('Logout API call failed: $e');
    } finally {
      await _api.clearTokens();
      _currentUser = null;
      _userCircles = null;
    }
  }

  /// 获取当前用户信息和圈子
  Future<AuthUser> fetchCurrentUser() async {
    final response = await _api.get<Map<String, dynamic>>(
      ApiConfig.authMe,
      fromData: (data) => data as Map<String, dynamic>,
    );

    if (!response.success || response.data == null) {
      throw ApiException(
        code: response.error?.code ?? 'FETCH_USER_FAILED',
        message: response.error?.message ?? '获取用户信息失败',
      );
    }

    final data = response.data!;
    _currentUser = AuthUser.fromJson(data['user'] as Map<String, dynamic>);

    // 解析圈子列表
    final circlesData = data['circles'] as List<dynamic>?;
    if (circlesData != null) {
      _userCircles =
          circlesData
              .map((c) => RemoteCircle.fromJson(c as Map<String, dynamic>))
              .toList();
    }

    return _currentUser!;
  }

  /// 修改密码
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final response = await _api.put(
      ApiConfig.authPassword,
      data: {'currentPassword': currentPassword, 'newPassword': newPassword},
    );

    if (!response.success) {
      throw ApiException(
        code: response.error?.code ?? 'CHANGE_PASSWORD_FAILED',
        message: response.error?.message ?? '修改密码失败',
      );
    }
  }

  /// 创建圈子
  Future<RemoteCircle> createCircle({
    required String name,
    DateTime? startDate,
  }) async {
    final response = await _api.post<Map<String, dynamic>>(
      ApiConfig.circles,
      data: {
        'name': name,
        if (startDate != null) 'startDate': startDate.toIso8601String(),
      },
      fromData: (data) => data as Map<String, dynamic>,
    );

    if (!response.success || response.data == null) {
      throw ApiException(
        code: response.error?.code ?? 'CREATE_CIRCLE_FAILED',
        message: response.error?.message ?? '创建圈子失败',
      );
    }

    final circle = RemoteCircle.fromJson(response.data!);

    // 更新本地缓存
    _userCircles = [...(_userCircles ?? []), circle];

    return circle;
  }

  /// 加入圈子
  Future<RemoteCircle> joinCircle({
    required String inviteCode,
    String? roleLabel,
  }) async {
    final response = await _api.post<Map<String, dynamic>>(
      ApiConfig.circleJoin,
      data: {
        'inviteCode': inviteCode,
        if (roleLabel != null) 'roleLabel': roleLabel,
      },
      fromData: (data) => data as Map<String, dynamic>,
    );

    if (!response.success || response.data == null) {
      throw ApiException(
        code: response.error?.code ?? 'JOIN_CIRCLE_FAILED',
        message: response.error?.message ?? '加入圈子失败',
      );
    }

    final circle = RemoteCircle.fromJson(response.data!);

    // 更新本地缓存
    _userCircles = [...(_userCircles ?? []), circle];

    return circle;
  }

  /// 生成邀请码
  Future<String> generateInviteCode(String circleId) async {
    final response = await _api.post<Map<String, dynamic>>(
      ApiConfig.circleInvite(circleId),
      fromData: (data) => data as Map<String, dynamic>,
    );

    if (!response.success || response.data == null) {
      throw ApiException(
        code: response.error?.code ?? 'GENERATE_INVITE_FAILED',
        message: response.error?.message ?? '生成邀请码失败',
      );
    }

    return response.data!['inviteCode'] as String;
  }

  /// 获取圈子成员
  Future<List<User>> getCircleMembers(String circleId) async {
    final response = await _api.get<List<dynamic>>(
      ApiConfig.circleMembers(circleId),
      fromData: (data) => data as List<dynamic>,
    );

    if (!response.success || response.data == null) {
      throw ApiException(
        code: response.error?.code ?? 'FETCH_MEMBERS_FAILED',
        message: response.error?.message ?? '获取成员列表失败',
      );
    }

    return response.data!.map((m) {
      final member = m as Map<String, dynamic>;
      return User(
        id: member['user_id'] as String,
        name: member['name'] as String,
        avatar: member['avatar'] as String? ?? '',
        roleLabel: member['role_label'] as String?,
      );
    }).toList();
  }

  /// 清除本地缓存
  void clearCache() {
    _currentUser = null;
    _userCircles = null;
  }
}

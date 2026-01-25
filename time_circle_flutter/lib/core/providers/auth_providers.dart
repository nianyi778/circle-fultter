import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../config/api_config.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

/// 认证状态
enum AuthStatus {
  /// 未初始化（启动时）
  initial,

  /// 已登录
  authenticated,

  /// 未登录
  unauthenticated,

  /// 已登录但未选择圈子
  noCircle,
}

/// 认证状态数据
class AuthState {
  final AuthStatus status;
  final AuthUser? user;
  final List<RemoteCircle>? circles;
  final RemoteCircle? selectedCircle;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.circles,
    this.selectedCircle,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    AuthStatus? status,
    AuthUser? user,
    List<RemoteCircle>? circles,
    RemoteCircle? selectedCircle,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      circles: circles ?? this.circles,
      selectedCircle: selectedCircle ?? this.selectedCircle,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  /// 是否完全认证（已登录且有圈子）
  bool get isFullyAuthenticated =>
      status == AuthStatus.authenticated && selectedCircle != null;

  /// 需要创建或加入圈子
  bool get needsCircleSetup => status == AuthStatus.noCircle;
}

/// 认证状态 Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;
  final FlutterSecureStorage _storage;

  AuthNotifier(this._authService, this._storage) : super(const AuthState()) {
    // 设置 token 过期回调
    ApiService.instance.onTokenExpired = _handleTokenExpired;
  }

  /// 处理 token 过期
  void _handleTokenExpired() {
    debugPrint('[Auth] Token expired, logging out...');
    logout();
  }

  /// 初始化认证状态（App 启动时调用）
  Future<void> init() async {
    state = state.copyWith(isLoading: true);

    try {
      final isLoggedIn = await _authService.isLoggedIn();

      if (!isLoggedIn) {
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          isLoading: false,
        );
        return;
      }

      // 获取用户信息和圈子列表
      await _authService.fetchCurrentUser();

      final user = _authService.currentUser;
      final circles = _authService.userCircles;

      if (user == null) {
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          isLoading: false,
        );
        return;
      }

      if (circles == null || circles.isEmpty) {
        state = state.copyWith(
          status: AuthStatus.noCircle,
          user: user,
          circles: circles,
          isLoading: false,
        );
        return;
      }

      // 尝试恢复上次选择的圈子
      final savedCircleId = await _storage.read(
        key: ApiConfig.selectedCircleKey,
      );
      RemoteCircle? selectedCircle;

      if (savedCircleId != null) {
        selectedCircle = circles.firstWhere(
          (c) => c.id == savedCircleId,
          orElse: () => circles.first,
        );
      } else {
        selectedCircle = circles.first;
      }

      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        circles: circles,
        selectedCircle: selectedCircle,
        isLoading: false,
      );
    } catch (e) {
      debugPrint('Auth init failed: $e');
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// 登录
  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _authService.login(
        email: email,
        password: password,
      );

      // 获取圈子列表
      await _authService.fetchCurrentUser();
      final circles = _authService.userCircles;

      if (circles == null || circles.isEmpty) {
        state = state.copyWith(
          status: AuthStatus.noCircle,
          user: response.user,
          circles: circles,
          isLoading: false,
        );
      } else {
        // 选择第一个圈子
        final selectedCircle = circles.first;
        await _storage.write(
          key: ApiConfig.selectedCircleKey,
          value: selectedCircle.id,
        );

        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: response.user,
          circles: circles,
          selectedCircle: selectedCircle,
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _parseError(e));
      rethrow;
    }
  }

  /// 注册
  Future<void> register({
    required String email,
    required String password,
    required String name,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _authService.register(
        email: email,
        password: password,
        name: name,
      );

      // 新用户没有圈子
      state = state.copyWith(
        status: AuthStatus.noCircle,
        user: response.user,
        circles: [],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _parseError(e));
      rethrow;
    }
  }

  /// 登出
  Future<void> logout() async {
    state = state.copyWith(isLoading: true);

    try {
      await _authService.logout();
      await _storage.delete(key: ApiConfig.selectedCircleKey);
    } finally {
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  /// 创建圈子
  Future<RemoteCircle> createCircle({
    required String name,
    DateTime? startDate,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final circle = await _authService.createCircle(
        name: name,
        startDate: startDate,
      );

      // 保存选择的圈子
      await _storage.write(key: ApiConfig.selectedCircleKey, value: circle.id);

      final circles = <RemoteCircle>[...(state.circles ?? []), circle];

      state = state.copyWith(
        status: AuthStatus.authenticated,
        circles: circles,
        selectedCircle: circle,
        isLoading: false,
      );

      return circle;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _parseError(e));
      rethrow;
    }
  }

  /// 加入圈子
  Future<RemoteCircle> joinCircle({
    required String inviteCode,
    String? roleLabel,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final circle = await _authService.joinCircle(
        inviteCode: inviteCode,
        roleLabel: roleLabel,
      );

      // 保存选择的圈子
      await _storage.write(key: ApiConfig.selectedCircleKey, value: circle.id);

      final circles = <RemoteCircle>[...(state.circles ?? []), circle];

      state = state.copyWith(
        status: AuthStatus.authenticated,
        circles: circles,
        selectedCircle: circle,
        isLoading: false,
      );

      return circle;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _parseError(e));
      rethrow;
    }
  }

  /// 切换圈子
  Future<void> selectCircle(RemoteCircle circle) async {
    await _storage.write(key: ApiConfig.selectedCircleKey, value: circle.id);
    state = state.copyWith(selectedCircle: circle);
  }

  /// 刷新用户信息和圈子列表
  Future<void> refresh() async {
    try {
      await _authService.fetchCurrentUser();

      final user = _authService.currentUser;
      final circles = _authService.userCircles;

      if (user != null) {
        // 保持当前选中的圈子
        RemoteCircle? selectedCircle = state.selectedCircle;
        if (selectedCircle != null && circles != null) {
          selectedCircle = circles.firstWhere(
            (c) => c.id == selectedCircle!.id,
            orElse: () => circles.first,
          );
        }

        state = state.copyWith(
          user: user,
          circles: circles,
          selectedCircle: selectedCircle,
        );
      }
    } catch (e) {
      debugPrint('Refresh auth failed: $e');
    }
  }

  /// 清除错误
  void clearError() {
    state = state.copyWith(error: null);
  }

  String _parseError(dynamic e) {
    if (e is ApiException) {
      return e.message;
    }
    return e.toString();
  }
}

// ============== Providers ==============

/// 安全存储 Provider - 使用统一配置
final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return secureStorage; // 来自 api_service.dart
});

/// AuthService Provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService.instance;
});

/// 认证状态 Provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  final storage = ref.watch(secureStorageProvider);
  return AuthNotifier(authService, storage);
});

/// 当前认证用户（仅在已登录时使用）
final currentAuthUserProvider = Provider<AuthUser?>((ref) {
  return ref.watch(authProvider.select((s) => s.user));
});

/// 用户圈子列表
final userCirclesProvider = Provider<List<RemoteCircle>>((ref) {
  return ref.watch(authProvider.select((s) => s.circles)) ?? [];
});

/// 当前选中的圈子
final selectedCircleProvider = Provider<RemoteCircle?>((ref) {
  return ref.watch(authProvider.select((s) => s.selectedCircle));
});

/// 当前选中圈子的 CircleInfo（兼容本地模型）
final selectedCircleInfoProvider = Provider<CircleInfo?>((ref) {
  final circle = ref.watch(selectedCircleProvider);
  return circle?.toCircleInfo();
});

/// 是否已完全认证
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider.select((s) => s.isFullyAuthenticated));
});

/// 认证加载状态
final authLoadingProvider = Provider<bool>((ref) {
  return ref.watch(authProvider.select((s) => s.isLoading));
});

/// 认证错误信息
final authErrorProvider = Provider<String?>((ref) {
  return ref.watch(authProvider.select((s) => s.error));
});

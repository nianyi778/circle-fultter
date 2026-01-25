import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../config/api_config.dart';

/// API 响应结构
class ApiResponse<T> {
  final bool success;
  final T? data;
  final ApiError? error;
  final ApiMeta? meta;

  const ApiResponse({required this.success, this.data, this.error, this.meta});

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromData,
  ) {
    return ApiResponse(
      success: json['success'] as bool? ?? false,
      data:
          json['data'] != null && fromData != null
              ? fromData(json['data'])
              : json['data'] as T?,
      error:
          json['error'] != null
              ? ApiError.fromJson(json['error'] as Map<String, dynamic>)
              : null,
      meta:
          json['meta'] != null
              ? ApiMeta.fromJson(json['meta'] as Map<String, dynamic>)
              : null,
    );
  }
}

/// API 错误
class ApiError {
  final String code;
  final String message;

  const ApiError({required this.code, required this.message});

  factory ApiError.fromJson(Map<String, dynamic> json) {
    return ApiError(
      code: json['code'] as String? ?? 'UNKNOWN',
      message: json['message'] as String? ?? 'Unknown error',
    );
  }

  @override
  String toString() => '[$code] $message';
}

/// API 分页元数据
class ApiMeta {
  final int? page;
  final int? limit;
  final int? total;
  final bool? hasMore;

  const ApiMeta({this.page, this.limit, this.total, this.hasMore});

  factory ApiMeta.fromJson(Map<String, dynamic> json) {
    return ApiMeta(
      page: json['page'] as int?,
      limit: json['limit'] as int?,
      total: json['total'] as int?,
      hasMore: json['hasMore'] as bool?,
    );
  }
}

/// API 异常
class ApiException implements Exception {
  final String code;
  final String message;
  final int? statusCode;

  const ApiException({
    required this.code,
    required this.message,
    this.statusCode,
  });

  factory ApiException.fromDioException(DioException e) {
    if (e.response?.data is Map<String, dynamic>) {
      final data = e.response!.data as Map<String, dynamic>;
      if (data['error'] != null) {
        final error = data['error'] as Map<String, dynamic>;
        return ApiException(
          code: error['code'] as String? ?? 'NETWORK_ERROR',
          message: error['message'] as String? ?? e.message ?? 'Network error',
          statusCode: e.response?.statusCode,
        );
      }
    }
    return ApiException(
      code: 'NETWORK_ERROR',
      message: e.message ?? 'Network error',
      statusCode: e.response?.statusCode,
    );
  }

  @override
  String toString() => '[$code] $message';

  bool get isUnauthorized => statusCode == 401;
  bool get isForbidden => statusCode == 403;
  bool get isNotFound => statusCode == 404;
  bool get isConflict => statusCode == 409;
  bool get isServerError => statusCode != null && statusCode! >= 500;
}

/// API 服务
///
/// 处理所有 HTTP 请求，包含 Token 自动刷新和错误处理
class ApiService {
  static ApiService? _instance;
  static ApiService get instance => _instance ??= ApiService._();

  late final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Token 刷新锁
  Completer<bool>? _refreshTokenCompleter;

  // 认证状态回调
  void Function()? onTokenExpired;

  ApiService._() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: const Duration(milliseconds: ApiConfig.connectTimeout),
        receiveTimeout: const Duration(milliseconds: ApiConfig.receiveTimeout),
        sendTimeout: const Duration(milliseconds: ApiConfig.sendTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // 添加拦截器
    _dio.interceptors.add(_AuthInterceptor(this));

    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(requestBody: true, responseBody: true, error: true),
      );
    }
  }

  /// 获取 Access Token
  Future<String?> getAccessToken() async {
    return await _storage.read(key: ApiConfig.accessTokenKey);
  }

  /// 保存 Tokens
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    String? userId,
    String? email,
  }) async {
    await _storage.write(key: ApiConfig.accessTokenKey, value: accessToken);
    await _storage.write(key: ApiConfig.refreshTokenKey, value: refreshToken);
    if (userId != null) {
      await _storage.write(key: ApiConfig.userIdKey, value: userId);
    }
    if (email != null) {
      await _storage.write(key: ApiConfig.userEmailKey, value: email);
    }
  }

  /// 清除 Tokens
  Future<void> clearTokens() async {
    await _storage.delete(key: ApiConfig.accessTokenKey);
    await _storage.delete(key: ApiConfig.refreshTokenKey);
    await _storage.delete(key: ApiConfig.userIdKey);
    await _storage.delete(key: ApiConfig.userEmailKey);
  }

  /// 检查是否已登录
  Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  /// 获取保存的用户 ID
  Future<String?> getUserId() async {
    return await _storage.read(key: ApiConfig.userIdKey);
  }

  /// 获取保存的用户邮箱
  Future<String?> getUserEmail() async {
    return await _storage.read(key: ApiConfig.userEmailKey);
  }

  /// 刷新 Token
  Future<bool> refreshToken() async {
    // 如果正在刷新，等待结果
    if (_refreshTokenCompleter != null) {
      return await _refreshTokenCompleter!.future;
    }

    _refreshTokenCompleter = Completer<bool>();

    try {
      final refreshToken = await _storage.read(key: ApiConfig.refreshTokenKey);
      if (refreshToken == null) {
        _refreshTokenCompleter!.complete(false);
        return false;
      }

      final response = await _dio.post(
        ApiConfig.authRefresh,
        data: {'refreshToken': refreshToken},
        options: Options(headers: {'Authorization': null}),
      );

      if (response.data['success'] == true) {
        final data = response.data['data'];
        await saveTokens(
          accessToken: data['accessToken'],
          refreshToken: data['refreshToken'],
        );
        _refreshTokenCompleter!.complete(true);
        return true;
      }

      _refreshTokenCompleter!.complete(false);
      return false;
    } catch (e) {
      debugPrint('Token refresh failed: $e');
      _refreshTokenCompleter!.complete(false);
      return false;
    } finally {
      _refreshTokenCompleter = null;
    }
  }

  /// GET 请求
  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromData,
    bool requiresAuth = true,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: Options(extra: {'requiresAuth': requiresAuth}),
      );
      return ApiResponse.fromJson(response.data, fromData);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// POST 请求
  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromData,
    bool requiresAuth = true,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(extra: {'requiresAuth': requiresAuth}),
      );
      return ApiResponse.fromJson(response.data, fromData);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// PUT 请求
  Future<ApiResponse<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromData,
    bool requiresAuth = true,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(extra: {'requiresAuth': requiresAuth}),
      );
      return ApiResponse.fromJson(response.data, fromData);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// DELETE 请求
  Future<ApiResponse<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromData,
    bool requiresAuth = true,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(extra: {'requiresAuth': requiresAuth}),
      );
      return ApiResponse.fromJson(response.data, fromData);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// 上传文件
  Future<ApiResponse<T>> uploadFile<T>(
    String url,
    List<int> bytes, {
    String? contentType,
    T Function(dynamic)? fromData,
    void Function(int, int)? onSendProgress,
  }) async {
    try {
      final response = await _dio.put(
        url,
        data: Stream.fromIterable([bytes]),
        options: Options(
          headers: {
            'Content-Type': contentType ?? 'application/octet-stream',
            'Content-Length': bytes.length,
          },
        ),
        onSendProgress: onSendProgress,
      );
      return ApiResponse.fromJson(response.data, fromData);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}

/// 认证拦截器
class _AuthInterceptor extends Interceptor {
  final ApiService _apiService;

  _AuthInterceptor(this._apiService);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final requiresAuth = options.extra['requiresAuth'] ?? true;

    if (requiresAuth) {
      final token = await _apiService.getAccessToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      final requiresAuth = err.requestOptions.extra['requiresAuth'] ?? true;

      // 如果是刷新 token 请求失败，不再重试
      if (err.requestOptions.path == ApiConfig.authRefresh) {
        _apiService.onTokenExpired?.call();
        handler.next(err);
        return;
      }

      if (requiresAuth) {
        // 尝试刷新 token
        final success = await _apiService.refreshToken();

        if (success) {
          // 重试原请求
          try {
            final token = await _apiService.getAccessToken();
            final options = err.requestOptions;
            options.headers['Authorization'] = 'Bearer $token';

            final response = await Dio().fetch(options);
            handler.resolve(response);
            return;
          } catch (e) {
            handler.next(err);
            return;
          }
        } else {
          // Token 刷新失败，通知登出
          _apiService.onTokenExpired?.call();
        }
      }
    }

    handler.next(err);
  }
}

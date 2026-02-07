import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../config/api_config.dart';
import '../errors/exceptions.dart';

/// API Response wrapper for type-safe responses
class ApiResponse<T> {
  final T? data;
  final String? message;
  final bool success;
  final Map<String, dynamic>? meta;

  const ApiResponse({this.data, this.message, this.success = true, this.meta});

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>)? fromJson,
  ) {
    final data = json['data'];
    return ApiResponse(
      data:
          data != null && fromJson != null
              ? fromJson(data as Map<String, dynamic>)
              : data as T?,
      message: json['message'] as String?,
      success: json['success'] as bool? ?? true,
      meta: json['meta'] as Map<String, dynamic>?,
    );
  }
}

/// Centralized API Client using Dio
///
/// Features:
/// - Automatic token refresh
/// - Request/Response logging (debug mode)
/// - Error handling with custom exceptions
/// - Secure token storage
class ApiClient {
  late final Dio _dio;
  final FlutterSecureStorage _secureStorage;
  final VoidCallback? onTokenExpired;

  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';

  ApiClient({FlutterSecureStorage? secureStorage, this.onTokenExpired})
    : _secureStorage = secureStorage ?? const FlutterSecureStorage() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.interceptors.addAll([
      // Auth interceptor
      InterceptorsWrapper(onRequest: _onRequest, onError: _onError),
      // Logging interceptor (debug only)
      if (kDebugMode)
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          error: true,
          logPrint: (obj) => debugPrint('[API] $obj'),
        ),
    ]);
  }

  Future<void> _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Add auth token to requests
    final token = await _secureStorage.read(key: _accessTokenKey);
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  Future<void> _onError(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    // Handle 401 - try to refresh token
    if (error.response?.statusCode == 401) {
      try {
        final refreshed = await _refreshToken();
        if (refreshed) {
          // Retry the original request
          final response = await _retry(error.requestOptions);
          return handler.resolve(response);
        }
      } catch (_) {
        // Refresh failed, notify and reject
        onTokenExpired?.call();
      }
    }
    handler.next(error);
  }

  Future<bool> _refreshToken() async {
    final refreshToken = await _secureStorage.read(key: _refreshTokenKey);
    if (refreshToken == null) return false;

    try {
      final response = await _dio.post(
        ApiConfig.refreshToken,
        data: {'refresh_token': refreshToken},
        options: Options(headers: {'Authorization': null}),
      );

      final newAccessToken = response.data['data']['access_token'] as String?;
      final newRefreshToken = response.data['data']['refresh_token'] as String?;

      if (newAccessToken != null) {
        await _secureStorage.write(key: _accessTokenKey, value: newAccessToken);
        if (newRefreshToken != null) {
          await _secureStorage.write(
            key: _refreshTokenKey,
            value: newRefreshToken,
          );
        }
        return true;
      }
    } catch (_) {
      // Clear tokens on refresh failure
      await clearTokens();
    }
    return false;
  }

  Future<Response<dynamic>> _retry(RequestOptions requestOptions) async {
    final token = await _secureStorage.read(key: _accessTokenKey);
    final options = Options(
      method: requestOptions.method,
      headers: {...requestOptions.headers, 'Authorization': 'Bearer $token'},
    );

    return _dio.request<dynamic>(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }

  // ============ Public API Methods ============

  /// GET request
  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(Map<String, dynamic>)? fromJson,
    T Function(List<dynamic>)? fromJsonList,
  }) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return _parseResponse(response, fromJson, fromJsonList);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// POST request
  Future<T> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return _parseResponse(response, fromJson, null);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// PUT request
  Future<T> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return _parseResponse(response, fromJson, null);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// DELETE request
  Future<T> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return _parseResponse(response, fromJson, null);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Upload file with multipart
  Future<T> uploadFile<T>(
    String path, {
    required String filePath,
    String fieldName = 'file',
    Map<String, dynamic>? additionalFields,
    T Function(Map<String, dynamic>)? fromJson,
    void Function(int, int)? onSendProgress,
  }) async {
    try {
      final formData = FormData.fromMap({
        fieldName: await MultipartFile.fromFile(filePath),
        ...?additionalFields,
      });

      final response = await _dio.post(
        path,
        data: formData,
        onSendProgress: onSendProgress,
      );
      return _parseResponse(response, fromJson, null);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // ============ Token Management ============

  /// Save auth tokens
  Future<void> saveTokens({
    required String accessToken,
    String? refreshToken,
  }) async {
    await _secureStorage.write(key: _accessTokenKey, value: accessToken);
    if (refreshToken != null) {
      await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);
    }
  }

  /// Clear auth tokens
  Future<void> clearTokens() async {
    await _secureStorage.delete(key: _accessTokenKey);
    await _secureStorage.delete(key: _refreshTokenKey);
  }

  /// Check if user is authenticated
  Future<bool> get isAuthenticated async {
    final token = await _secureStorage.read(key: _accessTokenKey);
    return token != null;
  }

  // ============ Private Helpers ============

  T _parseResponse<T>(
    Response response,
    T Function(Map<String, dynamic>)? fromJson,
    T Function(List<dynamic>)? fromJsonList,
  ) {
    final data = response.data;

    if (data == null) {
      return null as T;
    }

    // Handle list response
    if (data is List && fromJsonList != null) {
      return fromJsonList(data);
    }

    // Handle map response
    if (data is Map<String, dynamic>) {
      // If API wraps data in 'data' field
      final actualData = data['data'] ?? data;

      if (fromJson != null && actualData is Map<String, dynamic>) {
        return fromJson(actualData);
      }
      if (fromJsonList != null && actualData is List) {
        return fromJsonList(actualData);
      }
      return actualData as T;
    }

    return data as T;
  }

  AppException _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkException('Connection timeout');

      case DioExceptionType.connectionError:
        return const NetworkException();

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final data = error.response?.data;

        String message = 'Server error';
        if (data is Map<String, dynamic>) {
          message =
              data['message'] as String? ??
              data['error'] as String? ??
              'Server error';
        }

        return ServerException(
          message: message,
          statusCode: statusCode,
          response: data is Map<String, dynamic> ? data : null,
        );

      case DioExceptionType.cancel:
        return const ServerException(message: 'Request cancelled');

      case DioExceptionType.badCertificate:
        return const ServerException(message: 'Certificate error');

      case DioExceptionType.unknown:
        return ServerException(message: error.message ?? 'Unknown error');
    }
  }
}

/// Base Exception class for data layer errors
///
/// All data layer exceptions should extend this class.
/// Exceptions are caught in repositories and converted to [Failure] for domain layer.
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  const AppException({required this.message, this.code, this.details});

  @override
  String toString() => '$runtimeType($code): $message';
}

/// Server/API exceptions
class ServerException extends AppException {
  final int? statusCode;
  final Map<String, dynamic>? response;

  const ServerException({
    required String message,
    this.statusCode,
    this.response,
    String? code,
  }) : super(message: message, code: code ?? 'SERVER_ERROR');

  /// Create from HTTP status code
  factory ServerException.fromStatusCode(int statusCode, [String? message]) {
    switch (statusCode) {
      case 400:
        return ServerException(
          message: message ?? 'Bad request',
          statusCode: statusCode,
          code: 'BAD_REQUEST',
        );
      case 401:
        return ServerException(
          message: message ?? 'Unauthorized',
          statusCode: statusCode,
          code: 'UNAUTHORIZED',
        );
      case 403:
        return ServerException(
          message: message ?? 'Forbidden',
          statusCode: statusCode,
          code: 'FORBIDDEN',
        );
      case 404:
        return ServerException(
          message: message ?? 'Not found',
          statusCode: statusCode,
          code: 'NOT_FOUND',
        );
      case 422:
        return ServerException(
          message: message ?? 'Validation failed',
          statusCode: statusCode,
          code: 'VALIDATION_ERROR',
        );
      case 429:
        return ServerException(
          message: message ?? 'Too many requests',
          statusCode: statusCode,
          code: 'RATE_LIMITED',
        );
      case 500:
      case 502:
      case 503:
      case 504:
        return ServerException(
          message: message ?? 'Server error',
          statusCode: statusCode,
          code: 'SERVER_ERROR',
        );
      default:
        return ServerException(
          message: message ?? 'Unknown error',
          statusCode: statusCode,
        );
    }
  }
}

/// Network exceptions
class NetworkException extends AppException {
  const NetworkException([String message = 'No internet connection'])
    : super(message: message, code: 'NETWORK_ERROR');
}

/// Cache/Local storage exceptions
class CacheException extends AppException {
  const CacheException([String message = 'Cache error'])
    : super(message: message, code: 'CACHE_ERROR');

  factory CacheException.notFound([String? key]) => CacheException(
    key != null ? 'Cache key "$key" not found' : 'Cache not found',
  );

  factory CacheException.expired([String? key]) => CacheException(
    key != null ? 'Cache key "$key" expired' : 'Cache expired',
  );

  factory CacheException.corrupted() =>
      const CacheException('Cache data corrupted');
}

/// Database exceptions
class DatabaseException extends AppException {
  const DatabaseException([String message = 'Database error'])
    : super(message: message, code: 'DATABASE_ERROR');

  factory DatabaseException.notFound(String table, [String? id]) =>
      DatabaseException(
        id != null
            ? 'Record "$id" not found in $table'
            : 'Record not found in $table',
      );

  factory DatabaseException.constraint(String message) =>
      DatabaseException('Constraint violation: $message');
}

/// Authentication exceptions
class AuthException extends AppException {
  const AuthException(String message, {String? code})
    : super(message: message, code: code ?? 'AUTH_ERROR');

  factory AuthException.tokenExpired() =>
      const AuthException('Token expired', code: 'TOKEN_EXPIRED');

  factory AuthException.invalidToken() =>
      const AuthException('Invalid token', code: 'INVALID_TOKEN');

  factory AuthException.noToken() =>
      const AuthException('No authentication token', code: 'NO_TOKEN');
}

/// File system exceptions
class FileException extends AppException {
  const FileException(String message)
    : super(message: message, code: 'FILE_ERROR');

  factory FileException.notFound(String path) =>
      FileException('File not found: $path');

  factory FileException.permissionDenied(String path) =>
      FileException('Permission denied: $path');

  factory FileException.tooLarge(String path, int maxSize) =>
      FileException('File too large: $path (max: ${maxSize}MB)');
}

/// Parse/Format exceptions
class ParseException extends AppException {
  const ParseException(String message)
    : super(message: message, code: 'PARSE_ERROR');

  factory ParseException.json(String details) =>
      ParseException('Failed to parse JSON: $details');

  factory ParseException.date(String value) =>
      ParseException('Failed to parse date: $value');
}

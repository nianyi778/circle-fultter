import 'package:equatable/equatable.dart';

/// Base Failure class for domain layer errors
///
/// All business logic errors should extend this class.
/// Use [Failure] when returning errors from use cases and repositories.
abstract class Failure extends Equatable {
  final String message;
  final String? code;
  final dynamic details;

  const Failure({required this.message, this.code, this.details});

  @override
  List<Object?> get props => [message, code, details];

  @override
  String toString() => 'Failure($code): $message';
}

/// Server/API related failures
class ServerFailure extends Failure {
  final int? statusCode;

  const ServerFailure(
    String message, {
    this.statusCode,
    String? code,
    dynamic details,
  }) : super(message: message, code: code ?? 'SERVER_ERROR', details: details);

  @override
  List<Object?> get props => [...super.props, statusCode];
}

/// Network connectivity failures
class NetworkFailure extends Failure {
  const NetworkFailure([String message = 'No internet connection'])
    : super(message: message, code: 'NETWORK_ERROR');
}

/// Local cache/database failures
class CacheFailure extends Failure {
  const CacheFailure([String message = 'Cache error'])
    : super(message: message, code: 'CACHE_ERROR');
}

/// Authentication failures
class AuthFailure extends Failure {
  const AuthFailure(String message, {String? code})
    : super(message: message, code: code ?? 'AUTH_ERROR');

  /// Token expired
  factory AuthFailure.tokenExpired() => const AuthFailure(
    'Session expired, please login again',
    code: 'TOKEN_EXPIRED',
  );

  /// Invalid credentials
  factory AuthFailure.invalidCredentials() => const AuthFailure(
    'Invalid email or password',
    code: 'INVALID_CREDENTIALS',
  );

  /// User not found
  factory AuthFailure.userNotFound() =>
      const AuthFailure('User not found', code: 'USER_NOT_FOUND');

  /// Not authenticated
  factory AuthFailure.notAuthenticated() =>
      const AuthFailure('Please login to continue', code: 'NOT_AUTHENTICATED');
}

/// Validation failures
class ValidationFailure extends Failure {
  final Map<String, String>? fieldErrors;

  const ValidationFailure(String message, {this.fieldErrors})
    : super(message: message, code: 'VALIDATION_ERROR');

  @override
  List<Object?> get props => [...super.props, fieldErrors];
}

/// Permission/Authorization failures
class PermissionFailure extends Failure {
  const PermissionFailure([String message = 'Permission denied'])
    : super(message: message, code: 'PERMISSION_DENIED');
}

/// Resource not found failures
class NotFoundFailure extends Failure {
  final String resourceType;
  final String? resourceId;

  const NotFoundFailure({
    required this.resourceType,
    this.resourceId,
    String? message,
  }) : super(message: message ?? '$resourceType not found', code: 'NOT_FOUND');

  @override
  List<Object?> get props => [...super.props, resourceType, resourceId];
}

/// Sync/Offline failures
class SyncFailure extends Failure {
  final int pendingItems;

  const SyncFailure({String message = 'Sync failed', this.pendingItems = 0})
    : super(message: message, code: 'SYNC_ERROR');

  @override
  List<Object?> get props => [...super.props, pendingItems];
}

/// Unknown/Unexpected failures
class UnknownFailure extends Failure {
  final Object? originalError;
  final StackTrace? stackTrace;

  const UnknownFailure({
    String message = 'An unexpected error occurred',
    this.originalError,
    this.stackTrace,
  }) : super(message: message, code: 'UNKNOWN_ERROR');

  @override
  List<Object?> get props => [...super.props, originalError];
}

import 'package:drift/drift.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../core/storage/database/app_database.dart';
import '../../../domain/entities/user.dart' as domain;
import '../../models/user_model.dart';

/// Keys for secure storage
class AuthStorageKeys {
  static const accessToken = 'access_token';
  static const refreshToken = 'refresh_token';
  static const tokenExpiresAt = 'token_expires_at';
  static const currentUserId = 'current_user_id';
  static const currentCircleId = 'current_circle_id';
}

/// Local data source for Auth operations
/// Handles secure storage for tokens and database operations for user data
abstract class AuthLocalDataSource {
  // ============ Token Operations ============

  /// Save auth tokens
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required int expiresIn,
  });

  /// Get access token
  Future<String?> getAccessToken();

  /// Get refresh token
  Future<String?> getRefreshToken();

  /// Check if token is expired (or will expire soon)
  Future<bool> isTokenExpired();

  /// Clear all tokens (logout)
  Future<void> clearTokens();

  // ============ User Operations ============

  /// Save current user
  Future<void> saveCurrentUser(domain.User user);

  /// Get current user
  Future<domain.User?> getCurrentUser();

  /// Get current user ID
  Future<String?> getCurrentUserId();

  /// Update user profile locally
  Future<void> updateUser(domain.User user);

  // ============ Circle Operations ============

  /// Save circles for current user
  Future<void> saveCircles(List<domain.CircleInfo> circles);

  /// Get all circles for current user
  Future<List<domain.CircleInfo>> getCircles();

  /// Get current circle ID
  Future<String?> getCurrentCircleId();

  /// Set current circle ID
  Future<void> setCurrentCircleId(String circleId);

  /// Get circle by ID
  Future<domain.CircleInfo?> getCircleById(String id);

  /// Update circle locally
  Future<void> updateCircle(domain.CircleInfo circle);

  // ============ Session Operations ============

  /// Check if user is logged in
  Future<bool> isLoggedIn();

  /// Clear all auth data (full logout)
  Future<void> clearAll();
}

/// Implementation of AuthLocalDataSource
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage _secureStorage;
  final AppDatabase _database;

  AuthLocalDataSourceImpl(this._secureStorage, this._database);

  // ============ Token Operations ============

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required int expiresIn,
  }) async {
    final expiresAt = DateTime.now().add(Duration(seconds: expiresIn));

    await Future.wait([
      _secureStorage.write(
        key: AuthStorageKeys.accessToken,
        value: accessToken,
      ),
      _secureStorage.write(
        key: AuthStorageKeys.refreshToken,
        value: refreshToken,
      ),
      _secureStorage.write(
        key: AuthStorageKeys.tokenExpiresAt,
        value: expiresAt.toIso8601String(),
      ),
    ]);
  }

  @override
  Future<String?> getAccessToken() async {
    return _secureStorage.read(key: AuthStorageKeys.accessToken);
  }

  @override
  Future<String?> getRefreshToken() async {
    return _secureStorage.read(key: AuthStorageKeys.refreshToken);
  }

  @override
  Future<bool> isTokenExpired() async {
    final expiresAtStr = await _secureStorage.read(
      key: AuthStorageKeys.tokenExpiresAt,
    );
    if (expiresAtStr == null) return true;

    try {
      final expiresAt = DateTime.parse(expiresAtStr);
      // Consider token expired if it expires within 5 minutes
      return DateTime.now().isAfter(
        expiresAt.subtract(const Duration(minutes: 5)),
      );
    } catch (e) {
      return true;
    }
  }

  @override
  Future<void> clearTokens() async {
    await Future.wait([
      _secureStorage.delete(key: AuthStorageKeys.accessToken),
      _secureStorage.delete(key: AuthStorageKeys.refreshToken),
      _secureStorage.delete(key: AuthStorageKeys.tokenExpiresAt),
    ]);
  }

  // ============ User Operations ============

  @override
  Future<void> saveCurrentUser(domain.User user) async {
    // Save user to database
    await _database.getOrCreateUser(_userToCompanion(user));

    // Save current user ID to secure storage
    await _secureStorage.write(
      key: AuthStorageKeys.currentUserId,
      value: user.id,
    );
  }

  @override
  Future<domain.User?> getCurrentUser() async {
    final userId = await getCurrentUserId();
    if (userId == null) return null;

    final dbUser = await _database.getUserById(userId);
    if (dbUser == null) return null;

    return _userToEntity(dbUser);
  }

  @override
  Future<String?> getCurrentUserId() async {
    return _secureStorage.read(key: AuthStorageKeys.currentUserId);
  }

  @override
  Future<void> updateUser(domain.User user) async {
    await _database.updateUser(_userToCompanion(user));
  }

  // ============ Circle Operations ============

  @override
  Future<void> saveCircles(List<domain.CircleInfo> circles) async {
    final companions = circles.map(_circleToCompanion).toList();
    await _database.upsertCircles(companions);

    // Set first circle as current if none selected
    final currentId = await getCurrentCircleId();
    if (currentId == null && circles.isNotEmpty) {
      await setCurrentCircleId(circles.first.id);
    }
  }

  @override
  Future<List<domain.CircleInfo>> getCircles() async {
    final dbCircles = await _database.getUserCircles();
    return dbCircles.map(_circleToEntity).toList();
  }

  @override
  Future<String?> getCurrentCircleId() async {
    return _secureStorage.read(key: AuthStorageKeys.currentCircleId);
  }

  @override
  Future<void> setCurrentCircleId(String circleId) async {
    await _secureStorage.write(
      key: AuthStorageKeys.currentCircleId,
      value: circleId,
    );
  }

  @override
  Future<domain.CircleInfo?> getCircleById(String id) async {
    final dbCircle = await _database.getCircleById(id);
    if (dbCircle == null) return null;
    return _circleToEntity(dbCircle);
  }

  @override
  Future<void> updateCircle(domain.CircleInfo circle) async {
    await _database.upsertCircle(_circleToCompanion(circle));
  }

  // ============ Session Operations ============

  @override
  Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    final userId = await getCurrentUserId();
    return token != null && userId != null;
  }

  @override
  Future<void> clearAll() async {
    // Clear secure storage
    await Future.wait([
      clearTokens(),
      _secureStorage.delete(key: AuthStorageKeys.currentUserId),
      _secureStorage.delete(key: AuthStorageKeys.currentCircleId),
    ]);

    // Clear database
    await _database.clearAllData();
  }

  // ============ Conversion Helpers ============

  UsersCompanion _userToCompanion(domain.User user) {
    return UsersCompanion(
      id: Value(user.id),
      name: Value(user.name),
      email: Value(user.email ?? ''),
      avatar: Value(user.avatar.isNotEmpty ? user.avatar : null),
      roleLabel: Value(user.roleLabel),
      joinedAt: Value(user.joinedAt),
      createdAt: Value(user.createdAt ?? DateTime.now()),
    );
  }

  domain.User _userToEntity(User dbUser) {
    return domain.User(
      id: dbUser.id,
      name: dbUser.name,
      avatar: dbUser.avatar ?? '',
      email: dbUser.email,
      roleLabel: dbUser.roleLabel,
      joinedAt: dbUser.joinedAt,
      createdAt: dbUser.createdAt,
    );
  }

  CirclesCompanion _circleToCompanion(domain.CircleInfo circle) {
    return CirclesCompanion(
      id: Value(circle.id),
      name: Value(circle.name),
      startDate: Value(circle.startDate),
      inviteCode: Value(circle.inviteCode),
      joinedAt: Value(circle.joinedAt),
      memberCount: Value(circle.memberCount),
      // These fields need defaults since CircleInfo doesn't have them
      createdBy: const Value(''),
      createdAt: Value(DateTime.now()),
    );
  }

  domain.CircleInfo _circleToEntity(Circle dbCircle) {
    return domain.CircleInfo(
      id: dbCircle.id,
      name: dbCircle.name,
      startDate: dbCircle.startDate,
      joinedAt: dbCircle.joinedAt,
      memberCount: dbCircle.memberCount,
      inviteCode: dbCircle.inviteCode,
    );
  }
}

/// Extension to convert CircleModel to CircleInfo
extension CircleModelExtension on CircleModel {
  domain.CircleInfo toCircleInfo() {
    return domain.CircleInfo(
      id: id,
      name: name,
      startDate: startDate,
      joinedAt: joinedAt,
      memberCount: memberCount,
      inviteCode: inviteCode,
    );
  }
}

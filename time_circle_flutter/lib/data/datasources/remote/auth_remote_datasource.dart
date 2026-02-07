import '../../../core/network/api_client.dart';
import '../../../core/config/api_config.dart';
import '../../models/user_model.dart';

/// Remote data source for Auth operations
abstract class AuthRemoteDataSource {
  /// Register a new user
  Future<AuthResponseModel> register(RegisterRequest request);

  /// Login with email and password
  Future<AuthResponseModel> login(LoginRequest request);

  /// Refresh access token
  Future<TokenResponse> refreshToken(String refreshToken);

  /// Get current user profile with circles
  Future<UserWithCirclesResponse> getCurrentUser();

  /// Update current user profile
  Future<UserModel> updateProfile(UpdateUserRequest request);

  /// Change password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  /// Logout
  Future<void> logout(String? refreshToken);
}

/// Implementation
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient _apiClient;

  AuthRemoteDataSourceImpl(this._apiClient);

  @override
  Future<AuthResponseModel> register(RegisterRequest request) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiConfig.authRegister,
      data: request.toJson(),
    );
    return AuthResponseModel.fromJson(response);
  }

  @override
  Future<AuthResponseModel> login(LoginRequest request) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiConfig.authLogin,
      data: request.toJson(),
    );
    return AuthResponseModel.fromJson(response);
  }

  @override
  Future<TokenResponse> refreshToken(String refreshToken) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiConfig.authRefresh,
      data: {'refresh_token': refreshToken},
    );
    return TokenResponse.fromJson(response);
  }

  @override
  Future<UserWithCirclesResponse> getCurrentUser() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiConfig.authMe,
    );
    return UserWithCirclesResponse.fromJson(response);
  }

  @override
  Future<UserModel> updateProfile(UpdateUserRequest request) async {
    final response = await _apiClient.put<Map<String, dynamic>>(
      ApiConfig.authMe,
      data: request.toJson(),
    );
    return UserModel.fromJson(response['user'] as Map<String, dynamic>);
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _apiClient.put<void>(
      ApiConfig.authPassword,
      data: {'current_password': currentPassword, 'new_password': newPassword},
    );
  }

  @override
  Future<void> logout(String? refreshToken) async {
    await _apiClient.post<void>(
      ApiConfig.authLogout,
      data: refreshToken != null ? {'refresh_token': refreshToken} : null,
    );
  }
}

/// Token refresh response
class TokenResponse {
  final String accessToken;
  final String refreshToken;
  final int expiresIn;

  const TokenResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
  });

  factory TokenResponse.fromJson(Map<String, dynamic> json) {
    return TokenResponse(
      accessToken:
          json['accessToken'] as String? ?? json['access_token'] as String,
      refreshToken:
          json['refreshToken'] as String? ?? json['refresh_token'] as String,
      expiresIn:
          json['expiresIn'] as int? ?? json['expires_in'] as int? ?? 3600,
    );
  }
}

/// User with circles response
class UserWithCirclesResponse {
  final UserModel user;
  final List<CircleModel> circles;

  const UserWithCirclesResponse({required this.user, required this.circles});

  factory UserWithCirclesResponse.fromJson(Map<String, dynamic> json) {
    return UserWithCirclesResponse(
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      circles:
          (json['circles'] as List? ?? [])
              .map((e) => CircleModel.fromJson(e as Map<String, dynamic>))
              .toList(),
    );
  }
}

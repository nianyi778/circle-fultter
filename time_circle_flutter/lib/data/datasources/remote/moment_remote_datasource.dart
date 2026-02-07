import '../../../core/network/api_client.dart';
import '../../../core/config/api_config.dart';
import '../../models/moment_model.dart';

/// Remote data source for Moment operations
/// Handles all API calls related to moments
abstract class MomentRemoteDataSource {
  /// Get moments for a circle with pagination and filters
  Future<PaginatedResponse<MomentModel>> getMoments({
    required String circleId,
    int page = 1,
    int limit = 20,
    String? authorId,
    String? mediaType,
    bool? favorite,
    String? startDate,
    String? endDate,
    int? year,
  });

  /// Get a single moment by ID
  Future<MomentModel> getMomentById(String id);

  /// Create a new moment
  Future<MomentModel> createMoment({
    required String circleId,
    required CreateMomentRequest request,
  });

  /// Update a moment
  Future<MomentModel> updateMoment({
    required String id,
    required UpdateMomentRequest request,
  });

  /// Delete a moment
  Future<void> deleteMoment(String id);

  /// Toggle favorite status
  Future<bool> toggleFavorite(String id);

  /// Get "this day in history" moments
  Future<List<MomentModel>> getMemoryMoments({
    required String circleId,
    int limit = 10,
  });

  /// Get random moments for memory roaming
  Future<List<MomentModel>> getRandomMoments({
    required String circleId,
    int count = 5,
  });

  /// Get available years for filtering
  Future<List<int>> getAvailableYears(String circleId);

  /// Share moment to world
  Future<String> shareToWorld({
    required String momentId,
    required String tag,
    String? bgGradient,
  });

  /// Withdraw moment from world
  Future<void> withdrawFromWorld(String momentId);
}

/// Implementation of MomentRemoteDataSource
class MomentRemoteDataSourceImpl implements MomentRemoteDataSource {
  final ApiClient _apiClient;

  MomentRemoteDataSourceImpl(this._apiClient);

  @override
  Future<PaginatedResponse<MomentModel>> getMoments({
    required String circleId,
    int page = 1,
    int limit = 20,
    String? authorId,
    String? mediaType,
    bool? favorite,
    String? startDate,
    String? endDate,
    int? year,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
      if (authorId != null) 'author_id': authorId,
      if (mediaType != null) 'media_type': mediaType,
      if (favorite != null) 'favorite': favorite.toString(),
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (year != null) 'year': year,
    };

    final response = await _apiClient.get<Map<String, dynamic>>(
      '${ApiConfig.circles}/$circleId/moments',
      queryParameters: queryParams,
    );

    final data = response['data'] as List? ?? [];
    final meta = response['meta'] as Map<String, dynamic>? ?? {};

    return PaginatedResponse(
      data:
          data
              .map((e) => MomentModel.fromJson(e as Map<String, dynamic>))
              .toList(),
      page: meta['page'] as int? ?? page,
      limit: meta['limit'] as int? ?? limit,
      total: meta['total'] as int? ?? 0,
      totalPages: meta['total_pages'] as int? ?? 1,
      hasMore: meta['has_more'] as bool? ?? false,
    );
  }

  @override
  Future<MomentModel> getMomentById(String id) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiConfig.moment(id),
    );
    return MomentModel.fromJson(response);
  }

  @override
  Future<MomentModel> createMoment({
    required String circleId,
    required CreateMomentRequest request,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '${ApiConfig.circles}/$circleId/moments',
      data: request.toJson(),
    );
    return MomentModel.fromJson(response);
  }

  @override
  Future<MomentModel> updateMoment({
    required String id,
    required UpdateMomentRequest request,
  }) async {
    final response = await _apiClient.put<Map<String, dynamic>>(
      ApiConfig.moment(id),
      data: request.toJson(),
    );
    return MomentModel.fromJson(response);
  }

  @override
  Future<void> deleteMoment(String id) async {
    await _apiClient.delete<void>(ApiConfig.moment(id));
  }

  @override
  Future<bool> toggleFavorite(String id) async {
    final response = await _apiClient.put<Map<String, dynamic>>(
      ApiConfig.momentFavorite(id),
    );
    return response['is_favorite'] as bool? ?? false;
  }

  @override
  Future<List<MomentModel>> getMemoryMoments({
    required String circleId,
    int limit = 10,
  }) async {
    final response = await _apiClient.get<List<dynamic>>(
      '${ApiConfig.circles}/$circleId/moments/memory',
      queryParameters: {'limit': limit},
      fromJsonList: (list) => list,
    );
    return response
        .map((e) => MomentModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<MomentModel>> getRandomMoments({
    required String circleId,
    int count = 5,
  }) async {
    final response = await _apiClient.get<List<dynamic>>(
      '${ApiConfig.circles}/$circleId/moments/random',
      queryParameters: {'count': count},
      fromJsonList: (list) => list,
    );
    return response
        .map((e) => MomentModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<int>> getAvailableYears(String circleId) async {
    final response = await _apiClient.get<List<dynamic>>(
      '${ApiConfig.circles}/$circleId/moments/years',
      fromJsonList: (list) => list,
    );
    return response.map((e) => e as int).toList();
  }

  @override
  Future<String> shareToWorld({
    required String momentId,
    required String tag,
    String? bgGradient,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '${ApiConfig.moment(momentId)}/share',
      data: {'tag': tag, if (bgGradient != null) 'bg_gradient': bgGradient},
    );
    return response['world_post_id'] as String;
  }

  @override
  Future<void> withdrawFromWorld(String momentId) async {
    await _apiClient.delete<void>(ApiConfig.momentWorld(momentId));
  }
}

/// Paginated response wrapper
class PaginatedResponse<T> {
  final List<T> data;
  final int page;
  final int limit;
  final int total;
  final int totalPages;
  final bool hasMore;

  const PaginatedResponse({
    required this.data,
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
    required this.hasMore,
  });
}

import '../config/api_config.dart';
import '../models/world_post.dart';
import '../services/api_service.dart';

/// 世界频道 Repository
///
/// 处理世界帖子和频道的读取和操作，直接调用远程 API。
class WorldRepository {
  final ApiService _api;

  WorldRepository({ApiService? api}) : _api = api ?? ApiService.instance;

  /// 获取所有频道
  Future<List<WorldChannel>> getChannels() async {
    final response = await _api.get<List<dynamic>>(
      ApiConfig.worldChannels,
      fromData: (data) => data as List<dynamic>,
    );

    if (!response.success || response.data == null) {
      throw ApiException(
        code: response.error?.code ?? 'UNKNOWN',
        message: response.error?.message ?? 'Failed to get channels',
      );
    }

    return response.data!.map((json) => _parseChannel(json)).toList();
  }

  /// 获取世界帖子列表
  Future<WorldPostListResult> getPosts({
    String? tag,
    int page = 1,
    int limit = 20,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (tag != null) queryParams['tag'] = tag;

    final response = await _api.get<Map<String, dynamic>>(
      ApiConfig.worldPosts,
      queryParameters: queryParams,
      fromData: (data) => data as Map<String, dynamic>,
    );

    if (!response.success) {
      throw ApiException(
        code: response.error?.code ?? 'UNKNOWN',
        message: response.error?.message ?? 'Failed to get posts',
      );
    }

    final data = response.data!['data'] as List<dynamic>? ?? [];
    final meta = response.data!['meta'] as Map<String, dynamic>?;

    return WorldPostListResult(
      posts: data.map((json) => _parsePost(json)).toList(),
      page: meta?['page'] as int? ?? page,
      total: meta?['total'] as int? ?? data.length,
      hasMore: meta?['hasMore'] as bool? ?? false,
    );
  }

  /// 创建世界帖子
  Future<WorldPost> createPost({
    required String content,
    required String tag,
    required String bgGradient,
    String? momentId,
  }) async {
    final response = await _api.post<Map<String, dynamic>>(
      ApiConfig.worldPosts,
      data: {
        'content': content,
        'tag': tag,
        'bgGradient': bgGradient,
        if (momentId != null) 'momentId': momentId,
      },
      fromData: (data) => data as Map<String, dynamic>,
    );

    if (!response.success || response.data == null) {
      throw ApiException(
        code: response.error?.code ?? 'UNKNOWN',
        message: response.error?.message ?? 'Failed to create post',
      );
    }

    return _parsePost(response.data!);
  }

  /// 删除世界帖子
  Future<void> deletePost(String postId) async {
    final response = await _api.delete<void>(ApiConfig.worldPost(postId));

    if (!response.success) {
      throw ApiException(
        code: response.error?.code ?? 'UNKNOWN',
        message: response.error?.message ?? 'Failed to delete post',
      );
    }
  }

  /// 添加共鸣
  Future<ResonateResult> resonate(String postId) async {
    final response = await _api.post<Map<String, dynamic>>(
      ApiConfig.worldPostResonate(postId),
      fromData: (data) => data as Map<String, dynamic>,
    );

    if (!response.success || response.data == null) {
      throw ApiException(
        code: response.error?.code ?? 'UNKNOWN',
        message: response.error?.message ?? 'Failed to resonate',
      );
    }

    return ResonateResult(
      resonanceCount: response.data!['resonanceCount'] as int? ?? 0,
      hasResonated: response.data!['hasResonated'] as bool? ?? true,
    );
  }

  /// 取消共鸣
  Future<ResonateResult> unresonate(String postId) async {
    final response = await _api.delete<Map<String, dynamic>>(
      ApiConfig.worldPostResonate(postId),
      fromData: (data) => data as Map<String, dynamic>,
    );

    if (!response.success || response.data == null) {
      throw ApiException(
        code: response.error?.code ?? 'UNKNOWN',
        message: response.error?.message ?? 'Failed to remove resonance',
      );
    }

    return ResonateResult(
      resonanceCount: response.data!['resonanceCount'] as int? ?? 0,
      hasResonated: response.data!['hasResonated'] as bool? ?? false,
    );
  }

  /// 获取可用的背景渐变
  Future<List<String>> getGradients() async {
    final response = await _api.get<List<dynamic>>(
      ApiConfig.worldGradients,
      fromData: (data) => data as List<dynamic>,
      requiresAuth: false,
    );

    if (!response.success || response.data == null) {
      throw ApiException(
        code: response.error?.code ?? 'UNKNOWN',
        message: response.error?.message ?? 'Failed to get gradients',
      );
    }

    return response.data!.cast<String>();
  }

  /// 解析频道
  WorldChannel _parseChannel(Map<String, dynamic> json) {
    return WorldChannel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      postCount: json['post_count'] as int? ?? 0,
    );
  }

  /// 解析帖子
  WorldPost _parsePost(Map<String, dynamic> json) {
    DateTime? timestamp;
    final createdAt = json['created_at'];
    if (createdAt != null) {
      timestamp = DateTime.tryParse(createdAt.toString());
    }
    timestamp ??= DateTime.now();

    return WorldPost(
      id: json['id'] as String? ?? '',
      momentId: json['moment_id'] as String?,
      content: json['content'] as String? ?? '',
      tag: json['tag'] as String? ?? '',
      resonanceCount: json['resonance_count'] as int? ?? 0,
      bgGradient: json['bg_gradient'] as String? ?? '',
      timestamp: timestamp,
      hasResonated: _parseBool(json['hasResonated'] ?? json['has_resonated']),
    );
  }

  bool _parseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value.toLowerCase() == 'true' || value == '1';
    return false;
  }
}

/// 世界帖子列表结果
class WorldPostListResult {
  final List<WorldPost> posts;
  final int page;
  final int total;
  final bool hasMore;

  const WorldPostListResult({
    required this.posts,
    required this.page,
    required this.total,
    required this.hasMore,
  });
}

/// 共鸣结果
class ResonateResult {
  final int resonanceCount;
  final bool hasResonated;

  const ResonateResult({
    required this.resonanceCount,
    required this.hasResonated,
  });
}

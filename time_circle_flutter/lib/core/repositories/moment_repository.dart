import '../config/api_config.dart';
import 'dart:convert';

import '../models/moment.dart';
import '../models/user.dart';
import '../services/api_service.dart';

/// 时刻 Repository
///
/// 处理时刻的增删改查，直接调用远程 API。
class MomentRepository {
  final ApiService _api;

  MomentRepository({ApiService? api}) : _api = api ?? ApiService.instance;

  /// 获取圈子的时刻列表
  Future<MomentListResult> getMoments(
    String circleId, {
    int page = 1,
    int limit = 20,
    String? authorId,
    String? mediaType,
    bool? favorite,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (authorId != null) queryParams['authorId'] = authorId;
    if (mediaType != null) queryParams['mediaType'] = mediaType;
    if (favorite == true) queryParams['favorite'] = 'true';
    if (startDate != null) {
      queryParams['startDate'] = startDate.toIso8601String();
    }
    if (endDate != null) queryParams['endDate'] = endDate.toIso8601String();

    final response = await _api.get<Map<String, dynamic>>(
      ApiConfig.circleMoments(circleId),
      queryParameters: queryParams,
      fromData: (data) => data as Map<String, dynamic>,
    );

    if (!response.success) {
      throw ApiException(
        code: response.error?.code ?? 'UNKNOWN',
        message: response.error?.message ?? 'Failed to get moments',
      );
    }

    // API 返回 paginated 格式: { data: [...], meta: { page, limit, total, hasMore } }
    final data = response.data!['data'] as List<dynamic>? ?? [];
    final meta = response.data!['meta'] as Map<String, dynamic>?;

    return MomentListResult(
      moments: data.map((json) => _parseMoment(json)).toList(),
      page: meta?['page'] as int? ?? page,
      total: meta?['total'] as int? ?? data.length,
      hasMore: meta?['hasMore'] as bool? ?? false,
    );
  }

  /// 获取单个时刻详情
  Future<Moment> getMoment(String momentId) async {
    final response = await _api.get<Map<String, dynamic>>(
      ApiConfig.moment(momentId),
      fromData: (data) => data as Map<String, dynamic>,
    );

    if (!response.success || response.data == null) {
      throw ApiException(
        code: response.error?.code ?? 'UNKNOWN',
        message: response.error?.message ?? 'Failed to get moment',
      );
    }

    return _parseMoment(response.data!);
  }

  /// 创建时刻
  Future<Moment> createMoment({
    required String circleId,
    required String content,
    required MediaType mediaType,
    List<String>? mediaUrls,
    DateTime? timestamp,
    List<ContextTag>? contextTags,
    String? location,
    String? futureMessage,
  }) async {
    final data = <String, dynamic>{
      'content': content,
      'mediaType': mediaType.name,
    };

    if (mediaUrls != null) data['mediaUrls'] = mediaUrls;
    if (timestamp != null) data['timestamp'] = timestamp.toIso8601String();
    if (contextTags != null && contextTags.isNotEmpty) {
      data['contextTags'] =
          contextTags
              .map(
                (t) => {
                  'type': t.type.name,
                  'label': t.label,
                  'emoji': t.emoji,
                },
              )
              .toList();
    }
    if (location != null) data['location'] = location;
    if (futureMessage != null) data['futureMessage'] = futureMessage;

    final response = await _api.post<Map<String, dynamic>>(
      ApiConfig.circleMoments(circleId),
      data: data,
      fromData: (data) => data as Map<String, dynamic>,
    );

    if (!response.success || response.data == null) {
      throw ApiException(
        code: response.error?.code ?? 'UNKNOWN',
        message: response.error?.message ?? 'Failed to create moment',
      );
    }

    return _parseMoment(response.data!);
  }

  /// 更新时刻
  Future<Moment> updateMoment({
    required String momentId,
    String? content,
    List<String>? mediaUrls,
    List<ContextTag>? contextTags,
    String? location,
    bool clearLocation = false,
    String? futureMessage,
    bool clearFutureMessage = false,
  }) async {
    final data = <String, dynamic>{};

    if (content != null) data['content'] = content;
    if (mediaUrls != null) data['mediaUrls'] = mediaUrls;
    if (contextTags != null) {
      data['contextTags'] =
          contextTags
              .map(
                (t) => {
                  'type': t.type.name,
                  'label': t.label,
                  'emoji': t.emoji,
                },
              )
              .toList();
    }
    if (clearLocation) {
      data['location'] = null;
    } else if (location != null) {
      data['location'] = location;
    }
    if (clearFutureMessage) {
      data['futureMessage'] = null;
    } else if (futureMessage != null) {
      data['futureMessage'] = futureMessage;
    }

    final response = await _api.put<Map<String, dynamic>>(
      ApiConfig.moment(momentId),
      data: data,
      fromData: (data) => data as Map<String, dynamic>,
    );

    if (!response.success || response.data == null) {
      throw ApiException(
        code: response.error?.code ?? 'UNKNOWN',
        message: response.error?.message ?? 'Failed to update moment',
      );
    }

    return _parseMoment(response.data!);
  }

  /// 删除时刻
  Future<void> deleteMoment(String momentId) async {
    final response = await _api.delete<void>(ApiConfig.moment(momentId));

    if (!response.success) {
      throw ApiException(
        code: response.error?.code ?? 'UNKNOWN',
        message: response.error?.message ?? 'Failed to delete moment',
      );
    }
  }

  /// 切换收藏状态
  Future<bool> toggleFavorite(String momentId) async {
    final response = await _api.put<Map<String, dynamic>>(
      ApiConfig.momentFavorite(momentId),
      fromData: (data) => data as Map<String, dynamic>,
    );

    if (!response.success || response.data == null) {
      throw ApiException(
        code: response.error?.code ?? 'UNKNOWN',
        message: response.error?.message ?? 'Failed to toggle favorite',
      );
    }

    return response.data!['is_favorite'] as bool? ?? false;
  }

  /// 从世界撤回时刻
  Future<void> withdrawFromWorld(String momentId) async {
    final response = await _api.delete<void>(ApiConfig.momentWorld(momentId));

    if (!response.success) {
      throw ApiException(
        code: response.error?.code ?? 'UNKNOWN',
        message: response.error?.message ?? 'Failed to withdraw from world',
      );
    }
  }

  /// 解析时刻
  Moment _parseMoment(Map<String, dynamic> json) {
    // 解析作者
    final author = User(
      id: json['author_id'] as String? ?? '',
      name: json['author_name'] as String? ?? '',
      avatar: json['author_avatar'] as String? ?? '',
    );

    // 解析媒体类型
    final mediaTypeStr = json['media_type'] as String? ?? 'text';
    final mediaType = MediaType.values.firstWhere(
      (e) => e.name == mediaTypeStr,
      orElse: () => MediaType.text,
    );

    // 解析上下文标签
    final contextTagsRaw = json['context_tags'];
    final contextTags = <ContextTag>[];
    if (contextTagsRaw is List) {
      for (final tag in contextTagsRaw) {
        if (tag is Map<String, dynamic>) {
          final typeStr = tag['type'] as String? ?? 'myMood';
          final tagType = ContextTagType.values.firstWhere(
            (e) => e.name == typeStr,
            orElse: () => ContextTagType.myMood,
          );
          contextTags.add(
            ContextTag(
              type: tagType,
              label: tag['label'] as String? ?? '',
              emoji: tag['emoji'] as String? ?? '',
            ),
          );
        }
      }
    }

    // 解析时间戳
    DateTime? timestamp;
    final timestampStr = json['timestamp'];
    if (timestampStr != null) {
      timestamp = DateTime.tryParse(timestampStr.toString());
    }
    timestamp ??= DateTime.now();

    // 解析布尔值
    final isFavorite = _parseBool(json['is_favorite']);
    final isSharedToWorld = _parseBool(json['is_shared_to_world']);

    return Moment(
      id: json['id'] as String? ?? '',
      circleId: json['circle_id'] as String?,
      author: author,
      content: json['content'] as String? ?? '',
      mediaType: mediaType,
      mediaUrls: _parseMediaUrls(json['media_urls']),
      timestamp: timestamp,
      contextTags: contextTags,
      location: json['location'] as String?,
      isFavorite: isFavorite,
      futureMessage: json['future_message'] as String?,
      isSharedToWorld: isSharedToWorld,
      worldTopic: json['world_topic'] as String?,
      createdAt: _parseDateTime(json['created_at']),
      updatedAt: _parseDateTime(json['updated_at']),
      deletedAt: _parseDateTime(json['deleted_at']),
    );
  }

  bool _parseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value.toLowerCase() == 'true' || value == '1';
    return false;
  }

  DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }

  List<String> _parseMediaUrls(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.map((item) => item.toString()).toList();
    }
    if (value is String && value.isNotEmpty) {
      try {
        final decoded = jsonDecode(value);
        if (decoded is List) {
          return decoded.map((item) => item.toString()).toList();
        }
      } catch (_) {
        return [value];
      }
    }
    return [];
  }
}

/// 时刻列表结果
class MomentListResult {
  final List<Moment> moments;
  final int page;
  final int total;
  final bool hasMore;

  const MomentListResult({
    required this.moments,
    required this.page,
    required this.total,
    required this.hasMore,
  });
}

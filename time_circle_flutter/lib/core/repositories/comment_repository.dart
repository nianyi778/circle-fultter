import '../config/api_config.dart';
import '../models/comment.dart';
import '../models/user.dart';
import '../services/api_service.dart';

/// 评论 Repository
///
/// 处理评论的增删改查，直接调用远程 API。
class CommentRepository {
  final ApiService _api;

  CommentRepository({ApiService? api}) : _api = api ?? ApiService.instance;

  /// 获取时刻的评论列表
  Future<CommentListResult> getMomentComments(
    String momentId, {
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _api.get<Map<String, dynamic>>(
      ApiConfig.commentsMoment(momentId),
      queryParameters: {'page': page.toString(), 'limit': limit.toString()},
      fromData: (data) => data as Map<String, dynamic>,
    );

    if (!response.success) {
      throw ApiException(
        code: response.error?.code ?? 'UNKNOWN',
        message: response.error?.message ?? 'Failed to get comments',
      );
    }

    // API 返回 { data: [...], meta: { page, limit, total, hasMore } }
    final data = response.data!['data'] as List<dynamic>? ?? [];
    final meta = response.data!['meta'] as Map<String, dynamic>?;

    return CommentListResult(
      comments: data.map((json) => _parseComment(json, momentId)).toList(),
      page: meta?['page'] as int? ?? page,
      total: meta?['total'] as int? ?? data.length,
      hasMore: meta?['hasMore'] as bool? ?? false,
    );
  }

  /// 获取世界帖子的评论列表
  Future<CommentListResult> getWorldPostComments(
    String postId, {
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _api.get<Map<String, dynamic>>(
      ApiConfig.commentsWorld(postId),
      queryParameters: {'page': page.toString(), 'limit': limit.toString()},
      fromData: (data) => data as Map<String, dynamic>,
    );

    if (!response.success) {
      throw ApiException(
        code: response.error?.code ?? 'UNKNOWN',
        message: response.error?.message ?? 'Failed to get comments',
      );
    }

    final data = response.data!['data'] as List<dynamic>? ?? [];
    final meta = response.data!['meta'] as Map<String, dynamic>?;

    return CommentListResult(
      comments:
          data
              .map(
                (json) => _parseComment(
                  json,
                  postId,
                  targetType: CommentTargetType.worldPost,
                ),
              )
              .toList(),
      page: meta?['page'] as int? ?? page,
      total: meta?['total'] as int? ?? data.length,
      hasMore: meta?['hasMore'] as bool? ?? false,
    );
  }

  /// 添加时刻评论
  Future<Comment> addMomentComment({
    required String momentId,
    required String content,
    String? replyToId,
  }) async {
    final response = await _api.post<Map<String, dynamic>>(
      ApiConfig.commentsMoment(momentId),
      data: {'content': content, if (replyToId != null) 'replyToId': replyToId},
      fromData: (data) => data as Map<String, dynamic>,
    );

    if (!response.success || response.data == null) {
      throw ApiException(
        code: response.error?.code ?? 'UNKNOWN',
        message: response.error?.message ?? 'Failed to add comment',
      );
    }

    return _parseComment(response.data!, momentId);
  }

  /// 添加世界帖子评论
  Future<Comment> addWorldPostComment({
    required String postId,
    required String content,
    String? replyToId,
  }) async {
    final response = await _api.post<Map<String, dynamic>>(
      ApiConfig.commentsWorld(postId),
      data: {'content': content, if (replyToId != null) 'replyToId': replyToId},
      fromData: (data) => data as Map<String, dynamic>,
    );

    if (!response.success || response.data == null) {
      throw ApiException(
        code: response.error?.code ?? 'UNKNOWN',
        message: response.error?.message ?? 'Failed to add comment',
      );
    }

    return _parseComment(
      response.data!,
      postId,
      targetType: CommentTargetType.worldPost,
    );
  }

  /// 删除评论
  Future<void> deleteComment(String commentId) async {
    final response = await _api.delete<void>(ApiConfig.comment(commentId));

    if (!response.success) {
      throw ApiException(
        code: response.error?.code ?? 'UNKNOWN',
        message: response.error?.message ?? 'Failed to delete comment',
      );
    }
  }

  /// 点赞评论
  Future<int> likeComment(String commentId) async {
    final response = await _api.post<Map<String, dynamic>>(
      ApiConfig.commentLike(commentId),
      fromData: (data) => data as Map<String, dynamic>,
    );

    if (!response.success || response.data == null) {
      throw ApiException(
        code: response.error?.code ?? 'UNKNOWN',
        message: response.error?.message ?? 'Failed to like comment',
      );
    }

    return response.data!['likes'] as int? ?? 0;
  }

  /// 解析评论
  Comment _parseComment(
    Map<String, dynamic> json,
    String targetId, {
    CommentTargetType targetType = CommentTargetType.moment,
  }) {
    final author = User(
      id: json['author_id'] as String? ?? '',
      name: json['author_name'] as String? ?? '',
      avatar: json['author_avatar'] as String? ?? '',
    );

    // 解析回复目标用户
    User? replyTo;
    if (json['reply_to_id'] != null && json['reply_to_name'] != null) {
      replyTo = User(
        id: json['reply_to_id'] as String,
        name: json['reply_to_name'] as String,
        avatar: json['reply_to_avatar'] as String? ?? '',
      );
    }

    DateTime? timestamp;
    final createdAt = json['created_at'];
    if (createdAt != null) {
      timestamp = DateTime.tryParse(createdAt.toString());
    }
    timestamp ??= DateTime.now();

    return Comment(
      id: json['id'] as String? ?? '',
      targetId: targetId,
      targetType: targetType,
      author: author,
      content: json['content'] as String? ?? '',
      timestamp: timestamp,
      likes: json['likes'] as int? ?? 0,
      replyTo: replyTo,
    );
  }
}

/// 评论列表结果
class CommentListResult {
  final List<Comment> comments;
  final int page;
  final int total;
  final bool hasMore;

  const CommentListResult({
    required this.comments,
    required this.page,
    required this.total,
    required this.hasMore,
  });
}

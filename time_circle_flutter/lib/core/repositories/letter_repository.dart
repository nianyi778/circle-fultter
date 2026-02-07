import '../config/api_config.dart';
import '../models/letter.dart';
import '../services/api_service.dart';

/// 信件 Repository
///
/// 处理信件的增删改查，直接调用远程 API。
class LetterRepository {
  final ApiService _api;

  LetterRepository({ApiService? api}) : _api = api ?? ApiService.instance;

  /// 获取圈子的信件列表
  Future<List<Letter>> getLetters(
    String circleId, {
    LetterStatus? status,
    LetterType? type,
  }) async {
    final queryParams = <String, String>{};

    if (status != null) queryParams['status'] = status.name;
    if (type != null) queryParams['type'] = type.name;

    final response = await _api.get<List<dynamic>>(
      ApiConfig.circleLetters(circleId),
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
      fromData: (data) => data as List<dynamic>,
    );

    if (!response.success || response.data == null) {
      throw ApiException(
        code: response.error?.code ?? 'UNKNOWN',
        message: response.error?.message ?? 'Failed to get letters',
      );
    }

    return response.data!.map((json) => _parseLetter(json)).toList();
  }

  /// 获取单个信件详情
  Future<Letter> getLetter(String letterId) async {
    final response = await _api.get<Map<String, dynamic>>(
      ApiConfig.letter(letterId),
      fromData: (data) => data as Map<String, dynamic>,
    );

    if (!response.success || response.data == null) {
      throw ApiException(
        code: response.error?.code ?? 'UNKNOWN',
        message: response.error?.message ?? 'Failed to get letter',
      );
    }

    return _parseLetter(response.data!);
  }

  /// 创建信件
  Future<Letter> createLetter({
    required String circleId,
    required String title,
    required LetterType type,
    required String recipient,
    String? content,
  }) async {
    final response = await _api.post<Map<String, dynamic>>(
      ApiConfig.circleLetters(circleId),
      data: {
        'title': title,
        'type': type.name,
        'recipient': recipient,
        if (content != null) 'content': content,
      },
      fromData: (data) => data as Map<String, dynamic>,
    );

    if (!response.success || response.data == null) {
      throw ApiException(
        code: response.error?.code ?? 'UNKNOWN',
        message: response.error?.message ?? 'Failed to create letter',
      );
    }

    return _parseLetter(response.data!);
  }

  /// 更新信件（仅草稿状态可编辑）
  Future<Letter> updateLetter({
    required String letterId,
    String? title,
    String? content,
    String? recipient,
  }) async {
    final data = <String, dynamic>{};

    if (title != null) data['title'] = title;
    if (content != null) data['content'] = content;
    if (recipient != null) data['recipient'] = recipient;

    final response = await _api.put<Map<String, dynamic>>(
      ApiConfig.letter(letterId),
      data: data,
      fromData: (data) => data as Map<String, dynamic>,
    );

    if (!response.success || response.data == null) {
      throw ApiException(
        code: response.error?.code ?? 'UNKNOWN',
        message: response.error?.message ?? 'Failed to update letter',
      );
    }

    return _parseLetter(response.data!);
  }

  /// 删除信件
  Future<void> deleteLetter(String letterId) async {
    final response = await _api.delete<void>(ApiConfig.letter(letterId));

    if (!response.success) {
      throw ApiException(
        code: response.error?.code ?? 'UNKNOWN',
        message: response.error?.message ?? 'Failed to delete letter',
      );
    }
  }

  /// 封存信件（设置解锁日期）
  Future<Letter> sealLetter({
    required String letterId,
    required DateTime unlockDate,
  }) async {
    final response = await _api.post<Map<String, dynamic>>(
      ApiConfig.letterSeal(letterId),
      data: {'unlockDate': unlockDate.toUtc().toIso8601String()},
      fromData: (data) => data as Map<String, dynamic>,
    );

    if (!response.success || response.data == null) {
      throw ApiException(
        code: response.error?.code ?? 'UNKNOWN',
        message: response.error?.message ?? 'Failed to seal letter',
      );
    }

    return _parseLetter(response.data!);
  }

  /// 解锁信件（如果解锁日期已到）
  Future<Letter> unlockLetter(String letterId) async {
    final response = await _api.post<Map<String, dynamic>>(
      ApiConfig.letterUnlock(letterId),
      fromData: (data) => data as Map<String, dynamic>,
    );

    if (!response.success || response.data == null) {
      throw ApiException(
        code: response.error?.code ?? 'UNKNOWN',
        message: response.error?.message ?? 'Failed to unlock letter',
      );
    }

    return _parseLetter(response.data!);
  }

  /// 解析信件
  Letter _parseLetter(Map<String, dynamic> json) {
    // 解析状态
    final statusStr = json['status'] as String? ?? 'draft';
    final status = LetterStatus.values.firstWhere(
      (e) => e.name == statusStr,
      orElse: () => LetterStatus.draft,
    );

    // 解析类型
    final typeStr = json['type'] as String? ?? 'free';
    final type = LetterType.values.firstWhere(
      (e) => e.name == typeStr,
      orElse: () => LetterType.free,
    );

    return Letter(
      id: json['id'] as String? ?? '',
      circleId: json['circle_id'] as String?,
      authorId: json['author_id'] as String?,
      title: json['title'] as String? ?? '',
      preview: json['preview'] as String? ?? '',
      status: status,
      unlockDate: _parseDateTime(json['unlock_date']),
      recipient: json['recipient'] as String? ?? '',
      type: type,
      content: json['content'] as String?,
      createdAt: _parseDateTime(json['created_at']),
      sealedAt: _parseDateTime(json['sealed_at']),
      updatedAt: _parseDateTime(json['updated_at']),
      deletedAt: _parseDateTime(json['deleted_at']),
    );
  }

  DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}

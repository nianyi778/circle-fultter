import '../config/api_config.dart';
import '../models/user.dart';
import '../services/api_service.dart';

/// 圈子 Repository
///
/// 处理圈子信息的读取和更新，直接调用远程 API。
class CircleRepository {
  final ApiService _api;

  CircleRepository({ApiService? api}) : _api = api ?? ApiService.instance;

  /// 获取用户的所有圈子列表
  Future<List<CircleInfo>> getCircles() async {
    final response = await _api.get<List<dynamic>>(
      ApiConfig.circles,
      fromData: (data) => data as List<dynamic>,
    );

    if (!response.success || response.data == null) {
      throw ApiException(
        code: response.error?.code ?? 'UNKNOWN',
        message: response.error?.message ?? 'Failed to get circles',
      );
    }

    return response.data!.map((json) => _parseCircleInfo(json)).toList();
  }

  /// 获取单个圈子详情
  Future<CircleInfo> getCircle(String circleId) async {
    final response = await _api.get<Map<String, dynamic>>(
      ApiConfig.circle(circleId),
      fromData: (data) => data as Map<String, dynamic>,
    );

    if (!response.success || response.data == null) {
      throw ApiException(
        code: response.error?.code ?? 'UNKNOWN',
        message: response.error?.message ?? 'Failed to get circle',
      );
    }

    return _parseCircleInfo(response.data!);
  }

  /// 创建新圈子
  Future<CircleInfo> createCircle({
    required String name,
    DateTime? startDate,
  }) async {
    final response = await _api.post<Map<String, dynamic>>(
      ApiConfig.circles,
      data: {
        'name': name,
        if (startDate != null) 'startDate': startDate.toIso8601String(),
      },
      fromData: (data) => data as Map<String, dynamic>,
    );

    if (!response.success || response.data == null) {
      throw ApiException(
        code: response.error?.code ?? 'UNKNOWN',
        message: response.error?.message ?? 'Failed to create circle',
      );
    }

    return _parseCircleInfo(response.data!);
  }

  /// 更新圈子信息
  Future<CircleInfo> updateCircle({
    required String circleId,
    String? name,
    DateTime? startDate,
    bool clearStartDate = false,
  }) async {
    final data = <String, dynamic>{};

    if (name != null) {
      data['name'] = name;
    }

    if (clearStartDate) {
      data['startDate'] = null;
    } else if (startDate != null) {
      data['startDate'] = startDate.toIso8601String();
    }

    final response = await _api.put<Map<String, dynamic>>(
      ApiConfig.circle(circleId),
      data: data,
      fromData: (data) => data as Map<String, dynamic>,
    );

    if (!response.success || response.data == null) {
      throw ApiException(
        code: response.error?.code ?? 'UNKNOWN',
        message: response.error?.message ?? 'Failed to update circle',
      );
    }

    return _parseCircleInfo(response.data!);
  }

  /// 删除圈子
  Future<void> deleteCircle(String circleId) async {
    final response = await _api.delete<void>(ApiConfig.circle(circleId));

    if (!response.success) {
      throw ApiException(
        code: response.error?.code ?? 'UNKNOWN',
        message: response.error?.message ?? 'Failed to delete circle',
      );
    }
  }

  /// 生成新的邀请码
  Future<InviteCodeInfo> generateInviteCode(
    String circleId, {
    int expiresInDays = 7,
  }) async {
    final response = await _api.post<Map<String, dynamic>>(
      ApiConfig.circleInvite(circleId),
      data: {'expiresInDays': expiresInDays},
      fromData: (data) => data as Map<String, dynamic>,
    );

    if (!response.success || response.data == null) {
      throw ApiException(
        code: response.error?.code ?? 'UNKNOWN',
        message: response.error?.message ?? 'Failed to generate invite code',
      );
    }

    return InviteCodeInfo(
      code: response.data!['inviteCode'] as String,
      expiresAt: DateTime.parse(response.data!['expiresAt'] as String),
    );
  }

  /// 使用邀请码加入圈子
  Future<CircleInfo> joinCircle({
    required String inviteCode,
    String? roleLabel,
  }) async {
    final response = await _api.post<Map<String, dynamic>>(
      ApiConfig.circleJoin,
      data: {
        'inviteCode': inviteCode,
        if (roleLabel != null) 'roleLabel': roleLabel,
      },
      fromData: (data) => data as Map<String, dynamic>,
    );

    if (!response.success || response.data == null) {
      throw ApiException(
        code: response.error?.code ?? 'UNKNOWN',
        message: response.error?.message ?? 'Failed to join circle',
      );
    }

    return _parseCircleInfo(response.data!);
  }

  /// 解析圈子信息
  CircleInfo _parseCircleInfo(Map<String, dynamic> json) {
    DateTime? startDate;
    final startDateStr = json['start_date'] ?? json['startDate'];
    if (startDateStr != null && startDateStr.toString().isNotEmpty) {
      startDate = DateTime.tryParse(startDateStr.toString());
    }

    DateTime? joinedAt;
    final joinedAtStr = json['joined_at'] ?? json['joinedAt'];
    if (joinedAtStr != null && joinedAtStr.toString().isNotEmpty) {
      joinedAt = DateTime.tryParse(joinedAtStr.toString());
    }

    return CircleInfo(
      id: json['id'] as String?,
      name: json['name'] as String? ?? '',
      startDate: startDate,
      joinedAt: joinedAt,
    );
  }
}

/// 邀请码信息
class InviteCodeInfo {
  final String code;
  final DateTime expiresAt;

  const InviteCodeInfo({required this.code, required this.expiresAt});

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

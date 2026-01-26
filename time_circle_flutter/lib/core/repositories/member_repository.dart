import '../config/api_config.dart';
import '../models/user.dart';
import '../services/api_service.dart';

/// 成员 Repository
///
/// 处理圈子成员的读取和管理，直接调用远程 API。
class MemberRepository {
  final ApiService _api;

  MemberRepository({ApiService? api}) : _api = api ?? ApiService.instance;

  /// 获取圈子的所有成员
  Future<List<CircleMember>> getMembers(String circleId) async {
    final response = await _api.get<List<dynamic>>(
      ApiConfig.circleMembers(circleId),
      fromData: (data) => data as List<dynamic>,
    );

    if (!response.success || response.data == null) {
      throw ApiException(
        code: response.error?.code ?? 'UNKNOWN',
        message: response.error?.message ?? 'Failed to get members',
      );
    }

    return response.data!.map((json) => _parseMember(json)).toList();
  }

  /// 更新成员信息（角色标签等）
  Future<void> updateMember({
    required String circleId,
    required String userId,
    String? roleLabel,
    String? role,
  }) async {
    final data = <String, dynamic>{};

    if (roleLabel != null) {
      data['roleLabel'] = roleLabel;
    }

    if (role != null) {
      data['role'] = role;
    }

    final response = await _api.put<void>(
      '${ApiConfig.circleMembers(circleId)}/$userId',
      data: data,
    );

    if (!response.success) {
      throw ApiException(
        code: response.error?.code ?? 'UNKNOWN',
        message: response.error?.message ?? 'Failed to update member',
      );
    }
  }

  /// 移除成员
  Future<void> removeMember({
    required String circleId,
    required String userId,
  }) async {
    final response = await _api.delete<void>(
      '${ApiConfig.circleMembers(circleId)}/$userId',
    );

    if (!response.success) {
      throw ApiException(
        code: response.error?.code ?? 'UNKNOWN',
        message: response.error?.message ?? 'Failed to remove member',
      );
    }
  }

  /// 解析成员信息
  CircleMember _parseMember(Map<String, dynamic> json) {
    return CircleMember(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      email: json['email'] as String?,
      avatar: json['avatar'] as String? ?? '',
      role: json['role'] as String? ?? 'member',
      roleLabel: json['role_label'] as String?,
      joinedAt:
          json['joined_at'] != null
              ? DateTime.tryParse(json['joined_at'].toString())
              : null,
    );
  }
}

/// 圈子成员模型
///
/// 扩展 User 模型，包含成员在圈子中的角色信息
class CircleMember extends User {
  final String? email;
  final String role; // 'admin' or 'member'
  @override
  final DateTime? joinedAt;

  const CircleMember({
    required super.id,
    required super.name,
    required super.avatar,
    super.roleLabel,
    this.email,
    this.role = 'member',
    this.joinedAt,
  });

  bool get isAdmin => role == 'admin';

  /// 转换为基础 User 对象
  User toUser() =>
      User(id: id, name: name, avatar: avatar, roleLabel: roleLabel);
}

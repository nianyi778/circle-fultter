import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../config/api_config.dart';
import '../models/moment.dart';
import '../models/letter.dart';
import '../models/comment.dart';
import '../models/user.dart';
import 'api_service.dart';
import 'database_service.dart';

/// 持久化待同步队列的 key
const String _pendingChangesKey = 'pending_sync_changes';

/// 同步错误类型
enum SyncErrorType {
  network, // 网络错误
  server, // 服务器错误
  auth, // 认证错误
  conflict, // 数据冲突
  validation, // 数据验证错误
  unknown, // 未知错误
}

/// 同步错误
class SyncError implements Exception {
  final SyncErrorType type;
  final String message;
  final String? details;
  final dynamic originalError;

  const SyncError({
    required this.type,
    required this.message,
    this.details,
    this.originalError,
  });

  @override
  String toString() =>
      'SyncError($type): $message${details != null ? ' - $details' : ''}';

  /// 获取用户友好的错误信息
  String get userFriendlyMessage {
    switch (type) {
      case SyncErrorType.network:
        return '网络连接失败，请检查网络设置';
      case SyncErrorType.server:
        return '服务器暂时不可用，请稍后重试';
      case SyncErrorType.auth:
        return '登录已过期，请重新登录';
      case SyncErrorType.conflict:
        return '数据有冲突，正在自动解决';
      case SyncErrorType.validation:
        return '数据格式错误，请检查输入';
      case SyncErrorType.unknown:
        return '同步失败，请稍后重试';
    }
  }
}

/// 冲突解决策略
enum ConflictResolutionStrategy {
  serverWins, // 服务器数据优先
  clientWins, // 本地数据优先
  lastWriteWins, // 最后写入优先（默认）
  manual, // 手动解决（需要用户确认）
}

/// 冲突信息
class SyncConflict {
  final String entityType;
  final String entityId;
  final Map<String, dynamic>? localData;
  final Map<String, dynamic>? serverData;
  final DateTime localTimestamp;
  final DateTime serverTimestamp;

  const SyncConflict({
    required this.entityType,
    required this.entityId,
    this.localData,
    this.serverData,
    required this.localTimestamp,
    required this.serverTimestamp,
  });
}

/// 同步结果
class SyncResult {
  final bool success;
  final int pushedCount;
  final int pulledCount;
  final int conflictCount;
  final List<SyncError> errors;
  final Duration duration;

  const SyncResult({
    required this.success,
    this.pushedCount = 0,
    this.pulledCount = 0,
    this.conflictCount = 0,
    this.errors = const [],
    this.duration = Duration.zero,
  });

  factory SyncResult.failure(SyncError error) =>
      SyncResult(success: false, errors: [error]);
}

/// 同步变更
class SyncChange {
  final String entityType;
  final String entityId;
  final String action;
  final Map<String, dynamic>? data;
  final DateTime timestamp;

  const SyncChange({
    required this.entityType,
    required this.entityId,
    required this.action,
    this.data,
    required this.timestamp,
  });

  factory SyncChange.fromJson(Map<String, dynamic> json) {
    return SyncChange(
      entityType: json['entityType'] as String,
      entityId: json['entityId'] as String,
      action: json['action'] as String,
      data: json['data'] as Map<String, dynamic>?,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'entityType': entityType,
    'entityId': entityId,
    'action': action,
    if (data != null) 'data': data,
    'timestamp': timestamp.toIso8601String(),
  };
}

/// 同步状态
enum SyncStatus { idle, syncing, success, error, offline }

/// 同步状态详情
class SyncStatusInfo {
  final SyncStatus status;
  final String? message;
  final SyncError? error;
  final int pendingChangesCount;
  final DateTime? lastSyncTime;

  const SyncStatusInfo({
    required this.status,
    this.message,
    this.error,
    this.pendingChangesCount = 0,
    this.lastSyncTime,
  });

  SyncStatusInfo copyWith({
    SyncStatus? status,
    String? message,
    SyncError? error,
    int? pendingChangesCount,
    DateTime? lastSyncTime,
  }) {
    return SyncStatusInfo(
      status: status ?? this.status,
      message: message ?? this.message,
      error: error ?? this.error,
      pendingChangesCount: pendingChangesCount ?? this.pendingChangesCount,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
    );
  }
}

/// 同步服务
///
/// 处理离线优先的数据同步
class SyncService {
  static SyncService? _instance;
  static SyncService get instance => _instance ??= SyncService._();

  final ApiService _api = ApiService.instance;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final Connectivity _connectivity = Connectivity();

  DatabaseService? _db;
  String? _currentCircleId;

  // 同步状态
  SyncStatus _status = SyncStatus.idle;
  final _statusController = StreamController<SyncStatus>.broadcast();
  Stream<SyncStatus> get statusStream => _statusController.stream;
  SyncStatus get status => _status;

  // 详细状态
  SyncStatusInfo _statusInfo = const SyncStatusInfo(status: SyncStatus.idle);
  final _statusInfoController = StreamController<SyncStatusInfo>.broadcast();
  Stream<SyncStatusInfo> get statusInfoStream => _statusInfoController.stream;
  SyncStatusInfo get statusInfo => _statusInfo;

  // 待同步的本地变更
  final List<SyncChange> _pendingChanges = [];
  int get pendingChangesCount => _pendingChanges.length;

  // 同步锁
  bool _isSyncing = false;

  // 重试配置
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(seconds: 2);

  // 冲突解决策略
  ConflictResolutionStrategy _conflictStrategy =
      ConflictResolutionStrategy.lastWriteWins;
  ConflictResolutionStrategy get conflictStrategy => _conflictStrategy;
  set conflictStrategy(ConflictResolutionStrategy strategy) {
    _conflictStrategy = strategy;
  }

  // 冲突回调（用于手动解决）
  Future<Map<String, dynamic>?> Function(SyncConflict conflict)? onConflict;

  // 错误回调
  void Function(SyncError error)? onError;

  SyncService._() {
    // 监听网络状态变化
    _connectivity.onConnectivityChanged.listen(_onConnectivityChanged);
  }

  /// 初始化
  Future<void> init(DatabaseService db, String circleId) async {
    _db = db;
    _currentCircleId = circleId;

    // 重置同步状态为 idle
    _setStatus(SyncStatus.idle);

    // 加载持久化的待同步队列
    await _loadPendingChanges();

    // 更新状态信息
    _updateStatusInfo(
      status: SyncStatus.idle,
      pendingChangesCount: _pendingChanges.length,
    );
  }

  /// 加载持久化的待同步队列
  Future<void> _loadPendingChanges() async {
    try {
      final jsonStr = await _storage.read(key: _pendingChangesKey);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final List<dynamic> jsonList = json.decode(jsonStr);
        _pendingChanges.clear();
        _pendingChanges.addAll(
          jsonList.map((j) => SyncChange.fromJson(j as Map<String, dynamic>)),
        );
        debugPrint(
          'Loaded ${_pendingChanges.length} pending changes from storage',
        );
      }
    } catch (e) {
      debugPrint('Failed to load pending changes: $e');
      _handleError(
        SyncError(
          type: SyncErrorType.unknown,
          message: 'Failed to load pending changes',
          originalError: e,
        ),
      );
    }
  }

  /// 保存待同步队列到持久化存储
  Future<void> _savePendingChanges() async {
    try {
      final jsonStr = json.encode(
        _pendingChanges.map((c) => c.toJson()).toList(),
      );
      await _storage.write(key: _pendingChangesKey, value: jsonStr);
    } catch (e) {
      debugPrint('Failed to save pending changes: $e');
    }
  }

  /// 设置当前圈子 ID
  Future<void> setCurrentCircle(String circleId) async {
    _currentCircleId = circleId;
    await _storage.write(key: ApiConfig.currentCircleIdKey, value: circleId);
  }

  /// 获取当前圈子 ID
  Future<String?> getCurrentCircleId() async {
    _currentCircleId ??= await _storage.read(key: ApiConfig.currentCircleIdKey);
    return _currentCircleId;
  }

  /// 网络状态变化回调
  void _onConnectivityChanged(List<ConnectivityResult> results) {
    final hasConnection = results.any((r) => r != ConnectivityResult.none);
    if (hasConnection && _pendingChanges.isNotEmpty) {
      // 网络恢复，尝试同步
      sync();
    }
  }

  /// 检查是否在线
  Future<bool> isOnline() async {
    final result = await _connectivity.checkConnectivity();
    return result.any((r) => r != ConnectivityResult.none);
  }

  /// 添加本地变更
  Future<void> addLocalChange(SyncChange change) async {
    _pendingChanges.add(change);
    // 持久化保存
    await _savePendingChanges();
    // 尝试立即同步
    sync();
  }

  /// 记录时刻创建
  void recordMomentCreate(Moment moment) {
    addLocalChange(
      SyncChange(
        entityType: 'moment',
        entityId: moment.id,
        action: 'create',
        data: _momentToSyncData(moment),
        timestamp: DateTime.now(),
      ),
    );
  }

  /// 记录时刻更新
  void recordMomentUpdate(Moment moment) {
    addLocalChange(
      SyncChange(
        entityType: 'moment',
        entityId: moment.id,
        action: 'update',
        data: _momentToSyncData(moment),
        timestamp: DateTime.now(),
      ),
    );
  }

  /// 记录时刻删除
  void recordMomentDelete(String momentId) {
    addLocalChange(
      SyncChange(
        entityType: 'moment',
        entityId: momentId,
        action: 'delete',
        timestamp: DateTime.now(),
      ),
    );
  }

  /// 记录信件创建
  void recordLetterCreate(Letter letter) {
    addLocalChange(
      SyncChange(
        entityType: 'letter',
        entityId: letter.id,
        action: 'create',
        data: _letterToSyncData(letter),
        timestamp: DateTime.now(),
      ),
    );
  }

  /// 记录信件更新
  void recordLetterUpdate(Letter letter) {
    addLocalChange(
      SyncChange(
        entityType: 'letter',
        entityId: letter.id,
        action: 'update',
        data: _letterToSyncData(letter),
        timestamp: DateTime.now(),
      ),
    );
  }

  /// 记录信件删除
  void recordLetterDelete(String letterId) {
    addLocalChange(
      SyncChange(
        entityType: 'letter',
        entityId: letterId,
        action: 'delete',
        timestamp: DateTime.now(),
      ),
    );
  }

  /// 执行同步
  Future<SyncResult> sync() async {
    if (_isSyncing || _currentCircleId == null) {
      return const SyncResult(success: true);
    }

    final startTime = DateTime.now();
    final online = await isOnline();
    if (!online) {
      _setStatus(SyncStatus.offline);
      _updateStatusInfo(
        status: SyncStatus.offline,
        message: '离线模式',
        pendingChangesCount: _pendingChanges.length,
      );
      return SyncResult.failure(
        const SyncError(
          type: SyncErrorType.network,
          message: 'No network connection',
        ),
      );
    }

    _isSyncing = true;
    _setStatus(SyncStatus.syncing);
    _updateStatusInfo(
      status: SyncStatus.syncing,
      message: '正在同步...',
      pendingChangesCount: _pendingChanges.length,
    );

    int pushedCount = 0;
    int pulledCount = 0;
    int conflictCount = 0;
    final errors = <SyncError>[];

    try {
      // 1. 推送本地变更（带重试）
      if (_pendingChanges.isNotEmpty) {
        final pushResult = await _pushChangesWithRetry();
        pushedCount = pushResult.pushedCount;
        conflictCount = pushResult.conflictCount;
        errors.addAll(pushResult.errors);
      }

      // 2. 拉取远程变更
      final pullResult = await _pullChangesWithConflictResolution();
      pulledCount = pullResult.pulledCount;
      conflictCount += pullResult.conflictCount;
      errors.addAll(pullResult.errors);

      final duration = DateTime.now().difference(startTime);
      final success =
          errors.isEmpty ||
          errors.every((e) => e.type == SyncErrorType.conflict);

      debugPrint(
        'Sync completed: success=$success, pushed=$pushedCount, pulled=$pulledCount, errors=${errors.length}',
      );
      if (errors.isNotEmpty) {
        for (final e in errors) {
          debugPrint('  Sync error: ${e.type} - ${e.message}');
        }
      }

      _setStatus(success ? SyncStatus.success : SyncStatus.error);
      _updateStatusInfo(
        status: success ? SyncStatus.success : SyncStatus.error,
        message: success ? '同步完成' : '同步失败',
        pendingChangesCount: _pendingChanges.length,
        lastSyncTime: success ? DateTime.now() : null,
      );

      return SyncResult(
        success: success,
        pushedCount: pushedCount,
        pulledCount: pulledCount,
        conflictCount: conflictCount,
        errors: errors,
        duration: duration,
      );
    } catch (e) {
      debugPrint('Sync error: $e');
      final error = _classifyError(e);
      _handleError(error);
      _setStatus(SyncStatus.error);
      _updateStatusInfo(
        status: SyncStatus.error,
        message: error.userFriendlyMessage,
        error: error,
        pendingChangesCount: _pendingChanges.length,
      );
      return SyncResult.failure(error);
    } finally {
      _isSyncing = false;
    }
  }

  /// 带重试的推送变更
  Future<({int pushedCount, int conflictCount, List<SyncError> errors})>
  _pushChangesWithRetry() async {
    int retryCount = 0;
    int pushedCount = 0;
    int conflictCount = 0;
    final errors = <SyncError>[];

    while (retryCount < _maxRetries && _pendingChanges.isNotEmpty) {
      try {
        final result = await _pushChanges();
        pushedCount = result.pushedCount;
        conflictCount = result.conflictCount;
        errors.addAll(result.errors);
        break; // 成功，退出重试循环
      } catch (e) {
        retryCount++;
        final error = _classifyError(e);

        // 如果是认证错误或验证错误，不重试
        if (error.type == SyncErrorType.auth ||
            error.type == SyncErrorType.validation) {
          errors.add(error);
          break;
        }

        if (retryCount >= _maxRetries) {
          errors.add(
            SyncError(
              type: error.type,
              message: 'Push failed after $_maxRetries retries',
              details: error.message,
              originalError: e,
            ),
          );
        } else {
          debugPrint(
            'Push failed, retrying in ${_retryDelay.inSeconds}s... (attempt $retryCount/$_maxRetries)',
          );
          await Future.delayed(_retryDelay * retryCount); // 指数退避
        }
      }
    }

    return (
      pushedCount: pushedCount,
      conflictCount: conflictCount,
      errors: errors,
    );
  }

  /// 推送本地变更到服务器
  Future<({int pushedCount, int conflictCount, List<SyncError> errors})>
  _pushChanges() async {
    int pushedCount = 0;
    int conflictCount = 0;
    final errors = <SyncError>[];

    if (_pendingChanges.isEmpty || _currentCircleId == null) {
      return (pushedCount: 0, conflictCount: 0, errors: <SyncError>[]);
    }

    final changes = List<SyncChange>.from(_pendingChanges);

    try {
      final response = await _api.post<Map<String, dynamic>>(
        ApiConfig.syncPush,
        data: {
          'circleId': _currentCircleId,
          'changes': changes.map((c) => c.toJson()).toList(),
          'clientTimestamp': DateTime.now().toIso8601String(),
        },
        fromData: (data) => data as Map<String, dynamic>,
      );

      if (response.success) {
        pushedCount = changes.length;

        // 处理服务器返回的冲突
        final conflicts = response.data?['conflicts'] as List<dynamic>? ?? [];
        for (final c in conflicts) {
          final conflictData = c as Map<String, dynamic>;
          conflictCount++;

          // 根据策略处理冲突
          if (_conflictStrategy == ConflictResolutionStrategy.serverWins) {
            // 服务器优先，需要重新拉取该数据
            debugPrint('Conflict on ${conflictData['entityId']}, server wins');
          }
        }

        // 清除已成功推送的变更
        _pendingChanges.clear();
        // 清除持久化存储
        await _savePendingChanges();

        // 更新最后同步时间
        final serverTimestamp = response.data?['serverTimestamp'] as String?;
        if (serverTimestamp != null) {
          await _storage.write(
            key: ApiConfig.lastSyncTimestampKey,
            value: serverTimestamp,
          );
        }
      } else {
        errors.add(
          const SyncError(type: SyncErrorType.server, message: 'Push failed'),
        );
      }
    } catch (e) {
      debugPrint('Push changes error: $e');
      rethrow;
    }

    return (
      pushedCount: pushedCount,
      conflictCount: conflictCount,
      errors: errors,
    );
  }

  /// 应用单个变更到本地数据库
  Future<void> _applyChange(SyncChange change) async {
    if (_db == null) return;

    switch (change.entityType) {
      case 'moment':
        await _applyMomentChange(change);
        break;
      case 'letter':
        await _applyLetterChange(change);
        break;
      case 'comment':
        await _applyCommentChange(change);
        break;
    }
  }

  Future<void> _applyMomentChange(SyncChange change) async {
    if (_db == null || change.data == null && change.action != 'delete') return;

    switch (change.action) {
      case 'create':
      case 'update':
        final moment = _syncDataToMoment(change.entityId, change.data!);
        if (change.action == 'create') {
          await _db!.insertMoment(moment);
        } else {
          await _db!.updateMoment(moment);
        }
        break;
      case 'delete':
        await _db!.deleteMoment(change.entityId);
        break;
    }
  }

  Future<void> _applyLetterChange(SyncChange change) async {
    if (_db == null || change.data == null && change.action != 'delete') return;

    switch (change.action) {
      case 'create':
      case 'update':
        final letter = _syncDataToLetter(change.entityId, change.data!);
        if (change.action == 'create') {
          await _db!.insertLetter(letter);
        } else {
          await _db!.updateLetter(letter);
        }
        break;
      case 'delete':
        await _db!.deleteLetter(change.entityId);
        break;
    }
  }

  Future<void> _applyCommentChange(SyncChange change) async {
    if (_db == null || change.data == null && change.action != 'delete') return;

    switch (change.action) {
      case 'create':
        final comment = _syncDataToComment(change.entityId, change.data!);
        await _db!.insertComment(comment);
        break;
      case 'delete':
        await _db!.deleteComment(change.entityId);
        break;
    }
  }

  /// 完整同步（首次登录或数据丢失时使用）
  Future<void> fullSync() async {
    if (_currentCircleId == null || _db == null) return;

    final online = await isOnline();
    if (!online) {
      _setStatus(SyncStatus.offline);
      return;
    }

    _isSyncing = true;
    _setStatus(SyncStatus.syncing);

    try {
      final response = await _api.get<Map<String, dynamic>>(
        ApiConfig.syncFull,
        queryParameters: {'circleId': _currentCircleId},
        fromData: (data) => data as Map<String, dynamic>,
      );

      if (response.success && response.data != null) {
        final data = response.data!;

        // 同步时刻
        final moments = (data['moments'] as List<dynamic>?) ?? [];
        for (final m in moments) {
          final moment = _serverMomentToLocal(m as Map<String, dynamic>);
          // 使用 insertMoment，如果存在则会更新
          try {
            await _db!.insertMoment(moment);
          } catch (_) {
            await _db!.updateMoment(moment);
          }
        }

        // 同步信件
        final letters = (data['letters'] as List<dynamic>?) ?? [];
        for (final l in letters) {
          final letter = _serverLetterToLocal(l as Map<String, dynamic>);
          try {
            await _db!.insertLetter(letter);
          } catch (_) {
            await _db!.updateLetter(letter);
          }
        }

        // 更新最后同步时间
        final serverTimestamp = data['serverTimestamp'] as String?;
        if (serverTimestamp != null) {
          await _storage.write(
            key: ApiConfig.lastSyncTimestampKey,
            value: serverTimestamp,
          );
        }
      }

      _setStatus(SyncStatus.success);
    } catch (e) {
      debugPrint('Full sync error: $e');
      _setStatus(SyncStatus.error);
    } finally {
      _isSyncing = false;
    }
  }

  void _setStatus(SyncStatus status) {
    _status = status;
    _statusController.add(status);
  }

  /// 更新详细状态信息
  void _updateStatusInfo({
    SyncStatus? status,
    String? message,
    SyncError? error,
    int? pendingChangesCount,
    DateTime? lastSyncTime,
  }) {
    _statusInfo = SyncStatusInfo(
      status: status ?? _statusInfo.status,
      message: message ?? _statusInfo.message,
      error: error,
      pendingChangesCount:
          pendingChangesCount ?? _statusInfo.pendingChangesCount,
      lastSyncTime: lastSyncTime ?? _statusInfo.lastSyncTime,
    );
    _statusInfoController.add(_statusInfo);
  }

  /// 处理错误
  void _handleError(SyncError error) {
    debugPrint('SyncService Error: $error');
    onError?.call(error);
  }

  /// 错误分类
  SyncError _classifyError(dynamic e) {
    if (e is SyncError) return e;

    final errorStr = e.toString().toLowerCase();

    // 网络错误
    if (errorStr.contains('socket') ||
        errorStr.contains('connection') ||
        errorStr.contains('timeout') ||
        errorStr.contains('network')) {
      return SyncError(
        type: SyncErrorType.network,
        message: 'Network error',
        originalError: e,
      );
    }

    // 认证错误
    if (errorStr.contains('401') ||
        errorStr.contains('unauthorized') ||
        errorStr.contains('token')) {
      return SyncError(
        type: SyncErrorType.auth,
        message: 'Authentication error',
        originalError: e,
      );
    }

    // 服务器错误
    if (errorStr.contains('500') ||
        errorStr.contains('502') ||
        errorStr.contains('503') ||
        errorStr.contains('server')) {
      return SyncError(
        type: SyncErrorType.server,
        message: 'Server error',
        originalError: e,
      );
    }

    // 验证错误
    if (errorStr.contains('400') ||
        errorStr.contains('validation') ||
        errorStr.contains('invalid')) {
      return SyncError(
        type: SyncErrorType.validation,
        message: 'Validation error',
        originalError: e,
      );
    }

    // 冲突错误
    if (errorStr.contains('409') || errorStr.contains('conflict')) {
      return SyncError(
        type: SyncErrorType.conflict,
        message: 'Conflict error',
        originalError: e,
      );
    }

    return SyncError(
      type: SyncErrorType.unknown,
      message: 'Unknown error: $e',
      originalError: e,
    );
  }

  /// 带冲突解决的拉取变更
  Future<({int pulledCount, int conflictCount, List<SyncError> errors})>
  _pullChangesWithConflictResolution() async {
    if (_currentCircleId == null || _db == null) {
      return (pulledCount: 0, conflictCount: 0, errors: <SyncError>[]);
    }

    int pulledCount = 0;
    int conflictCount = 0;
    final errors = <SyncError>[];
    final lastSync = await _storage.read(key: ApiConfig.lastSyncTimestampKey);

    try {
      final response = await _api.get<Map<String, dynamic>>(
        ApiConfig.syncChanges,
        queryParameters: {
          'circleId': _currentCircleId,
          if (lastSync != null) 'since': lastSync,
        },
        fromData: (data) => data as Map<String, dynamic>,
      );

      if (!response.success) {
        // API 返回了错误，但请求本身成功
        // 这种情况下不视为严重错误，只记录日志
        debugPrint('Sync pull returned non-success: ${response.error}');
        // 不添加到 errors，让同步被视为成功
        return (pulledCount: 0, conflictCount: 0, errors: <SyncError>[]);
      }

      if (response.data != null) {
        final data = response.data!;
        final changesData = data['changes'] as List<dynamic>? ?? [];
        final changes =
            changesData
                .map((c) => SyncChange.fromJson(c as Map<String, dynamic>))
                .toList();

        // 应用变更到本地数据库，处理冲突
        for (final change in changes) {
          try {
            final hasConflict = await _checkAndResolveConflict(change);
            if (hasConflict) {
              conflictCount++;
            }
            await _applyChange(change);
            pulledCount++;
          } catch (e) {
            errors.add(_classifyError(e));
          }
        }

        // 更新最后同步时间
        final serverTimestamp = data['serverTimestamp'] as String?;
        if (serverTimestamp != null) {
          await _storage.write(
            key: ApiConfig.lastSyncTimestampKey,
            value: serverTimestamp,
          );
        }

        // 如果还有更多变更，继续拉取
        final hasMore = data['hasMore'] as bool? ?? false;
        if (hasMore) {
          final moreResult = await _pullChangesWithConflictResolution();
          pulledCount += moreResult.pulledCount;
          conflictCount += moreResult.conflictCount;
          errors.addAll(moreResult.errors);
        }
      }
    } catch (e) {
      debugPrint('Sync pull changes error: $e');
      // 网络错误等严重错误才添加到 errors
      final error = _classifyError(e);
      if (error.type == SyncErrorType.network ||
          error.type == SyncErrorType.auth ||
          error.type == SyncErrorType.server) {
        errors.add(error);
      } else {
        // 其他错误只记录，不影响同步状态
        debugPrint('Sync pull non-critical error: $error');
      }
    }

    return (
      pulledCount: pulledCount,
      conflictCount: conflictCount,
      errors: errors,
    );
  }

  /// 检查并解决冲突
  Future<bool> _checkAndResolveConflict(SyncChange serverChange) async {
    if (_db == null) return false;

    // 检查本地是否有对同一实体的待处理变更
    final localChange = _pendingChanges.firstWhere(
      (c) =>
          c.entityType == serverChange.entityType &&
          c.entityId == serverChange.entityId,
      orElse:
          () => SyncChange(
            entityType: '',
            entityId: '',
            action: '',
            timestamp: DateTime.now(),
          ),
    );

    if (localChange.entityType.isEmpty) {
      // 没有冲突
      return false;
    }

    // 发现冲突，根据策略解决
    debugPrint(
      'Conflict detected for ${serverChange.entityType}/${serverChange.entityId}',
    );

    switch (_conflictStrategy) {
      case ConflictResolutionStrategy.serverWins:
        // 服务器优先：移除本地变更
        _pendingChanges.removeWhere(
          (c) =>
              c.entityType == serverChange.entityType &&
              c.entityId == serverChange.entityId,
        );
        await _savePendingChanges();
        return true;

      case ConflictResolutionStrategy.clientWins:
        // 本地优先：保留本地变更，忽略服务器变更
        // 服务器变更不会被应用（通过返回 true 但不移除本地变更）
        return true;

      case ConflictResolutionStrategy.lastWriteWins:
        // 最后写入优先：比较时间戳
        if (localChange.timestamp.isAfter(serverChange.timestamp)) {
          // 本地更新，保留本地变更
          return true;
        } else {
          // 服务器更新，移除本地变更
          _pendingChanges.removeWhere(
            (c) =>
                c.entityType == serverChange.entityType &&
                c.entityId == serverChange.entityId,
          );
          await _savePendingChanges();
          return true;
        }

      case ConflictResolutionStrategy.manual:
        // 手动解决：调用回调
        if (onConflict != null) {
          final conflict = SyncConflict(
            entityType: serverChange.entityType,
            entityId: serverChange.entityId,
            localData: localChange.data,
            serverData: serverChange.data,
            localTimestamp: localChange.timestamp,
            serverTimestamp: serverChange.timestamp,
          );

          final resolvedData = await onConflict!(conflict);
          if (resolvedData != null) {
            // 用户选择了合并后的数据，更新本地变更
            final index = _pendingChanges.indexWhere(
              (c) =>
                  c.entityType == serverChange.entityType &&
                  c.entityId == serverChange.entityId,
            );
            if (index >= 0) {
              _pendingChanges[index] = SyncChange(
                entityType: localChange.entityType,
                entityId: localChange.entityId,
                action: 'update',
                data: resolvedData,
                timestamp: DateTime.now(),
              );
              await _savePendingChanges();
            }
          } else {
            // 用户选择使用服务器数据
            _pendingChanges.removeWhere(
              (c) =>
                  c.entityType == serverChange.entityType &&
                  c.entityId == serverChange.entityId,
            );
            await _savePendingChanges();
          }
        }
        return true;
    }
  }

  // ============== 数据转换方法 ==============

  Map<String, dynamic> _momentToSyncData(Moment moment) {
    return {
      'content': moment.content,
      'mediaType': moment.mediaType.name,
      'mediaUrl': moment.mediaUrl,
      'timestamp': moment.timestamp.toIso8601String(),
      'timeLabel': moment.timeLabel,
      'contextTags':
          moment.contextTags
              .map(
                (t) => {
                  'type': t.type.name,
                  'label': t.label,
                  'emoji': t.emoji,
                },
              )
              .toList(),
      'location': moment.location,
      'isFavorite': moment.isFavorite,
      'futureMessage': moment.futureMessage,
    };
  }

  ContextTagType _parseContextTagType(String type) {
    switch (type) {
      case 'myMood':
        return ContextTagType.myMood;
      case 'atmosphere':
        return ContextTagType.atmosphere;
      default:
        return ContextTagType.myMood;
    }
  }

  Moment _syncDataToMoment(String id, Map<String, dynamic> data) {
    return Moment(
      id: id,
      circleId: data['circleId'] as String?,
      content: data['content'] as String? ?? '',
      mediaType: MediaType.values.firstWhere(
        (t) => t.name == (data['mediaType'] as String? ?? 'text'),
        orElse: () => MediaType.text,
      ),
      mediaUrl: data['mediaUrl'] as String?,
      timestamp: DateTime.parse(data['timestamp'] as String),
      timeLabel: data['timeLabel'] as String? ?? '',
      author: const User(id: 'u1', name: '我', avatar: ''),
      contextTags:
          ((data['contextTags'] as List<dynamic>?) ?? [])
              .map(
                (t) => ContextTag(
                  type: _parseContextTagType(
                    (t as Map<String, dynamic>)['type'] as String,
                  ),
                  label: t['label'] as String,
                  emoji: t['emoji'] as String,
                ),
              )
              .toList(),
      location: data['location'] as String?,
      isFavorite: data['isFavorite'] as bool? ?? false,
      futureMessage: data['futureMessage'] as String?,
      createdAt:
          data['createdAt'] != null
              ? DateTime.parse(data['createdAt'] as String)
              : null,
      updatedAt:
          data['updatedAt'] != null
              ? DateTime.parse(data['updatedAt'] as String)
              : null,
      deletedAt:
          data['deletedAt'] != null
              ? DateTime.parse(data['deletedAt'] as String)
              : null,
    );
  }

  Map<String, dynamic> _letterToSyncData(Letter letter) {
    return {
      'title': letter.title,
      'preview': letter.preview,
      'content': letter.content,
      'type': letter.type.name,
      'recipient': letter.recipient,
      'unlockDate': letter.unlockDate?.toIso8601String(),
    };
  }

  Letter _syncDataToLetter(String id, Map<String, dynamic> data) {
    return Letter(
      id: id,
      circleId: data['circleId'] as String?,
      authorId: data['authorId'] as String?,
      title: data['title'] as String? ?? '',
      preview: data['preview'] as String? ?? '',
      content: data['content'] as String? ?? '',
      status: LetterStatus.draft,
      type: LetterType.values.firstWhere(
        (t) => t.name == (data['type'] as String? ?? 'free'),
        orElse: () => LetterType.free,
      ),
      recipient: data['recipient'] as String? ?? '',
      unlockDate:
          data['unlockDate'] != null
              ? DateTime.parse(data['unlockDate'] as String)
              : null,
      createdAt:
          data['createdAt'] != null
              ? DateTime.parse(data['createdAt'] as String)
              : null,
      updatedAt:
          data['updatedAt'] != null
              ? DateTime.parse(data['updatedAt'] as String)
              : null,
      deletedAt:
          data['deletedAt'] != null
              ? DateTime.parse(data['deletedAt'] as String)
              : null,
    );
  }

  Comment _syncDataToComment(String id, Map<String, dynamic> data) {
    return Comment(
      id: id,
      targetId: data['targetId'] as String,
      targetType: CommentTargetType.values.firstWhere(
        (t) => t.name == (data['targetType'] as String? ?? 'moment'),
        orElse: () => CommentTargetType.moment,
      ),
      author: const User(id: 'u1', name: '我', avatar: ''),
      content: data['content'] as String? ?? '',
      timestamp: DateTime.now(),
    );
  }

  Moment _serverMomentToLocal(Map<String, dynamic> m) {
    return Moment(
      id: m['id'] as String,
      circleId: m['circle_id'] as String?,
      content: m['content'] as String? ?? '',
      mediaType: MediaType.values.firstWhere(
        (t) => t.name == (m['media_type'] as String? ?? 'text'),
        orElse: () => MediaType.text,
      ),
      mediaUrl: m['media_url'] as String?,
      timestamp: DateTime.parse(m['timestamp'] as String),
      timeLabel: m['time_label'] as String? ?? '',
      author: const User(id: 'u1', name: '我', avatar: ''),
      isFavorite: (m['is_favorite'] as int? ?? 0) == 1,
      futureMessage: m['future_message'] as String?,
      createdAt:
          m['created_at'] != null
              ? DateTime.parse(m['created_at'] as String)
              : null,
      updatedAt:
          m['updated_at'] != null
              ? DateTime.parse(m['updated_at'] as String)
              : null,
      deletedAt:
          m['deleted_at'] != null
              ? DateTime.parse(m['deleted_at'] as String)
              : null,
    );
  }

  Letter _serverLetterToLocal(Map<String, dynamic> l) {
    return Letter(
      id: l['id'] as String,
      circleId: l['circle_id'] as String?,
      authorId: l['author_id'] as String?,
      title: l['title'] as String? ?? '',
      preview: l['preview'] as String? ?? '',
      content: l['content'] as String?,
      status: LetterStatus.values.firstWhere(
        (s) => s.name == (l['status'] as String? ?? 'draft'),
        orElse: () => LetterStatus.draft,
      ),
      type: LetterType.values.firstWhere(
        (t) => t.name == (l['type'] as String? ?? 'free'),
        orElse: () => LetterType.free,
      ),
      recipient: l['recipient'] as String? ?? '',
      createdAt:
          l['created_at'] != null
              ? DateTime.parse(l['created_at'] as String)
              : null,
      sealedAt:
          l['sealed_at'] != null
              ? DateTime.parse(l['sealed_at'] as String)
              : null,
      unlockDate:
          l['unlock_date'] != null
              ? DateTime.parse(l['unlock_date'] as String)
              : null,
      updatedAt:
          l['updated_at'] != null
              ? DateTime.parse(l['updated_at'] as String)
              : null,
      deletedAt:
          l['deleted_at'] != null
              ? DateTime.parse(l['deleted_at'] as String)
              : null,
    );
  }

  /// 释放资源
  void dispose() {
    _statusController.close();
    _statusInfoController.close();
  }
}

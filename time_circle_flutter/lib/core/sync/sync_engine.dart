// Aura 同步引擎
//
// 实现离线优先的数据同步策略
// - 本地优先：所有操作先写入本地
// - 后台同步：网络恢复后自动同步
// - 冲突解决：基于时间戳的冲突处理

import 'dart:async';
import 'package:flutter/foundation.dart';

/// 同步状态
enum SyncStatus {
  /// 空闲状态
  idle,

  /// 正在同步
  syncing,

  /// 同步完成
  synced,

  /// 同步错误
  error,

  /// 等待网络
  waitingForNetwork,
}

/// 同步项状态
enum SyncItemStatus {
  /// 待同步
  pending,

  /// 正在同步
  syncing,

  /// 已同步
  synced,

  /// 同步失败
  failed,
}

/// 同步操作类型
enum SyncAction { create, update, delete }

/// 同步项
class SyncItem {
  final String id;
  final String entityType;
  final String entityId;
  final SyncAction action;
  final Map<String, dynamic>? data;
  final DateTime clientTimestamp;
  final int retryCount;
  final SyncItemStatus status;

  const SyncItem({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.action,
    this.data,
    required this.clientTimestamp,
    this.retryCount = 0,
    this.status = SyncItemStatus.pending,
  });

  SyncItem copyWith({
    String? id,
    String? entityType,
    String? entityId,
    SyncAction? action,
    Map<String, dynamic>? data,
    DateTime? clientTimestamp,
    int? retryCount,
    SyncItemStatus? status,
  }) {
    return SyncItem(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      action: action ?? this.action,
      data: data ?? this.data,
      clientTimestamp: clientTimestamp ?? this.clientTimestamp,
      retryCount: retryCount ?? this.retryCount,
      status: status ?? this.status,
    );
  }
}

/// 同步结果
class SyncResult {
  final int uploadedCount;
  final int downloadedCount;
  final int conflictCount;
  final List<SyncConflict> conflicts;
  final String? errorMessage;

  const SyncResult({
    this.uploadedCount = 0,
    this.downloadedCount = 0,
    this.conflictCount = 0,
    this.conflicts = const [],
    this.errorMessage,
  });

  bool get isSuccess => errorMessage == null;
}

/// 同步冲突
class SyncConflict {
  final String entityType;
  final String entityId;
  final Map<String, dynamic> localData;
  final Map<String, dynamic> serverData;
  final ConflictResolution? resolution;

  const SyncConflict({
    required this.entityType,
    required this.entityId,
    required this.localData,
    required this.serverData,
    this.resolution,
  });
}

/// 冲突解决策略
enum ConflictResolution { keepLocal, keepServer, merge }

/// 同步队列接口
abstract class SyncQueue {
  /// 添加同步项
  Future<void> enqueue(SyncItem item);

  /// 获取待同步项
  Future<List<SyncItem>> getPendingItems();

  /// 标记为已同步
  Future<void> markAsSynced(String id);

  /// 增加重试次数
  Future<void> incrementRetryCount(String id);

  /// 移除同步项
  Future<void> remove(String id);

  /// 清空队列
  Future<void> clear();
}

/// 网络信息接口
abstract class NetworkInfo {
  /// 检查网络连接
  Future<bool> get isConnected;

  /// 网络状态变化流
  Stream<bool> get onConnectivityChanged;
}

/// 同步引擎
///
/// 使用示例:
/// ```dart
/// final syncEngine = SyncEngine(
///   syncQueue: localSyncQueue,
///   networkInfo: networkInfoService,
///   remoteSyncService: apiSyncService,
/// );
///
/// // 监听同步状态
/// syncEngine.syncStatus.listen((status) {
///   print('Sync status: $status');
/// });
///
/// // 立即同步
/// await syncEngine.syncNow();
///
/// // 队列操作
/// await syncEngine.queueCreate('moment', momentData);
/// ```
class SyncEngine {
  final SyncQueue _syncQueue;
  final NetworkInfo _networkInfo;
  final RemoteSyncService _remoteSyncService;

  /// 最大重试次数
  final int maxRetries;

  /// 自动同步间隔
  final Duration autoSyncInterval;

  final _syncStatusController = StreamController<SyncStatus>.broadcast();
  StreamSubscription<bool>? _connectivitySubscription;
  Timer? _autoSyncTimer;

  SyncStatus _currentStatus = SyncStatus.idle;
  DateTime? _lastSyncTime;

  SyncEngine({
    required SyncQueue syncQueue,
    required NetworkInfo networkInfo,
    required RemoteSyncService remoteSyncService,
    this.maxRetries = 3,
    this.autoSyncInterval = const Duration(minutes: 5),
  }) : _syncQueue = syncQueue,
       _networkInfo = networkInfo,
       _remoteSyncService = remoteSyncService {
    _init();
  }

  /// 同步状态流
  Stream<SyncStatus> get syncStatus => _syncStatusController.stream;

  /// 当前同步状态
  SyncStatus get currentStatus => _currentStatus;

  /// 最后同步时间
  DateTime? get lastSyncTime => _lastSyncTime;

  void _init() {
    // 监听网络状态变化
    _connectivitySubscription = _networkInfo.onConnectivityChanged.listen(
      _onConnectivityChanged,
    );

    // 启动自动同步定时器
    _startAutoSyncTimer();
  }

  void _onConnectivityChanged(bool isConnected) {
    if (isConnected && _currentStatus == SyncStatus.waitingForNetwork) {
      // 网络恢复，触发同步
      syncNow();
    }
  }

  void _startAutoSyncTimer() {
    _autoSyncTimer?.cancel();
    _autoSyncTimer = Timer.periodic(autoSyncInterval, (_) {
      syncNow();
    });
  }

  void _updateStatus(SyncStatus status) {
    _currentStatus = status;
    _syncStatusController.add(status);
  }

  /// 立即同步
  ///
  /// 返回同步结果
  Future<SyncResult> syncNow() async {
    if (_currentStatus == SyncStatus.syncing) {
      return const SyncResult(errorMessage: 'Sync already in progress');
    }

    // 检查网络
    if (!await _networkInfo.isConnected) {
      _updateStatus(SyncStatus.waitingForNetwork);
      return const SyncResult(errorMessage: 'No network connection');
    }

    _updateStatus(SyncStatus.syncing);

    try {
      // 1. 上传本地待同步数据
      final uploadResult = await _uploadPendingChanges();

      // 2. 下载远程更新
      final downloadResult = await _downloadRemoteChanges();

      _lastSyncTime = DateTime.now();
      _updateStatus(SyncStatus.synced);

      return SyncResult(
        uploadedCount: uploadResult.uploadedCount,
        downloadedCount: downloadResult.downloadedCount,
        conflictCount: downloadResult.conflictCount,
        conflicts: downloadResult.conflicts,
      );
    } catch (e) {
      debugPrint('Sync error: $e');
      _updateStatus(SyncStatus.error);
      return SyncResult(errorMessage: e.toString());
    }
  }

  Future<SyncResult> _uploadPendingChanges() async {
    final pendingItems = await _syncQueue.getPendingItems();
    int uploadedCount = 0;

    for (final item in pendingItems) {
      if (item.retryCount >= maxRetries) {
        // 超过最大重试次数，跳过
        continue;
      }

      try {
        await _remoteSyncService.pushChange(item);
        await _syncQueue.markAsSynced(item.id);
        uploadedCount++;
      } catch (e) {
        debugPrint('Failed to sync item ${item.id}: $e');
        await _syncQueue.incrementRetryCount(item.id);
      }
    }

    return SyncResult(uploadedCount: uploadedCount);
  }

  Future<SyncResult> _downloadRemoteChanges() async {
    final changes = await _remoteSyncService.pullChanges(since: _lastSyncTime);

    int downloadedCount = 0;
    final conflicts = <SyncConflict>[];

    for (final change in changes) {
      final conflict = await _applyChange(change);
      if (conflict != null) {
        conflicts.add(conflict);
      } else {
        downloadedCount++;
      }
    }

    return SyncResult(
      downloadedCount: downloadedCount,
      conflictCount: conflicts.length,
      conflicts: conflicts,
    );
  }

  Future<SyncConflict?> _applyChange(RemoteChange change) async {
    // 检查是否有本地冲突
    // 这里需要根据实际业务逻辑实现冲突检测和解决
    // 简单示例：基于时间戳的 Last-Write-Wins 策略
    return null;
  }

  /// 队列创建操作
  Future<void> queueCreate(
    String entityType,
    String entityId,
    Map<String, dynamic> data,
  ) async {
    await _syncQueue.enqueue(
      SyncItem(
        id:
            '${entityType}_${entityId}_create_${DateTime.now().millisecondsSinceEpoch}',
        entityType: entityType,
        entityId: entityId,
        action: SyncAction.create,
        data: data,
        clientTimestamp: DateTime.now(),
      ),
    );

    // 尝试立即同步
    if (await _networkInfo.isConnected) {
      syncNow();
    }
  }

  /// 队列更新操作
  Future<void> queueUpdate(
    String entityType,
    String entityId,
    Map<String, dynamic> data,
  ) async {
    await _syncQueue.enqueue(
      SyncItem(
        id:
            '${entityType}_${entityId}_update_${DateTime.now().millisecondsSinceEpoch}',
        entityType: entityType,
        entityId: entityId,
        action: SyncAction.update,
        data: data,
        clientTimestamp: DateTime.now(),
      ),
    );

    if (await _networkInfo.isConnected) {
      syncNow();
    }
  }

  /// 队列删除操作
  Future<void> queueDelete(String entityType, String entityId) async {
    await _syncQueue.enqueue(
      SyncItem(
        id:
            '${entityType}_${entityId}_delete_${DateTime.now().millisecondsSinceEpoch}',
        entityType: entityType,
        entityId: entityId,
        action: SyncAction.delete,
        clientTimestamp: DateTime.now(),
      ),
    );

    if (await _networkInfo.isConnected) {
      syncNow();
    }
  }

  /// 释放资源
  void dispose() {
    _connectivitySubscription?.cancel();
    _autoSyncTimer?.cancel();
    _syncStatusController.close();
  }
}

/// 远程同步服务接口
abstract class RemoteSyncService {
  /// 推送本地变更
  Future<void> pushChange(SyncItem item);

  /// 拉取远程变更
  Future<List<RemoteChange>> pullChanges({DateTime? since});
}

/// 远程变更
class RemoteChange {
  final String entityType;
  final String entityId;
  final SyncAction action;
  final Map<String, dynamic>? data;
  final DateTime serverTimestamp;

  const RemoteChange({
    required this.entityType,
    required this.entityId,
    required this.action,
    this.data,
    required this.serverTimestamp,
  });
}

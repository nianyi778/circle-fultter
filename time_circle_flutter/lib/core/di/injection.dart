// Aura 依赖注入系统
//
// 提供统一的依赖注入入口，简化 Provider 管理

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../sync/sync_engine.dart';
import '../sync/sync_queue_impl.dart';
import '../sync/network_info_impl.dart';
import '../sync/remote_sync_service_impl.dart';
import '../services/api_service.dart';

/// 依赖注入容器
///
/// 使用 Riverpod Provider 管理所有依赖
class Injection {
  Injection._();

  /// 初始化所有依赖
  ///
  /// 在 main.dart 中调用
  static Future<void> init() async {
    // 初始化需要异步设置的服务
    // 例如：数据库、安全存储等
  }
}

// ==================== 基础服务 Provider ====================

/// Connectivity Provider
final connectivityProvider = Provider<Connectivity>((ref) {
  return Connectivity();
});

/// API Service Provider
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService.instance;
});

// ==================== 同步相关 Provider ====================

/// Network Info Provider
final networkInfoProvider = Provider<NetworkInfo>((ref) {
  final connectivity = ref.watch(connectivityProvider);
  return NetworkInfoImpl(connectivity);
});

/// Sync Queue Provider
final syncQueueProvider = Provider<SyncQueue>((ref) {
  return SyncQueueImpl();
});

/// Remote Sync Service Provider
final remoteSyncServiceProvider = Provider<RemoteSyncService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return RemoteSyncServiceImpl(apiService);
});

/// Sync Engine Provider
final syncEngineProvider = Provider<SyncEngine>((ref) {
  final syncQueue = ref.watch(syncQueueProvider);
  final networkInfo = ref.watch(networkInfoProvider);
  final remoteSyncService = ref.watch(remoteSyncServiceProvider);

  final engine = SyncEngine(
    syncQueue: syncQueue,
    networkInfo: networkInfo,
    remoteSyncService: remoteSyncService,
  );

  // 当 Provider 被销毁时，释放资源
  ref.onDispose(() {
    engine.dispose();
  });

  return engine;
});

/// Sync Status Provider (可监听的同步状态)
final syncStatusProvider = StreamProvider<SyncStatus>((ref) {
  final engine = ref.watch(syncEngineProvider);
  return engine.syncStatus;
});

/// 当前同步状态 Provider
final currentSyncStatusProvider = Provider<SyncStatus>((ref) {
  final asyncStatus = ref.watch(syncStatusProvider);
  return asyncStatus.when(
    data: (status) => status,
    loading: () => SyncStatus.idle,
    error: (_, __) => SyncStatus.error,
  );
});

// ==================== 连接状态 Provider ====================

/// 网络连接状态 Provider
final isConnectedProvider = FutureProvider<bool>((ref) async {
  final networkInfo = ref.watch(networkInfoProvider);
  return networkInfo.isConnected;
});

/// 网络连接状态 Stream Provider
final connectivityStreamProvider = StreamProvider<bool>((ref) {
  final networkInfo = ref.watch(networkInfoProvider);
  return networkInfo.onConnectivityChanged;
});

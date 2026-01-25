import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/database_service.dart';
import '../services/sync_service.dart';
import 'auth_providers.dart';

/// 同步状态 Provider
///
/// 监听认证状态，当用户完全认证后初始化 SyncService 并触发同步
final syncStatusProvider = StreamProvider<SyncStatus>((ref) {
  final authState = ref.watch(authProvider);

  // 如果用户未完全认证，返回 idle 状态，不触发同步
  if (!authState.isFullyAuthenticated || authState.selectedCircle == null) {
    // 返回一个单值 stream，不触发任何同步
    return Stream.value(SyncStatus.idle);
  }

  final circleId = authState.selectedCircle!.id;

  // 创建一个流控制器，先发出 idle 状态，然后初始化并监听 SyncService
  final controller = StreamController<SyncStatus>();

  // 立即发出 idle 状态，避免显示错误
  controller.add(SyncStatus.idle);

  // 异步初始化并订阅
  () async {
    await SyncService.instance.init(DatabaseService(), circleId);

    // 监听 SyncService 的状态流
    final subscription = SyncService.instance.statusStream.listen(
      (status) => controller.add(status),
      onError: (error) => controller.addError(error),
    );

    // 当 controller 关闭时取消订阅
    controller.onCancel = () => subscription.cancel();

    // 触发增量同步
    SyncService.instance.sync();
  }();

  return controller.stream;
});

/// 同步状态详情 Provider
final syncStatusInfoProvider = StreamProvider<SyncStatusInfo>((ref) {
  final authState = ref.watch(authProvider);

  if (!authState.isFullyAuthenticated || authState.selectedCircle == null) {
    return Stream.value(const SyncStatusInfo(status: SyncStatus.idle));
  }

  // 确保同步流程初始化
  ref.watch(syncStatusProvider);

  return SyncService.instance.statusInfoStream;
});

/// 当前同步状态（同步访问）
final currentSyncStatusProvider = Provider<SyncStatus>((ref) {
  final asyncStatus = ref.watch(syncStatusProvider);
  return asyncStatus.when(
    data: (status) => status,
    loading: () => SyncStatus.idle,
    error: (_, __) => SyncStatus.error,
  );
});

/// 当前同步状态详情（同步访问）
final currentSyncStatusInfoProvider = Provider<SyncStatusInfo>((ref) {
  final asyncStatus = ref.watch(syncStatusInfoProvider);
  return asyncStatus.when(
    data: (status) => status,
    loading: () => const SyncStatusInfo(status: SyncStatus.idle),
    error: (_, __) => const SyncStatusInfo(status: SyncStatus.error),
  );
});

/// 是否正在同步
final isSyncingProvider = Provider<bool>((ref) {
  final status = ref.watch(currentSyncStatusProvider);
  return status == SyncStatus.syncing;
});

/// 同步是否成功
final syncSuccessProvider = Provider<bool>((ref) {
  final status = ref.watch(currentSyncStatusProvider);
  return status == SyncStatus.success;
});

/// 是否离线
final isOfflineProvider = Provider<bool>((ref) {
  final status = ref.watch(currentSyncStatusProvider);
  return status == SyncStatus.offline;
});

/// 同步是否出错
final syncErrorProvider = Provider<bool>((ref) {
  final status = ref.watch(currentSyncStatusProvider);
  return status == SyncStatus.error;
});

/// 手动触发同步
final triggerSyncProvider = Provider<Future<void> Function()>((ref) {
  return () async {
    await SyncService.instance.sync();
  };
});

/// 手动触发完整同步
final triggerFullSyncProvider = Provider<Future<void> Function()>((ref) {
  return () async {
    await SyncService.instance.fullSync();
  };
});

/// 刷新数据并同步
///
/// 用于下拉刷新等场景
final refreshAndSyncProvider = Provider<Future<void> Function(WidgetRef ref)>((
  ref,
) {
  return (WidgetRef widgetRef) async {
    // 触发同步
    await SyncService.instance.sync();

    // 刷新本地数据
    // 注意：这需要在调用处使用 ref.refresh() 来刷新相关 providers
  };
});

/// 同步状态 Notifier（用于更复杂的同步控制）
class SyncController extends StateNotifier<SyncStatus> {
  final Ref _ref;
  StreamSubscription<SyncStatus>? _subscription;

  SyncController(this._ref) : super(SyncStatus.idle) {
    _init();
  }

  void _init() {
    // 监听认证状态变化
    _ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.isFullyAuthenticated && next.selectedCircle != null) {
        // 用户刚刚完成认证，初始化同步
        if (previous?.isFullyAuthenticated != true) {
          _initSync(next.selectedCircle!.id);
        }
        // 用户切换了圈子
        else if (previous?.selectedCircle?.id != next.selectedCircle?.id) {
          _initSync(next.selectedCircle!.id);
        }
      } else {
        // 用户未认证，重置状态
        state = SyncStatus.idle;
        _subscription?.cancel();
        _subscription = null;
      }
    });
  }

  Future<void> _initSync(String circleId) async {
    // 先重置状态
    state = SyncStatus.idle;

    await SyncService.instance.init(DatabaseService(), circleId);

    // 开始监听 SyncService 状态流
    _subscription?.cancel();
    _subscription = SyncService.instance.statusStream.listen((status) {
      state = status;
    });

    SyncService.instance.sync();
  }

  /// 手动触发同步
  Future<void> sync() async {
    await SyncService.instance.sync();
  }

  /// 手动触发完整同步
  Future<void> fullSync() async {
    await SyncService.instance.fullSync();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

/// 同步控制器 Provider
final syncControllerProvider =
    StateNotifierProvider<SyncController, SyncStatus>((ref) {
      return SyncController(ref);
    });

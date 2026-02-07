import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/network_info.dart';
import '../../domain/repositories/moment_repository.dart';

/// Sync status for UI display
enum SyncState {
  /// Idle - no sync in progress
  idle,

  /// Syncing - sync in progress
  syncing,

  /// Success - last sync succeeded
  success,

  /// Error - last sync failed
  error,

  /// Offline - cannot sync (no network)
  offline,
}

/// Sync result with details
class SyncResult {
  final int momentsSynced;
  final int lettersSynced;
  final int failedCount;
  final DateTime timestamp;
  final String? error;

  const SyncResult({
    this.momentsSynced = 0,
    this.lettersSynced = 0,
    this.failedCount = 0,
    required this.timestamp,
    this.error,
  });

  bool get hasErrors => failedCount > 0 || error != null;
  int get totalSynced => momentsSynced + lettersSynced;
}

/// Sync state for Riverpod
class SyncServiceState {
  final SyncState state;
  final SyncResult? lastResult;
  final bool isAutoSyncEnabled;
  final DateTime? lastSyncTime;

  const SyncServiceState({
    this.state = SyncState.idle,
    this.lastResult,
    this.isAutoSyncEnabled = true,
    this.lastSyncTime,
  });

  SyncServiceState copyWith({
    SyncState? state,
    SyncResult? lastResult,
    bool? isAutoSyncEnabled,
    DateTime? lastSyncTime,
  }) {
    return SyncServiceState(
      state: state ?? this.state,
      lastResult: lastResult ?? this.lastResult,
      isAutoSyncEnabled: isAutoSyncEnabled ?? this.isAutoSyncEnabled,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
    );
  }
}

/// Sync Service - handles periodic background sync of offline changes
class SyncService extends StateNotifier<SyncServiceState> {
  final MomentRepository _momentRepository;
  final NetworkInfo _networkInfo;

  Timer? _syncTimer;
  StreamSubscription? _connectivitySubscription;

  /// Sync interval in minutes
  static const int syncIntervalMinutes = 5;

  SyncService({
    required MomentRepository momentRepository,
    required NetworkInfo networkInfo,
  }) : _momentRepository = momentRepository,
       _networkInfo = networkInfo,
       super(const SyncServiceState()) {
    _init();
  }

  void _init() {
    // Listen for connectivity changes
    _connectivitySubscription = _networkInfo.onConnectivityChanged.listen(
      _onConnectivityChanged,
    );

    // Start periodic sync
    _startPeriodicSync();

    // Check initial connectivity
    _checkConnectivity();
  }

  void _onConnectivityChanged(bool isConnected) {
    if (isConnected) {
      // Came online - trigger immediate sync
      debugPrint('[SyncService] Network connected, triggering sync...');
      state = state.copyWith(state: SyncState.idle);
      syncNow();
    } else {
      // Went offline
      debugPrint('[SyncService] Network disconnected');
      state = state.copyWith(state: SyncState.offline);
    }
  }

  Future<void> _checkConnectivity() async {
    final isConnected = await _networkInfo.isConnected;
    if (!isConnected) {
      state = state.copyWith(state: SyncState.offline);
    }
  }

  void _startPeriodicSync() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(
      const Duration(minutes: syncIntervalMinutes),
      (_) => _periodicSync(),
    );
  }

  Future<void> _periodicSync() async {
    if (!state.isAutoSyncEnabled) return;
    if (state.state == SyncState.syncing) return;
    if (state.state == SyncState.offline) return;

    debugPrint('[SyncService] Starting periodic sync...');
    await syncNow();
  }

  /// Manually trigger a sync
  Future<SyncResult> syncNow() async {
    if (state.state == SyncState.syncing) {
      return state.lastResult ?? SyncResult(timestamp: DateTime.now());
    }

    // Check connectivity
    final isConnected = await _networkInfo.isConnected;
    if (!isConnected) {
      state = state.copyWith(state: SyncState.offline);
      return SyncResult(
        timestamp: DateTime.now(),
        error: 'No network connection',
      );
    }

    state = state.copyWith(state: SyncState.syncing);

    try {
      int momentsSynced = 0;
      int failedCount = 0;

      // Sync moments
      final momentsResult = await _momentRepository.syncPendingMoments();
      momentsResult.fold(
        (failure) {
          debugPrint('[SyncService] Moments sync failed: ${failure.message}');
          failedCount++;
        },
        (count) {
          momentsSynced = count;
          debugPrint('[SyncService] Synced $count moments');
        },
      );

      // TODO: Add letter sync when LetterRepository has syncPendingLetters

      final result = SyncResult(
        momentsSynced: momentsSynced,
        lettersSynced: 0, // TODO: Add letter sync count
        failedCount: failedCount,
        timestamp: DateTime.now(),
      );

      state = state.copyWith(
        state: failedCount > 0 ? SyncState.error : SyncState.success,
        lastResult: result,
        lastSyncTime: DateTime.now(),
      );

      // Reset to idle after a delay
      Future.delayed(const Duration(seconds: 3), () {
        if (state.state == SyncState.success) {
          state = state.copyWith(state: SyncState.idle);
        }
      });

      return result;
    } catch (e) {
      debugPrint('[SyncService] Sync error: $e');
      final result = SyncResult(timestamp: DateTime.now(), error: e.toString());
      state = state.copyWith(state: SyncState.error, lastResult: result);
      return result;
    }
  }

  /// Enable or disable auto sync
  void setAutoSync(bool enabled) {
    state = state.copyWith(isAutoSyncEnabled: enabled);
    if (enabled) {
      _startPeriodicSync();
    } else {
      _syncTimer?.cancel();
    }
  }

  /// Get human-readable sync status
  String get statusMessage {
    switch (state.state) {
      case SyncState.idle:
        if (state.lastSyncTime != null) {
          final diff = DateTime.now().difference(state.lastSyncTime!);
          if (diff.inMinutes < 1) {
            return 'Synced just now';
          } else if (diff.inMinutes < 60) {
            return 'Synced ${diff.inMinutes}m ago';
          } else {
            return 'Synced ${diff.inHours}h ago';
          }
        }
        return 'Ready to sync';
      case SyncState.syncing:
        return 'Syncing...';
      case SyncState.success:
        final total = state.lastResult?.totalSynced ?? 0;
        return 'Synced $total items';
      case SyncState.error:
        return 'Sync failed';
      case SyncState.offline:
        return 'Offline';
    }
  }

  @override
  void dispose() {
    _syncTimer?.cancel();
    _connectivitySubscription?.cancel();
    super.dispose();
  }
}

// ============== Riverpod Providers ==============

/// Sync Service Provider
final syncServiceProvider =
    StateNotifierProvider<SyncService, SyncServiceState>((ref) {
      // Import these from di/providers.dart in real usage
      throw UnimplementedError(
        'syncServiceProvider must be overridden with actual dependencies',
      );
    });

/// Sync State Provider (for UI)
final syncStateProvider = Provider<SyncState>((ref) {
  return ref.watch(syncServiceProvider).state;
});

/// Is Syncing Provider
final isSyncingProvider = Provider<bool>((ref) {
  return ref.watch(syncStateProvider) == SyncState.syncing;
});

/// Is Offline Provider
final isOfflineProvider = Provider<bool>((ref) {
  return ref.watch(syncStateProvider) == SyncState.offline;
});

/// Sync Status Message Provider
final syncStatusMessageProvider = Provider<String>((ref) {
  final service = ref.read(syncServiceProvider.notifier);
  return service.statusMessage;
});

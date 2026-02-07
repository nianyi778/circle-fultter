import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/animations/animation_config.dart';
import '../../../core/haptics/haptic_service.dart';
import '../../../core/di/providers.dart';
import '../../../core/di/injection.dart'
    show syncEngineProvider, currentSyncStatusProvider;
import '../../../core/sync/sync_engine.dart';

/// Provider for connectivity status
final connectivityProvider = StreamProvider<bool>((ref) {
  final networkInfo = ref.watch(networkInfoProvider);
  return networkInfo.onConnectivityChanged;
});

/// Provider for initial connectivity check
final isConnectedProvider = FutureProvider<bool>((ref) async {
  final networkInfo = ref.watch(networkInfoProvider);
  return networkInfo.isConnected;
});

/// Offline banner that shows at the top of screens when offline
class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivityAsync = ref.watch(connectivityProvider);
    final initialConnected = ref.watch(isConnectedProvider);

    // Determine if offline
    final isOffline = connectivityAsync.when(
      data: (connected) => !connected,
      loading:
          () => initialConnected.when(
            data: (connected) => !connected,
            loading: () => false,
            error: (_, __) => false,
          ),
      error: (_, __) => false,
    );

    if (!isOffline) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: AppColors.warmGray200,
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Iconsax.wifi_square, size: 18, color: AppColors.warmGray600),
            const SizedBox(width: 8),
            Text(
              '离线模式 - 更改将在联网后同步',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.warmGray600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Small offline indicator for app bars
class OfflineIndicator extends ConsumerWidget {
  final double size;
  final Color? color;

  const OfflineIndicator({super.key, this.size = 20, this.color});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivityAsync = ref.watch(connectivityProvider);
    final initialConnected = ref.watch(isConnectedProvider);

    final isOffline = connectivityAsync.when(
      data: (connected) => !connected,
      loading:
          () => initialConnected.when(
            data: (connected) => !connected,
            loading: () => false,
            error: (_, __) => false,
          ),
      error: (_, __) => false,
    );

    if (!isOffline) return const SizedBox.shrink();

    return Tooltip(
      message: '离线模式',
      child: Icon(
        Iconsax.cloud_cross,
        size: size,
        color: color ?? AppColors.warmGray500,
      ),
    );
  }
}

/// 同步状态指示器 - 显示同步进度
///
/// 整合网络状态和同步引擎状态
class EnhancedSyncIndicator extends ConsumerWidget {
  final double size;
  final bool showLabel;

  const EnhancedSyncIndicator({
    super.key,
    this.size = 20,
    this.showLabel = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncStatus = ref.watch(currentSyncStatusProvider);
    final isOffline = ref.isOffline;

    return GestureDetector(
      onTap: () {
        HapticService.lightTap();
        if (!isOffline) {
          ref.read(syncEngineProvider).syncNow();
        }
      },
      child: AnimatedSwitcher(
        duration: AuraDurations.fast,
        child: _buildIndicator(context, syncStatus, isOffline),
      ),
    );
  }

  Widget _buildIndicator(
    BuildContext context,
    SyncStatus status,
    bool isOffline,
  ) {
    if (isOffline) {
      return _buildIcon(
        key: const ValueKey('offline'),
        icon: Iconsax.cloud_cross,
        color: AppColors.warmGray400,
        label: '离线',
      );
    }

    switch (status) {
      case SyncStatus.syncing:
        return _buildSyncing();
      case SyncStatus.synced:
        return _buildIcon(
          key: const ValueKey('synced'),
          icon: Iconsax.cloud_change,
          color: AppColors.softGreenDeep,
          label: '已同步',
        );
      case SyncStatus.error:
        return _buildIcon(
          key: const ValueKey('error'),
          icon: Iconsax.cloud_cross,
          color: AppColors.warmOrangeDeep,
          label: '同步失败',
        );
      case SyncStatus.waitingForNetwork:
        return _buildIcon(
          key: const ValueKey('waiting'),
          icon: Iconsax.cloud_minus,
          color: AppColors.warmGray400,
          label: '等待网络',
        );
      case SyncStatus.idle:
        return _buildIcon(
          key: const ValueKey('idle'),
          icon: Iconsax.cloud,
          color: AppColors.warmGray300,
          label: '就绪',
        );
    }
  }

  Widget _buildSyncing() {
    return Row(
      key: const ValueKey('syncing'),
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size * 0.8,
          height: size * 0.8,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.calmBlueDeep),
          ),
        ),
        if (showLabel) ...[
          const SizedBox(width: 6),
          Text(
            '同步中...',
            style: TextStyle(fontSize: 12, color: AppColors.calmBlueDeep),
          ),
        ],
      ],
    );
  }

  Widget _buildIcon({
    required Key key,
    required IconData icon,
    required Color color,
    required String label,
  }) {
    return Row(
      key: key,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: size, color: color),
        if (showLabel) ...[
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 12, color: color)),
        ],
      ],
    );
  }
}

/// Wrapper widget that shows offline banner above content
class ConnectivityAwareScaffold extends ConsumerWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final Color? backgroundColor;
  final bool showOfflineBanner;

  const ConnectivityAwareScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.backgroundColor,
    this.showOfflineBanner = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: appBar,
      body: Column(
        children: [
          if (showOfflineBanner) const OfflineBanner(),
          Expanded(child: body),
        ],
      ),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}

/// Animated connectivity indicator with transition
class AnimatedConnectivityIndicator extends ConsumerStatefulWidget {
  final Widget child;
  final Duration animationDuration;

  const AnimatedConnectivityIndicator({
    super.key,
    required this.child,
    this.animationDuration = const Duration(milliseconds: 300),
  });

  @override
  ConsumerState<AnimatedConnectivityIndicator> createState() =>
      _AnimatedConnectivityIndicatorState();
}

class _AnimatedConnectivityIndicatorState
    extends ConsumerState<AnimatedConnectivityIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _wasOffline = false;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _hideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final connectivityAsync = ref.watch(connectivityProvider);

    final isOffline = connectivityAsync.when(
      data: (connected) => !connected,
      loading: () => _wasOffline,
      error: (_, __) => false,
    );

    // Handle transition from offline to online
    if (_wasOffline && !isOffline) {
      // Show "back online" message briefly
      _hideTimer?.cancel();
      _hideTimer = Timer(const Duration(seconds: 2), () {
        if (mounted) {
          _controller.reverse();
        }
      });
      _controller.forward();
    } else if (isOffline && !_wasOffline) {
      _controller.forward();
    }

    _wasOffline = isOffline;

    return Stack(
      children: [
        widget.child,
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, -1),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(parent: _controller, curve: Curves.easeOut),
            ),
            child: _buildBanner(isOffline),
          ),
        ),
      ],
    );
  }

  Widget _buildBanner(bool isOffline) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: isOffline ? AppColors.warmGray300 : AppColors.softGreenDeep,
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isOffline ? Iconsax.wifi_square : Iconsax.tick_circle,
              size: 16,
              color: isOffline ? AppColors.warmGray700 : Colors.white,
            ),
            const SizedBox(width: 8),
            Text(
              isOffline ? '离线模式' : '已恢复连接',
              style: TextStyle(
                fontSize: 13,
                color: isOffline ? AppColors.warmGray700 : Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Extension for easy access to offline status
extension OfflineX on WidgetRef {
  /// Check if currently offline
  bool get isOffline {
    final connectivity = watch(connectivityProvider);
    final initial = watch(isConnectedProvider);

    return connectivity.when(
      data: (connected) => !connected,
      loading:
          () => initial.when(
            data: (connected) => !connected,
            loading: () => false,
            error: (_, __) => false,
          ),
      error: (_, __) => false,
    );
  }
}

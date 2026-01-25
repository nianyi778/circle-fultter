import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/auth_providers.dart';
import '../../core/providers/sync_provider.dart';
import '../../core/services/sync_service.dart';

/// 同步状态指示器
///
/// 显示当前同步状态的小图标，可放在 AppBar 或页面任意位置
class SyncStatusIndicator extends ConsumerWidget {
  /// 图标大小
  final double size;

  /// 是否显示文字
  final bool showLabel;

  /// 点击时是否触发同步
  final bool syncOnTap;

  const SyncStatusIndicator({
    super.key,
    this.size = 20,
    this.showLabel = false,
    this.syncOnTap = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusInfo = ref.watch(currentSyncStatusInfoProvider);
    final status = statusInfo.status;

    return GestureDetector(
      onTap: syncOnTap ? () => _onTap(ref, status) : null,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child:
            showLabel
                ? _buildWithLabel(context, status, statusInfo)
                : _buildIconOnly(context, status),
      ),
    );
  }

  Widget _buildIconOnly(BuildContext context, SyncStatus status) {
    return SizedBox(
      width: size,
      height: size,
      child: _buildStatusWidget(context, status),
    );
  }

  Widget _buildWithLabel(
    BuildContext context,
    SyncStatus status,
    SyncStatusInfo statusInfo,
  ) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: _buildStatusWidget(context, status),
        ),
        const SizedBox(width: 6),
        Text(
          _getStatusLabel(status, statusInfo),
          style: theme.textTheme.bodySmall?.copyWith(
            color: _getStatusColor(context, status),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusWidget(BuildContext context, SyncStatus status) {
    switch (status) {
      case SyncStatus.syncing:
        return SizedBox(
          width: size * 0.8,
          height: size * 0.8,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
          ),
        );

      case SyncStatus.success:
        return Icon(Icons.cloud_done_outlined, size: size, color: Colors.green);

      case SyncStatus.error:
        return Icon(Icons.cloud_off_outlined, size: size, color: Colors.red);

      case SyncStatus.offline:
        return Icon(Icons.cloud_off_outlined, size: size, color: Colors.grey);

      case SyncStatus.idle:
        return Icon(
          Icons.cloud_outlined,
          size: size,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
        );
    }
  }

  Color _getStatusColor(BuildContext context, SyncStatus status) {
    switch (status) {
      case SyncStatus.syncing:
        return Theme.of(context).colorScheme.primary;
      case SyncStatus.success:
        return Colors.green;
      case SyncStatus.error:
        return Colors.red;
      case SyncStatus.offline:
        return Colors.grey;
      case SyncStatus.idle:
        return Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5);
    }
  }

  String _getStatusLabel(SyncStatus status, SyncStatusInfo statusInfo) {
    if (status == SyncStatus.error) {
      return statusInfo.message ?? '同步失败';
    }

    switch (status) {
      case SyncStatus.syncing:
        return '同步中...';
      case SyncStatus.success:
        return '已同步';
      case SyncStatus.error:
        return '同步失败';
      case SyncStatus.offline:
        return '离线';
      case SyncStatus.idle:
        return '待同步';
    }
  }

  void _onTap(WidgetRef ref, SyncStatus status) {
    // 如果正在同步，不执行任何操作
    if (status == SyncStatus.syncing) return;

    // 触发同步
    final triggerSync = ref.read(triggerSyncProvider);
    triggerSync();
  }
}

/// 同步状态横幅
///
/// 当同步失败或离线时显示在页面顶部的横幅
/// 使用 debounce 机制避免瞬时错误导致横幅闪烁
class SyncStatusBanner extends ConsumerStatefulWidget {
  const SyncStatusBanner({super.key});

  @override
  ConsumerState<SyncStatusBanner> createState() => _SyncStatusBannerState();
}

class _SyncStatusBannerState extends ConsumerState<SyncStatusBanner> {
  bool _showBanner = false;
  SyncStatus? _lastStatus;

  // 延迟显示错误横幅的时间（秒）
  static const int _debounceSeconds = 3;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final statusInfo = ref.watch(currentSyncStatusInfoProvider);
    final status = statusInfo.status;

    // 如果用户未完全认证，不显示同步错误
    if (!authState.isFullyAuthenticated) {
      return const SizedBox.shrink();
    }

    // 状态变化时处理显示逻辑
    if (status != _lastStatus) {
      _lastStatus = status;

      if (status == SyncStatus.error || status == SyncStatus.offline) {
        // 延迟显示错误，给同步一个机会恢复
        if (!_showBanner) {
          Future.delayed(const Duration(seconds: _debounceSeconds), () {
            if (mounted) {
              final currentStatus = ref.read(currentSyncStatusProvider);
              // 只有当状态仍然是错误时才显示
              if (currentStatus == SyncStatus.error ||
                  currentStatus == SyncStatus.offline) {
                setState(() => _showBanner = true);
              }
            }
          });
        }
      } else {
        // 其他状态（idle, syncing, success）立即隐藏横幅
        if (_showBanner) {
          setState(() => _showBanner = false);
        }
      }
    }

    // 不显示横幅
    if (!_showBanner) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final isError = status == SyncStatus.error;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color:
          isError
              ? Colors.red.withValues(alpha: 0.1)
              : Colors.grey.withValues(alpha: 0.1),
      child: Row(
        children: [
          Icon(
            isError ? Icons.error_outline : Icons.cloud_off_outlined,
            size: 18,
            color: isError ? Colors.red : Colors.grey,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _buildBannerMessage(status, statusInfo),
              style: theme.textTheme.bodySmall?.copyWith(
                color: isError ? Colors.red : Colors.grey[700],
              ),
            ),
          ),
          if (isError)
            TextButton(
              onPressed: () {
                final triggerSync = ref.read(triggerSyncProvider);
                triggerSync();
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                minimumSize: const Size(0, 32),
              ),
              child: const Text('重试'),
            ),
        ],
      ),
    );
  }

  String _buildBannerMessage(SyncStatus status, SyncStatusInfo statusInfo) {
    if (status == SyncStatus.error) {
      return statusInfo.message ?? '同步失败，请稍后重试';
    }

    if (status == SyncStatus.offline) {
      return '当前处于离线模式，数据将在恢复网络后同步';
    }

    return '同步状态异常';
  }
}

/// 同步状态底部提示
///
/// 在同步完成时短暂显示的提示
class SyncStatusToast extends ConsumerStatefulWidget {
  final Widget child;

  const SyncStatusToast({super.key, required this.child});

  @override
  ConsumerState<SyncStatusToast> createState() => _SyncStatusToastState();
}

class _SyncStatusToastState extends ConsumerState<SyncStatusToast> {
  SyncStatus? _lastStatus;
  bool _showToast = false;

  @override
  Widget build(BuildContext context) {
    final status = ref.watch(currentSyncStatusProvider);

    // 检测状态变化，显示 toast
    if (_lastStatus == SyncStatus.syncing && status == SyncStatus.success) {
      _showSuccessToast();
    }
    _lastStatus = status;

    return Stack(
      children: [
        widget.child,
        if (_showToast)
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Center(
              child: AnimatedOpacity(
                opacity: _showToast ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check, size: 16, color: Colors.white),
                      SizedBox(width: 6),
                      Text(
                        '同步完成',
                        style: TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _showSuccessToast() {
    setState(() => _showToast = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _showToast = false);
      }
    });
  }
}

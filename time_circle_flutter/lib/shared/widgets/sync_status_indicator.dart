import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/auth_providers.dart';

/// 连接状态
enum ConnectionStatus { connected, connecting, disconnected }

/// 连接状态指示器
///
/// 显示当前与服务器的连接状态
class SyncStatusIndicator extends ConsumerWidget {
  /// 图标大小
  final double size;

  /// 是否显示文字
  final bool showLabel;

  /// 点击时是否触发刷新
  final bool syncOnTap;

  const SyncStatusIndicator({
    super.key,
    this.size = 20,
    this.showLabel = false,
    this.syncOnTap = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    // 根据认证状态判断连接状态
    final status =
        authState.isFullyAuthenticated
            ? ConnectionStatus.connected
            : authState.isLoading
            ? ConnectionStatus.connecting
            : ConnectionStatus.disconnected;

    return GestureDetector(
      onTap: syncOnTap ? () => _onTap(ref) : null,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child:
            showLabel
                ? _buildWithLabel(context, status)
                : _buildIconOnly(context, status),
      ),
    );
  }

  Widget _buildIconOnly(BuildContext context, ConnectionStatus status) {
    return SizedBox(
      width: size,
      height: size,
      child: _buildStatusWidget(context, status),
    );
  }

  Widget _buildWithLabel(BuildContext context, ConnectionStatus status) {
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
          _getStatusLabel(status),
          style: theme.textTheme.bodySmall?.copyWith(
            color: _getStatusColor(context, status),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusWidget(BuildContext context, ConnectionStatus status) {
    switch (status) {
      case ConnectionStatus.connecting:
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

      case ConnectionStatus.connected:
        return Icon(Icons.cloud_done_outlined, size: size, color: Colors.green);

      case ConnectionStatus.disconnected:
        return Icon(Icons.cloud_off_outlined, size: size, color: Colors.grey);
    }
  }

  Color _getStatusColor(BuildContext context, ConnectionStatus status) {
    switch (status) {
      case ConnectionStatus.connecting:
        return Theme.of(context).colorScheme.primary;
      case ConnectionStatus.connected:
        return Colors.green;
      case ConnectionStatus.disconnected:
        return Colors.grey;
    }
  }

  String _getStatusLabel(ConnectionStatus status) {
    switch (status) {
      case ConnectionStatus.connecting:
        return '连接中...';
      case ConnectionStatus.connected:
        return '已连接';
      case ConnectionStatus.disconnected:
        return '未连接';
    }
  }

  void _onTap(WidgetRef ref) {
    // 刷新认证状态
    ref.read(authProvider.notifier).refresh();
  }
}

/// 同步状态横幅 - 简化版
///
/// 当未连接时显示在页面顶部的横幅
class SyncStatusBanner extends ConsumerWidget {
  const SyncStatusBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    // 如果已完全认证，不显示横幅
    if (authState.isFullyAuthenticated) {
      return const SizedBox.shrink();
    }

    // 如果正在加载，不显示横幅
    if (authState.isLoading) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: Colors.grey.withValues(alpha: 0.1),
      child: Row(
        children: [
          const Icon(Icons.cloud_off_outlined, size: 18, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '未登录，请先登录以同步数据',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 同步状态 Toast - 简化版
///
/// 包装子组件，不再显示同步 toast
class SyncStatusToast extends StatelessWidget {
  final Widget child;

  const SyncStatusToast({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // 简化版直接返回子组件，不再显示 toast
    return child;
  }
}

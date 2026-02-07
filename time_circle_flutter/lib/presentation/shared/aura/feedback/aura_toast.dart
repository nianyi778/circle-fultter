// Aura Toast 轻提示组件
//
// 提供优雅的轻量级消息提示
// 符合 Aura 设计系统的温和视觉风格

import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/animations/animation_config.dart';
import '../../../../core/haptics/haptic_service.dart';

/// Toast 类型
enum AuraToastType {
  /// 普通信息
  info,

  /// 成功
  success,

  /// 警告
  warning,

  /// 错误
  error,
}

/// Toast 位置
enum AuraToastPosition {
  /// 顶部
  top,

  /// 底部
  bottom,

  /// 中间
  center,
}

/// Aura Toast 服务
///
/// 使用示例:
/// ```dart
/// // 显示普通提示
/// AuraToast.show(context, message: '已保存');
///
/// // 显示成功提示
/// AuraToast.success(context, message: '发布成功');
///
/// // 显示错误提示
/// AuraToast.error(context, message: '网络连接失败');
///
/// // 自定义配置
/// AuraToast.show(
///   context,
///   message: '操作完成',
///   icon: Icons.check,
///   duration: Duration(seconds: 3),
///   position: AuraToastPosition.top,
/// );
/// ```
class AuraToast {
  static OverlayEntry? _currentEntry;
  static Timer? _dismissTimer;

  /// 显示 Toast
  static void show(
    BuildContext context, {
    required String message,
    AuraToastType type = AuraToastType.info,
    AuraToastPosition position = AuraToastPosition.bottom,
    Duration duration = const Duration(milliseconds: 2500),
    IconData? icon,
    bool haptic = true,
  }) {
    // 移除当前显示的 Toast
    dismiss();

    // 触觉反馈
    if (haptic) {
      switch (type) {
        case AuraToastType.success:
          HapticService.success();
          break;
        case AuraToastType.error:
          HapticService.error();
          break;
        case AuraToastType.warning:
          HapticService.warning();
          break;
        case AuraToastType.info:
          HapticService.lightTap();
          break;
      }
    }

    final overlay = Overlay.of(context);

    _currentEntry = OverlayEntry(
      builder:
          (context) => _AuraToastWidget(
            message: message,
            type: type,
            position: position,
            icon: icon,
            onDismiss: dismiss,
          ),
    );

    overlay.insert(_currentEntry!);

    // 自动消失
    _dismissTimer = Timer(duration, dismiss);
  }

  /// 显示成功提示
  static void success(
    BuildContext context, {
    required String message,
    AuraToastPosition position = AuraToastPosition.bottom,
    Duration duration = const Duration(milliseconds: 2500),
  }) {
    show(
      context,
      message: message,
      type: AuraToastType.success,
      position: position,
      duration: duration,
    );
  }

  /// 显示错误提示
  static void error(
    BuildContext context, {
    required String message,
    AuraToastPosition position = AuraToastPosition.bottom,
    Duration duration = const Duration(milliseconds: 3000),
  }) {
    show(
      context,
      message: message,
      type: AuraToastType.error,
      position: position,
      duration: duration,
    );
  }

  /// 显示警告提示
  static void warning(
    BuildContext context, {
    required String message,
    AuraToastPosition position = AuraToastPosition.bottom,
    Duration duration = const Duration(milliseconds: 2500),
  }) {
    show(
      context,
      message: message,
      type: AuraToastType.warning,
      position: position,
      duration: duration,
    );
  }

  /// 关闭 Toast
  static void dismiss() {
    _dismissTimer?.cancel();
    _dismissTimer = null;
    _currentEntry?.remove();
    _currentEntry = null;
  }
}

/// Toast Widget
class _AuraToastWidget extends StatefulWidget {
  final String message;
  final AuraToastType type;
  final AuraToastPosition position;
  final IconData? icon;
  final VoidCallback onDismiss;

  const _AuraToastWidget({
    required this.message,
    required this.type,
    required this.position,
    this.icon,
    required this.onDismiss,
  });

  @override
  State<_AuraToastWidget> createState() => _AuraToastWidgetState();
}

class _AuraToastWidgetState extends State<_AuraToastWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: AuraDurations.normal,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: AuraCurves.enter,
    );

    final slideBegin = switch (widget.position) {
      AuraToastPosition.top => const Offset(0, -0.3),
      AuraToastPosition.bottom => const Offset(0, 0.3),
      AuraToastPosition.center => const Offset(0, 0.1),
    };

    _slideAnimation = Tween<Offset>(
      begin: slideBegin,
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: AuraCurves.enter));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return Positioned(
      top:
          widget.position == AuraToastPosition.top
              ? mediaQuery.padding.top + 16
              : null,
      bottom:
          widget.position == AuraToastPosition.bottom
              ? mediaQuery.padding.bottom + 100
              : null,
      left: 20,
      right: 20,
      child:
          widget.position == AuraToastPosition.center
              ? Center(child: _buildToast())
              : _buildToast(),
    );
  }

  Widget _buildToast() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Center(
          child: GestureDetector(
            onTap: widget.onDismiss,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: _getBackgroundColor(),
                borderRadius: BorderRadius.circular(AppRadius.full),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_getIcon() != null) ...[
                    Icon(_getIcon(), size: 18, color: _getIconColor()),
                    const SizedBox(width: 10),
                  ],
                  Flexible(
                    child: Text(
                      widget.message,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: _getTextColor(),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (widget.type) {
      case AuraToastType.info:
        return AppColors.warmGray800;
      case AuraToastType.success:
        return AppColors.successDark;
      case AuraToastType.warning:
        return AppColors.warningDark;
      case AuraToastType.error:
        return AppColors.dangerDark;
    }
  }

  Color _getTextColor() {
    return AppColors.white;
  }

  Color _getIconColor() {
    return AppColors.white;
  }

  IconData? _getIcon() {
    if (widget.icon != null) return widget.icon;

    switch (widget.type) {
      case AuraToastType.info:
        return null;
      case AuraToastType.success:
        return Icons.check_circle_outline;
      case AuraToastType.warning:
        return Icons.warning_amber_outlined;
      case AuraToastType.error:
        return Icons.error_outline;
    }
  }
}

/// SnackBar 风格的 Toast（底部固定）
class AuraSnackToast {
  static void show(
    BuildContext context, {
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: AppColors.warmGray800,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        margin: const EdgeInsets.all(16),
        duration: duration,
        action:
            actionLabel != null
                ? SnackBarAction(
                  label: actionLabel,
                  textColor: AppColors.primaryMuted,
                  onPressed: onAction ?? () {},
                )
                : null,
      ),
    );
  }
}

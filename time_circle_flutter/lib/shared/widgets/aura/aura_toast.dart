import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';

/// Aura Toast 类型
enum AuraToastType {
  /// 普通提示
  info,

  /// 成功提示
  success,

  /// 警告提示
  warning,

  /// 错误提示
  error,
}

/// Aura Toast 组件
///
/// 设计原则：
/// - 柔和的出现与消失
/// - 底部居中显示
/// - 不打断用户操作
class AuraToast {
  static OverlayEntry? _currentEntry;
  static bool _isShowing = false;

  /// 显示 Toast
  static void show(
    BuildContext context, {
    required String message,
    AuraToastType type = AuraToastType.info,
    Duration duration = const Duration(milliseconds: 2000),
    IconData? icon,
  }) {
    // 如果已经在显示，先移除
    _dismiss();

    final overlay = Overlay.of(context);

    _currentEntry = OverlayEntry(
      builder:
          (context) => _AuraToastWidget(
            message: message,
            type: type,
            duration: duration,
            icon: icon,
            onDismiss: _dismiss,
          ),
    );

    _isShowing = true;
    overlay.insert(_currentEntry!);
  }

  /// 显示成功 Toast
  static void success(BuildContext context, String message) {
    show(context, message: message, type: AuraToastType.success);
  }

  /// 显示错误 Toast
  static void error(BuildContext context, String message) {
    show(context, message: message, type: AuraToastType.error);
  }

  /// 显示警告 Toast
  static void warning(BuildContext context, String message) {
    show(context, message: message, type: AuraToastType.warning);
  }

  static void _dismiss() {
    if (_currentEntry != null && _isShowing) {
      _currentEntry!.remove();
      _currentEntry = null;
      _isShowing = false;
    }
  }
}

class _AuraToastWidget extends StatefulWidget {
  final String message;
  final AuraToastType type;
  final Duration duration;
  final IconData? icon;
  final VoidCallback onDismiss;

  const _AuraToastWidget({
    required this.message,
    required this.type,
    required this.duration,
    this.icon,
    required this.onDismiss,
  });

  @override
  State<_AuraToastWidget> createState() => _AuraToastWidgetState();
}

class _AuraToastWidgetState extends State<_AuraToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppDurations.normal,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: AppCurves.enter));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: AppCurves.enter));

    // 入场动画
    _controller.forward();

    // 自动消失
    Future.delayed(widget.duration, () {
      if (mounted) {
        _controller.reverse().then((_) {
          widget.onDismiss();
        });
      }
    });

    // 触觉反馈
    if (widget.type == AuraToastType.success) {
      HapticFeedback.lightImpact();
    } else if (widget.type == AuraToastType.error) {
      HapticFeedback.mediumImpact();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Positioned(
      bottom: bottomPadding + 32,
      left: 20,
      right: 20,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Center(child: _buildToastContent()),
        ),
      ),
    );
  }

  Widget _buildToastContent() {
    final style = _getToastStyle();

    return Container(
      constraints: const BoxConstraints(maxWidth: 320),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: style.backgroundColor,
        borderRadius: BorderRadius.circular(AppRadius.full),
        boxShadow: AppShadows.soft,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (style.icon != null) ...[
            Icon(style.icon, size: 18, color: style.iconColor),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Text(
              widget.message,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: style.textColor,
                height: 1.3,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  _ToastStyle _getToastStyle() {
    switch (widget.type) {
      case AuraToastType.info:
        return _ToastStyle(
          backgroundColor: AppColors.warmGray800,
          textColor: AppColors.white,
          icon: widget.icon,
          iconColor: AppColors.white,
        );
      case AuraToastType.success:
        return _ToastStyle(
          backgroundColor: AppColors.warmGray800,
          textColor: AppColors.white,
          icon: widget.icon ?? Icons.check_circle_outline_rounded,
          iconColor: AppColors.success,
        );
      case AuraToastType.warning:
        return _ToastStyle(
          backgroundColor: AppColors.warningLight,
          textColor: AppColors.warningDark,
          icon: widget.icon ?? Icons.info_outline_rounded,
          iconColor: AppColors.warningDark,
        );
      case AuraToastType.error:
        return _ToastStyle(
          backgroundColor: AppColors.dangerLight,
          textColor: AppColors.dangerDark,
          icon: widget.icon ?? Icons.error_outline_rounded,
          iconColor: AppColors.dangerDark,
        );
    }
  }
}

class _ToastStyle {
  final Color backgroundColor;
  final Color textColor;
  final IconData? icon;
  final Color iconColor;

  const _ToastStyle({
    required this.backgroundColor,
    required this.textColor,
    this.icon,
    required this.iconColor,
  });
}

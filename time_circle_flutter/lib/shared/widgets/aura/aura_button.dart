import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';

/// Aura 按钮变体
enum AuraButtonVariant {
  /// 主按钮 - 用于页面主操作
  primary,

  /// 次要按钮 - 用于次要操作
  secondary,

  /// 幽灵按钮 - 用于隐形操作
  ghost,

  /// 危险按钮 - 用于删除等操作
  danger,
}

/// Aura 按钮尺寸
enum AuraButtonSize {
  /// 小尺寸 - 32px 高度
  small,

  /// 中尺寸 - 40px 高度
  medium,

  /// 大尺寸 - 48px 高度
  large,
}

/// Aura 设计系统按钮组件
///
/// 设计原则：
/// - 柔和的视觉反馈
/// - 触觉反馈（轻量级）
/// - 足够的触控区域（最小 44px）
class AuraButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final AuraButtonVariant variant;
  final AuraButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final bool fullWidth;

  const AuraButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = AuraButtonVariant.primary,
    this.size = AuraButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.fullWidth = false,
  });

  /// 主按钮快捷构造
  const AuraButton.primary({
    super.key,
    required this.text,
    this.onPressed,
    this.size = AuraButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.fullWidth = false,
  }) : variant = AuraButtonVariant.primary;

  /// 次要按钮快捷构造
  const AuraButton.secondary({
    super.key,
    required this.text,
    this.onPressed,
    this.size = AuraButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.fullWidth = false,
  }) : variant = AuraButtonVariant.secondary;

  /// 幽灵按钮快捷构造
  const AuraButton.ghost({
    super.key,
    required this.text,
    this.onPressed,
    this.size = AuraButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.fullWidth = false,
  }) : variant = AuraButtonVariant.ghost;

  /// 危险按钮快捷构造
  const AuraButton.danger({
    super.key,
    required this.text,
    this.onPressed,
    this.size = AuraButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.fullWidth = false,
  }) : variant = AuraButtonVariant.danger;

  @override
  State<AuraButton> createState() => _AuraButtonState();
}

class _AuraButtonState extends State<AuraButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppDurations.instant,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.97,
    ).animate(CurvedAnimation(parent: _controller, curve: AppCurves.standard));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed == null || widget.isLoading) return;
    setState(() => _isPressed = true);
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  void _handleTap() {
    if (widget.onPressed == null || widget.isLoading) return;
    // 轻量触觉反馈
    HapticFeedback.lightImpact();
    widget.onPressed!();
  }

  @override
  Widget build(BuildContext context) {
    final style = _getButtonStyle();
    final height = _getHeight();
    final fontSize = _getFontSize();
    final iconSize = _getIconSize();
    final horizontalPadding = _getHorizontalPadding();

    final isDisabled = widget.onPressed == null || widget.isLoading;

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(scale: _scaleAnimation.value, child: child);
        },
        child: AnimatedContainer(
          duration: AppDurations.fast,
          height: height,
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          decoration: BoxDecoration(
            color: _isPressed ? style.pressedBackground : style.background,
            borderRadius: BorderRadius.circular(AppRadius.button),
            border: style.border,
          ),
          child: AnimatedOpacity(
            duration: AppDurations.fast,
            opacity: isDisabled ? 0.5 : 1.0,
            child: Row(
              mainAxisSize:
                  widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.isLoading) ...[
                  SizedBox(
                    width: iconSize,
                    height: iconSize,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(style.foreground),
                    ),
                  ),
                  const SizedBox(width: 8),
                ] else if (widget.icon != null) ...[
                  Icon(widget.icon, size: iconSize, color: style.foreground),
                  const SizedBox(width: 8),
                ],
                Text(
                  widget.text,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w500,
                    color: style.foreground,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _ButtonStyle _getButtonStyle() {
    switch (widget.variant) {
      case AuraButtonVariant.primary:
        return _ButtonStyle(
          background: AppColors.warmGray800,
          pressedBackground: AppColors.warmGray900,
          foreground: AppColors.white,
        );
      case AuraButtonVariant.secondary:
        return _ButtonStyle(
          background: Colors.transparent,
          pressedBackground: AppColors.warmGray100,
          foreground: AppColors.warmGray700,
          border: Border.all(color: AppColors.warmGray300, width: 1),
        );
      case AuraButtonVariant.ghost:
        return _ButtonStyle(
          background: Colors.transparent,
          pressedBackground: AppColors.warmGray100,
          foreground: AppColors.warmGray600,
        );
      case AuraButtonVariant.danger:
        return _ButtonStyle(
          background: AppColors.dangerDark,
          pressedBackground: AppColors.dangerDark.withValues(alpha: 0.9),
          foreground: AppColors.white,
        );
    }
  }

  double _getHeight() {
    switch (widget.size) {
      case AuraButtonSize.small:
        return 32;
      case AuraButtonSize.medium:
        return 40;
      case AuraButtonSize.large:
        return 48;
    }
  }

  double _getFontSize() {
    switch (widget.size) {
      case AuraButtonSize.small:
        return 12;
      case AuraButtonSize.medium:
        return 14;
      case AuraButtonSize.large:
        return 16;
    }
  }

  double _getIconSize() {
    switch (widget.size) {
      case AuraButtonSize.small:
        return 14;
      case AuraButtonSize.medium:
        return 18;
      case AuraButtonSize.large:
        return 20;
    }
  }

  double _getHorizontalPadding() {
    switch (widget.size) {
      case AuraButtonSize.small:
        return 16;
      case AuraButtonSize.medium:
        return 24;
      case AuraButtonSize.large:
        return 32;
    }
  }
}

class _ButtonStyle {
  final Color background;
  final Color pressedBackground;
  final Color foreground;
  final Border? border;

  const _ButtonStyle({
    required this.background,
    required this.pressedBackground,
    required this.foreground,
    this.border,
  });
}

/// Aura 图标按钮
class AuraIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final Color? color;
  final Color? backgroundColor;

  const AuraIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.size = 44,
    this.color,
    this.backgroundColor,
  });

  @override
  State<AuraIconButton> createState() => _AuraIconButtonState();
}

class _AuraIconButtonState extends State<AuraIconButton> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed == null) return;
    setState(() => _isPressed = true);
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
  }

  void _handleTap() {
    if (widget.onPressed == null) return;
    HapticFeedback.selectionClick();
    widget.onPressed!();
  }

  @override
  Widget build(BuildContext context) {
    final iconColor = widget.color ?? AppColors.warmGray600;
    final bgColor = widget.backgroundColor ?? Colors.transparent;

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: _handleTap,
      child: AnimatedContainer(
        duration: AppDurations.fast,
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: _isPressed ? AppColors.warmGray100 : bgColor,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Icon(widget.icon, size: widget.size * 0.5, color: iconColor),
        ),
      ),
    );
  }
}

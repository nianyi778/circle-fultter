// Aura Haptic Button 触觉反馈按钮
//
// 提供触觉反馈和动画效果的按钮组件
// 符合 Aura 设计系统的交互规范

import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/haptics/haptic_service.dart';
import '../../../../core/animations/animation_config.dart';

/// 按钮变体
enum AuraButtonVariant {
  /// 主要按钮 - 深色背景
  primary,

  /// 次要按钮 - 边框
  secondary,

  /// 幽灵按钮 - 透明背景
  ghost,

  /// 危险按钮 - 红色
  danger,
}

/// 按钮尺寸
enum AuraButtonSize {
  /// 小尺寸 - 36px
  small,

  /// 中等尺寸 - 48px
  medium,

  /// 大尺寸 - 56px
  large,
}

/// Aura Haptic Button
///
/// 使用示例:
/// ```dart
/// AuraHapticButton(
///   label: '留下',
///   onPressed: () {},
/// )
///
/// AuraHapticButton(
///   label: '取消',
///   variant: AuraButtonVariant.secondary,
///   onPressed: () {},
/// )
///
/// AuraHapticButton(
///   label: '删除',
///   variant: AuraButtonVariant.danger,
///   icon: Icons.delete_outline,
///   onPressed: () {},
/// )
/// ```
class AuraHapticButton extends StatefulWidget {
  /// 按钮文字
  final String label;

  /// 点击回调
  final VoidCallback? onPressed;

  /// 按钮变体
  final AuraButtonVariant variant;

  /// 按钮尺寸
  final AuraButtonSize size;

  /// 前置图标
  final IconData? icon;

  /// 是否加载中
  final bool isLoading;

  /// 是否全宽
  final bool fullWidth;

  /// 是否启用触觉反馈
  final bool hapticEnabled;

  /// 自定义触觉类型
  final HapticType hapticType;

  const AuraHapticButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AuraButtonVariant.primary,
    this.size = AuraButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.fullWidth = false,
    this.hapticEnabled = true,
    this.hapticType = HapticType.light,
  });

  @override
  State<AuraHapticButton> createState() => _AuraHapticButtonState();
}

class _AuraHapticButtonState extends State<AuraHapticButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  bool _isPressed = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: AuraDurations.instant,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(parent: _controller, curve: AuraCurves.standard));
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
    if (widget.onPressed == null || widget.isLoading) return;
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  void _handleTapCancel() {
    if (widget.onPressed == null || widget.isLoading) return;
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  Future<void> _handleTap() async {
    if (widget.onPressed == null || widget.isLoading) return;

    // 触觉反馈
    if (widget.hapticEnabled) {
      switch (widget.hapticType) {
        case HapticType.light:
          await HapticService.lightTap();
          break;
        case HapticType.medium:
          await HapticService.mediumTap();
          break;
        case HapticType.heavy:
          await HapticService.heavyTap();
          break;
        case HapticType.selection:
          await HapticService.selection();
          break;
      }
    }

    widget.onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onPressed == null;

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: AnimatedContainer(
              duration: AuraDurations.fast,
              width: widget.fullWidth ? double.infinity : null,
              height: _getHeight(),
              padding: _getPadding(),
              decoration: BoxDecoration(
                color: _getBackgroundColor(isDisabled),
                borderRadius: BorderRadius.circular(_getBorderRadius()),
                border: _getBorder(isDisabled),
                boxShadow: _isPressed ? null : _getShadow(isDisabled),
              ),
              child: _buildContent(isDisabled),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(bool isDisabled) {
    if (widget.isLoading) {
      return Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation(_getTextColor(isDisabled)),
          ),
        ),
      );
    }

    return Row(
      mainAxisSize: widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.icon != null) ...[
          Icon(
            widget.icon,
            size: _getIconSize(),
            color: _getTextColor(isDisabled),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
        Text(widget.label, style: _getTextStyle(isDisabled)),
      ],
    );
  }

  double _getHeight() {
    switch (widget.size) {
      case AuraButtonSize.small:
        return 36;
      case AuraButtonSize.medium:
        return 48;
      case AuraButtonSize.large:
        return 56;
    }
  }

  double _getBorderRadius() {
    switch (widget.size) {
      case AuraButtonSize.small:
        return 10;
      case AuraButtonSize.medium:
        return 14;
      case AuraButtonSize.large:
        return 18;
    }
  }

  EdgeInsets _getPadding() {
    switch (widget.size) {
      case AuraButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 14, vertical: 8);
      case AuraButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 20, vertical: 12);
      case AuraButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 28, vertical: 16);
    }
  }

  double _getIconSize() {
    switch (widget.size) {
      case AuraButtonSize.small:
        return 16;
      case AuraButtonSize.medium:
        return 20;
      case AuraButtonSize.large:
        return 24;
    }
  }

  Color _getBackgroundColor(bool isDisabled) {
    if (isDisabled) {
      return widget.variant == AuraButtonVariant.ghost ||
              widget.variant == AuraButtonVariant.secondary
          ? Colors.transparent
          : AppColors.warmGray300;
    }

    switch (widget.variant) {
      case AuraButtonVariant.primary:
        return _isPressed ? AppColors.warmGray900 : AppColors.warmGray800;
      case AuraButtonVariant.secondary:
        return _isPressed ? AppColors.warmGray100 : Colors.transparent;
      case AuraButtonVariant.ghost:
        return _isPressed ? AppColors.warmGray100 : Colors.transparent;
      case AuraButtonVariant.danger:
        return _isPressed ? AppColors.heartDark : AppColors.dangerDark;
    }
  }

  Border? _getBorder(bool isDisabled) {
    if (widget.variant == AuraButtonVariant.secondary) {
      return Border.all(
        color: isDisabled ? AppColors.warmGray300 : AppColors.warmGray300,
        width: 1,
      );
    }
    return null;
  }

  List<BoxShadow>? _getShadow(bool isDisabled) {
    if (isDisabled ||
        widget.variant == AuraButtonVariant.ghost ||
        widget.variant == AuraButtonVariant.secondary) {
      return null;
    }
    return AppShadows.subtle;
  }

  Color _getTextColor(bool isDisabled) {
    if (isDisabled) {
      return AppColors.warmGray400;
    }

    switch (widget.variant) {
      case AuraButtonVariant.primary:
      case AuraButtonVariant.danger:
        return AppColors.white;
      case AuraButtonVariant.secondary:
      case AuraButtonVariant.ghost:
        return _isPressed ? AppColors.warmGray900 : AppColors.warmGray700;
    }
  }

  TextStyle _getTextStyle(bool isDisabled) {
    final fontSize = switch (widget.size) {
      AuraButtonSize.small => 13.0,
      AuraButtonSize.medium => 15.0,
      AuraButtonSize.large => 16.0,
    };

    return TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w500,
      color: _getTextColor(isDisabled),
    );
  }
}

/// 图标触觉按钮
class AuraHapticIconButton extends StatefulWidget {
  /// 图标
  final IconData icon;

  /// 点击回调
  final VoidCallback? onPressed;

  /// 图标大小
  final double size;

  /// 图标颜色
  final Color? color;

  /// 背景颜色
  final Color? backgroundColor;

  /// 是否启用触觉反馈
  final bool hapticEnabled;

  const AuraHapticIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.size = 24,
    this.color,
    this.backgroundColor,
    this.hapticEnabled = true,
  });

  @override
  State<AuraHapticIconButton> createState() => _AuraHapticIconButtonState();
}

class _AuraHapticIconButtonState extends State<AuraHapticIconButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: AuraDurations.instant,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(parent: _controller, curve: AuraCurves.standard));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    if (widget.onPressed == null) return;

    _controller.forward().then((_) => _controller.reverse());

    if (widget.hapticEnabled) {
      await HapticService.lightTap();
    }

    widget.onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onPressed == null;

    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: 44, // 最小触控区域
              height: 44,
              decoration: BoxDecoration(
                color: widget.backgroundColor ?? Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  widget.icon,
                  size: widget.size,
                  color:
                      widget.color ??
                      (isDisabled
                          ? AppColors.warmGray400
                          : AppColors.warmGray600),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

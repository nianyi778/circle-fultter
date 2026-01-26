import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Aura 卡片变体
enum AuraCardVariant {
  /// 标准卡片 - 白色背景，paper 阴影
  standard,

  /// 紧凑卡片 - 较小的内边距和圆角
  compact,

  /// 宽松卡片 - 更大的内边距，用于仪式感场景
  relaxed,

  /// 浮层卡片 - 更强的阴影
  elevated,
}

/// Aura 设计系统卡片组件
///
/// 设计原则：
/// - 足够的呼吸空间
/// - 柔和的阴影
/// - 统一的圆角
class AuraCard extends StatelessWidget {
  final Widget child;
  final AuraCardVariant variant;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  final bool showShadow;

  const AuraCard({
    super.key,
    required this.child,
    this.variant = AuraCardVariant.standard,
    this.padding,
    this.backgroundColor,
    this.onTap,
    this.showShadow = true,
  });

  /// 标准卡片
  const AuraCard.standard({
    super.key,
    required this.child,
    this.padding,
    this.backgroundColor,
    this.onTap,
    this.showShadow = true,
  }) : variant = AuraCardVariant.standard;

  /// 紧凑卡片
  const AuraCard.compact({
    super.key,
    required this.child,
    this.padding,
    this.backgroundColor,
    this.onTap,
    this.showShadow = true,
  }) : variant = AuraCardVariant.compact;

  /// 宽松卡片
  const AuraCard.relaxed({
    super.key,
    required this.child,
    this.padding,
    this.backgroundColor,
    this.onTap,
    this.showShadow = true,
  }) : variant = AuraCardVariant.relaxed;

  /// 浮层卡片
  const AuraCard.elevated({
    super.key,
    required this.child,
    this.padding,
    this.backgroundColor,
    this.onTap,
    this.showShadow = true,
  }) : variant = AuraCardVariant.elevated;

  @override
  Widget build(BuildContext context) {
    final config = _getCardConfig();
    final effectivePadding = padding ?? config.padding;
    final effectiveBackgroundColor = backgroundColor ?? AppColors.bgElevated;

    Widget cardContent = Container(
      padding: effectivePadding,
      decoration: BoxDecoration(
        color: effectiveBackgroundColor,
        borderRadius: BorderRadius.circular(config.borderRadius),
        boxShadow: showShadow ? config.shadow : null,
      ),
      child: child,
    );

    if (onTap != null) {
      return _TappableCard(
        onTap: onTap!,
        borderRadius: config.borderRadius,
        child: cardContent,
      );
    }

    return cardContent;
  }

  _CardConfig _getCardConfig() {
    switch (variant) {
      case AuraCardVariant.standard:
        return _CardConfig(
          padding: const EdgeInsets.all(AppSpacing.cardPadding),
          borderRadius: AppRadius.card,
          shadow: AppShadows.paper,
        );
      case AuraCardVariant.compact:
        return _CardConfig(
          padding: const EdgeInsets.all(AppSpacing.base),
          borderRadius: AppRadius.lg,
          shadow: AppShadows.subtle,
        );
      case AuraCardVariant.relaxed:
        return _CardConfig(
          padding: const EdgeInsets.all(AppSpacing.xl),
          borderRadius: AppRadius.xxl,
          shadow: AppShadows.soft,
        );
      case AuraCardVariant.elevated:
        return _CardConfig(
          padding: const EdgeInsets.all(AppSpacing.cardPadding),
          borderRadius: AppRadius.card,
          shadow: AppShadows.elevated,
        );
    }
  }
}

class _CardConfig {
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final List<BoxShadow> shadow;

  const _CardConfig({
    required this.padding,
    required this.borderRadius,
    required this.shadow,
  });
}

/// 可点击卡片包装器
class _TappableCard extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final double borderRadius;

  const _TappableCard({
    required this.child,
    required this.onTap,
    required this.borderRadius,
  });

  @override
  State<_TappableCard> createState() => _TappableCardState();
}

class _TappableCardState extends State<_TappableCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppDurations.instant,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(parent: _controller, curve: AppCurves.standard));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(scale: _scaleAnimation.value, child: child);
        },
        child: widget.child,
      ),
    );
  }
}

/// 情绪色卡片 - 用于标签、情绪分类等
class AuraMoodCard extends StatelessWidget {
  final Widget child;
  final AuraMoodType mood;
  final EdgeInsetsGeometry? padding;

  const AuraMoodCard({
    super.key,
    required this.child,
    required this.mood,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _getMoodColors();

    return Container(
      padding:
          padding ??
          const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(AppRadius.chip),
      ),
      child: child,
    );
  }

  _MoodColors _getMoodColors() {
    switch (mood) {
      case AuraMoodType.calm:
        return _MoodColors(
          background: AppColors.calmBlueLight,
          foreground: AppColors.calmBlueDeep,
        );
      case AuraMoodType.warm:
        return _MoodColors(
          background: AppColors.warmPeachLight,
          foreground: AppColors.warmPeachDeep,
        );
      case AuraMoodType.peaceful:
        return _MoodColors(
          background: AppColors.softGreenLight,
          foreground: AppColors.softGreenDeep,
        );
      case AuraMoodType.nostalgic:
        return _MoodColors(
          background: AppColors.mutedVioletLight,
          foreground: AppColors.mutedVioletDeep,
        );
      case AuraMoodType.joyful:
        return _MoodColors(
          background: AppColors.warmOrangeLight,
          foreground: AppColors.warmOrangeDeep,
        );
    }
  }
}

/// 情绪类型
enum AuraMoodType {
  /// 平静
  calm,

  /// 温暖
  warm,

  /// 安心
  peaceful,

  /// 思念
  nostalgic,

  /// 快乐
  joyful,
}

class _MoodColors {
  final Color background;
  final Color foreground;

  const _MoodColors({required this.background, required this.foreground});
}

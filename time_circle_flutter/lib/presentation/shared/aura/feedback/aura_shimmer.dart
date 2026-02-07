// Aura Shimmer 骨架屏组件
//
// 提供优雅的加载占位效果
// 符合 Aura 设计系统的温和视觉风格

import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

/// Shimmer 效果组件
///
/// 使用示例:
/// ```dart
/// // 基础用法
/// AuraShimmer(
///   width: 200,
///   height: 100,
/// )
///
/// // 圆形
/// AuraShimmer.circle(size: 48)
///
/// // 文本占位
/// AuraShimmer.text(width: 150)
/// ```
class AuraShimmer extends StatefulWidget {
  /// 宽度
  final double? width;

  /// 高度
  final double? height;

  /// 圆角
  final BorderRadius? borderRadius;

  /// 基础颜色
  final Color? baseColor;

  /// 高亮颜色
  final Color? highlightColor;

  /// 动画周期
  final Duration duration;

  /// 是否启用动画
  final bool enabled;

  const AuraShimmer({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.baseColor,
    this.highlightColor,
    this.duration = const Duration(milliseconds: 1500),
    this.enabled = true,
  });

  /// 圆形 Shimmer
  factory AuraShimmer.circle({
    Key? key,
    required double size,
    Color? baseColor,
    Color? highlightColor,
    bool enabled = true,
  }) {
    return AuraShimmer(
      key: key,
      width: size,
      height: size,
      borderRadius: BorderRadius.circular(size / 2),
      baseColor: baseColor,
      highlightColor: highlightColor,
      enabled: enabled,
    );
  }

  /// 文本行 Shimmer
  factory AuraShimmer.text({
    Key? key,
    required double width,
    double height = 14,
    Color? baseColor,
    Color? highlightColor,
    bool enabled = true,
  }) {
    return AuraShimmer(
      key: key,
      width: width,
      height: height,
      borderRadius: BorderRadius.circular(height / 2),
      baseColor: baseColor,
      highlightColor: highlightColor,
      enabled: enabled,
    );
  }

  /// 卡片 Shimmer
  factory AuraShimmer.card({
    Key? key,
    double? width,
    required double height,
    Color? baseColor,
    Color? highlightColor,
    bool enabled = true,
  }) {
    return AuraShimmer(
      key: key,
      width: width,
      height: height,
      borderRadius: BorderRadius.circular(AppRadius.card),
      baseColor: baseColor,
      highlightColor: highlightColor,
      enabled: enabled,
    );
  }

  @override
  State<AuraShimmer> createState() => _AuraShimmerState();
}

class _AuraShimmerState extends State<AuraShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: widget.duration);

    _animation = Tween<double>(
      begin: -2,
      end: 2,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    if (widget.enabled) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(AuraShimmer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.enabled && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.enabled && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = widget.baseColor ?? AppColors.warmGray200;
    final highlightColor = widget.highlightColor ?? AppColors.warmGray100;
    final borderRadius =
        widget.borderRadius ?? BorderRadius.circular(AppRadius.sm);

    if (!widget.enabled) {
      return Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(color: baseColor, borderRadius: borderRadius),
      );
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            gradient: LinearGradient(
              begin: Alignment(_animation.value - 1, 0),
              end: Alignment(_animation.value + 1, 0),
              colors: [baseColor, highlightColor, baseColor],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }
}

/// 骨架屏容器
///
/// 用于快速构建复杂的骨架屏布局
class AuraShimmerContainer extends StatelessWidget {
  final Widget child;

  const AuraShimmerContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

/// 预定义的骨架屏布局

/// Moment 卡片骨架屏
class MomentCardSkeleton extends StatelessWidget {
  const MomentCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.bgElevated,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: AppShadows.paper,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 头部
          Row(
            children: [
              AuraShimmer.circle(size: 40),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AuraShimmer.text(width: 80),
                    const SizedBox(height: 6),
                    AuraShimmer.text(width: 60, height: 12),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // 内容
          AuraShimmer.text(width: double.infinity),
          const SizedBox(height: 8),
          AuraShimmer.text(width: 200),

          const SizedBox(height: AppSpacing.lg),

          // 图片区域
          AuraShimmer.card(height: 180),
        ],
      ),
    );
  }
}

/// 列表项骨架屏
class ListItemSkeleton extends StatelessWidget {
  final double height;

  const ListItemSkeleton({super.key, this.height = 72});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          AuraShimmer.circle(size: 48),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AuraShimmer.text(width: 120),
                const SizedBox(height: 8),
                AuraShimmer.text(width: 80, height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 时间线骨架屏
class TimelineSkeletonList extends StatelessWidget {
  final int itemCount;

  const TimelineSkeletonList({super.key, this.itemCount = 3});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        itemCount,
        (index) => Padding(
          padding: EdgeInsets.only(
            bottom: index < itemCount - 1 ? AppSpacing.lg : 0,
          ),
          child: const MomentCardSkeleton(),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Aura 骨架屏组件
///
/// 设计原则：
/// - 柔和的 shimmer 效果
/// - 与目标元素相同的形状
/// - 不打断视觉节奏
class AuraSkeleton extends StatefulWidget {
  final double? width;
  final double? height;
  final double borderRadius;
  final bool isCircle;

  const AuraSkeleton({
    super.key,
    this.width,
    this.height,
    this.borderRadius = AppRadius.sm,
    this.isCircle = false,
  });

  /// 文本行骨架
  const AuraSkeleton.text({super.key, this.width = 120, this.height = 14})
    : borderRadius = 4,
      isCircle = false;

  /// 标题骨架
  const AuraSkeleton.title({super.key, this.width = 180, this.height = 20})
    : borderRadius = 6,
      isCircle = false;

  /// 圆形骨架（头像）
  const AuraSkeleton.circle({super.key, required double size})
    : width = size,
      height = size,
      borderRadius = 999,
      isCircle = true;

  /// 矩形骨架（图片、卡片）
  const AuraSkeleton.rect({
    super.key,
    this.width,
    this.height,
    this.borderRadius = AppRadius.md,
  }) : isCircle = false;

  @override
  State<AuraSkeleton> createState() => _AuraSkeletonState();
}

class _AuraSkeletonState extends State<AuraSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius:
                widget.isCircle
                    ? null
                    : BorderRadius.circular(widget.borderRadius),
            shape: widget.isCircle ? BoxShape.circle : BoxShape.rectangle,
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                AppColors.warmGray200,
                AppColors.warmGray100,
                AppColors.warmGray200,
              ],
              stops: [
                (_animation.value - 0.3).clamp(0.0, 1.0),
                _animation.value.clamp(0.0, 1.0),
                (_animation.value + 0.3).clamp(0.0, 1.0),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// 卡片骨架屏
class AuraCardSkeleton extends StatelessWidget {
  final double? height;
  final bool showAvatar;
  final bool showImage;
  final int textLines;

  const AuraCardSkeleton({
    super.key,
    this.height,
    this.showAvatar = true,
    this.showImage = false,
    this.textLines = 2,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.bgElevated,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: AppShadows.paper,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 头部区域
          if (showAvatar) ...[
            Row(
              children: [
                const AuraSkeleton.circle(size: 36),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    AuraSkeleton.text(width: 80, height: 14),
                    SizedBox(height: 6),
                    AuraSkeleton.text(width: 50, height: 10),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],

          // 图片区域
          if (showImage) ...[
            const AuraSkeleton.rect(height: 180, borderRadius: AppRadius.md),
            const SizedBox(height: 16),
          ],

          // 文本行
          ...List.generate(
            textLines,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AuraSkeleton.text(
                width: index == textLines - 1 ? 160 : double.infinity,
                height: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 列表骨架屏
class AuraListSkeleton extends StatelessWidget {
  final int itemCount;
  final bool showAvatar;
  final bool showImage;
  final int textLines;
  final double itemSpacing;

  const AuraListSkeleton({
    super.key,
    this.itemCount = 3,
    this.showAvatar = true,
    this.showImage = false,
    this.textLines = 2,
    this.itemSpacing = AppSpacing.cardGap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        itemCount,
        (index) => Padding(
          padding: EdgeInsets.only(
            bottom: index < itemCount - 1 ? itemSpacing : 0,
          ),
          child: AuraCardSkeleton(
            showAvatar: showAvatar,
            showImage: showImage,
            textLines: textLines,
          ),
        ),
      ),
    );
  }
}

/// 时间线骨架屏
class AuraTimelineSkeleton extends StatelessWidget {
  final int itemCount;

  const AuraTimelineSkeleton({super.key, this.itemCount = 3});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
      child: Column(
        children: List.generate(
          itemCount,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.cardGap),
            child: const _TimelineItemSkeleton(),
          ),
        ),
      ),
    );
  }
}

class _TimelineItemSkeleton extends StatelessWidget {
  const _TimelineItemSkeleton();

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
              const AuraSkeleton.circle(size: 36),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    AuraSkeleton.text(width: 100, height: 14),
                    SizedBox(height: 4),
                    AuraSkeleton.text(width: 60, height: 10),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 图片
          const AuraSkeleton.rect(height: 200, borderRadius: AppRadius.md),
          const SizedBox(height: 16),

          // 文本
          const AuraSkeleton.text(width: double.infinity, height: 14),
          const SizedBox(height: 8),
          const AuraSkeleton.text(width: 200, height: 14),
          const SizedBox(height: 16),

          // 底部操作区
          Row(
            children: const [
              AuraSkeleton.text(width: 50, height: 12),
              SizedBox(width: 24),
              AuraSkeleton.text(width: 50, height: 12),
            ],
          ),
        ],
      ),
    );
  }
}

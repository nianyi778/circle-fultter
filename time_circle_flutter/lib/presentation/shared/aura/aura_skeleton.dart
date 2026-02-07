import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_theme.dart';

/// Aura Skeleton Loading Component
///
/// A shimmer loading placeholder following Aura design.
/// Uses breathing animation for a calm, non-aggressive loading state.
class AuraSkeleton extends StatelessWidget {
  /// Width of the skeleton (null = expand to parent)
  final double? width;

  /// Height of the skeleton (required)
  final double height;

  /// Border radius
  final double borderRadius;

  /// Base color
  final Color? baseColor;

  /// Highlight color
  final Color? highlightColor;

  /// Animate the skeleton
  final bool animate;

  const AuraSkeleton({
    super.key,
    this.width,
    required this.height,
    this.borderRadius = 8,
    this.baseColor,
    this.highlightColor,
    this.animate = true,
  });

  /// Factory for text line skeleton
  factory AuraSkeleton.text({
    Key? key,
    double? width,
    double height = 14,
    double borderRadius = 4,
  }) => AuraSkeleton(
    key: key,
    width: width,
    height: height,
    borderRadius: borderRadius,
  );

  /// Factory for circular skeleton (avatar)
  factory AuraSkeleton.circle({Key? key, double size = 40}) =>
      AuraSkeleton(key: key, width: size, height: size, borderRadius: size / 2);

  /// Factory for card skeleton
  factory AuraSkeleton.card({
    Key? key,
    double? width,
    double height = 120,
    double borderRadius = 16,
  }) => AuraSkeleton(
    key: key,
    width: width,
    height: height,
    borderRadius: borderRadius,
  );

  @override
  Widget build(BuildContext context) {
    Widget skeleton = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: baseColor ?? AppColors.warmGray200,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );

    if (animate) {
      skeleton = skeleton
          .animate(onComplete: (controller) => controller.repeat())
          .shimmer(
            duration: AppDurations.breathing,
            color: highlightColor ?? AppColors.warmGray100,
          );
    }

    return skeleton;
  }
}

/// Skeleton template for common layouts
class AuraSkeletonTemplates {
  /// Timeline feed card skeleton
  static Widget feedCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pagePadding,
        vertical: AppSpacing.sm,
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.base),
        decoration: BoxDecoration(
          color: AppColors.bgElevated,
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                AuraSkeleton.circle(size: 40),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AuraSkeleton.text(width: 80),
                      const SizedBox(height: 6),
                      AuraSkeleton.text(width: 60, height: 12),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.base),
            // Content
            AuraSkeleton.text(width: double.infinity),
            const SizedBox(height: 8),
            AuraSkeleton.text(width: 200),
            const SizedBox(height: AppSpacing.base),
            // Media placeholder
            AuraSkeleton.card(height: 180),
          ],
        ),
      ),
    );
  }

  /// Letter card skeleton
  static Widget letterCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pagePadding,
        vertical: AppSpacing.sm,
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        decoration: BoxDecoration(
          color: AppColors.bgElevated,
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Badge
            const AuraSkeleton(width: 60, height: 24, borderRadius: 12),
            const SizedBox(height: AppSpacing.base),
            // Title
            AuraSkeleton.text(width: 200, height: 20),
            const SizedBox(height: 8),
            // Preview lines
            AuraSkeleton.text(width: double.infinity),
            const SizedBox(height: 6),
            AuraSkeleton.text(width: 150),
            const SizedBox(height: AppSpacing.base),
            // Footer
            Row(
              children: [
                AuraSkeleton.text(width: 80, height: 12),
                const Spacer(),
                AuraSkeleton.text(width: 60, height: 12),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Profile/User card skeleton
  static Widget profileCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.bgElevated,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Row(
        children: [
          AuraSkeleton.circle(size: 56),
          const SizedBox(width: AppSpacing.base),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AuraSkeleton.text(width: 120, height: 18),
                const SizedBox(height: 8),
                AuraSkeleton.text(width: 80, height: 14),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// List of feed cards skeleton
  static Widget feedList({int count = 3}) {
    return ListView.builder(
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: count,
      itemBuilder: (_, __) => feedCard(),
    );
  }

  /// Grid of images skeleton
  static Widget imageGrid({int count = 6, int crossAxisCount = 3}) {
    return GridView.builder(
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
      ),
      itemCount: count,
      itemBuilder:
          (_, __) =>
              const AuraSkeleton(height: 100, borderRadius: 8, animate: false),
    );
  }
}

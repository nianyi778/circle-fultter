import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_theme.dart';

/// Aura Card Component
///
/// A styled card container following the Aura design system.
/// Features paper-like shadows and warm backgrounds.
class AuraCard extends StatelessWidget {
  /// Card child content
  final Widget child;

  /// Card padding (default: cardPadding)
  final EdgeInsetsGeometry? padding;

  /// Card margin
  final EdgeInsetsGeometry? margin;

  /// Background color
  final Color? backgroundColor;

  /// Border radius
  final double? borderRadius;

  /// Shadow style (use AppShadows)
  final List<BoxShadow>? boxShadow;

  /// Border
  final Border? border;

  /// Callback when card is tapped
  final VoidCallback? onTap;

  /// Callback when card is long pressed
  final VoidCallback? onLongPress;

  /// Enable haptic feedback on tap
  final bool enableHaptic;

  /// Clip behavior
  final Clip clipBehavior;

  const AuraCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderRadius,
    this.boxShadow,
    this.border,
    this.onTap,
    this.onLongPress,
    this.enableHaptic = true,
    this.clipBehavior = Clip.antiAlias,
  });

  /// Factory for standard card with paper shadow
  factory AuraCard.paper({
    Key? key,
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
  }) => AuraCard(
    key: key,
    padding: padding,
    margin: margin,
    boxShadow: AppShadows.paper,
    onTap: onTap,
    onLongPress: onLongPress,
    child: child,
  );

  /// Factory for subtle elevated card
  factory AuraCard.subtle({
    Key? key,
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
  }) => AuraCard(
    key: key,
    padding: padding,
    margin: margin,
    boxShadow: AppShadows.subtle,
    onTap: onTap,
    onLongPress: onLongPress,
    child: child,
  );

  /// Factory for flat card (no shadow)
  factory AuraCard.flat({
    Key? key,
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    Color? backgroundColor,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
  }) => AuraCard(
    key: key,
    padding: padding,
    margin: margin,
    backgroundColor: backgroundColor ?? AppColors.bgMuted,
    boxShadow: const [],
    onTap: onTap,
    onLongPress: onLongPress,
    child: child,
  );

  /// Factory for outlined card
  factory AuraCard.outlined({
    Key? key,
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    Color? borderColor,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
  }) => AuraCard(
    key: key,
    padding: padding,
    margin: margin,
    backgroundColor: AppColors.white,
    boxShadow: const [],
    border: Border.all(color: borderColor ?? AppColors.warmGray250, width: 1),
    onTap: onTap,
    onLongPress: onLongPress,
    child: child,
  );

  @override
  Widget build(BuildContext context) {
    final hasInteraction = onTap != null || onLongPress != null;

    Widget cardContent = Container(
      padding: padding ?? const EdgeInsets.all(AppSpacing.cardPadding),
      child: child,
    );

    Widget card = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.bgElevated,
        borderRadius: BorderRadius.circular(borderRadius ?? AppRadius.card),
        boxShadow: boxShadow ?? AppShadows.soft,
        border: border,
      ),
      clipBehavior: clipBehavior,
      child:
          hasInteraction
              ? Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap:
                      onTap != null
                          ? () {
                            if (enableHaptic) {
                              HapticFeedback.lightImpact();
                            }
                            onTap!();
                          }
                          : null,
                  onLongPress:
                      onLongPress != null
                          ? () {
                            if (enableHaptic) {
                              HapticFeedback.mediumImpact();
                            }
                            onLongPress!();
                          }
                          : null,
                  borderRadius: BorderRadius.circular(
                    borderRadius ?? AppRadius.card,
                  ),
                  child: cardContent,
                ),
              )
              : cardContent,
    );

    return card;
  }
}

/// Aura Section Card
///
/// A card with title and optional action button.
/// Used for home page sections.
class AuraSectionCard extends StatelessWidget {
  /// Section title
  final String title;

  /// Optional subtitle
  final String? subtitle;

  /// Card content
  final Widget child;

  /// Optional trailing action
  final Widget? action;

  /// Card padding
  final EdgeInsetsGeometry? contentPadding;

  /// Card margin
  final EdgeInsetsGeometry? margin;

  /// Header padding
  final EdgeInsetsGeometry? headerPadding;

  const AuraSectionCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.child,
    this.action,
    this.contentPadding,
    this.margin,
    this.headerPadding,
  });

  @override
  Widget build(BuildContext context) {
    return AuraCard(
      padding: EdgeInsets.zero,
      margin: margin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding:
                headerPadding ??
                const EdgeInsets.fromLTRB(
                  AppSpacing.cardPadding,
                  AppSpacing.cardPadding,
                  AppSpacing.cardPadding,
                  AppSpacing.md,
                ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: AppTypography.subtitle(context)),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(subtitle!, style: AppTypography.caption(context)),
                      ],
                    ],
                  ),
                ),
                if (action != null) action!,
              ],
            ),
          ),
          // Content
          Padding(
            padding:
                contentPadding ??
                const EdgeInsets.fromLTRB(
                  AppSpacing.cardPadding,
                  0,
                  AppSpacing.cardPadding,
                  AppSpacing.cardPadding,
                ),
            child: child,
          ),
        ],
      ),
    );
  }
}

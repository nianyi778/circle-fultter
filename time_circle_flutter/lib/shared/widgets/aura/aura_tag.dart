import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Aura 标签变体
enum AuraTagVariant {
  /// 情绪标签
  mood,

  /// 时间标签
  time,

  /// 类型标签
  type,

  /// 普通标签
  normal,
}

/// Aura 标签组件
class AuraTag extends StatelessWidget {
  final String text;
  final AuraTagVariant variant;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;
  final VoidCallback? onTap;

  const AuraTag({
    super.key,
    required this.text,
    this.variant = AuraTagVariant.normal,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.onTap,
  });

  /// 时间标签
  const AuraTag.time({super.key, required this.text, this.icon, this.onTap})
    : variant = AuraTagVariant.time,
      backgroundColor = null,
      textColor = null;

  /// 类型标签
  const AuraTag.type({super.key, required this.text, this.icon, this.onTap})
    : variant = AuraTagVariant.type,
      backgroundColor = null,
      textColor = null;

  @override
  Widget build(BuildContext context) {
    final style = _getTagStyle();

    Widget tagContent = Container(
      padding: style.padding,
      decoration: BoxDecoration(
        color: style.backgroundColor,
        borderRadius: BorderRadius.circular(style.borderRadius),
        border: style.border,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: style.iconSize, color: style.textColor),
            SizedBox(width: style.iconSpacing),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: style.fontSize,
              fontWeight: style.fontWeight,
              color: style.textColor,
              height: 1.2,
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: tagContent);
    }

    return tagContent;
  }

  _TagStyle _getTagStyle() {
    switch (variant) {
      case AuraTagVariant.mood:
        return _TagStyle(
          backgroundColor: backgroundColor ?? AppColors.warmGray100,
          textColor: textColor ?? AppColors.warmGray600,
          borderRadius: AppRadius.chip,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          fontSize: 12,
          fontWeight: FontWeight.w500,
          iconSize: 14,
          iconSpacing: 4,
        );
      case AuraTagVariant.time:
        return _TagStyle(
          backgroundColor: AppColors.warmGray100,
          textColor: AppColors.warmGray600,
          borderRadius: 8,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          fontSize: 12,
          fontWeight: FontWeight.w400,
          iconSize: 12,
          iconSpacing: 4,
        );
      case AuraTagVariant.type:
        return _TagStyle(
          backgroundColor: Colors.transparent,
          textColor: AppColors.warmGray600,
          borderRadius: AppRadius.full,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          fontSize: 11,
          fontWeight: FontWeight.w500,
          iconSize: 12,
          iconSpacing: 4,
          border: Border.all(color: AppColors.warmGray300, width: 1),
        );
      case AuraTagVariant.normal:
        return _TagStyle(
          backgroundColor: backgroundColor ?? AppColors.warmGray100,
          textColor: textColor ?? AppColors.warmGray600,
          borderRadius: AppRadius.sm,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          fontSize: 12,
          fontWeight: FontWeight.w400,
          iconSize: 14,
          iconSpacing: 4,
        );
    }
  }
}

class _TagStyle {
  final Color backgroundColor;
  final Color textColor;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final double fontSize;
  final FontWeight fontWeight;
  final double iconSize;
  final double iconSpacing;
  final Border? border;

  const _TagStyle({
    required this.backgroundColor,
    required this.textColor,
    required this.borderRadius,
    required this.padding,
    required this.fontSize,
    required this.fontWeight,
    required this.iconSize,
    required this.iconSpacing,
    this.border,
  });
}

/// 情绪标签（带颜色）
class AuraMoodTag extends StatelessWidget {
  final String text;
  final AuraMoodTagType mood;
  final VoidCallback? onTap;

  const AuraMoodTag({
    super.key,
    required this.text,
    required this.mood,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _getMoodColors();

    Widget tag = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(AppRadius.chip),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: colors.foreground,
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: tag);
    }

    return tag;
  }

  _MoodColors _getMoodColors() {
    switch (mood) {
      case AuraMoodTagType.calm:
        return _MoodColors(
          background: AppColors.calmBlueLight,
          foreground: AppColors.calmBlueDeep,
        );
      case AuraMoodTagType.warm:
        return _MoodColors(
          background: AppColors.warmPeachLight,
          foreground: AppColors.warmPeachDeep,
        );
      case AuraMoodTagType.peaceful:
        return _MoodColors(
          background: AppColors.softGreenLight,
          foreground: AppColors.softGreenDeep,
        );
      case AuraMoodTagType.nostalgic:
        return _MoodColors(
          background: AppColors.mutedVioletLight,
          foreground: AppColors.mutedVioletDeep,
        );
      case AuraMoodTagType.joyful:
        return _MoodColors(
          background: AppColors.warmOrangeLight,
          foreground: AppColors.warmOrangeDeep,
        );
    }
  }
}

enum AuraMoodTagType { calm, warm, peaceful, nostalgic, joyful }

class _MoodColors {
  final Color background;
  final Color foreground;

  const _MoodColors({required this.background, required this.foreground});
}

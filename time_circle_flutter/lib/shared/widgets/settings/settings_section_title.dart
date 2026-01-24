import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

/// 设置页面的普通分组标题
class SettingsSectionTitle extends StatelessWidget {
  final String title;
  final String? subtitle;
  final EdgeInsetsGeometry? padding;

  const SettingsSectionTitle({
    super.key,
    required this.title,
    this.subtitle,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.subtitle(context).copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.warmGray700,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: AppTypography.caption(
                context,
              ).copyWith(color: AppColors.warmGray400),
            ),
          ],
        ],
      ),
    );
  }
}

/// 带彩色指示条的分组标题
class SettingsGroupHeader extends StatelessWidget {
  final String title;
  final Color indicatorColor;
  final EdgeInsetsGeometry? padding;

  const SettingsGroupHeader({
    super.key,
    required this.title,
    required this.indicatorColor,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.only(left: 4, bottom: 12),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 14,
            decoration: BoxDecoration(
              color: indicatorColor.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: AppTypography.caption(context).copyWith(
              color: AppColors.warmGray500,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

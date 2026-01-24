import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

/// 设置页面的信息列表
class SettingsInfoList extends StatelessWidget {
  final String? title;
  final List<SettingsInfoItem> items;
  final EdgeInsetsGeometry? padding;

  const SettingsInfoList({
    super.key,
    this.title,
    required this.items,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Text(
            title!,
            style: AppTypography.caption(context).copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.warmGray500,
            ),
          ),
          const SizedBox(height: 12),
        ],
        ...items.map(
          (item) => Padding(
            padding: padding ?? const EdgeInsets.only(bottom: 8),
            child: item,
          ),
        ),
      ],
    );
  }
}

/// 信息列表中的单项
class SettingsInfoItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final String? boldPrefix;
  final Color? iconColor;

  const SettingsInfoItem({
    super.key,
    required this.icon,
    required this.text,
    this.boldPrefix,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: iconColor ?? AppColors.warmGray400),
        const SizedBox(width: 8),
        Expanded(
          child:
              boldPrefix != null
                  ? RichText(
                    text: TextSpan(
                      style: AppTypography.caption(
                        context,
                      ).copyWith(color: AppColors.warmGray500),
                      children: [
                        TextSpan(
                          text: '$boldPrefix：',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        TextSpan(text: text),
                      ],
                    ),
                  )
                  : Text(
                    text,
                    style: AppTypography.caption(
                      context,
                    ).copyWith(color: AppColors.warmGray500),
                  ),
        ),
      ],
    );
  }
}

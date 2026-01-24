import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

/// 设置页面统一的卡片容器
class SettingsCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const SettingsCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.warmGray100),
      ),
      child: child,
    );
  }
}

/// 带分隔线的设置列表区域
class SettingsListSection extends StatelessWidget {
  final List<Widget> children;
  final double dividerIndent;

  const SettingsListSection({
    super.key,
    required this.children,
    this.dividerIndent = 56,
  });

  @override
  Widget build(BuildContext context) {
    return SettingsCard(
      child: Column(
        children:
            children.asMap().entries.map((entry) {
              final index = entry.key;
              final child = entry.value;
              final isLast = index == children.length - 1;

              return Column(
                children: [
                  child,
                  if (!isLast)
                    Padding(
                      padding: EdgeInsets.only(left: dividerIndent),
                      child: Container(height: 1, color: AppColors.warmGray100),
                    ),
                ],
              );
            }).toList(),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

/// 品牌橙色
const Color _brandOrange = Color(0xFFE8A87C);

/// 设置页面的单选指示器
class SettingsRadioIndicator extends StatelessWidget {
  final bool isSelected;
  final Color? activeColor;

  const SettingsRadioIndicator({
    super.key,
    required this.isSelected,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    if (isSelected) {
      return Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: activeColor ?? _brandOrange,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.check, size: 16, color: AppColors.white),
      );
    }

    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.warmGray300, width: 2),
      ),
    );
  }
}

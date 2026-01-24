import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

/// 提示框样式
enum HintBoxStyle {
  /// 信息提示 - 蓝色
  info,

  /// 成功提示 - 绿色
  success,

  /// 警告提示 - 橙色
  warning,

  /// 中性提示 - 灰色
  neutral,

  /// 紫色提示
  purple,
}

/// 设置页面的提示框组件
class SettingsHintBox extends StatelessWidget {
  final IconData icon;
  final String message;
  final Color? customColor;
  final HintBoxStyle style;
  final Widget? action;

  const SettingsHintBox({
    super.key,
    required this.icon,
    required this.message,
    this.customColor,
    this.style = HintBoxStyle.info,
    this.action,
  });

  Color get _color {
    if (customColor != null) return customColor!;
    switch (style) {
      case HintBoxStyle.info:
        return const Color(0xFF5A8AB8); // 蓝色
      case HintBoxStyle.success:
        return AppColors.softGreenDeep; // 绿色
      case HintBoxStyle.warning:
        return const Color(0xFFE8A87C); // 橙色
      case HintBoxStyle.neutral:
        return AppColors.warmGray500; // 灰色
      case HintBoxStyle.purple:
        return const Color(0xFF8B7A9C); // 紫色
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: _color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: AppTypography.caption(
                context,
              ).copyWith(color: _color.withValues(alpha: 0.9)),
            ),
          ),
          if (action != null) ...[const SizedBox(width: 8), action!],
        ],
      ),
    );
  }
}

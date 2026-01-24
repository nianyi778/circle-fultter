import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../core/theme/app_theme.dart';

/// 统一的 SnackBar 组件
///
/// 提供多种预设样式：
/// - [showMomentSaved] - 记录保存成功（温暖文案）
/// - [showSuccess] - 通用成功提示
/// - [showError] - 错误提示
/// - [showInfo] - 信息提示
class AppSnackBar {
  AppSnackBar._();

  /// 记录保存成功 - 温暖文案
  static void showMomentSaved(BuildContext context) {
    _show(
      context,
      message: '这一刻，已经被你留住了。',
      icon: Icons.check_rounded,
      iconBackgroundColor: AppColors.softGreenDeep.withValues(alpha: 0.15),
      iconColor: AppColors.softGreenDeep,
    );
  }

  /// 信件保存成功
  static void showLetterSaved(BuildContext context) {
    _show(
      context,
      message: '这一刻，已经被你留住了。',
      icon: Icons.check_rounded,
      iconBackgroundColor: AppColors.softGreenDeep.withValues(alpha: 0.15),
      iconColor: AppColors.softGreenDeep,
    );
  }

  /// 通用成功提示
  static void showSuccess(BuildContext context, String message) {
    _show(
      context,
      message: message,
      icon: Icons.check_rounded,
      iconBackgroundColor: AppColors.softGreenDeep.withValues(alpha: 0.15),
      iconColor: AppColors.softGreenDeep,
    );
  }

  /// 错误提示
  static void showError(BuildContext context, String message) {
    _show(
      context,
      message: message,
      icon: Iconsax.warning_2,
      iconBackgroundColor: AppColors.dangerDark.withValues(alpha: 0.15),
      iconColor: AppColors.dangerDark,
      backgroundColor: AppColors.warmGray800,
    );
  }

  /// 信息提示
  static void showInfo(BuildContext context, String message) {
    _show(
      context,
      message: message,
      icon: Iconsax.info_circle,
      iconBackgroundColor: const Color(0xFF5A8AB8).withValues(alpha: 0.15),
      iconColor: const Color(0xFF5A8AB8),
    );
  }

  /// 警告提示
  static void showWarning(BuildContext context, String message) {
    _show(
      context,
      message: message,
      icon: Iconsax.warning_2,
      iconBackgroundColor: const Color(0xFFE8A87C).withValues(alpha: 0.15),
      iconColor: const Color(0xFFE8A87C),
    );
  }

  /// 内部统一显示方法
  static void _show(
    BuildContext context, {
    required String message,
    required IconData icon,
    required Color iconBackgroundColor,
    required Color iconColor,
    Color? backgroundColor,
    Duration duration = const Duration(seconds: 2),
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            // 图标容器 - 使用 Center 确保图标完美居中
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: iconBackgroundColor,
                shape: BoxShape.circle,
              ),
              child: Center(child: Icon(icon, size: 16, color: iconColor)),
            ),
            const SizedBox(width: 12),
            // 文字 - 使用 Expanded 防止溢出
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor ?? AppColors.warmGray800,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        duration: duration,
        elevation: 6,
      ),
    );
  }
}

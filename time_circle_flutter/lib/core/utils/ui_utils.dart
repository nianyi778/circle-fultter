import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../theme/app_theme.dart';
import '../../shared/widgets/aura/aura_toast.dart';
import '../../shared/widgets/aura/aura_dialog.dart';

/// 通用 UI 组件
/// 统一常用的 UI 模式，减少代码重复

/// 空状态组件
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onAction;
  final String? actionText;

  const EmptyState({
    super.key,
    this.icon = Iconsax.magic_star,
    required this.title,
    this.subtitle,
    this.onAction,
    this.actionText,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: AppColors.warmGray100,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.warmGray300, size: 28),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.warmGray500,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 12),
              Text(
                subtitle!,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.warmGray400),
                textAlign: TextAlign.center,
              ),
            ],
            if (onAction != null && actionText != null) ...[
              const SizedBox(height: 16),
              GestureDetector(
                onTap: onAction,
                child: Text(
                  actionText!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.warmGray400,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 确认对话框（现使用 AuraDialog）
class ConfirmDialog extends StatelessWidget {
  final String title;
  final String? content;
  final String confirmText;
  final String cancelText;
  final Color? confirmColor;
  final VoidCallback onConfirm;

  const ConfirmDialog({
    super.key,
    required this.title,
    this.content,
    this.confirmText = '确定',
    this.cancelText = '取消',
    this.confirmColor,
    required this.onConfirm,
  });

  /// 显示确认对话框
  static Future<bool?> show({
    required BuildContext context,
    required String title,
    String? content,
    String confirmText = '确定',
    String cancelText = '取消',
    Color? confirmColor,
  }) {
    // 判断是否是删除/危险操作
    final isDanger =
        confirmColor == Colors.red ||
        confirmText.contains('删除') ||
        confirmText.contains('移除');

    return AuraDialog.show(
      context,
      title: title,
      message: content,
      confirmText: confirmText,
      cancelText: cancelText,
      isDanger: isDanger,
    );
  }

  @override
  Widget build(BuildContext context) {
    // 判断是否是删除/危险操作
    final isDanger =
        confirmColor == Colors.red ||
        confirmText.contains('删除') ||
        confirmText.contains('移除');

    return AuraDialog(
      title: title,
      message: content,
      confirmText: confirmText,
      cancelText: cancelText,
      isDanger: isDanger,
      onConfirm: () {
        Navigator.pop(context, true);
        onConfirm();
      },
      onCancel: () => Navigator.pop(context, false),
    );
  }
}

/// Toast 工具类（原 SnackBar，现使用 AuraToast）
class AppSnackBar {
  AppSnackBar._();

  /// 显示成功提示
  static void showSuccess(BuildContext context, String message) {
    AuraToast.success(context, message);
  }

  /// 显示错误提示
  static void showError(BuildContext context, String message) {
    AuraToast.error(context, message);
  }

  /// 显示普通提示
  static void showInfo(BuildContext context, String message, {IconData? icon}) {
    AuraToast.show(
      context,
      message: message,
      type: AuraToastType.info,
      icon: icon,
    );
  }
}

/// 虚线边框绘制器
class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double radius;
  final double dashWidth;
  final double dashSpace;

  DashedBorderPainter({
    required this.color,
    this.strokeWidth = 1.5,
    this.radius = 16,
    this.dashWidth = 6,
    this.dashSpace = 4,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..strokeWidth = strokeWidth
          ..style = PaintingStyle.stroke;

    final path =
        Path()..addRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(0, 0, size.width, size.height),
            Radius.circular(radius),
          ),
        );

    // 绘制虚线
    final dashPath = Path();
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        dashPath.addPath(
          metric.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth + dashSpace;
      }
    }

    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant DashedBorderPainter oldDelegate) {
    return color != oldDelegate.color ||
        strokeWidth != oldDelegate.strokeWidth ||
        radius != oldDelegate.radius;
  }
}

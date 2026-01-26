import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';
import 'aura_button.dart';

/// Aura 对话框组件
///
/// 设计原则：
/// - 温和的确认语气
/// - 按钮垂直排列（移动端友好）
/// - 主按钮在上
class AuraDialog extends StatelessWidget {
  final String title;
  final String? message;
  final Widget? content;
  final String confirmText;
  final String? cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final bool isDanger;

  const AuraDialog({
    super.key,
    required this.title,
    this.message,
    this.content,
    this.confirmText = '确定',
    this.cancelText,
    this.onConfirm,
    this.onCancel,
    this.isDanger = false,
  });

  /// 显示对话框
  static Future<bool?> show(
    BuildContext context, {
    required String title,
    String? message,
    Widget? content,
    String confirmText = '确定',
    String? cancelText = '取消',
    bool isDanger = false,
  }) {
    return showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black.withValues(alpha: 0.4),
      transitionDuration: AppDurations.normal,
      pageBuilder: (context, animation, secondaryAnimation) {
        return AuraDialog(
          title: title,
          message: message,
          content: content,
          confirmText: confirmText,
          cancelText: cancelText,
          isDanger: isDanger,
          onConfirm: () => Navigator.of(context).pop(true),
          onCancel: () => Navigator.of(context).pop(false),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final scaleAnimation = Tween<double>(
          begin: 0.95,
          end: 1.0,
        ).animate(CurvedAnimation(parent: animation, curve: AppCurves.enter));
        final fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(parent: animation, curve: AppCurves.standard),
        );

        return FadeTransition(
          opacity: fadeAnimation,
          child: ScaleTransition(scale: scaleAnimation, child: child),
        );
      },
    );
  }

  /// 显示确认删除对话框
  static Future<bool?> showDelete(
    BuildContext context, {
    required String title,
    String? message,
  }) {
    return show(
      context,
      title: title,
      message: message ?? '删除后无法恢复，但记忆永远在心里',
      confirmText: '删除',
      cancelText: '取消',
      isDanger: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 320),
        margin: const EdgeInsets.symmetric(horizontal: 40),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          boxShadow: AppShadows.elevated,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 标题
            Text(
              title,
              style: AppTypography.subtitle(context).copyWith(fontSize: 18),
              textAlign: TextAlign.center,
            ),

            // 消息
            if (message != null) ...[
              const SizedBox(height: 12),
              Text(
                message!,
                style: AppTypography.body(
                  context,
                ).copyWith(color: AppColors.warmGray500, height: 1.5),
                textAlign: TextAlign.center,
              ),
            ],

            // 自定义内容
            if (content != null) ...[const SizedBox(height: 16), content!],

            const SizedBox(height: 24),

            // 按钮区域
            Column(
              children: [
                // 主按钮
                SizedBox(
                  width: double.infinity,
                  child:
                      isDanger
                          ? AuraButton.danger(
                            text: confirmText,
                            onPressed: () {
                              HapticFeedback.mediumImpact();
                              onConfirm?.call();
                            },
                          )
                          : AuraButton.primary(
                            text: confirmText,
                            onPressed: onConfirm,
                          ),
                ),

                // 取消按钮
                if (cancelText != null) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: AuraButton.ghost(
                      text: cancelText!,
                      onPressed: onCancel,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import 'aura/aura_toast.dart';

/// 统一的 Toast 组件（原 SnackBar，现已迁移至 AuraToast）
///
/// 提供多种预设样式：
/// - [showMomentSaved] - 记录保存成功（温暖文案）
/// - [showSuccess] - 通用成功提示
/// - [showError] - 错误提示
/// - [showInfo] - 信息提示
///
/// 注意：此类现在是 AuraToast 的包装器，保持向后兼容
class AppSnackBar {
  AppSnackBar._();

  /// 记录保存成功 - 温暖文案
  static void showMomentSaved(BuildContext context) {
    AuraToast.show(
      context,
      message: '这一刻，已经被你留住了。',
      type: AuraToastType.success,
    );
  }

  /// 信件保存成功
  static void showLetterSaved(BuildContext context) {
    AuraToast.show(
      context,
      message: '这一刻，已经被你留住了。',
      type: AuraToastType.success,
    );
  }

  /// 通用成功提示
  static void showSuccess(BuildContext context, String message) {
    AuraToast.success(context, message);
  }

  /// 错误提示
  static void showError(BuildContext context, String message) {
    AuraToast.error(context, message);
  }

  /// 信息提示
  static void showInfo(BuildContext context, String message) {
    AuraToast.show(context, message: message, type: AuraToastType.info);
  }

  /// 警告提示
  static void showWarning(BuildContext context, String message) {
    AuraToast.warning(context, message);
  }
}

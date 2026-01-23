import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// 输入框样式类型
enum AppTextFieldStyle {
  /// 灰色背景 + 大圆角（用于评论、搜索等）
  filled,

  /// 透明背景 + 无边框（用于发布页、信件编辑等）
  transparent,
}

/// 统一的单行输入框组件
///
/// 参考 Web 版本设计：
/// - 灰色背景 (stone-100)
/// - 大圆角 (rounded-2xl = 16px)
/// - 无边框
/// - 柔和的占位符颜色
class AppTextField extends StatelessWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextInputAction? textInputAction;
  final bool autofocus;
  final bool enabled;
  final int? maxLength;
  final AppTextFieldStyle style;

  /// 前缀组件（如回复标签）
  final Widget? prefix;

  /// 后缀组件（如发送按钮）
  final Widget? suffix;

  const AppTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.hintText,
    this.onChanged,
    this.onSubmitted,
    this.textInputAction,
    this.autofocus = false,
    this.enabled = true,
    this.maxLength,
    this.style = AppTextFieldStyle.filled,
    this.prefix,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    final isFilled = style == AppTextFieldStyle.filled;

    return Container(
      padding:
          isFilled
              ? const EdgeInsets.symmetric(horizontal: 16, vertical: 10)
              : EdgeInsets.zero,
      decoration:
          isFilled
              ? BoxDecoration(
                color: AppColors.warmGray100,
                borderRadius: BorderRadius.circular(20),
              )
              : null,
      child: Row(
        children: [
          if (prefix != null) ...[prefix!, const SizedBox(width: 8)],
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              autofocus: autofocus,
              enabled: enabled,
              maxLength: maxLength,
              textInputAction: textInputAction,
              onChanged: onChanged,
              onSubmitted: onSubmitted,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.warmGray800),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppColors.warmGray400),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
                counterText: '', // 隐藏字数统计
              ),
            ),
          ),
          if (suffix != null) ...[const SizedBox(width: 8), suffix!],
        ],
      ),
    );
  }
}

/// 统一的多行文本区域组件
///
/// 用于发布内容、信件编辑等场景
/// 默认透明背景，大字体，书写感强
class AppTextArea extends StatelessWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? hintText;
  final ValueChanged<String>? onChanged;
  final bool autofocus;
  final bool enabled;
  final int minLines;
  final int maxLines;
  final int? maxLength;
  final AppTextFieldStyle style;

  /// 字体大小（默认 18）
  final double fontSize;

  /// 行高（默认 1.8）
  final double lineHeight;

  const AppTextArea({
    super.key,
    this.controller,
    this.focusNode,
    this.hintText,
    this.onChanged,
    this.autofocus = false,
    this.enabled = true,
    this.minLines = 4,
    this.maxLines = 10,
    this.maxLength,
    this.style = AppTextFieldStyle.transparent,
    this.fontSize = 18,
    this.lineHeight = 1.8,
  });

  @override
  Widget build(BuildContext context) {
    final isFilled = style == AppTextFieldStyle.filled;

    return Container(
      padding: isFilled ? const EdgeInsets.all(16) : EdgeInsets.zero,
      decoration:
          isFilled
              ? BoxDecoration(
                color: AppColors.warmGray100,
                borderRadius: BorderRadius.circular(16),
              )
              : null,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        autofocus: autofocus,
        enabled: enabled,
        maxLength: maxLength,
        minLines: minLines,
        maxLines: maxLines,
        onChanged: onChanged,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontSize: fontSize,
          height: lineHeight,
          color: AppColors.warmGray800,
          letterSpacing: 0.3,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontSize: fontSize,
            height: lineHeight,
            color: AppColors.warmGray300,
            letterSpacing: 0.3,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.zero,
          counterText: '', // 隐藏字数统计
        ),
      ),
    );
  }
}

/// 回复目标标签组件
///
/// 用于评论输入框中显示 "回复 xxx" 标签
class ReplyTargetTag extends StatelessWidget {
  final String name;
  final VoidCallback onCancel;

  const ReplyTargetTag({super.key, required this.name, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onCancel,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.warmGray200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '回复 $name',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.warmGray600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.close, size: 14, color: AppColors.warmGray400),
          ],
        ),
      ),
    );
  }
}

/// 发送按钮组件
///
/// 有内容时显示红色圆形发送按钮，否则显示 @ 或表情按钮
class SendButton extends StatelessWidget {
  final bool hasContent;
  final VoidCallback onSend;
  final VoidCallback? onAtPressed;

  const SendButton({
    super.key,
    required this.hasContent,
    required this.onSend,
    this.onAtPressed,
  });

  @override
  Widget build(BuildContext context) {
    if (hasContent) {
      return GestureDetector(
        onTap: onSend,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.warmPeach,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.send_rounded, size: 16, color: Colors.white),
        ),
      );
    }

    // 无内容时显示 @ 按钮
    return GestureDetector(
      onTap: onAtPressed,
      child: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        child: Text(
          '@',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: AppColors.warmGray600,
          ),
        ),
      ),
    );
  }
}

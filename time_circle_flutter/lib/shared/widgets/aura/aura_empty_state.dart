import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Aura 空状态组件
///
/// 设计原则：
/// - 温暖的文案，不责备
/// - 柔和的视觉
/// - 可选的操作引导
class AuraEmptyState extends StatelessWidget {
  final IconData? icon;
  final Widget? illustration;
  final String title;
  final String? description;
  final Widget? action;

  const AuraEmptyState({
    super.key,
    this.icon,
    this.illustration,
    required this.title,
    this.description,
    this.action,
  });

  /// 时间线空状态
  factory AuraEmptyState.timeline({VoidCallback? onAction}) {
    return AuraEmptyState(
      icon: Icons.auto_stories_outlined,
      title: '这里会慢慢被时间填满',
      description: '每一刻的记录，都是给未来的礼物',
      action:
          onAction != null
              ? _ActionButton(text: '留下第一刻', onPressed: onAction)
              : null,
    );
  }

  /// 搜索无结果
  factory AuraEmptyState.noResults({String? keyword}) {
    return AuraEmptyState(
      icon: Icons.search_off_rounded,
      title: '没有找到相关回忆',
      description: keyword != null ? '换个关键词试试？' : '试着搜索其他内容',
    );
  }

  /// 信件空状态
  factory AuraEmptyState.letters({VoidCallback? onAction}) {
    return AuraEmptyState(
      icon: Icons.mail_outline_rounded,
      title: '还没有信件',
      description: '写一封给未来的信吧',
      action:
          onAction != null
              ? _ActionButton(text: '开始写信', onPressed: onAction)
              : null,
    );
  }

  /// 评论空状态
  factory AuraEmptyState.comments() {
    return const AuraEmptyState(
      icon: Icons.chat_bubble_outline_rounded,
      title: '还没有人回应',
      description: '留下你的想法吧',
    );
  }

  /// 网络错误
  factory AuraEmptyState.networkError({VoidCallback? onRetry}) {
    return AuraEmptyState(
      icon: Icons.cloud_off_rounded,
      title: '网络不太顺畅',
      description: '检查一下网络，稍后再试',
      action:
          onRetry != null
              ? _ActionButton(text: '重试', onPressed: onRetry)
              : null,
    );
  }

  /// 通用错误
  factory AuraEmptyState.error({String? message, VoidCallback? onRetry}) {
    return AuraEmptyState(
      icon: Icons.error_outline_rounded,
      title: '出了点小问题',
      description: message ?? '请稍后再试',
      action:
          onRetry != null
              ? _ActionButton(text: '重试', onPressed: onRetry)
              : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xxl,
          vertical: AppSpacing.xxxl,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 图标或插画
            if (illustration != null)
              illustration!
            else if (icon != null)
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.warmGray100,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 36, color: AppColors.warmGray300),
              ),

            const SizedBox(height: 20),

            // 标题
            Text(
              title,
              style: AppTypography.subtitle(
                context,
              ).copyWith(color: AppColors.warmGray600),
              textAlign: TextAlign.center,
            ),

            // 描述
            if (description != null) ...[
              const SizedBox(height: 8),
              Text(
                description!,
                style: AppTypography.body(
                  context,
                ).copyWith(color: AppColors.warmGray400),
                textAlign: TextAlign.center,
              ),
            ],

            // 操作按钮
            if (action != null) ...[const SizedBox(height: 24), action!],
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const _ActionButton({required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.warmGray800,
          borderRadius: BorderRadius.circular(AppRadius.button),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.white,
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';

import '../../core/theme/app_theme.dart';

/// 空状态组件 - 温柔诗意的空白提示
/// 设计原则：空状态不是错误，而是一种可能性的开始
class EmptyState extends StatelessWidget {
  /// 图标
  final IconData? icon;

  /// 主标题（诗意的表达）
  final String title;

  /// 副标题（可选的引导）
  final String? subtitle;

  /// 行动按钮文案
  final String? actionLabel;

  /// 行动按钮回调
  final VoidCallback? onAction;

  /// 变体类型
  final EmptyStateVariant variant;

  const EmptyState({
    super.key,
    this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.variant = EmptyStateVariant.normal,
  });

  /// 时间线为空
  factory EmptyState.timeline({VoidCallback? onAction}) => EmptyState(
    icon: Iconsax.clock,
    title: '时光正在等待被记录',
    subtitle: '每一个平凡的瞬间，都值得被留住',
    actionLabel: '留下第一刻',
    onAction: onAction,
    variant: EmptyStateVariant.gentle,
  );

  /// 搜索无结果
  factory EmptyState.noResults({String? keyword}) => EmptyState(
    icon: Iconsax.search_normal,
    title: '没有找到匹配的记忆',
    subtitle: keyword != null ? '换个关键词试试？' : null,
    variant: EmptyStateVariant.subtle,
  );

  /// 年度信为空
  factory EmptyState.noLetters() => const EmptyState(
    icon: Iconsax.sms,
    title: '给未来的信，正在路上',
    subtitle: '时间到了，它们会自动出现',
    variant: EmptyStateVariant.gentle,
  );

  /// 收藏为空
  factory EmptyState.noFavorites() => const EmptyState(
    icon: Iconsax.heart,
    title: '还没有特别想收藏的时刻',
    subtitle: '点击心形图标，珍藏那些共鸣的瞬间',
    variant: EmptyStateVariant.subtle,
  );

  /// 评论为空
  factory EmptyState.noComments() => const EmptyState(
    icon: Iconsax.message,
    title: '安静的空间',
    subtitle: '第一个留下想法吧',
    variant: EmptyStateVariant.minimal,
  );

  /// 网络错误
  factory EmptyState.networkError({VoidCallback? onRetry}) => EmptyState(
    icon: Iconsax.wifi_square,
    title: '网络好像不太稳定',
    subtitle: '检查一下连接，再试试？',
    actionLabel: '重新加载',
    onAction: onRetry,
    variant: EmptyStateVariant.subtle,
  );

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 图标
            if (icon != null) ...[_buildIcon(), const SizedBox(height: 24)],

            // 主标题
            Text(
              title,
              style: _getTitleStyle(context),
              textAlign: TextAlign.center,
            ),

            // 副标题
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: AppTypography.caption(
                  context,
                ).copyWith(color: AppColors.warmGray400),
                textAlign: TextAlign.center,
              ),
            ],

            // 行动按钮
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 28),
              _buildActionButton(context),
            ],

            // 底部留白
            const SizedBox(height: 48),
          ],
        ),
      ),
    ).animate().fadeIn(duration: AppDurations.slow, curve: AppCurves.enter);
  }

  Widget _buildIcon() {
    final size = variant == EmptyStateVariant.minimal ? 48.0 : 64.0;
    final iconSize = variant == EmptyStateVariant.minimal ? 24.0 : 28.0;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _getIconBackgroundColor(),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: iconSize, color: _getIconColor()),
    );
  }

  Color _getIconBackgroundColor() {
    switch (variant) {
      case EmptyStateVariant.gentle:
        return AppColors.warmPeachLight;
      case EmptyStateVariant.subtle:
      case EmptyStateVariant.minimal:
        return AppColors.warmGray100;
      case EmptyStateVariant.normal:
        return AppColors.warmGray100;
    }
  }

  Color _getIconColor() {
    switch (variant) {
      case EmptyStateVariant.gentle:
        return AppColors.warmPeachDeep;
      case EmptyStateVariant.subtle:
      case EmptyStateVariant.minimal:
        return AppColors.warmGray300;
      case EmptyStateVariant.normal:
        return AppColors.warmGray400;
    }
  }

  TextStyle _getTitleStyle(BuildContext context) {
    switch (variant) {
      case EmptyStateVariant.gentle:
        return AppTypography.body(
          context,
        ).copyWith(color: AppColors.warmGray600, fontSize: 16);
      case EmptyStateVariant.minimal:
        return AppTypography.body(
          context,
        ).copyWith(color: AppColors.warmGray400, fontSize: 14);
      case EmptyStateVariant.subtle:
      case EmptyStateVariant.normal:
        return AppTypography.body(
          context,
        ).copyWith(color: AppColors.warmGray500);
    }
  }

  Widget _buildActionButton(BuildContext context) {
    return GestureDetector(
      onTap: onAction,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.warmGray800,
          borderRadius: BorderRadius.circular(AppRadius.full),
          boxShadow: AppShadows.subtle,
        ),
        child: Text(
          actionLabel!,
          style: AppTypography.caption(
            context,
          ).copyWith(color: AppColors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

/// 空状态变体
enum EmptyStateVariant {
  /// 普通 - 标准空状态
  normal,

  /// 温柔 - 更柔和的视觉，用于重要场景
  gentle,

  /// 微妙 - 更低调，不抢注意力
  subtle,

  /// 极简 - 最小化表达
  minimal,
}

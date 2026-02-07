// Aura Empty State 空状态组件
//
// 提供优雅的空状态展示
// 符合 Aura 设计系统的温和文案风格

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/animations/animation_config.dart';

/// 空状态类型
enum EmptyStateType {
  /// 通用空状态
  generic,

  /// 无记录
  noMoments,

  /// 搜索无结果
  noSearchResults,

  /// 无信件
  noLetters,

  /// 去年今天无内容
  noMemoryToday,

  /// 无评论
  noComments,

  /// 无通知
  noNotifications,
}

/// Aura Empty State
///
/// 使用示例:
/// ```dart
/// // 使用预设类型
/// AuraEmptyState.noMoments()
///
/// // 自定义内容
/// AuraEmptyState(
///   title: '还没有数据',
///   description: '数据会慢慢出现的',
///   icon: Icons.inbox_outlined,
/// )
///
/// // 带操作按钮
/// AuraEmptyState(
///   title: '还没有记录',
///   description: '留下第一个瞬间吧',
///   action: TextButton(
///     onPressed: () {},
///     child: Text('开始记录'),
///   ),
/// )
/// ```
class AuraEmptyState extends StatelessWidget {
  /// 标题
  final String title;

  /// 描述文字
  final String? description;

  /// 图标
  final IconData? icon;

  /// 自定义图标组件
  final Widget? iconWidget;

  /// 操作按钮
  final Widget? action;

  /// 空状态类型
  final EmptyStateType type;

  /// 是否显示入场动画
  final bool animate;

  /// 图标大小
  final double iconSize;

  /// 图标颜色
  final Color? iconColor;

  const AuraEmptyState({
    super.key,
    required this.title,
    this.description,
    this.icon,
    this.iconWidget,
    this.action,
    this.type = EmptyStateType.generic,
    this.animate = true,
    this.iconSize = 64,
    this.iconColor,
  });

  /// 首页无记录
  const AuraEmptyState.noMoments({super.key, this.action})
    : title = '这里会慢慢被时间填满',
      description = '记录第一个瞬间吧',
      icon = Iconsax.clock,
      iconWidget = null,
      type = EmptyStateType.noMoments,
      animate = true,
      iconSize = 64,
      iconColor = null;

  /// 搜索无结果
  const AuraEmptyState.noSearchResults({super.key, this.action})
    : title = '没有找到相关记忆',
      description = '试试其他关键词',
      icon = Iconsax.search_status,
      iconWidget = null,
      type = EmptyStateType.noSearchResults,
      animate = true,
      iconSize = 64,
      iconColor = null;

  /// 信件箱空
  const AuraEmptyState.noLetters({super.key, this.action})
    : title = '还没有信件',
      description = '写一封给未来的信吧',
      icon = Iconsax.sms,
      iconWidget = null,
      type = EmptyStateType.noLetters,
      animate = true,
      iconSize = 64,
      iconColor = null;

  /// 去年今天无内容
  const AuraEmptyState.noMemoryToday({super.key, this.action})
    : title = '去年的今天，你还没有记录',
      description = '等明年，它会出现的',
      icon = Iconsax.calendar_1,
      iconWidget = null,
      type = EmptyStateType.noMemoryToday,
      animate = true,
      iconSize = 64,
      iconColor = null;

  /// 无评论
  const AuraEmptyState.noComments({super.key, this.action})
    : title = '还没有评论',
      description = '留下你的想法',
      icon = Iconsax.message,
      iconWidget = null,
      type = EmptyStateType.noComments,
      animate = true,
      iconSize = 56,
      iconColor = null;

  /// 无通知
  const AuraEmptyState.noNotifications({super.key, this.action})
    : title = '暂无新消息',
      description = '一切安好',
      icon = Iconsax.notification,
      iconWidget = null,
      type = EmptyStateType.noNotifications,
      animate = true,
      iconSize = 64,
      iconColor = null;

  @override
  Widget build(BuildContext context) {
    Widget content = Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 图标
            _buildIcon(),
            const SizedBox(height: AppSpacing.lg),

            // 标题
            Text(
              title,
              style: AppTypography.subtitle(
                context,
              ).copyWith(color: AppColors.warmGray700),
              textAlign: TextAlign.center,
            ),

            // 描述
            if (description != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                description!,
                style: AppTypography.body(
                  context,
                ).copyWith(color: AppColors.warmGray500),
                textAlign: TextAlign.center,
              ),
            ],

            // 操作按钮
            if (action != null) ...[
              const SizedBox(height: AppSpacing.xl),
              action!,
            ],
          ],
        ),
      ),
    );

    if (animate) {
      content = content
          .animate()
          .fadeIn(duration: AuraDurations.slow, curve: AuraCurves.enter)
          .slideY(begin: 0.02, curve: AuraCurves.enter);
    }

    return content;
  }

  Widget _buildIcon() {
    if (iconWidget != null) {
      return iconWidget!;
    }

    final iconData = icon ?? _getDefaultIcon();
    final color = iconColor ?? AppColors.warmGray300;

    return Container(
      width: iconSize + 24,
      height: iconSize + 24,
      decoration: BoxDecoration(
        color: AppColors.warmGray100,
        shape: BoxShape.circle,
      ),
      child: Center(child: Icon(iconData, size: iconSize, color: color)),
    );
  }

  IconData _getDefaultIcon() {
    switch (type) {
      case EmptyStateType.noMoments:
        return Iconsax.clock;
      case EmptyStateType.noSearchResults:
        return Iconsax.search_status;
      case EmptyStateType.noLetters:
        return Iconsax.sms;
      case EmptyStateType.noMemoryToday:
        return Iconsax.calendar_1;
      case EmptyStateType.noComments:
        return Iconsax.message;
      case EmptyStateType.noNotifications:
        return Iconsax.notification;
      case EmptyStateType.generic:
        return Iconsax.box;
    }
  }
}

/// 简洁的内联空状态
///
/// 用于小区域的空状态提示
class AuraEmptyStateInline extends StatelessWidget {
  final String message;
  final IconData? icon;

  const AuraEmptyStateInline({super.key, required this.message, this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xl,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: AppColors.warmGray400),
            const SizedBox(width: AppSpacing.sm),
          ],
          Text(
            message,
            style: AppTypography.caption(
              context,
            ).copyWith(color: AppColors.warmGray500),
          ),
        ],
      ),
    );
  }
}

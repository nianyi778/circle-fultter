import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// 统一的弹出菜单组件
///
/// 设计理念：
/// - 白色背景 + 大圆角 + 柔和阴影
/// - 与 FeedCard 菜单风格保持一致
/// - 温柔、简洁的视觉效果
class AppPopupMenu extends StatelessWidget {
  final List<AppPopupMenuItem> items;
  final double width;

  const AppPopupMenu({super.key, required this.items, this.width = 160});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.elevated,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Column(mainAxisSize: MainAxisSize.min, children: items),
      ),
    );
  }
}

/// 弹出菜单项
///
/// 支持图标、文字、危险操作（红色）
class AppPopupMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const AppPopupMenuItem({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? AppColors.dangerDark : AppColors.warmGray700;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: AppTypography.body(
                  context,
                ).copyWith(color: color, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 显示弹出菜单的辅助函数
///
/// 在指定位置显示菜单，点击外部自动关闭
/// 返回用户选择的菜单项索引，取消返回 null
Future<int?> showAppPopupMenu({
  required BuildContext context,
  required RelativeRect position,
  required List<AppPopupMenuItemData> items,
  double width = 160,
}) async {
  return showMenu<int>(
    context: context,
    position: position,
    elevation: 0,
    color: Colors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.lg),
    ),
    items: [
      PopupMenuItem<int>(
        enabled: false,
        padding: EdgeInsets.zero,
        child: _AppPopupMenuContent(items: items, width: width),
      ),
    ],
  );
}

/// 菜单项数据
class AppPopupMenuItemData {
  final IconData icon;
  final String label;
  final bool isDestructive;
  final VoidCallback onTap;

  const AppPopupMenuItemData({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });
}

/// 内部使用的菜单内容组件
class _AppPopupMenuContent extends StatelessWidget {
  final List<AppPopupMenuItemData> items;
  final double width;

  const _AppPopupMenuContent({required this.items, required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.elevated,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children:
              items.asMap().entries.map((entry) {
                final item = entry.value;
                final color =
                    item.isDestructive
                        ? AppColors.dangerDark
                        : AppColors.warmGray700;

                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                    item.onTap();
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Row(
                      children: [
                        Icon(item.icon, size: 18, color: color),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            item.label,
                            style: AppTypography.body(context).copyWith(
                              color: color,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
        ),
      ),
    );
  }
}

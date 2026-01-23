import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../core/theme/app_theme.dart';

/// 详情页底部操作栏
class DetailActionBar extends StatelessWidget {
  final bool isFavorite;
  final VoidCallback? onFavoriteTap;
  final VoidCallback? onBookmarkTap;
  final VoidCallback? onMoreTap;

  const DetailActionBar({
    super.key,
    this.isFavorite = false,
    this.onFavoriteTap,
    this.onBookmarkTap,
    this.onMoreTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.pagePadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _ActionButton(
            icon: isFavorite ? Iconsax.heart5 : Iconsax.heart,
            label: '共鸣',
            isActive: isFavorite,
            activeColor: AppColors.heart,
            onTap: onFavoriteTap,
          ),
          const SizedBox(width: 32),
          _ActionButton(
            icon: Iconsax.bookmark,
            label: '收藏',
            onTap: onBookmarkTap,
          ),
          const SizedBox(width: 32),
          _ActionButton(icon: Iconsax.more, label: '更多', onTap: onMoreTap),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final Color? activeColor;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    this.isActive = false,
    this.activeColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        isActive
            ? (activeColor ?? AppColors.warmGray800)
            : AppColors.warmGray400;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../core/theme/app_theme.dart';

/// 详情页通用 AppBar
class DetailAppBar extends StatelessWidget {
  final bool floating;
  final bool pinned;
  final Color? backgroundColor;
  final VoidCallback? onMoreTap;
  final List<Widget>? extraActions;

  const DetailAppBar({
    super.key,
    this.floating = false,
    this.pinned = false,
    this.backgroundColor,
    this.onMoreTap,
    this.extraActions,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      backgroundColor: backgroundColor ?? Colors.transparent,
      elevation: 0,
      pinned: pinned,
      floating: floating,
      leading: IconButton(
        onPressed: () => context.pop(),
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.9),
            shape: BoxShape.circle,
            boxShadow: AppShadows.subtle,
          ),
          child: const Icon(
            Iconsax.arrow_left_2,
            size: 20,
            color: AppColors.warmGray700,
          ),
        ),
      ),
      actions: [
        if (extraActions != null) ...extraActions!,
        IconButton(
          onPressed: onMoreTap ?? () {},
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.9),
              shape: BoxShape.circle,
              boxShadow: AppShadows.subtle,
            ),
            child: const Icon(
              Iconsax.more,
              size: 20,
              color: AppColors.warmGray700,
            ),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}

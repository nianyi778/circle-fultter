import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/theme/app_theme.dart';
import '../../create/views/create_moment_view.dart';

/// 显示创建时刻弹窗
void _showCreateModal(BuildContext context, {String? hint}) {
  Navigator.of(context).push(
    PageRouteBuilder(
      opaque: false,
      barrierDismissible: false,
      pageBuilder: (context, animation, secondaryAnimation) {
        return CreateMomentModal(hint: hint);
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.05),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(parent: animation, curve: AppCurves.enter),
            ),
            child: child,
          ),
        );
      },
      transitionDuration: AppDurations.pageTransition,
      reverseTransitionDuration: AppDurations.normal,
    ),
  );
}

/// 灵感胶囊 - 新用户引导标签
///
/// 显示一些灵感标签，帮助用户开始第一次记录
class InspirationTags extends StatelessWidget {
  const InspirationTags({super.key});

  static const List<_InspirationItem> _items = [
    _InspirationItem(emoji: '📸', label: '第一张合影'),
    _InspirationItem(emoji: '🏠', label: '搬进新家'),
    _InspirationItem(emoji: '✈️', label: '一次旅行'),
    _InspirationItem(emoji: '🎁', label: '收到的礼物'),
    _InspirationItem(emoji: '🍜', label: '一顿晚餐'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题行
        Row(
          children: [
            Icon(Iconsax.magic_star, size: 16, color: AppColors.warmGray400),
            const SizedBox(width: 8),
            Text(
              '灵感胶囊',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppColors.warmGray500,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // 标签
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _items.map((item) => _TagChip(item: item)).toList(),
        ),
      ],
    );
  }
}

class _InspirationItem {
  final String emoji;
  final String label;

  const _InspirationItem({required this.emoji, required this.label});
}

class _TagChip extends StatelessWidget {
  final _InspirationItem item;

  const _TagChip({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showCreateModal(context, hint: item.label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.warmGray200, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(item.emoji, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 6),
            Text(
              item.label,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.warmGray700),
            ),
          ],
        ),
      ),
    );
  }
}

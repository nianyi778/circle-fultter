import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/models/moment.dart';

/// 这一年的片段（自动回忆）
class FragmentsSection extends ConsumerWidget {
  const FragmentsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final moments = ref.watch(momentsProvider);
    
    // 计算统计数据
    final audioCount = moments.where((m) => m.mediaType == MediaType.audio).length;
    final favoriteEmoji = _getMostFrequentMood(moments);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题行
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '片段',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.warmGray500,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Icon(
                Iconsax.arrow_right_3,
                size: 16,
                color: AppColors.warmGray400,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 片段卡片网格
          Row(
            children: [
              Expanded(
                child: _FragmentCard(
                  icon: Iconsax.microphone_2,
                  iconColor: AppColors.warmOrangeDark,
                  bgColor: AppColors.warmOrange,
                  label: '声音',
                  content: '留下了 $audioCount 段声音',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _FragmentCard(
                  icon: Iconsax.emoji_happy,
                  iconColor: AppColors.warmGray700,
                  bgColor: AppColors.warmGray100,
                  label: '情绪',
                  content: '最常记录的是：$favoriteEmoji',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getMostFrequentMood(List<Moment> moments) {
    // 简单统计最常见的情绪标签
    final moodCount = <String, int>{};
    for (final moment in moments) {
      for (final tag in moment.contextTags) {
        if (tag.type == ContextTagType.myMood) {
          moodCount[tag.label] = (moodCount[tag.label] ?? 0) + 1;
        }
      }
    }
    
    if (moodCount.isEmpty) return '开心';
    
    return moodCount.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }
}

/// 片段卡片
class _FragmentCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final String label;
  final String content;

  const _FragmentCard({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.label,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Stack(
        children: [
          // 背景图标
          Positioned(
            right: -12,
            bottom: -12,
            child: Transform.rotate(
              angle: 0.2,
              child: Icon(
                icon,
                size: 72,
                color: iconColor.withValues(alpha: 0.15),
              ),
            ),
          ),
          
          // 内容
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: iconColor.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
              const Spacer(),
              Text(
                content,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: iconColor,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

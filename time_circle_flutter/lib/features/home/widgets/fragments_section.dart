import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/models/moment.dart';

/// 时光碎片统计区域 - 重新设计
///
/// 设计理念：
/// - 横向滑动的统计卡片
/// - 更简洁的视觉，使用新的图标和配色
/// - 无缝滑动体验
class FragmentsSection extends ConsumerWidget {
  const FragmentsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final moments = ref.watch(momentsProvider);

    // 计算统计数据
    final imageCount =
        moments.where((m) => m.mediaType == MediaType.image).length;
    final audioCount =
        moments.where((m) => m.mediaType == MediaType.audio).length;
    final videoCount =
        moments.where((m) => m.mediaType == MediaType.video).length;
    final textCount =
        moments.where((m) => m.mediaType == MediaType.text).length;
    final totalCount = moments.length;

    // 如果没有任何记录，不显示这个区块
    if (totalCount == 0) {
      return const SizedBox.shrink();
    }

    final stats = <_StatItem>[
      _StatItem(
        icon: Iconsax.gallery,
        label: '照片',
        count: imageCount,
        color: AppColors.warmOrangeDark,
        bgColor: AppColors.warmOrangeLight.withValues(alpha: 0.3),
      ),
      _StatItem(
        icon: Iconsax.microphone,
        label: '声音',
        count: audioCount,
        color: AppColors.warmPeachDeep,
        bgColor: AppColors.warmPeach.withValues(alpha: 0.3),
      ),
      _StatItem(
        icon: Iconsax.video,
        label: '视频',
        count: videoCount,
        color: AppColors.warmGray600,
        bgColor: AppColors.warmGray150,
      ),
      _StatItem(
        icon: Iconsax.document_text,
        label: '文字',
        count: textCount,
        color: AppColors.warmGray500,
        bgColor: AppColors.warmGray100,
      ),
    ];

    // 只显示有数据的统计项
    final visibleStats = stats.where((s) => s.count > 0).toList();

    if (visibleStats.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section 标题
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.pagePadding,
          ),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: AppColors.warmGray300,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '时光碎片',
                style: AppTypography.caption(
                  context,
                ).copyWith(color: AppColors.warmGray500, letterSpacing: 1),
              ),
              const Spacer(),
              Text(
                '共 $totalCount 条',
                style: AppTypography.caption(
                  context,
                ).copyWith(color: AppColors.warmGray400),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // 横向滑动卡片
        SizedBox(
          height: 88,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.pagePadding,
            ),
            physics: const BouncingScrollPhysics(),
            itemCount: visibleStats.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              return _FragmentCard(stat: visibleStats[index]);
            },
          ),
        ),
      ],
    );
  }
}

/// 统计项数据
class _StatItem {
  final IconData icon;
  final String label;
  final int count;
  final Color color;
  final Color bgColor;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.count,
    required this.color,
    required this.bgColor,
  });
}

/// 单个碎片统计卡片
class _FragmentCard extends StatelessWidget {
  final _StatItem stat;

  const _FragmentCard({required this.stat});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: stat.bgColor,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: stat.color.withValues(alpha: 0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 图标
          Icon(stat.icon, size: 20, color: stat.color),

          // 底部：数字和标签
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${stat.count}',
                style: AppTypography.title(context).copyWith(
                  color: stat.color,
                  fontSize: 24,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                stat.label,
                style: AppTypography.caption(
                  context,
                ).copyWith(color: stat.color.withValues(alpha: 0.7)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

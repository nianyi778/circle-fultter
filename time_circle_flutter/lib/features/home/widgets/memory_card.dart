import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/utils/image_utils.dart';

/// 回忆卡片 - 根据用户状态显示不同内容
///
/// 场景1: 新用户（无任何记录）→ 显示「留下第一刻」引导卡片
/// 场景2: 有去年今天的数据 → 显示回忆内容
/// 场景3: 无去年今天数据但圈子满一年 → 显示"去年的今天没有记录"
/// 场景4: 圈子不满一年但有记录 → 显示温暖的引导卡片
class MemoryCard extends ConsumerWidget {
  const MemoryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasAnyMoments = ref.watch(hasAnyMomentsProvider);
    final lastYearMoments = ref.watch(lastYearTodayMomentsProvider);
    final hasLastYearData = ref.watch(hasLastYearDataProvider);

    // 场景1: 新用户 - 显示「留下第一刻」
    if (!hasAnyMoments) {
      return _FirstMomentCard();
    }

    // 场景4: 圈子不满一年 - 显示引导卡片
    if (!hasLastYearData) {
      return _WelcomeCard();
    }

    // 场景3: 满一年但去年今天没有记录
    if (lastYearMoments.isEmpty) {
      return _EmptyMemoryCard();
    }

    // 场景2: 有去年今天的记录
    final featuredMoment = lastYearMoments.firstWhere(
      (m) => m.mediaUrl != null,
      orElse: () => lastYearMoments.first,
    );

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
          color: AppColors.warmGray200.withValues(alpha: 0.5),
          width: 1,
        ),
        boxShadow: AppShadows.subtle,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题区 - 横向布局
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 左侧图片
                if (featuredMoment.mediaUrl != null &&
                    featuredMoment.mediaUrl!.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    child: SizedBox(
                      width: 100,
                      height: 100,
                      child: ImageUtils.buildImage(
                        url: featuredMoment.mediaUrl!,
                      ),
                    ),
                  ),
                if (featuredMoment.mediaUrl != null &&
                    featuredMoment.mediaUrl!.isNotEmpty)
                  const SizedBox(width: 16),

                // 右侧内容
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 标签和日期
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '去年的今天',
                            style: Theme.of(
                              context,
                            ).textTheme.labelMedium?.copyWith(
                              color: AppColors.warmOrangeDark,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            _formatDate(featuredMoment.timestamp),
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(color: AppColors.warmGray400),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // 内容
                      Text(
                        '"${featuredMoment.content}"',
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(height: 1.5),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),

                      // 年龄标签
                      Text(
                        featuredMoment.childAgeLabel,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.warmGray400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}年${date.month}月${date.day}日';
  }
}

/// 新用户引导卡片 - 「留下第一刻」
class _FirstMomentCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/create'),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(
            color: AppColors.warmGray200.withValues(alpha: 0.5),
            width: 1,
          ),
          boxShadow: AppShadows.subtle,
        ),
        child: Stack(
          children: [
            // 背景装饰 - 羽毛/笔的图标
            Positioned(
              right: 0,
              bottom: 0,
              child: Opacity(
                opacity: 0.06,
                child: Icon(
                  Iconsax.edit,
                  size: 120,
                  color: AppColors.warmGray900,
                ),
              ),
            ),

            // 内容
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // + 按钮
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.warmGray800,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Iconsax.add,
                    color: AppColors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 20),

                // 标题
                Text(
                  '留下第一刻',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),

                // 副标题
                Text(
                  '一张照片，或是一句想说的话。',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.warmGray500,
                  ),
                ),
                const SizedBox(height: 16),

                // 开始记录按钮
                Row(
                  children: [
                    Text(
                      '开始记录',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.warmOrangeDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Iconsax.arrow_right_3,
                      size: 16,
                      color: AppColors.warmOrangeDark,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 有记录但不满一年的引导卡片
class _WelcomeCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.warmPeach.withValues(alpha: 0.3),
            AppColors.timeBeigeLight,
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
          color: AppColors.warmGray200.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 小标签
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: AppColors.warmPeachDeep.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '时间的开始',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.warmGray500,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 主文案
          Text(
            '这里，会慢慢被时间填满',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.warmGray800,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '明年的今天，你会在这里看见今天留下的痕迹。',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.warmGray500,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

/// 满一年但去年今天没有记录
class _EmptyMemoryCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
          color: AppColors.warmGray200.withValues(alpha: 0.5),
          width: 1,
        ),
        boxShadow: AppShadows.subtle,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppColors.warmGray300,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '去年的今天',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.warmGray500,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 空状态文案
          Text(
            '去年的这一天，没有留下记录。',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.warmGray400,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '时间有它自己的节奏。',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.warmGray300),
          ),
        ],
      ),
    );
  }
}

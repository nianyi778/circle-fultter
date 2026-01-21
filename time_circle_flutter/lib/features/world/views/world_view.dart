import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/models/world_post.dart';

class WorldView extends ConsumerWidget {
  const WorldView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final posts = ref.watch(worldPostsProvider);
    final channels = ref.watch(worldChannelsProvider);

    return Scaffold(
      backgroundColor: AppColors.warmGray100,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // 顶部标题
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pagePadding,
                  AppSpacing.xxl,
                  AppSpacing.pagePadding,
                  0,
                ),
                child: Column(
                  children: [
                    Text(
                      '世界',
                      style: Theme.of(context).textTheme.headlineLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '其他父母的回声。安全且匿名。',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.warmGray500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '这里，是一些被允许看见的片段。',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.warmGray400,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms),
            ),

            // 频道标签
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 24),
                child: SizedBox(
                  height: 36,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.pagePadding,
                    ),
                    itemCount: channels.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final channel = channels[index];
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(AppRadius.full),
                          border: Border.all(
                            color: AppColors.warmGray200,
                            width: 1,
                          ),
                          boxShadow: AppShadows.subtle,
                        ),
                        child: Text(
                          '# ${channel.name}',
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: AppColors.warmGray600,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
            ),

            // 帖子列表
            SliverPadding(
              padding: const EdgeInsets.all(AppSpacing.pagePadding),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final post = posts[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _WorldPostCard(post: post),
                    ).animate().fadeIn(
                      duration: 500.ms,
                      delay: Duration(milliseconds: 150 + (index * 50)),
                      curve: Curves.easeOut,
                    ).slideY(begin: 0.03, end: 0);
                  },
                  childCount: posts.length,
                ),
              ),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ],
        ),
      ),
    );
  }
}

/// 世界频道帖子卡片
class _WorldPostCard extends ConsumerWidget {
  final WorldPost post;

  const _WorldPostCard({required this.post});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gradient = _getGradient(post.bgGradient);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
          color: AppColors.white.withValues(alpha: 0.5),
          width: 1,
        ),
        boxShadow: AppShadows.subtle,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标签
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Text(
              post.tag.toUpperCase(),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.warmGray600,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 内容
          Text(
            '"${post.content}"',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              height: 1.6,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 20),

          // 底部操作
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 假头像
              Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.warmGray100,
                        width: 1,
                      ),
                    ),
                  ),
                  Transform.translate(
                    offset: const Offset(-6, 0),
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: AppColors.warmGray100,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.warmGray100,
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // 共鸣按钮
              GestureDetector(
                onTap: () {
                  ref.read(worldPostsProvider.notifier).toggleResonance(post.id);
                },
                child: AnimatedContainer(
                  duration: AppDurations.fast,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: post.hasResonated 
                        ? AppColors.heart.withValues(alpha: 0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        post.hasResonated ? Iconsax.heart5 : Iconsax.heart,
                        size: 18,
                        color: post.hasResonated 
                            ? AppColors.heart 
                            : AppColors.warmGray500,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '共鸣',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: post.hasResonated 
                              ? AppColors.heart 
                              : AppColors.warmGray500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  LinearGradient _getGradient(String type) {
    switch (type) {
      case 'orange':
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.warmOrange,
            AppColors.warmPeach,
          ],
        );
      case 'blue':
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.calmBlue,
            AppColors.calmBlue.withValues(alpha: 0.6),
          ],
        );
      case 'violet':
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.mutedViolet,
            AppColors.mutedViolet.withValues(alpha: 0.6),
          ],
        );
      case 'green':
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.softGreen,
            AppColors.softGreen.withValues(alpha: 0.6),
          ],
        );
      case 'peach':
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.warmPeach,
            AppColors.warmPeach.withValues(alpha: 0.6),
          ],
        );
      default:
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.warmGray100,
            AppColors.warmGray200,
          ],
        );
    }
  }
}

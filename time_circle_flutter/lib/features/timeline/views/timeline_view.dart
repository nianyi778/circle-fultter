import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/providers/app_providers.dart';
import '../widgets/feed_card.dart';

class TimelineView extends ConsumerWidget {
  const TimelineView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final moments = ref.watch(momentsProvider);
    final childInfo = ref.watch(childInfoProvider);
    final hasMoments = moments.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.timeBeige,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // 顶部圈子信息条
          SliverAppBar(
            pinned: true,
            floating: false,
            expandedHeight: 0,
            toolbarHeight: 72,
            backgroundColor: AppColors.white.withValues(alpha: 0.95),
            surfaceTintColor: Colors.transparent,
            automaticallyImplyLeading: false,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.warmGray100,
                    width: 1,
                  ),
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.pagePadding,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      // 孩子头像和年龄
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.white,
                                width: 2,
                              ),
                              boxShadow: AppShadows.subtle,
                            ),
                            child: ClipOval(
                              child: CachedNetworkImage(
                                imageUrl: 'https://picsum.photos/seed/child/100/100',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: -4,
                            right: -4,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.warmGray800,
                                borderRadius: BorderRadius.circular(AppRadius.full),
                                border: Border.all(
                                  color: AppColors.white,
                                  width: 1.5,
                                ),
                              ),
                              child: Text(
                                childInfo.shortAgeLabel,
                                style: const TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      
                      // 圈子名称和成员
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${childInfo.name}的时间圈',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            // 成员头像叠放
                            Row(
                              children: [
                                _buildMiniAvatar('https://picsum.photos/seed/dad/100/100'),
                                Transform.translate(
                                  offset: const Offset(-6, 0),
                                  child: _buildMiniAvatar('https://picsum.photos/seed/mom/100/100'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      // 操作按钮
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Iconsax.filter),
                        color: AppColors.warmGray500,
                        iconSize: 20,
                      ),
                      IconButton(
                        onPressed: () => context.push('/settings'),
                        icon: const Icon(Iconsax.more),
                        color: AppColors.warmGray500,
                        iconSize: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 时间线内容
          if (hasMoments) ...[
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.pagePadding,
                AppSpacing.lg,
                AppSpacing.pagePadding,
                0,
              ),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final moment = moments[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.cardGap),
                      child: FeedCard(
                        moment: moment,
                        onTap: () => context.push('/moment/${moment.id}'),
                      ),
                    ).animate().fadeIn(
                      duration: 400.ms,
                      delay: Duration(milliseconds: 50 * index),
                      curve: Curves.easeOut,
                    ).slideY(begin: 0.05, end: 0);
                  },
                  childCount: moments.length,
                ),
              ),
            ),
            
            // 底部提示
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Column(
                  children: [
                    Text(
                      '到底了',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.warmGray400,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '暂时就这么多。',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.warmGray300,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else
            // 空状态
            SliverFillRemaining(
              hasScrollBody: false,
              child: _EmptyTimeline(),
            ),

          // 底部安全区域
          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniAvatar(String url) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.white,
          width: 1,
        ),
      ),
      child: ClipOval(
        child: CachedNetworkImage(
          imageUrl: url,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

/// 空状态
class _EmptyTimeline extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.warmGray100,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Iconsax.magic_star,
                color: AppColors.warmGray300,
                size: 28,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '这一条时间线，\n会慢慢被你填满。',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.warmGray500,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              '不必着急，时间一直在发生。',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.warmGray400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

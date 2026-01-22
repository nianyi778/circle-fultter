import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/providers/app_providers.dart';
import '../widgets/memory_card.dart';
import '../widgets/time_header.dart';
import '../widgets/annual_letter_card.dart';
import '../widgets/fragments_section.dart';

/// 检查是否为有效的网络 URL
bool _isValidNetworkUrl(String url) {
  if (url.isEmpty) return false;
  return url.startsWith('http://') || url.startsWith('https://');
}

class HomeView extends ConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserSyncProvider);
    final childInfo = ref.watch(childInfoProvider);
    final moments = ref.watch(momentsProvider);
    final hasHistory = moments.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.timeBeige,
      body: SafeArea(
        bottom: false,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.zero,
          children: [
            // 顶部区域
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.pagePadding,
                AppSpacing.lg,
                AppSpacing.pagePadding,
                0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 头像和设置入口
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TimeHeader(
                          circleInfo: childInfo,
                          hasHistory: hasHistory,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.push('/settings'),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.warmGray200,
                              width: 1,
                            ),
                            boxShadow: AppShadows.subtle,
                          ),
                          child: ClipOval(
                            child: _isValidNetworkUrl(currentUser.avatar)
                                ? CachedNetworkImage(
                                    imageUrl: currentUser.avatar,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Container(
                                      color: AppColors.warmGray200,
                                    ),
                                    errorWidget: (context, url, error) => Container(
                                      color: AppColors.warmGray200,
                                      child: const Icon(
                                        Iconsax.user,
                                        color: AppColors.warmGray400,
                                      ),
                                    ),
                                  )
                                : Container(
                                    color: AppColors.warmGray200,
                                    child: const Icon(
                                      Iconsax.user,
                                      color: AppColors.warmGray400,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms, curve: Curves.easeOut),

            const SizedBox(height: AppSpacing.sectionGap),

            // 模块一：去年的今天 / 空状态
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
              child: hasHistory
                  ? const MemoryCard()
                  : _EmptyStateCard(
                      onTap: () => context.push('/create'),
                    ),
            ).animate().fadeIn(
              duration: 500.ms, 
              delay: 100.ms,
              curve: Curves.easeOut,
            ).slideY(begin: 0.05, end: 0),

            const SizedBox(height: AppSpacing.sectionGap),

            // 模块二：年度信状态
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
              child: const AnnualLetterCard(),
            ).animate().fadeIn(
              duration: 500.ms,
              delay: 200.ms,
              curve: Curves.easeOut,
            ).slideY(begin: 0.05, end: 0),

            const SizedBox(height: AppSpacing.sectionGap),

            // 模块三：这一年的片段
            if (hasHistory)
              const FragmentsSection().animate().fadeIn(
                duration: 500.ms,
                delay: 300.ms,
                curve: Curves.easeOut,
              ).slideY(begin: 0.05, end: 0),

            // 底部安全区域
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }
}

/// 空状态卡片
class _EmptyStateCard extends StatelessWidget {
  final VoidCallback onTap;

  const _EmptyStateCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(
            color: AppColors.warmGray200,
            width: 1,
          ),
          boxShadow: AppShadows.subtle,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.warmGray100,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Iconsax.add,
                color: AppColors.warmGray400,
                size: 24,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '这里，会慢慢被时间填满。',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.warmGray500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '点击留下第一刻',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.warmGray400,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

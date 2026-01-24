import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/providers/app_providers.dart';
import '../../../shared/widgets/app_logo.dart';
import '../widgets/memory_card.dart';
import '../widgets/time_header.dart';
import '../widgets/annual_letter_card.dart';
import '../widgets/fragments_section.dart';
import '../widgets/inspiration_tags.dart';
import '../widgets/daily_quote_card.dart';
import '../widgets/recent_moments_preview.dart';
import '../widgets/milestone_card.dart';

/// 首页 - 重新设计
///
/// 设计理念：
/// - 时间叙事区作为视觉焦点
/// - 沉浸式回忆卡片
/// - 更大的呼吸空间
/// - 温柔、安静、克制
class HomeView extends ConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserSyncProvider);
    final childInfo = ref.watch(childInfoProvider);
    final hasAnyMoments = ref.watch(hasAnyMomentsProvider);
    final hasEnoughMoments = ref.watch(hasEnoughMomentsProvider);
    final moments = ref.watch(momentsProvider);

    return Scaffold(
      backgroundColor: AppColors.timeBeige,
      body: SafeArea(
        bottom: false,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.zero,
          children: [
            // ========== 顶部区域 ==========
            _buildTopSection(
              context,
              currentUser: currentUser,
              childInfo: childInfo,
              hasAnyMoments: hasAnyMoments,
              momentCount: moments.length,
            ),

            SizedBox(
              height: hasAnyMoments ? AppSpacing.sectionGap : AppSpacing.xl,
            ),

            // ========== 内容区域 ==========
            if (!hasAnyMoments)
              _buildNewUserContent(context)
            else
              _buildReturningUserContent(
                context,
                hasEnoughMoments: hasEnoughMoments,
              ),

            // 底部安全区域
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }

  /// 顶部区域：时间叙事 + 头像
  Widget _buildTopSection(
    BuildContext context, {
    required dynamic currentUser,
    required dynamic childInfo,
    required bool hasAnyMoments,
    required int momentCount,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pagePadding,
        AppSpacing.lg,
        AppSpacing.pagePadding,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 顶部行：头像（右对齐）
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [_buildAvatarButton(context, currentUser)],
          ),
          const SizedBox(height: AppSpacing.lg),

          // 时间叙事区
          TimeHeader(
            circleInfo: childInfo,
            hasHistory: hasAnyMoments,
            momentCount: momentCount,
          ),
        ],
      ),
    ).animate().fadeIn(duration: AppDurations.normal, curve: AppCurves.smooth);
  }

  /// 新用户内容
  Widget _buildNewUserContent(BuildContext context) {
    return Column(
      children: [
        // 留下第一刻卡片
        Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.pagePadding,
              ),
              child: const MemoryCard(),
            )
            .animate()
            .fadeIn(
              duration: AppDurations.entrance,
              delay: 100.ms,
              curve: AppCurves.smooth,
            )
            .slideY(begin: 0.03, end: 0),

        const SizedBox(height: AppSpacing.sectionGap),

        // 灵感胶囊
        Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.pagePadding,
              ),
              child: const InspirationTags(),
            )
            .animate()
            .fadeIn(
              duration: AppDurations.entrance,
              delay: 200.ms,
              curve: AppCurves.smooth,
            )
            .slideY(begin: 0.03, end: 0),
      ],
    );
  }

  /// 老用户内容
  Widget _buildReturningUserContent(
    BuildContext context, {
    required bool hasEnoughMoments,
  }) {
    return Column(
      children: [
        // 1. 今日一句
        const DailyQuoteCard().animate().fadeIn(
          duration: AppDurations.entrance,
          delay: 50.ms,
          curve: AppCurves.smooth,
        ),

        // 2. 里程碑提醒（条件显示）
        const MilestoneCard()
            .animate()
            .fadeIn(
              duration: AppDurations.entrance,
              delay: 100.ms,
              curve: AppCurves.smooth,
            )
            .slideY(begin: 0.02, end: 0),

        const SizedBox(height: AppSpacing.md),

        // 3. 回忆漫游卡片（去年的今天）
        Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.pagePadding,
              ),
              child: const MemoryCard(),
            )
            .animate()
            .fadeIn(
              duration: AppDurations.entrance,
              delay: 150.ms,
              curve: AppCurves.smooth,
            )
            .slideY(begin: 0.03, end: 0),

        const SizedBox(height: AppSpacing.lg),

        // 4. 记录统计卡片（最近30天）
        const RecordStatsCard()
            .animate()
            .fadeIn(
              duration: AppDurations.entrance,
              delay: 200.ms,
              curve: AppCurves.smooth,
            )
            .slideY(begin: 0.03, end: 0),

        const SizedBox(height: AppSpacing.lg),

        // 5. 年度信卡片（简化版）
        Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.pagePadding,
              ),
              child: const AnnualLetterCard(),
            )
            .animate()
            .fadeIn(
              duration: AppDurations.entrance,
              delay: 250.ms,
              curve: AppCurves.smooth,
            )
            .slideY(begin: 0.03, end: 0),

        // 6. 时光碎片（至少有5条记录才显示）
        if (hasEnoughMoments) ...[
          const SizedBox(height: AppSpacing.sectionGap),
          const FragmentsSection()
              .animate()
              .fadeIn(
                duration: AppDurations.entrance,
                delay: 300.ms,
                curve: AppCurves.smooth,
              )
              .slideY(begin: 0.03, end: 0),
        ],
      ],
    );
  }

  /// 构建 Logo 按钮（点击进入设置）
  Widget _buildAvatarButton(BuildContext context, dynamic currentUser) {
    return AppLogo(
      size: AppLogoSize.medium,
      onTap: () => context.push('/settings'),
    );
  }
}

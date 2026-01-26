import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/providers/app_providers.dart';
import '../../../shared/widgets/sync_status_indicator.dart';
import '../widgets/memory_card.dart';
import '../widgets/time_header.dart';
import '../widgets/annual_letter_card.dart';
import '../widgets/inspiration_tags.dart';
import '../widgets/milestone_card.dart';

/// 首页 - 精简版设计
///
/// 设计理念：
/// - 时间叙事区作为视觉焦点
/// - 仅保留 3 个核心模块：时间、回忆、年度信
/// - 大量留白，增加呼吸空间
/// - 温柔、安静、克制
///
/// 模块结构：
/// 1. 时间叙事区 (TimeHeader) - 视觉焦点
/// 2. 里程碑提醒 (MilestoneCard) - 条件性显示
/// 3. 回忆漫游卡片 (MemoryCard) - 核心功能
/// 4. 年度信卡片 (AnnualLetterCard) - 仪式感功能
class HomeView extends ConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserSyncProvider);
    final childInfo = ref.watch(childInfoProvider);
    final hasAnyMoments = ref.watch(hasAnyMomentsProvider);
    final moments = ref.watch(momentsProvider);

    // 获取状态栏高度，实现沉浸式全面屏
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.timeBeige,
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.zero,
        children: [
          // 状态栏占位（背景色会延伸到状态栏区域）
          SizedBox(height: statusBarHeight),

          // ========== 顶部区域 ==========
          _buildTopSection(
            context,
            currentUser: currentUser,
            childInfo: childInfo,
            hasAnyMoments: hasAnyMoments,
            momentCount: moments.length,
          ),

          // 更大的呼吸空间
          SizedBox(height: hasAnyMoments ? AppSpacing.xxxl : AppSpacing.xxl),

          // ========== 内容区域 ==========
          if (!hasAnyMoments)
            _buildNewUserContent(context)
          else
            _buildReturningUserContent(context),

          // 底部安全区域（更大）
          const SizedBox(height: 140),
        ],
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
          // 顶部行：同步状态 + 头像（右对齐）
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // 同步状态指示器
              const SyncStatusIndicator(size: 18),
              const SizedBox(width: 12),
              _buildSettingsButton(context),
            ],
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

  /// 老用户内容 - 精简版（仅 3 个核心模块）
  ///
  /// 设计原则：留白即呼吸
  /// - 移除了今日一句、记录统计、时光碎片
  /// - 保留里程碑（条件显示）、回忆、年度信
  Widget _buildReturningUserContent(BuildContext context) {
    return Column(
      children: [
        // 1. 里程碑提醒（条件显示，只在接近里程碑时出现）
        const MilestoneCard()
            .animate()
            .fadeIn(
              duration: AppDurations.entrance,
              delay: 50.ms,
              curve: AppCurves.smooth,
            )
            .slideY(begin: 0.02, end: 0),

        // 里程碑与回忆卡片之间的间距
        const SizedBox(height: AppSpacing.lg),

        // 2. 回忆漫游卡片（核心功能）
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

        // 更大的模块间距（32px → 48px）
        const SizedBox(height: AppSpacing.xxxl),

        // 3. 年度信卡片（仪式感功能）
        Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.pagePadding,
              ),
              child: const AnnualLetterCard(),
            )
            .animate()
            .fadeIn(
              duration: AppDurations.entrance,
              delay: 150.ms,
              curve: AppCurves.smooth,
            )
            .slideY(begin: 0.03, end: 0),
      ],
    );
  }

  /// 构建设置按钮（点击进入设置）
  Widget _buildSettingsButton(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/settings'),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.bgElevated,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.settings_outlined,
          size: 22,
          color: AppColors.warmGray600,
        ),
      ),
    );
  }
}

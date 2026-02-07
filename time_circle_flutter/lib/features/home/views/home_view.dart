import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/animations/animation_config.dart';
import '../../../core/haptics/haptic_service.dart';
import '../../../core/providers/app_providers.dart';
import '../../../presentation/shared/aura/animations/aura_stagger_list.dart';
import '../../../shared/widgets/sync_status_indicator.dart';
import '../widgets/memory_card.dart';
import '../widgets/time_header.dart';
import '../widgets/annual_letter_card.dart';
import '../widgets/inspiration_tags.dart';
import '../widgets/milestone_card.dart';

/// 首页入场动画配置
const _homeStaggerConfig = StaggerConfig(
  baseDelay: Duration(milliseconds: 80),
  itemDuration: Duration(milliseconds: 500),
  maxDelayItems: 4,
  slideOffset: Offset(0, 0.03),
);

/// 首页 - 全新设计
///
/// 设计理念：
/// - 时间叙事区作为视觉焦点
/// - 精致的卡片式布局
/// - 大量留白，增加呼吸空间
/// - 温柔、安静、克制
/// - 支持全面屏设备
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
    // currentUser can be used for future features
    ref.watch(currentUserSyncProvider);
    final childInfo = ref.watch(childInfoProvider);
    final hasAnyMoments = ref.watch(hasAnyMomentsProvider);
    final moments = ref.watch(momentsProvider);

    // 获取安全区域
    final mediaQuery = MediaQuery.of(context);
    final topPadding = mediaQuery.padding.top;
    final bottomPadding = mediaQuery.padding.bottom;

    // 设置状态栏样式
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.timeBeige,
      extendBodyBehindAppBar: true,
      extendBody: true,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          // 顶部安全区域 + 操作栏
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.only(top: topPadding),
              child: _buildTopBar(context),
            ),
          ),

          // 时间叙事区
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.pagePadding,
                AppSpacing.lg,
                AppSpacing.pagePadding,
                0,
              ),
              child: TimeHeader(
                circleInfo: childInfo,
                hasHistory: hasAnyMoments,
                momentCount: moments.length,
              ),
            ),
          ),

          // 间距
          SliverToBoxAdapter(
            child: SizedBox(
              height: hasAnyMoments ? AppSpacing.xxl : AppSpacing.xl,
            ),
          ),

          // 内容区域
          if (!hasAnyMoments)
            SliverToBoxAdapter(child: _buildNewUserContent(context))
          else
            SliverToBoxAdapter(child: _buildReturningUserContent(context)),

          // 底部安全区域
          SliverToBoxAdapter(child: SizedBox(height: 100 + bottomPadding)),
        ],
      ),
    );
  }

  /// 顶部操作栏
  Widget _buildTopBar(BuildContext context) {
    return AuraStaggerItem(
      index: 0,
      config: _homeStaggerConfig,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.pagePadding,
          vertical: AppSpacing.md,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 左侧：App Logo/名称
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.warmOrangeDeep,
                        AppColors.warmPeachDeep,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Iconsax.sun_15, size: 18, color: Colors.white),
                ),
                const SizedBox(width: 10),
                Text(
                  '拾光',
                  style: AppTypography.subtitle(context).copyWith(
                    color: AppColors.warmGray800,
                    fontWeight: FontWeight.w600,
                    fontSize: 17,
                  ),
                ),
              ],
            ),

            // 右侧：同步状态 + 设置
            Row(
              children: [
                const SyncStatusIndicator(size: 18),
                const SizedBox(width: 12),
                _buildSettingsButton(context),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 新用户内容
  Widget _buildNewUserContent(BuildContext context) {
    return AuraStaggerList(
      baseDelay: _homeStaggerConfig.baseDelay,
      itemDuration: _homeStaggerConfig.itemDuration,
      maxDelayItems: _homeStaggerConfig.maxDelayItems,
      slideOffset: _homeStaggerConfig.slideOffset,
      children: [
        // 留下第一刻卡片
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.pagePadding,
          ),
          child: const MemoryCard(),
        ),

        const SizedBox(height: AppSpacing.sectionGap),

        // 灵感胶囊
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.pagePadding,
          ),
          child: const InspirationTags(),
        ),
      ],
    );
  }

  /// 老用户内容 - 精简版
  Widget _buildReturningUserContent(BuildContext context) {
    return AuraStaggerList(
      baseDelay: _homeStaggerConfig.baseDelay,
      itemDuration: _homeStaggerConfig.itemDuration,
      maxDelayItems: _homeStaggerConfig.maxDelayItems,
      slideOffset: _homeStaggerConfig.slideOffset,
      children: [
        // 1. 里程碑提醒（条件显示）
        const MilestoneCard(),

        const SizedBox(height: AppSpacing.lg),

        // 2. 回忆漫游卡片
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.pagePadding,
          ),
          child: const MemoryCard(),
        ),

        const SizedBox(height: AppSpacing.sectionGap),

        // 3. 年度信卡片
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.pagePadding,
          ),
          child: const AnnualLetterCard(),
        ),
      ],
    );
  }

  /// 设置按钮
  Widget _buildSettingsButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticService.lightTap();
        context.push('/settings');
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.white,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.warmGray150, width: 1),
          boxShadow: AppShadows.subtle,
        ),
        child: Icon(Iconsax.setting_2, size: 20, color: AppColors.warmGray600),
      ),
    );
  }
}

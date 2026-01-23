import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/utils/image_utils.dart';
import '../widgets/memory_card.dart';
import '../widgets/time_header.dart';
import '../widgets/annual_letter_card.dart';
import '../widgets/fragments_section.dart';
import '../widgets/inspiration_tags.dart';

class HomeView extends ConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserSyncProvider);
    final childInfo = ref.watch(childInfoProvider);
    final hasAnyMoments = ref.watch(hasAnyMomentsProvider);
    final hasEnoughMoments = ref.watch(hasEnoughMomentsProvider);
    final moments = ref.watch(momentsProvider);
    final annualDraft = ref.watch(annualDraftLetterProvider);

    return Scaffold(
      backgroundColor: AppColors.timeBeige,
      body: SafeArea(
        bottom: false,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.zero,
          children: [
            // 顶部区域：头像（新用户）/ 头像+信件按钮（老用户）
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
                  // 新用户：只显示右上角头像
                  if (!hasAnyMoments)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [_buildAvatarButton(context, currentUser)],
                    ),

                  // 老用户：头部信息 + 头像 + 信件按钮
                  if (hasAnyMoments)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 左侧：TimeHeader
                        Expanded(
                          child: TimeHeader(
                            circleInfo: childInfo,
                            hasHistory: hasAnyMoments,
                            momentCount: moments.length,
                          ),
                        ),
                        const SizedBox(width: 12),
                        // 右侧：信件按钮
                        _buildLetterButton(context, annualDraft != null),
                      ],
                    ),

                  // 新用户：TimeHeader 放在头像下方
                  if (!hasAnyMoments) ...[
                    const SizedBox(height: AppSpacing.md),
                    TimeHeader(
                      circleInfo: childInfo,
                      hasHistory: hasAnyMoments,
                      momentCount: moments.length,
                    ),
                  ],
                ],
              ),
            ).animate().fadeIn(duration: 400.ms, curve: Curves.easeOut),

            const SizedBox(height: AppSpacing.sectionGap),

            // ========== 新用户区域 ==========
            if (!hasAnyMoments) ...[
              // 留下第一刻卡片
              Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.pagePadding,
                    ),
                    child: const MemoryCard(),
                  )
                  .animate()
                  .fadeIn(
                    duration: 500.ms,
                    delay: 100.ms,
                    curve: Curves.easeOut,
                  )
                  .slideY(begin: 0.05, end: 0),

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
                    duration: 500.ms,
                    delay: 200.ms,
                    curve: Curves.easeOut,
                  )
                  .slideY(begin: 0.05, end: 0),
            ],

            // ========== 老用户区域 ==========
            if (hasAnyMoments) ...[
              // 回忆漫游 section
              Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.pagePadding,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Section 标题
                        _buildSectionHeader(
                          context,
                          icon: Icons.auto_awesome,
                          iconColor: AppColors.warmOrangeDark,
                          title: '回忆漫游',
                        ),
                        const SizedBox(height: 12),
                        // 回忆卡片
                        const MemoryCard(),
                      ],
                    ),
                  )
                  .animate()
                  .fadeIn(
                    duration: 500.ms,
                    delay: 100.ms,
                    curve: Curves.easeOut,
                  )
                  .slideY(begin: 0.05, end: 0),

              const SizedBox(height: AppSpacing.sectionGap),

              // 时光碎片（至少有5条记录才显示）
              if (hasEnoughMoments)
                const FragmentsSection()
                    .animate()
                    .fadeIn(
                      duration: 500.ms,
                      delay: 200.ms,
                      curve: Curves.easeOut,
                    )
                    .slideY(begin: 0.05, end: 0),

              if (hasEnoughMoments)
                const SizedBox(height: AppSpacing.sectionGap),

              // 年度草稿提醒卡片
              if (annualDraft != null)
                Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.pagePadding,
                      ),
                      child: _buildDraftReminderCard(context),
                    )
                    .animate()
                    .fadeIn(
                      duration: 500.ms,
                      delay: 300.ms,
                      curve: Curves.easeOut,
                    )
                    .slideY(begin: 0.05, end: 0),

              // 如果没有草稿，显示年度信卡片
              if (annualDraft == null)
                Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.pagePadding,
                      ),
                      child: const AnnualLetterCard(),
                    )
                    .animate()
                    .fadeIn(
                      duration: 500.ms,
                      delay: 300.ms,
                      curve: Curves.easeOut,
                    )
                    .slideY(begin: 0.05, end: 0),
            ],

            // 底部安全区域
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }

  /// 构建头像按钮
  Widget _buildAvatarButton(BuildContext context, dynamic currentUser) {
    return GestureDetector(
      onTap: () => context.push('/settings'),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.warmGray200, width: 1),
          boxShadow: AppShadows.subtle,
        ),
        child: ImageUtils.buildAvatar(url: currentUser.avatar, size: 44),
      ),
    );
  }

  /// 构建信件按钮（圆形深色按钮，右上角）
  Widget _buildLetterButton(BuildContext context, bool hasDraft) {
    return GestureDetector(
      onTap: () => context.push('/letter-editor'),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.warmGray800,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.warmGray400.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              hasDraft ? Icons.edit_rounded : Icons.create_rounded,
              color: AppColors.warmGray50,
              size: 22,
            ),
            // 草稿小圆点
            if (hasDraft)
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: AppColors.warmOrangeDark,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.warmGray800, width: 2),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// 构建 Section 标题
  Widget _buildSectionHeader(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: iconColor),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: AppColors.warmGray800,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  /// 构建草稿提醒卡片
  Widget _buildDraftReminderCard(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/letter-editor'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(
            color: AppColors.warmGray200.withValues(alpha: 0.5),
            width: 1,
          ),
          boxShadow: AppShadows.subtle,
        ),
        child: Row(
          children: [
            // 左侧图标
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.warmGray100,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.create_rounded,
                color: AppColors.warmGray500,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),

            // 中间文字
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '未完成的信',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppColors.warmGray800,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '上次编辑于近日',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.warmGray400,
                    ),
                  ),
                ],
              ),
            ),

            // 右侧箭头
            Row(
              children: [
                Text(
                  '继续',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.warmGray500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.warmGray300,
                  size: 18,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

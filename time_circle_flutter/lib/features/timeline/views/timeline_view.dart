import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/models/moment.dart';
import '../../../shared/widgets/comment_drawer.dart';
import '../widgets/feed_card.dart';
import '../widgets/filter_drawer.dart';

/// 时间线页面 - 重新设计
///
/// 设计理念：
/// - 收缩式 AppBar，向上滚动时隐藏
/// - 侧边筛选抽屉
/// - 更大的卡片间距
/// - 简洁的头部
class TimelineView extends ConsumerStatefulWidget {
  const TimelineView({super.key});

  @override
  ConsumerState<TimelineView> createState() => _TimelineViewState();
}

class _TimelineViewState extends ConsumerState<TimelineView> {
  bool _isFilterOpen = false;
  Moment? _replyingMoment;

  void _openFilter() => setState(() => _isFilterOpen = true);
  void _closeFilter() => setState(() => _isFilterOpen = false);

  void _openCommentDrawer(Moment moment) {
    setState(() => _replyingMoment = moment);
  }

  void _closeCommentDrawer() {
    setState(() => _replyingMoment = null);
  }

  @override
  Widget build(BuildContext context) {
    final moments = ref.watch(filteredMomentsProvider);
    final childInfo = ref.watch(childInfoProvider);
    final filter = ref.watch(timelineFilterProvider);
    final hasMoments = moments.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.timeBeige,
      body: Stack(
        children: [
          // 主内容
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // 收缩式 AppBar
              SliverAppBar(
                pinned: true,
                floating: true,
                snap: true,
                expandedHeight: 100,
                collapsedHeight: 60,
                backgroundColor: AppColors.timeBeige,
                surfaceTintColor: Colors.transparent,
                automaticallyImplyLeading: false,
                flexibleSpace: LayoutBuilder(
                  builder: (context, constraints) {
                    final expandRatio = ((constraints.maxHeight - 60) / 40)
                        .clamp(0.0, 1.0);
                    return _buildAppBar(context, childInfo, expandRatio);
                  },
                ),
                actions: [
                  // 筛选按钮
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: _openFilter,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color:
                              filter.isFiltering
                                  ? AppColors.warmGray800
                                  : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Iconsax.filter,
                          size: 20,
                          color:
                              filter.isFiltering
                                  ? AppColors.white
                                  : AppColors.warmGray500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // 筛选状态提示
              if (filter.isFiltering)
                SliverToBoxAdapter(
                  child: _buildFilterIndicator(context, ref, filter),
                ),

              // 时间线内容
              if (hasMoments) ...[
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.pagePadding,
                    AppSpacing.md,
                    AppSpacing.pagePadding,
                    0,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final moment = moments[index];
                      return Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.cardGap,
                            ),
                            child: FeedCard(
                              moment: moment,
                              onTap: () => context.push('/moment/${moment.id}'),
                              onDelete:
                                  (id) => _showDeleteConfirm(context, ref, id),
                              onShareToWorld:
                                  (id) => _showShareToWorld(context, ref, id),
                              onReply: () => _openCommentDrawer(moment),
                            ),
                          )
                          .animate()
                          .fadeIn(
                            duration: AppDurations.normal,
                            delay: Duration(
                              milliseconds: 50 * (index.clamp(0, 5)),
                            ),
                            curve: AppCurves.smooth,
                          )
                          .slideY(begin: 0.03, end: 0);
                    }, childCount: moments.length),
                  ),
                ),

                // 底部提示
                SliverToBoxAdapter(child: _buildEndIndicator(context)),
              ] else
                // 空状态
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EmptyTimeline(isFiltering: filter.isFiltering),
                ),

              // 底部安全区域
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),

          // 筛选抽屉
          if (_isFilterOpen)
            FilterDrawer(onClose: _closeFilter)
                .animate()
                .fadeIn(duration: AppDurations.fast)
                .slideX(begin: 0.1, end: 0, curve: AppCurves.smooth),

          // 评论抽屉
          if (_replyingMoment != null)
            Positioned.fill(
              child: CommentDrawer(
                moment: _replyingMoment!,
                onClose: _closeCommentDrawer,
              ),
            ),
        ],
      ),
    );
  }

  /// 收缩式 AppBar 内容
  Widget _buildAppBar(
    BuildContext context,
    dynamic childInfo,
    double expandRatio,
  ) {
    return SafeArea(
      bottom: false,
      child: ClipRect(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.pagePadding,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 展开时显示的标题
              if (expandRatio > 0.3)
                Flexible(
                  child: Opacity(
                    opacity: expandRatio,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${childInfo.name}的时间线',
                          style: AppTypography.title(context),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          childInfo.timeLabel,
                          style: AppTypography.caption(
                            context,
                          ).copyWith(color: AppColors.warmGray400),
                        ),
                      ],
                    ),
                  ),
                ),
              // 收缩时的简化标题
              if (expandRatio <= 0.3)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Opacity(
                    opacity: 1 - expandRatio,
                    child: Text('时间线', style: AppTypography.subtitle(context)),
                  ),
                ),
              if (expandRatio > 0.3) const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  /// 筛选状态指示器
  Widget _buildFilterIndicator(
    BuildContext context,
    WidgetRef ref,
    TimelineFilterState filter,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pagePadding,
        AppSpacing.sm,
        AppSpacing.pagePadding,
        0,
      ),
      child: GestureDetector(
        onTap: () => ref.read(timelineFilterProvider.notifier).reset(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppRadius.full),
            border: Border.all(color: AppColors.warmGray150, width: 1),
            boxShadow: AppShadows.subtle,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Iconsax.filter, size: 14, color: AppColors.warmOrangeDark),
              const SizedBox(width: 8),
              Text(
                '筛选中',
                style: AppTypography.caption(context).copyWith(
                  color: AppColors.warmGray600,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Iconsax.close_circle,
                size: 14,
                color: AppColors.warmGray400,
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: AppDurations.fast);
  }

  /// 底部结束指示器
  Widget _buildEndIndicator(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Container(
            width: 4,
            height: 4,
            decoration: const BoxDecoration(
              color: AppColors.warmGray300,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '暂时就这么多',
            style: AppTypography.caption(
              context,
            ).copyWith(color: AppColors.warmGray300),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirm(BuildContext context, WidgetRef ref, String id) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            title: Text('删除这条记录？', style: AppTypography.subtitle(context)),
            content: Text(
              '删除后无法恢复，确定要继续吗？',
              style: AppTypography.body(
                context,
              ).copyWith(color: AppColors.warmGray500),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(
                  '取消',
                  style: AppTypography.body(
                    context,
                  ).copyWith(color: AppColors.warmGray500),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  ref.read(momentsProvider.notifier).deleteMoment(id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(
                            Iconsax.tick_circle,
                            color: AppColors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '已删除',
                            style: AppTypography.body(
                              context,
                            ).copyWith(color: AppColors.white),
                          ),
                        ],
                      ),
                      backgroundColor: AppColors.warmGray800,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                    ),
                  );
                },
                child: Text(
                  '删除',
                  style: AppTypography.body(
                    context,
                  ).copyWith(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  void _showShareToWorld(BuildContext context, WidgetRef ref, String id) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Iconsax.global, color: AppColors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              '分享到世界功能开发中...',
              style: AppTypography.body(
                context,
              ).copyWith(color: AppColors.white),
            ),
          ],
        ),
        backgroundColor: AppColors.warmGray800,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
      ),
    );
  }
}

/// 空状态
class _EmptyTimeline extends StatelessWidget {
  final bool isFiltering;

  const _EmptyTimeline({this.isFiltering = false});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.warmGray100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isFiltering ? Iconsax.filter : Iconsax.clock,
                color: AppColors.warmGray300,
                size: 32,
              ),
            ),
            const SizedBox(height: 24),
            if (isFiltering) ...[
              Text(
                '没有找到符合条件的记录',
                style: AppTypography.subtitle(
                  context,
                ).copyWith(color: AppColors.warmGray500),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Consumer(
                builder:
                    (context, ref, _) => GestureDetector(
                      onTap: () {
                        ref.read(timelineFilterProvider.notifier).reset();
                      },
                      child: Text(
                        '清除筛选',
                        style: AppTypography.body(context).copyWith(
                          color: AppColors.warmOrangeDark,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
              ),
            ] else ...[
              Text(
                '时间线是空的',
                style: AppTypography.subtitle(
                  context,
                ).copyWith(color: AppColors.warmGray500),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '所有的记录，都会在这里汇聚',
                style: AppTypography.body(
                  context,
                ).copyWith(color: AppColors.warmGray400),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

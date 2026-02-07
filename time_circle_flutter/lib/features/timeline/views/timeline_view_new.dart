import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../presentation/providers/moments/moments_provider.dart';
import '../../../presentation/shared/aura/aura.dart';
import '../widgets/feed_card_new.dart';
import '../widgets/filter_drawer_new.dart';

/// Timeline View - Redesigned with new architecture
///
/// Features:
/// - Riverpod state management with selectors
/// - Pull-to-refresh
/// - Infinite scroll pagination
/// - Filter drawer
/// - Performance optimized ListView
class TimelineView extends ConsumerStatefulWidget {
  const TimelineView({super.key});

  @override
  ConsumerState<TimelineView> createState() => _TimelineViewState();
}

class _TimelineViewState extends ConsumerState<TimelineView> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Load more when near bottom
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(momentsNotifierProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use selectors to minimize rebuilds
    final isLoading = ref.watch(
      momentsNotifierProvider.select((s) => s.isLoading),
    );
    final hasError = ref.watch(
      momentsNotifierProvider.select((s) => s.hasError),
    );
    final errorMessage = ref.watch(
      momentsNotifierProvider.select((s) => s.errorMessage),
    );

    // Watch filtered moments (derived provider)
    final moments = ref.watch(filteredMomentsProvider);
    final hasReachedEnd = ref.watch(
      momentsNotifierProvider.select((s) => s.hasReachedEnd),
    );
    final isLoadingMore = ref.watch(
      momentsNotifierProvider.select((s) => s.isLoadingMore),
    );

    // Filter state
    final hasActiveFilters = ref.watch(
      timelineFilterProvider.select((f) => f.hasActiveFilters),
    );

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: _buildAppBar(hasActiveFilters),
      body: _buildBody(
        isLoading: isLoading,
        hasError: hasError,
        errorMessage: errorMessage,
        moments: moments,
        hasReachedEnd: hasReachedEnd,
        isLoadingMore: isLoadingMore,
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool hasActiveFilters) {
    return AppBar(
      backgroundColor: AppColors.bg,
      title: Text('时间轴', style: AppTypography.title(context)),
      actions: [
        // Filter button
        Stack(
          children: [
            AuraIconButton(
              icon: Icons.tune_rounded,
              onPressed: _showFilterDrawer,
              tooltip: '筛选',
            ),
            if (hasActiveFilters)
              Positioned(
                right: 10,
                top: 10,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildBody({
    required bool isLoading,
    required bool hasError,
    required String? errorMessage,
    required List moments,
    required bool hasReachedEnd,
    required bool isLoadingMore,
  }) {
    // Initial loading
    if (isLoading && moments.isEmpty) {
      return AuraSkeletonTemplates.feedList(count: 5);
    }

    // Error state
    if (hasError && moments.isEmpty) {
      return _buildErrorState(errorMessage ?? '加载失败');
    }

    // Empty state
    if (moments.isEmpty) {
      return _buildEmptyState();
    }

    // Content
    return RefreshIndicator(
      onRefresh: () => ref.read(momentsNotifierProvider.notifier).refresh(),
      color: AppColors.primary,
      backgroundColor: AppColors.bgElevated,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.only(
          top: AppSpacing.sm,
          bottom: 100, // Space for FAB
        ),
        // Performance: Use itemCount for virtualization
        itemCount: moments.length + (hasReachedEnd ? 0 : 1),
        // Performance: Cache extent for smoother scrolling
        cacheExtent: 500,
        itemBuilder: (context, index) {
          // Loading more indicator
          if (index == moments.length) {
            return _buildLoadingMore(isLoadingMore);
          }

          final moment = moments[index];

          // Performance: Use key for efficient updates
          return FeedCardNew(
                key: ValueKey(moment.id),
                moment: moment,
                onTap: () => context.push('/moment/${moment.id}'),
                onFavorite:
                    () => ref
                        .read(momentsNotifierProvider.notifier)
                        .toggleFavorite(moment.id),
                onComment: () => _showComments(moment.id),
                onShare: () => _showShareOptions(moment),
              )
              // Staggered entrance animation (limit to first 10 items)
              .animate(delay: Duration(milliseconds: 50 * (index.clamp(0, 10))))
              .fadeIn(duration: AppDurations.normal)
              .slideY(begin: 0.05, end: 0);
        },
      ),
    );
  }

  Widget _buildLoadingMore(bool isLoading) {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primary,
          ),
        ),
      );
    }

    // Trigger load more
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(momentsNotifierProvider.notifier).loadMore();
    });

    return const SizedBox(height: AppSpacing.lg);
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.photo_library_outlined,
              size: 64,
              color: AppColors.warmGray400,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              '还没有任何记录',
              style: AppTypography.subtitle(
                context,
              ).copyWith(color: AppColors.warmGray500),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text('点击下方按钮记录第一个时刻', style: AppTypography.caption(context)),
            const SizedBox(height: AppSpacing.xl),
            AuraButton.primary(
              label: '记录时刻',
              icon: Icons.add_rounded,
              onPressed: () => context.push('/create'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: AppColors.warmGray400,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              message,
              style: AppTypography.body(
                context,
              ).copyWith(color: AppColors.warmGray500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            AuraButton.secondary(
              label: '重试',
              icon: Icons.refresh_rounded,
              onPressed:
                  () => ref.read(momentsNotifierProvider.notifier).refresh(),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterDrawer() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const FilterDrawerNew(),
    );
  }

  void _showComments(String momentId) {
    // TODO: Implement comment drawer
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('评论功能开发中')));
  }

  void _showShareOptions(dynamic moment) {
    // TODO: Implement share options
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('分享功能开发中')));
  }
}

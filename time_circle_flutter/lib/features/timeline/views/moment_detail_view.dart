import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/providers/app_providers.dart';
import '../../../shared/widgets/media_viewer.dart';
import '../../../shared/widgets/context_tags_view.dart';
import '../../../shared/widgets/future_message_card.dart';
import '../../../shared/widgets/detail_app_bar.dart';
import '../../../shared/widgets/comment_drawer.dart';

/// 记录详情页（沉浸回看 + 回复抽屉）
class MomentDetailView extends ConsumerStatefulWidget {
  final String momentId;

  const MomentDetailView({super.key, required this.momentId});

  @override
  ConsumerState<MomentDetailView> createState() => _MomentDetailViewState();
}

class _MomentDetailViewState extends ConsumerState<MomentDetailView>
    with SingleTickerProviderStateMixin {
  late AnimationController _likeController;
  late Animation<double> _likeScale;
  bool _showCommentDrawer = false;

  @override
  void initState() {
    super.initState();
    _likeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _likeScale = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(parent: _likeController, curve: Curves.easeOut));
    _likeController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _likeController.reverse();
      }
    });
  }

  @override
  void dispose() {
    _likeController.dispose();
    super.dispose();
  }

  void _handleLike() {
    _likeController.forward();
    ref.read(momentsProvider.notifier).toggleFavorite(widget.momentId);
  }

  void _openCommentDrawer() {
    setState(() {
      _showCommentDrawer = true;
    });
  }

  void _closeCommentDrawer() {
    setState(() {
      _showCommentDrawer = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final moment = ref.watch(momentByIdProvider(widget.momentId));
    final comments = ref.watch(commentsProvider(widget.momentId));

    if (moment == null) {
      return Scaffold(
        backgroundColor: AppColors.timeBeige,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Iconsax.document_filter,
                size: 48,
                color: AppColors.warmGray300,
              ),
              const SizedBox(height: 16),
              Text(
                '这一刻，可能已经被你带走了。',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: AppColors.warmGray500),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.timeBeige,
      body: Stack(
        children: [
          // 主内容
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // 顶部导航
              const DetailAppBar(),

              // 时间叙事区
              SliverToBoxAdapter(
                child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.pagePadding,
                        8,
                        AppSpacing.pagePadding,
                        24,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            moment.timeNarrative,
                            style: Theme.of(
                              context,
                            ).textTheme.headlineSmall?.copyWith(
                              height: 1.5,
                              color: AppColors.warmGray700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text(
                                _formatDate(moment.timestamp),
                                style: Theme.of(context).textTheme.labelMedium
                                    ?.copyWith(color: AppColors.warmGray400),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                width: 4,
                                height: 4,
                                decoration: const BoxDecoration(
                                  color: AppColors.warmGray300,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                moment.author.name,
                                style: Theme.of(context).textTheme.labelMedium
                                    ?.copyWith(color: AppColors.warmGray400),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                    .animate()
                    .fadeIn(duration: 500.ms)
                    .slideY(begin: 0.05, end: 0),
              ),

              // 文字内容
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.pagePadding,
                  ),
                  child: Text(
                    moment.content,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(height: 1.8, fontSize: 17),
                  ),
                ).animate().fadeIn(duration: 600.ms, delay: 100.ms),
              ),

              // 主内容区 - 使用共享 MediaViewer
              if (moment.mediaUrl != null && moment.mediaUrl!.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.pagePadding),
                        child: MediaViewer(
                          mediaType: moment.mediaType,
                          mediaUrl: moment.mediaUrl,
                        ),
                      )
                      .animate()
                      .fadeIn(duration: 600.ms, delay: 150.ms)
                      .slideY(begin: 0.03, end: 0),
                ),

              // 语境还原区 - 使用共享 ContextTagsView
              if (moment.contextTags.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.pagePadding,
                    ),
                    child: ContextTagsView(tags: moment.contextTags),
                  ).animate().fadeIn(duration: 600.ms, delay: 200.ms),
                ),

              // 对未来的一句话 - 使用共享 FutureMessageCard
              if (moment.futureMessage != null)
                SliverToBoxAdapter(
                  child: FutureMessageCard(
                    message: moment.futureMessage!,
                    margin: const EdgeInsets.all(AppSpacing.pagePadding),
                  ).animate().fadeIn(duration: 700.ms, delay: 250.ms),
                ),

              // 互动栏（极简克制）
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.pagePadding,
                    24,
                    AppSpacing.pagePadding,
                    8,
                  ),
                  child: Row(
                    children: [
                      // 共鸣（小心形图标）
                      GestureDetector(
                        onTap: _handleLike,
                        behavior: HitTestBehavior.opaque,
                        child: AnimatedBuilder(
                          animation: _likeScale,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _likeScale.value,
                              child: Icon(
                                moment.isFavorite
                                    ? Iconsax.heart5
                                    : Iconsax.heart,
                                size: 20,
                                color:
                                    moment.isFavorite
                                        ? AppColors.heart
                                        : AppColors.warmGray400,
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(width: 20),

                      // 回复（图标 + 数字）
                      GestureDetector(
                        onTap: _openCommentDrawer,
                        behavior: HitTestBehavior.opaque,
                        child: Row(
                          children: [
                            Transform.flip(
                              flipX: true,
                              child: Icon(
                                Iconsax.message,
                                size: 20,
                                color: AppColors.warmGray400,
                              ),
                            ),
                            if (comments.isNotEmpty) ...[
                              const SizedBox(width: 6),
                              Text(
                                '${comments.length}',
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(color: AppColors.warmGray400),
                              ),
                            ],
                          ],
                        ),
                      ),

                      const Spacer(),

                      // 时间
                      Text(
                        _formatTime(moment.timestamp),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.warmGray300,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 600.ms, delay: 300.ms),
              ),

              // 底部安全区
              SliverToBoxAdapter(
                child: SizedBox(
                  height: MediaQuery.of(context).padding.bottom + 32,
                ),
              ),
            ],
          ),

          // 评论抽屉
          if (_showCommentDrawer)
            Positioned.fill(
              child: CommentDrawer(
                moment: moment,
                onClose: _closeCommentDrawer,
              ),
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}年${date.month}月${date.day}日';
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

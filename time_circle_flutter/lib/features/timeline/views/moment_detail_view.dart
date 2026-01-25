import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/models/comment.dart';
import '../../../core/providers/app_providers.dart';
import '../../../shared/widgets/media_viewer.dart';
import '../../../shared/widgets/context_tags_view.dart';
import '../../../shared/widgets/future_message_card.dart';
import '../../../shared/widgets/detail_app_bar.dart';
import '../../../shared/widgets/comment_drawer.dart';

/// 记录详情页（沉浸回看 + 回复抽屉）
/// 设计原则：温柔、安静、克制 - 让用户"感受时间"而非"阅读信息"
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

  // 交错动画延迟基数
  static const _baseDelay = 80;

  @override
  void initState() {
    super.initState();
    _likeController = AnimationController(
      duration: AppDurations.normal,
      vsync: this,
    );
    _likeScale = Tween<double>(begin: 1.0, end: 1.25).animate(
      CurvedAnimation(parent: _likeController, curve: AppCurves.gentle),
    );
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

  void _handleLike() async {
    _likeController.forward();
    try {
      await ref.read(momentsProvider.notifier).toggleFavorite(widget.momentId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('操作失败：${e.toString()}'),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
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

  String _buildTimeNarrative(String timeLabel) {
    if (timeLabel.isEmpty) {
      return '这是你留下的这一刻。';
    }
    return '这是 $timeLabel 时留下的这一刻。';
  }

  @override
  Widget build(BuildContext context) {
    final moment = ref.watch(momentByIdProvider(widget.momentId));
    final comments = ref.watch(
      commentsProvider((widget.momentId, CommentTargetType.moment)),
    );

    if (moment == null) {
      return Scaffold(
        backgroundColor: AppColors.timeBeige,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Iconsax.document_filter,
                size: 56,
                color: AppColors.warmGray300,
              ),
              const SizedBox(height: 20),
              Text(
                '这一刻，可能已经被你带走了',
                style: AppTypography.body(
                  context,
                ).copyWith(color: AppColors.warmGray400),
              ),
            ],
          ),
        ),
      );
    }

    final childInfo = ref.watch(childInfoProvider);

    // 计算动态延迟索引
    int delayIndex = 0;

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

              // 时间叙事区 - 使用衬线标题字体
              SliverToBoxAdapter(
                child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.pagePadding,
                        12,
                        AppSpacing.pagePadding,
                        28,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 时间叙事标题
                          Text(
                            _buildTimeNarrative(childInfo.timeLabel),
                            style: AppTypography.title(
                              context,
                            ).copyWith(fontSize: 22, height: 1.5),
                          ),
                          const SizedBox(height: 12),
                          // 元信息行
                          Row(
                            children: [
                              Text(
                                _formatDate(moment.timestamp),
                                style: AppTypography.caption(
                                  context,
                                ).copyWith(color: AppColors.warmGray400),
                              ),
                              Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                width: 3,
                                height: 3,
                                decoration: const BoxDecoration(
                                  color: AppColors.warmGray300,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Text(
                                moment.author.name,
                                style: AppTypography.caption(
                                  context,
                                ).copyWith(color: AppColors.warmGray400),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                    .animate()
                    .fadeIn(duration: AppDurations.slow, curve: AppCurves.enter)
                    .slideY(begin: 0.06, end: 0, curve: AppCurves.enter),
              ),

              // 文字内容 - 使用衬线正文字体，增强沉浸感
              if (moment.content.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.pagePadding,
                        ),
                        child: Text(
                          moment.content,
                          style: AppTypography.bodySerif(context),
                        ),
                      )
                      .animate()
                      .fadeIn(
                        duration: AppDurations.slow,
                        delay: Duration(
                          milliseconds: _baseDelay * ++delayIndex,
                        ),
                        curve: AppCurves.enter,
                      )
                      .slideY(begin: 0.04, end: 0, curve: AppCurves.enter),
                ),

              // 媒体内容 - 更大的展示空间
              if (moment.mediaUrl != null && moment.mediaUrl!.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.pagePadding,
                          24,
                          AppSpacing.pagePadding,
                          8,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(AppRadius.card),
                          child: MediaViewer(
                            mediaType: moment.mediaType,
                            mediaUrl: moment.mediaUrl,
                          ),
                        ),
                      )
                      .animate()
                      .fadeIn(
                        duration: AppDurations.slow,
                        delay: Duration(
                          milliseconds: _baseDelay * ++delayIndex,
                        ),
                        curve: AppCurves.enter,
                      )
                      .slideY(begin: 0.03, end: 0, curve: AppCurves.enter)
                      .scale(
                        begin: const Offset(0.98, 0.98),
                        end: const Offset(1, 1),
                        curve: AppCurves.enter,
                      ),
                ),

              // 语境标签区
              if (moment.contextTags.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.pagePadding,
                      20,
                      AppSpacing.pagePadding,
                      0,
                    ),
                    child: ContextTagsView(tags: moment.contextTags),
                  ).animate().fadeIn(
                    duration: AppDurations.slow,
                    delay: Duration(milliseconds: _baseDelay * ++delayIndex),
                    curve: AppCurves.enter,
                  ),
                ),

              // 对未来的一句话
              if (moment.futureMessage != null)
                SliverToBoxAdapter(
                  child: FutureMessageCard(
                        message: moment.futureMessage!,
                        margin: const EdgeInsets.fromLTRB(
                          AppSpacing.pagePadding,
                          24,
                          AppSpacing.pagePadding,
                          0,
                        ),
                      )
                      .animate()
                      .fadeIn(
                        duration: AppDurations.ceremony,
                        delay: Duration(
                          milliseconds: _baseDelay * ++delayIndex,
                        ),
                        curve: AppCurves.enter,
                      )
                      .slideY(begin: 0.05, end: 0, curve: AppCurves.enter),
                ),

              // 分隔线
              SliverToBoxAdapter(
                child: Container(
                      margin: const EdgeInsets.fromLTRB(
                        AppSpacing.pagePadding,
                        32,
                        AppSpacing.pagePadding,
                        20,
                      ),
                      height: 1,
                      color: AppColors.warmGray200.withValues(alpha: 0.5),
                    )
                    .animate()
                    .fadeIn(
                      duration: AppDurations.normal,
                      delay: Duration(milliseconds: _baseDelay * ++delayIndex),
                    )
                    .scaleX(begin: 0, end: 1, alignment: Alignment.centerLeft),
              ),

              // 互动栏（极简克制）
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.pagePadding,
                  ),
                  child: Row(
                    children: [
                      // 共鸣（心形图标）
                      _buildActionButton(
                        onTap: _handleLike,
                        child: AnimatedBuilder(
                          animation: _likeScale,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _likeScale.value,
                              child: Icon(
                                moment.isFavorite
                                    ? Iconsax.heart5
                                    : Iconsax.heart,
                                size: 22,
                                color:
                                    moment.isFavorite
                                        ? AppColors.heart
                                        : AppColors.warmGray400,
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(width: 24),

                      // 回复（图标 + 数字）
                      _buildActionButton(
                        onTap: _openCommentDrawer,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Transform.flip(
                              flipX: true,
                              child: Icon(
                                Iconsax.message,
                                size: 22,
                                color: AppColors.warmGray400,
                              ),
                            ),
                            if (comments.isNotEmpty) ...[
                              const SizedBox(width: 6),
                              Text(
                                '${comments.length}',
                                style: AppTypography.caption(context).copyWith(
                                  color: AppColors.warmGray400,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      const Spacer(),

                      // 时间
                      Text(
                        _formatTime(moment.timestamp),
                        style: AppTypography.micro(context).copyWith(
                          color: AppColors.warmGray300,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(
                  duration: AppDurations.slow,
                  delay: Duration(milliseconds: _baseDelay * ++delayIndex),
                  curve: AppCurves.enter,
                ),
              ),

              // 底部安全区
              SliverToBoxAdapter(
                child: SizedBox(
                  height: MediaQuery.of(context).padding.bottom + 48,
                ),
              ),
            ],
          ),

          // 评论抽屉
          if (_showCommentDrawer)
            Positioned.fill(
              child: CommentDrawer(
                targetId: moment.id,
                onClose: _closeCommentDrawer,
              ),
            ),
        ],
      ),
    );
  }

  /// 构建交互按钮（带点击反馈）
  Widget _buildActionButton({
    required VoidCallback onTap,
    required Widget child,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: child,
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

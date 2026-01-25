import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/models/comment.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/models/world_post.dart';
import '../../../shared/widgets/comment_drawer.dart';

/// 当前选中的频道
final selectedChannelProvider = StateProvider<String?>((ref) => null);

/// 根据频道筛选的帖子
final filteredWorldPostsProvider = Provider<List<WorldPost>>((ref) {
  final posts = ref.watch(worldPostsProvider);
  final selectedChannel = ref.watch(selectedChannelProvider);

  if (selectedChannel == null) {
    return posts;
  }
  return posts.where((p) => p.tag == selectedChannel).toList();
});

class WorldView extends ConsumerStatefulWidget {
  const WorldView({super.key});

  @override
  ConsumerState<WorldView> createState() => _WorldViewState();
}

class _WorldViewState extends ConsumerState<WorldView> {
  /// 下拉刷新
  Future<void> _onRefresh() async {
    await ref.read(worldPostsProvider.notifier).refresh();
  }

  void _openCommentDrawer(WorldPost post) {
    Navigator.of(context, rootNavigator: true).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        barrierColor: Colors.transparent,
        pageBuilder: (context, animation, secondaryAnimation) {
          return CommentDrawer(
            targetId: post.id,
            onClose: () => Navigator.of(context, rootNavigator: true).pop(),
          );
        },
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final posts = ref.watch(filteredWorldPostsProvider);
    final channels = ref.watch(worldChannelsSyncProvider);
    final selectedChannel = ref.watch(selectedChannelProvider);

    return Scaffold(
      backgroundColor: AppColors.warmGray100,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          color: AppColors.warmOrangeDark,
          backgroundColor: AppColors.white,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              // 顶部标题
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.pagePadding,
                    AppSpacing.xl,
                    AppSpacing.pagePadding,
                    0,
                  ),
                  child: Column(
                    children: [
                      Text(
                        '世界',
                        style: Theme.of(context).textTheme.headlineLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '其他父母的回声。安全且匿名。',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.warmGray500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 400.ms),
              ),

              // 频道标签（可滚动，有选中态）
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 20, bottom: 8),
                  child: SizedBox(
                    height: 36,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.pagePadding,
                      ),
                      itemCount: channels.length + 1, // +1 for "全部"
                      separatorBuilder:
                          (context, index) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        // 第一个是"全部"
                        if (index == 0) {
                          final isSelected = selectedChannel == null;
                          return _ChannelChip(
                            label: '全部',
                            isSelected: isSelected,
                            onTap: () {
                              ref.read(selectedChannelProvider.notifier).state =
                                  null;
                            },
                          );
                        }

                        final channel = channels[index - 1];
                        final isSelected = selectedChannel == channel.name;
                        return _ChannelChip(
                          label: channel.name,
                          isSelected: isSelected,
                          onTap: () {
                            ref.read(selectedChannelProvider.notifier).state =
                                channel.name;
                          },
                        );
                      },
                    ),
                  ),
                ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
              ),

              // 帖子列表
              if (posts.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Iconsax.message_text,
                          size: 48,
                          color: AppColors.warmGray300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '这个话题还没有回声',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.warmGray400),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.pagePadding,
                    vertical: 8,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final post = posts[index];
                      return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _WorldPostCard(
                              post: post,
                              onComment: () => _openCommentDrawer(post),
                            ),
                          )
                          .animate()
                          .fadeIn(
                            duration: 400.ms,
                            delay: Duration(milliseconds: 100 + (index * 40)),
                            curve: Curves.easeOut,
                          )
                          .slideY(begin: 0.02, end: 0);
                    }, childCount: posts.length),
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),
    );
  }
}

/// 频道标签 Chip
class _ChannelChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ChannelChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppDurations.fast,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.warmGray800 : AppColors.white,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(
            color: isSelected ? AppColors.warmGray800 : AppColors.warmGray200,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: isSelected ? AppColors.white : AppColors.warmGray600,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

/// 世界频道帖子卡片
class _WorldPostCard extends ConsumerWidget {
  final WorldPost post;
  final VoidCallback onComment;

  const _WorldPostCard({required this.post, required this.onComment});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gradient = _getGradient(post.bgGradient);
    final comments = ref.watch(
      commentsProvider((post.id, CommentTargetType.worldPost)),
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
          color: AppColors.white.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标签（小巧低调）
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Text(
              post.tag,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.warmGray600,
                fontSize: 10,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // 内容
          Text(
            '"${post.content}"',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              height: 1.7,
              fontStyle: FontStyle.italic,
              color: AppColors.warmGray800,
            ),
          ),
          const SizedBox(height: 16),

          // 底部：共鸣数 + 心形 + 评论
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // 共鸣数（如果有）
              if (post.resonanceCount > 0) ...[
                Text(
                  '${post.resonanceCount}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color:
                        post.hasResonated
                            ? AppColors.heart
                            : AppColors.warmGray500,
                  ),
                ),
                const SizedBox(width: 4),
              ],

              // 心形图标
              GestureDetector(
                onTap: () {
                  ref
                      .read(worldPostsProvider.notifier)
                      .toggleResonance(post.id);
                },
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    post.hasResonated ? Iconsax.heart5 : Iconsax.heart,
                    size: 18,
                    color:
                        post.hasResonated
                            ? AppColors.heart
                            : AppColors.warmGray500,
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // 评论按钮
              GestureDetector(
                onTap: onComment,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Row(
                    children: [
                      Icon(
                        Iconsax.message,
                        size: 18,
                        color: AppColors.warmGray500,
                      ),
                      if (comments.isNotEmpty) ...[
                        const SizedBox(width: 4),
                        Text(
                          '${comments.length}',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(color: AppColors.warmGray500),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  LinearGradient _getGradient(String type) {
    switch (type) {
      case 'orange':
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.warmOrange.withValues(alpha: 0.8),
            AppColors.warmPeach.withValues(alpha: 0.6),
          ],
        );
      case 'blue':
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.calmBlue.withValues(alpha: 0.7),
            AppColors.calmBlue.withValues(alpha: 0.4),
          ],
        );
      case 'violet':
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.mutedViolet.withValues(alpha: 0.7),
            AppColors.mutedViolet.withValues(alpha: 0.4),
          ],
        );
      case 'green':
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.softGreen.withValues(alpha: 0.7),
            AppColors.softGreen.withValues(alpha: 0.4),
          ],
        );
      case 'peach':
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.warmPeach.withValues(alpha: 0.8),
            AppColors.warmPeach.withValues(alpha: 0.5),
          ],
        );
      default:
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.warmGray100, AppColors.warmGray200],
        );
    }
  }
}

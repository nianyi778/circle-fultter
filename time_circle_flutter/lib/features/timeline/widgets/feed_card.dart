import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'dart:math' as math;

import '../../../core/theme/app_theme.dart';
import '../../../core/models/moment.dart';
import '../../../core/models/comment.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/utils/image_utils.dart';
import '../../../shared/widgets/app_popup_menu.dart';

/// 时间线卡片 - 重新设计
///
/// 设计理念：
/// - 更大的呼吸空间
/// - 优化的图片布局（更大、更沉浸）
/// - 简洁的交互
/// - 温柔的视觉层次
class FeedCard extends ConsumerStatefulWidget {
  final Moment moment;
  final VoidCallback? onTap;
  final void Function(String id)? onDelete;
  final void Function(String id)? onShareToWorld;
  final VoidCallback? onReply;

  const FeedCard({
    super.key,
    required this.moment,
    this.onTap,
    this.onDelete,
    this.onShareToWorld,
    this.onReply,
  });

  @override
  ConsumerState<FeedCard> createState() => _FeedCardState();
}

class _FeedCardState extends ConsumerState<FeedCard>
    with SingleTickerProviderStateMixin {
  bool _isMenuOpen = false;
  late AnimationController _likeController;
  late Animation<double> _likeScale;

  @override
  void initState() {
    super.initState();
    _likeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _likeScale = Tween<double>(
      begin: 1.0,
      end: 1.3,
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
    ref.read(momentsProvider.notifier).toggleFavorite(widget.moment.id);
  }

  void _openMenu() => setState(() => _isMenuOpen = true);
  void _closeMenu() => setState(() => _isMenuOpen = false);

  @override
  Widget build(BuildContext context) {
    final moment = widget.moment;
    final circleInfo = ref.watch(childInfoProvider);
    final hasMedia = moment.mediaUrl != null && moment.mediaUrl!.isNotEmpty;
    final isImageType = moment.mediaType == MediaType.image;

    return Stack(
      children: [
        // 卡片主体
        GestureDetector(
          onTap: widget.onTap,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppRadius.card),
              border: Border.all(color: AppColors.warmGray150, width: 1),
              boxShadow: AppShadows.paper,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 图片在顶部（如果有图片）
                if (hasMedia && isImageType) _buildTopImage(context),

                // 发布者信息 + 内容
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 头部：头像 + 名字 + 时间 + 更多
                      _buildHeader(context),

                      // 文字内容
                      if (moment.content.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Text(
                          moment.content,
                          style: AppTypography.body(
                            context,
                          ).copyWith(height: 1.75),
                          maxLines: 6,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],

                      // 非图片媒体
                      if (hasMedia && !isImageType) ...[
                        const SizedBox(height: 16),
                        _buildMediaSection(context),
                      ],

                      // 语境标签
                      if (moment.contextTags.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        _buildContextTags(context),
                      ],

                      // 世界分享状态
                      if (moment.isSharedToWorld) ...[
                        const SizedBox(height: 12),
                        _buildWorldShareBadge(context),
                      ],
                    ],
                  ),
                ),

                // 底部操作区
                _buildActionBar(context),

                // 评论预览
                _buildCommentPreview(context),
              ],
            ),
          ),
        ),

        // 菜单遮罩
        if (_isMenuOpen)
          Positioned.fill(
            child: GestureDetector(
              onTap: _closeMenu,
              child: Container(color: Colors.transparent),
            ),
          ),

        // 弹出菜单
        if (_isMenuOpen)
          Positioned(
            top: 60,
            right: 20,
            child: _CardMenu(
              moment: moment,
              onClose: _closeMenu,
              onDelete: widget.onDelete,
              onShareToWorld: widget.onShareToWorld,
            ),
          ),
      ],
    );
  }

  /// 顶部图片（大尺寸）
  Widget _buildTopImage(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(AppRadius.card),
        topRight: Radius.circular(AppRadius.card),
      ),
      child: AspectRatio(
        aspectRatio: 4 / 3,
        child: ImageUtils.buildImage(
          url: widget.moment.mediaUrl!,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  /// 头部信息
  Widget _buildHeader(BuildContext context) {
    final moment = widget.moment;
    final circleInfo = ref.watch(childInfoProvider);

    return Row(
      children: [
        // 头像
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.warmGray100, width: 1),
          ),
          child: ClipOval(
            child: ImageUtils.buildAvatar(url: moment.author.avatar, size: 40),
          ),
        ),
        const SizedBox(width: 12),

        // 名字和时间标签
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                moment.author.displayName,
                style: AppTypography.body(
                  context,
                ).copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 2),
              Text(
                circleInfo.timeLabel.isEmpty ? '刚开始' : circleInfo.timeLabel,
                style: AppTypography.caption(
                  context,
                ).copyWith(color: AppColors.warmGray400),
              ),
            ],
          ),
        ),

        // 更多按钮
        GestureDetector(
          onTap: _openMenu,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _isMenuOpen ? AppColors.warmGray100 : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Iconsax.more,
              size: 20,
              color:
                  _isMenuOpen ? AppColors.warmGray600 : AppColors.warmGray300,
            ),
          ),
        ),
      ],
    );
  }

  /// 媒体区（视频/音频）
  Widget _buildMediaSection(BuildContext context) {
    final moment = widget.moment;

    switch (moment.mediaType) {
      case MediaType.video:
        return ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(width: double.infinity, color: AppColors.warmGray800),
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Iconsax.play5,
                    color: AppColors.white,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
        );

      case MediaType.audio:
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.warmOrangeLight,
                AppColors.warmOrange.withValues(alpha: 0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.warmOrangeDeep.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Iconsax.play5,
                  color: AppColors.warmOrangeDark,
                  size: 18,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 波形图
                    SizedBox(
                      height: 24,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(20, (index) {
                          final height =
                              8.0 + (math.Random(index).nextDouble() * 16);
                          return Container(
                            width: 3,
                            height: height,
                            decoration: BoxDecoration(
                              color: AppColors.warmOrangeDeep.withValues(
                                alpha: 0.5,
                              ),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '0:24 · 语音记录',
                      style: AppTypography.caption(context).copyWith(
                        color: AppColors.warmOrangeDark,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );

      default:
        return const SizedBox.shrink();
    }
  }

  /// 语境标签
  Widget _buildContextTags(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children:
          widget.moment.contextTags.map((tag) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.warmGray100,
                borderRadius: BorderRadius.circular(AppRadius.chip),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(tag.emoji, style: const TextStyle(fontSize: 12)),
                  const SizedBox(width: 4),
                  Text(
                    tag.label,
                    style: AppTypography.caption(
                      context,
                    ).copyWith(color: AppColors.warmGray600),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }

  /// 世界分享状态
  Widget _buildWorldShareBadge(BuildContext context) {
    return Row(
      children: [
        Icon(Iconsax.global, size: 12, color: AppColors.warmGray400),
        const SizedBox(width: 4),
        Text(
          '已分享至世界',
          style: AppTypography.micro(
            context,
          ).copyWith(color: AppColors.warmGray400),
        ),
      ],
    );
  }

  /// 底部操作区
  Widget _buildActionBar(BuildContext context) {
    final moment = widget.moment;
    final comments = ref.watch(
      commentsProvider((moment.id, CommentTargetType.moment)),
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.warmGray100, width: 1)),
      ),
      child: Row(
        children: [
          // 共鸣
          GestureDetector(
            onTap: _handleLike,
            behavior: HitTestBehavior.opaque,
            child: AnimatedBuilder(
              animation: _likeScale,
              builder: (context, child) {
                return Transform.scale(
                  scale: _likeScale.value,
                  child: Row(
                    children: [
                      Icon(
                        moment.isFavorite ? Iconsax.heart5 : Iconsax.heart,
                        size: 20,
                        color:
                            moment.isFavorite
                                ? AppColors.heart
                                : AppColors.warmGray400,
                      ),
                      if (moment.isFavorite) ...[
                        const SizedBox(width: 4),
                        Text(
                          '共鸣',
                          style: AppTypography.caption(
                            context,
                          ).copyWith(color: AppColors.heart),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 24),

          // 回复
          GestureDetector(
            onTap: widget.onReply,
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
                    style: AppTypography.caption(
                      context,
                    ).copyWith(color: AppColors.warmGray400),
                  ),
                ],
              ],
            ),
          ),

          const Spacer(),

          // 时间戳
          Text(
            widget.moment.relativeTime,
            style: AppTypography.micro(
              context,
            ).copyWith(color: AppColors.warmGray300),
          ),
        ],
      ),
    );
  }

  /// 评论预览条
  Widget _buildCommentPreview(BuildContext context) {
    final comments = ref.watch(
      commentsProvider((widget.moment.id, CommentTargetType.moment)),
    );
    if (comments.isEmpty) return const SizedBox.shrink();

    final lastComment = comments.last;
    String previewText = lastComment.content;
    if (lastComment.replyTo != null) {
      previewText = '回复 @${lastComment.replyTo!.name} : ${lastComment.content}';
    }

    return GestureDetector(
      onTap: widget.onReply,
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.warmGray50,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          children: [
            Text(
              '${comments.length} 条回复',
              style: AppTypography.caption(context).copyWith(
                color: AppColors.warmGray600,
                fontWeight: FontWeight.w600,
              ),
            ),
            Container(
              width: 4,
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: AppColors.warmGray300,
                shape: BoxShape.circle,
              ),
            ),
            Expanded(
              child: Text(
                previewText,
                style: AppTypography.caption(
                  context,
                ).copyWith(color: AppColors.warmGray400),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 卡片操作菜单
class _CardMenu extends StatelessWidget {
  final Moment moment;
  final VoidCallback onClose;
  final void Function(String id)? onDelete;
  final void Function(String id)? onShareToWorld;

  const _CardMenu({
    required this.moment,
    required this.onClose,
    this.onDelete,
    this.onShareToWorld,
  });

  @override
  Widget build(BuildContext context) {
    final isShared = moment.isSharedToWorld;

    return AppPopupMenu(
      width: 180,
      items: [
        // 分享到世界
        if (onShareToWorld != null)
          AppPopupMenuItem(
            icon: isShared ? Iconsax.eye_slash : Iconsax.global,
            label: isShared ? '从世界撤回' : '发布到世界',
            onTap: () {
              onClose();
              onShareToWorld!(moment.id);
            },
          ),

        // 删除
        if (onDelete != null)
          AppPopupMenuItem(
            icon: Iconsax.trash,
            label: '删除',
            isDestructive: true,
            onTap: () {
              onClose();
              onDelete!(moment.id);
            },
          ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'dart:math' as math;

import '../../../core/theme/app_theme.dart';
import '../../../core/models/moment.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/utils/image_utils.dart';

/// 时间线卡片
class FeedCard extends ConsumerStatefulWidget {
  final Moment moment;
  final VoidCallback? onTap;
  final void Function(String id)? onDelete;
  final void Function(String id)? onShareToWorld;
  final VoidCallback? onReply; // 打开回复抽屉

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

  void _openMenu() {
    setState(() => _isMenuOpen = true);
  }

  void _closeMenu() {
    setState(() => _isMenuOpen = false);
  }

  @override
  Widget build(BuildContext context) {
    final moment = widget.moment;

    return Stack(
      children: [
        // 卡片主体
        GestureDetector(
          onTap: widget.onTap,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppRadius.card),
              border: Border.all(
                color: AppColors.warmGray200.withValues(alpha: 0.5),
                width: 1,
              ),
              boxShadow: AppShadows.subtle,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 发布者信息区
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 12, 12),
                  child: Row(
                    children: [
                      // 头像
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.warmGray100,
                            width: 1,
                          ),
                        ),
                        child: ImageUtils.buildAvatar(
                          url: moment.author.avatar,
                          size: 36,
                        ),
                      ),
                      const SizedBox(width: 12),

                      // 名字和时间
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              moment.author.name,
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              moment.childAgeLabel,
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(color: AppColors.warmGray400),
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
                            color:
                                _isMenuOpen
                                    ? AppColors.warmGray100
                                    : Colors.transparent,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Iconsax.more,
                            size: 20,
                            color:
                                _isMenuOpen
                                    ? AppColors.warmGray600
                                    : AppColors.warmGray300,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 文字内容
                if (moment.content.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Text(
                      moment.content,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(height: 1.6),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                // 媒体区
                _buildMediaSection(context),

                // 语境标签
                if (moment.contextTags.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          moment.contextTags.map((tag) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.warmGray100,
                                borderRadius: BorderRadius.circular(
                                  AppRadius.full,
                                ),
                                border: Border.all(
                                  color: AppColors.warmGray200.withValues(
                                    alpha: 0.5,
                                  ),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    tag.emoji,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    tag.label,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.labelSmall?.copyWith(
                                      color: AppColors.warmGray600,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                    ),
                  ),

                // 世界分享状态
                if (moment.isSharedToWorld)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: Row(
                      children: [
                        Icon(
                          Iconsax.global,
                          size: 12,
                          color: AppColors.warmGray400,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '已分享至世界',
                          style: Theme.of(
                            context,
                          ).textTheme.labelSmall?.copyWith(
                            color: AppColors.warmGray400,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),

                // 操作区（极简）
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: AppColors.warmGray100, width: 1),
                    ),
                  ),
                  child: Row(
                    children: [
                      // 共鸣（心形图标）
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
                        onTap: widget.onReply,
                        behavior: HitTestBehavior.opaque,
                        child: Builder(
                          builder: (context) {
                            final comments = ref.watch(
                              commentsProvider(moment.id),
                            );
                            return Row(
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
                                    style: Theme.of(
                                      context,
                                    ).textTheme.labelSmall?.copyWith(
                                      color: AppColors.warmGray400,
                                    ),
                                  ),
                                ],
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // 评论预览条
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
            top: 56,
            right: 12,
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

  Widget _buildMediaSection(BuildContext context) {
    final moment = widget.moment;

    switch (moment.mediaType) {
      case MediaType.image:
        if (moment.mediaUrl == null || moment.mediaUrl!.isEmpty) {
          return const SizedBox.shrink();
        }
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: AspectRatio(
              aspectRatio: 1,
              child: ImageUtils.buildImage(url: moment.mediaUrl!),
            ),
          ),
        );

      case MediaType.video:
        if (moment.mediaUrl == null || moment.mediaUrl!.isEmpty) {
          return const SizedBox.shrink();
        }
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: double.infinity,
                    color: AppColors.warmGray800,
                  ),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Iconsax.play5,
                      color: AppColors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

      case MediaType.audio:
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.warmOrange,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: AppColors.warmOrangeDeep.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.warmOrangeDeep.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Iconsax.play5,
                    color: AppColors.warmOrangeDark,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                      const SizedBox(height: 4),
                      Text(
                        '0:24 · 语音',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.warmOrangeDark,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );

      case MediaType.text:
        return const SizedBox.shrink();
    }
  }

  /// 评论预览条
  Widget _buildCommentPreview(BuildContext context) {
    final comments = ref.watch(commentsProvider(widget.moment.id));
    if (comments.isEmpty) return const SizedBox.shrink();

    final lastComment = comments.last;
    String previewText = lastComment.content;
    if (lastComment.replyTo != null) {
      previewText = '回复 @${lastComment.replyTo!.name} : ${lastComment.content}';
    }

    return GestureDetector(
      onTap: widget.onReply,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.warmGray100,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Row(
          children: [
            Text(
              '已有 ${comments.length} 条回复',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
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
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(color: AppColors.warmGray400),
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

    return Container(
      width: 200,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.warmGray100, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.warmGray900.withValues(alpha: 0.12),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 分享到世界按钮
            if (onShareToWorld != null)
              GestureDetector(
                onTap: () {
                  onClose();
                  onShareToWorld!(moment.id);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  margin: const EdgeInsets.only(bottom: 4),
                  decoration: BoxDecoration(
                    color: isShared ? AppColors.warmGray50 : AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color:
                          isShared
                              ? AppColors.warmGray200
                              : AppColors.warmGray100,
                      width: 1,
                    ),
                    boxShadow:
                        isShared
                            ? null
                            : [
                              BoxShadow(
                                color: AppColors.warmGray200.withValues(
                                  alpha: 0.5,
                                ),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                  ),
                  child: Column(
                    children: [
                      // 图标
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color:
                              isShared
                                  ? AppColors.warmGray200
                                  : AppColors.warmGray50,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isShared
                              ? Icons.visibility_off_rounded
                              : Icons.public_rounded,
                          size: 20,
                          color:
                              isShared
                                  ? AppColors.warmGray500
                                  : AppColors.warmGray600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // 文字
                      Text(
                        isShared ? '从世界撤回' : '发布到世界',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: AppColors.warmGray700,
                        ),
                      ),
                      // 当前话题提示
                      if (isShared && moment.worldTopic != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            '当前话题: ${moment.worldTopic}',
                            style: Theme.of(
                              context,
                            ).textTheme.labelSmall?.copyWith(
                              color: AppColors.warmGray400,
                              fontSize: 10,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

            // 删除按钮
            if (onDelete != null)
              GestureDetector(
                onTap: () {
                  onClose();
                  onDelete!(moment.id);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.delete_outline_rounded,
                        size: 18,
                        color: Colors.red.shade400,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '删除',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.red.shade400,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

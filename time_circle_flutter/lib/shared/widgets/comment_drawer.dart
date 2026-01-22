import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:uuid/uuid.dart';

import '../../core/theme/app_theme.dart';
import '../../core/models/comment.dart';
import '../../core/models/user.dart';
import '../../core/models/moment.dart';
import '../../core/providers/app_providers.dart';
import 'app_text_field.dart';

/// 抖音风格评论抽屉
class CommentDrawer extends ConsumerStatefulWidget {
  final Moment moment;
  final VoidCallback onClose;

  const CommentDrawer({
    super.key,
    required this.moment,
    required this.onClose,
  });

  @override
  ConsumerState<CommentDrawer> createState() => _CommentDrawerState();
}

class _CommentDrawerState extends ConsumerState<CommentDrawer>
    with SingleTickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  User? _replyTarget; // 回复目标用户

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _handleClose() async {
    await _animationController.reverse();
    widget.onClose();
  }

  void _handleReplyTo(User user) {
    setState(() {
      _replyTarget = user;
    });
    _focusNode.requestFocus();
  }

  void _cancelReplyTarget() {
    setState(() {
      _replyTarget = null;
    });
    _focusNode.requestFocus();
  }

  void _handleSubmit() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    final currentUser = ref.read(currentUserSyncProvider);
    final comment = Comment(
      id: const Uuid().v4(),
      momentId: widget.moment.id,
      author: currentUser,
      content: text,
      timestamp: DateTime.now(),
      replyTo: _replyTarget,
    );

    ref.read(commentsProvider(widget.moment.id).notifier).addComment(comment);
    _textController.clear();
    setState(() {
      _replyTarget = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final comments = ref.watch(commentsProvider(widget.moment.id));
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return GestureDetector(
      onTap: _handleClose,
      child: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return Container(
            color: Colors.black.withValues(alpha: 0.4 * _fadeAnimation.value),
            child: child,
          );
        },
        child: GestureDetector(
          onTap: () {}, // 阻止点击穿透
          child: SlideTransition(
            position: _slideAnimation,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.75,
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Column(
                  children: [
                    // 顶部标题栏
                    _buildHeader(comments.length),

                    // 评论列表
                    Expanded(
                      child: comments.isEmpty
                          ? _buildEmptyState()
                          : _buildCommentList(comments),
                    ),

                    // 底部输入区
                    _buildInputBar(bottomPadding),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.warmGray100,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 32), // 平衡右侧关闭按钮
          Expanded(
            child: Text(
              count > 0 ? '$count 条评论' : '评论',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          GestureDetector(
            onTap: _handleClose,
            child: Container(
              padding: const EdgeInsets.all(4),
              child: Icon(
                Iconsax.close_circle,
                size: 24,
                color: AppColors.warmGray400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.warmGray100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Iconsax.message,
              size: 24,
              color: AppColors.warmGray300,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '暂时还没有评论',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.warmGray400,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            '说点什么吧',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.warmGray300,
                ),
          ),
          const SizedBox(height: 80), // 给底部留空间
        ],
      ),
    );
  }

  Widget _buildCommentList(List<Comment> comments) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: comments.length + 1, // +1 for footer
      itemBuilder: (context, index) {
        if (index == comments.length) {
          // Footer
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                '没有更多评论了',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.warmGray300,
                    ),
              ),
            ),
          );
        }

        final comment = comments[index];
        return _CommentItem(
          comment: comment,
          onReply: () => _handleReplyTo(comment.author),
        );
      },
    );
  }

  Widget _buildInputBar(double bottomPadding) {
    final hasText = _textController.text.trim().isNotEmpty;

    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + bottomPadding),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(
          top: BorderSide(
            color: AppColors.warmGray100,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.warmGray900.withValues(alpha: 0.02),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 输入框（使用统一组件）
          Expanded(
            child: AppTextField(
              controller: _textController,
              focusNode: _focusNode,
              hintText: _replyTarget != null ? '' : '有什么想法，展开说说',
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _handleSubmit(),
              onChanged: (_) => setState(() {}),
              prefix: _replyTarget != null
                  ? ReplyTargetTag(
                      name: _replyTarget!.name,
                      onCancel: _cancelReplyTarget,
                    )
                  : null,
            ),
          ),

          const SizedBox(width: 12),

          // @ 按钮
          GestureDetector(
            onTap: () {
              // TODO: 打开 @ 用户选择器
            },
            child: Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                '@',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                  color: AppColors.warmGray800,
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // 发送/表情按钮
          GestureDetector(
            onTap: hasText ? _handleSubmit : null,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: hasText
                  ? Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.heart,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Iconsax.send_15,
                        size: 16,
                        color: AppColors.white,
                      ),
                    )
                  : Icon(
                      Iconsax.emoji_happy,
                      size: 24,
                      color: AppColors.warmGray800,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 单条评论项
class _CommentItem extends StatelessWidget {
  final Comment comment;
  final VoidCallback onReply;

  const _CommentItem({
    required this.comment,
    required this.onReply,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 头像
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.warmGray100,
                width: 1,
              ),
            ),
            child: ClipOval(
              child: _buildAvatar(comment.author.avatar),
            ),
          ),
          const SizedBox(width: 12),

          // 内容区
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 用户名
                Text(
                  comment.author.name,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.warmGray500,
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: 4),

                // 评论内容（含回复标记）
                _buildContent(context),

                const SizedBox(height: 8),

                // 底部信息
                Row(
                  children: [
                    // 时间
                    Text(
                      comment.relativeTime,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.warmGray400,
                            fontSize: 10,
                          ),
                    ),
                    const SizedBox(width: 16),
                    // 回复按钮
                    GestureDetector(
                      onTap: onReply,
                      child: Text(
                        '回复',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppColors.warmGray500,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 点赞区
          const SizedBox(width: 8),
          Column(
            children: [
              const SizedBox(height: 4),
              GestureDetector(
                onTap: () {
                  // TODO: 点赞评论
                },
                child: Icon(
                  Iconsax.heart,
                  size: 18,
                  color: AppColors.warmGray300,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                comment.likes > 0 ? '${comment.likes}' : '0',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.warmGray400,
                      fontSize: 10,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (comment.replyTo != null) {
      return RichText(
        text: TextSpan(
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.warmGray800,
                height: 1.5,
              ),
          children: [
            TextSpan(
              text: '回复 ',
              style: TextStyle(color: AppColors.warmGray500),
            ),
            TextSpan(
              text: '@${comment.replyTo!.name}',
              style: TextStyle(
                color: AppColors.calmBlue,
                fontWeight: FontWeight.w500,
              ),
            ),
            TextSpan(text: ' : ${comment.content}'),
          ],
        ),
      );
    }

    return Text(
      comment.content,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.warmGray800,
            height: 1.5,
          ),
    );
  }

  Widget _buildAvatar(String avatar) {
    if (avatar.isEmpty) {
      return Container(
        color: AppColors.warmGray200,
        child: Icon(
          Iconsax.user,
          size: 16,
          color: AppColors.warmGray400,
        ),
      );
    }

    if (avatar.startsWith('http://') || avatar.startsWith('https://')) {
      return CachedNetworkImage(
        imageUrl: avatar,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(color: AppColors.warmGray200),
        errorWidget: (context, url, error) =>
            Container(color: AppColors.warmGray200),
      );
    }

    return Container(
      color: AppColors.warmGray200,
      child: Icon(
        Iconsax.user,
        size: 16,
        color: AppColors.warmGray400,
      ),
    );
  }
}

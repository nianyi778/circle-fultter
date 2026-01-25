import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:uuid/uuid.dart';

import '../../core/theme/app_theme.dart';
import '../../core/models/comment.dart';
import '../../core/models/user.dart';
import '../../core/providers/app_providers.dart';

/// 评论抽屉 - 温柔、克制的交互体验
/// 支持 Moment 和 WorldPost 等任何可评论的内容
class CommentDrawer extends ConsumerStatefulWidget {
  final String targetId; // 可以是 moment.id 或 worldPost.id
  final CommentTargetType targetType; // 目标类型
  final VoidCallback onClose;

  const CommentDrawer({
    super.key,
    required this.targetId,
    this.targetType = CommentTargetType.moment,
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
      duration: AppDurations.pageTransition,
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: AppCurves.enter),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: AppCurves.standard),
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
      targetId: widget.targetId,
      targetType: widget.targetType,
      author: currentUser,
      content: text,
      timestamp: DateTime.now(),
      replyTo: _replyTarget,
    );

    ref
        .read(commentsProvider((widget.targetId, widget.targetType)).notifier)
        .addComment(comment);
    _textController.clear();
    setState(() {
      _replyTarget = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final comments = ref.watch(
      commentsProvider((widget.targetId, widget.targetType)),
    );
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Material(
      color: Colors.transparent,
      child: GestureDetector(
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
                  height: MediaQuery.of(context).size.height * 0.7,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(AppRadius.xl),
                    ),
                    boxShadow: AppShadows.elevated,
                  ),
                  child: Column(
                    children: [
                      // 顶部标题栏
                      _buildHeader(comments.length),

                      // 评论列表
                      Expanded(
                        child:
                            comments.isEmpty
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
      ),
    );
  }

  Widget _buildHeader(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.warmGray200.withValues(alpha: 0.5),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 32), // 平衡右侧关闭按钮
          Expanded(
            child: Text(
              count > 0 ? '$count 条回应' : '回应',
              textAlign: TextAlign.center,
              style: AppTypography.subtitle(context).copyWith(fontSize: 15),
            ),
          ),
          GestureDetector(
            onTap: _handleClose,
            child: Container(
              padding: const EdgeInsets.all(4),
              child: Icon(Icons.close, size: 22, color: AppColors.warmGray400),
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
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.warmGray100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Iconsax.message,
              size: 28,
              color: AppColors.warmGray300,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '还没有人回应',
            style: AppTypography.body(
              context,
            ).copyWith(color: AppColors.warmGray400),
          ),
          const SizedBox(height: 6),
          Text(
            '留下你的想法吧',
            style: AppTypography.caption(
              context,
            ).copyWith(color: AppColors.warmGray300),
          ),
          const SizedBox(height: 80), // 给底部留空间
        ],
      ),
    );
  }

  Widget _buildCommentList(List<Comment> comments) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      itemCount: comments.length + 1, // +1 for footer
      itemBuilder: (context, index) {
        if (index == comments.length) {
          // Footer
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 28),
            child: Center(
              child: Text(
                '— 到底了 —',
                style: AppTypography.micro(
                  context,
                ).copyWith(color: AppColors.warmGray300, letterSpacing: 2),
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
    // 获取底部安全区域高度（用于 home indicator）
    final bottomSafeArea = MediaQuery.of(context).padding.bottom;
    // 如果键盘弹出，使用键盘高度；否则只需要考虑底部安全区域
    final actualBottomPadding =
        bottomPadding > 0 ? bottomPadding : bottomSafeArea;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 12, 20, 12 + actualBottomPadding),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(
          top: BorderSide(
            color: AppColors.warmGray200.withValues(alpha: 0.3),
            width: 0.5,
          ),
        ),
        boxShadow: AppShadows.subtle,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 圆角输入框
          Expanded(
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.warmGray100,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              child: Row(
                children: [
                  // 回复标签
                  if (_replyTarget != null) ...[
                    Text(
                      '回复 ${_replyTarget!.name}',
                      style: AppTypography.caption(context).copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.warmGray500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: _cancelReplyTarget,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: AppColors.warmGray200,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          size: 10,
                          color: AppColors.warmGray500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],

                  // 文本输入
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      focusNode: _focusNode,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _handleSubmit(),
                      onChanged: (_) => setState(() {}),
                      cursorColor: AppColors.warmGray600,
                      cursorWidth: 1.5,
                      style: AppTypography.body(context).copyWith(
                        fontSize: 14,
                        height: 1.4,
                        color: AppColors.warmGray800,
                      ),
                      decoration: InputDecoration(
                        hintText: _replyTarget != null ? '' : '有什么想法，说说看',
                        hintStyle: AppTypography.body(
                          context,
                        ).copyWith(fontSize: 14, color: AppColors.warmGray400),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                        filled: false,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 12),

          // 发送按钮
          GestureDetector(
            onTap: hasText ? _handleSubmit : null,
            child: AnimatedContainer(
              duration: AppDurations.fast,
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: hasText ? AppColors.warmGray800 : AppColors.warmGray200,
                shape: BoxShape.circle,
              ),
              child: Transform.rotate(
                angle: -0.65, // 约 -37 度，将倾斜的图标扶正
                child: Icon(
                  Iconsax.send_15,
                  size: 18,
                  color: hasText ? AppColors.white : AppColors.warmGray400,
                ),
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

  const _CommentItem({required this.comment, required this.onReply});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 头像
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.warmGray200.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            child: ClipOval(child: _buildAvatar(comment.author.avatar)),
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
                  style: AppTypography.caption(context).copyWith(
                    color: AppColors.warmGray500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),

                // 评论内容（含回复标记）
                _buildContent(context),

                const SizedBox(height: 10),

                // 底部信息
                Row(
                  children: [
                    // 时间
                    Text(
                      comment.relativeTime,
                      style: AppTypography.micro(
                        context,
                      ).copyWith(color: AppColors.warmGray400),
                    ),
                    const SizedBox(width: 20),
                    // 回复按钮
                    GestureDetector(
                      onTap: onReply,
                      child: Text(
                        '回复',
                        style: AppTypography.micro(context).copyWith(
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
              if (comment.likes > 0) ...[
                const SizedBox(height: 2),
                Text(
                  '${comment.likes}',
                  style: AppTypography.micro(
                    context,
                  ).copyWith(color: AppColors.warmGray400),
                ),
              ],
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
          style: AppTypography.body(
            context,
          ).copyWith(fontSize: 14, height: 1.6, color: AppColors.warmGray700),
          children: [
            TextSpan(
              text: '回复 ',
              style: TextStyle(color: AppColors.warmGray400),
            ),
            TextSpan(
              text: '@${comment.replyTo!.name}',
              style: TextStyle(
                color: AppColors.calmBlueDeep,
                fontWeight: FontWeight.w500,
              ),
            ),
            TextSpan(text: ' ${comment.content}'),
          ],
        ),
      );
    }

    return Text(
      comment.content,
      style: AppTypography.body(
        context,
      ).copyWith(fontSize: 14, height: 1.6, color: AppColors.warmGray700),
    );
  }

  Widget _buildAvatar(String avatar) {
    if (avatar.isEmpty) {
      return Container(
        color: AppColors.warmGray100,
        child: Icon(Iconsax.user, size: 18, color: AppColors.warmGray300),
      );
    }

    if (avatar.startsWith('http://') || avatar.startsWith('https://')) {
      return CachedNetworkImage(
        imageUrl: avatar,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(color: AppColors.warmGray100),
        errorWidget:
            (context, url, error) => Container(color: AppColors.warmGray100),
      );
    }

    return Container(
      color: AppColors.warmGray100,
      child: Icon(Iconsax.user, size: 18, color: AppColors.warmGray300),
    );
  }
}

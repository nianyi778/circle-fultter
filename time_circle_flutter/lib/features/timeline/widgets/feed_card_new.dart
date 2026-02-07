import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../domain/entities/moment.dart';
import '../../../presentation/shared/aura/aura.dart';

/// Feed Card - Timeline item component
///
/// Displays a single moment in the timeline.
/// Optimized for performance with const constructors and memoization.
class FeedCardNew extends StatelessWidget {
  final Moment moment;
  final VoidCallback onTap;
  final VoidCallback? onFavorite;
  final VoidCallback? onComment;
  final VoidCallback? onShare;
  final VoidCallback? onLongPress;

  const FeedCardNew({
    super.key,
    required this.moment,
    required this.onTap,
    this.onFavorite,
    this.onComment,
    this.onShare,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pagePadding,
        vertical: AppSpacing.sm,
      ),
      child: AuraCard(
        onTap: onTap,
        onLongPress: onLongPress,
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(context),

            // Content
            if (moment.content.isNotEmpty) _buildContent(context),

            // Media
            if (moment.hasMedia) _buildMedia(context),

            // Footer
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.cardPadding,
        AppSpacing.cardPadding,
        AppSpacing.cardPadding,
        AppSpacing.sm,
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.warmGray200,
            backgroundImage:
                moment.author.avatar.isNotEmpty
                    ? CachedNetworkImageProvider(moment.author.avatar)
                    : null,
            child:
                moment.author.avatar.isEmpty
                    ? Text(
                      moment.author.initials,
                      style: const TextStyle(
                        color: AppColors.warmGray600,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    )
                    : null,
          ),
          const SizedBox(width: AppSpacing.md),
          // Author info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  moment.author.name,
                  style: AppTypography.subtitle(
                    context,
                  ).copyWith(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  moment.relativeTime,
                  style: AppTypography.caption(context),
                ),
              ],
            ),
          ),
          // Menu
          AuraIconButton(
            icon: Icons.more_horiz_rounded,
            size: 20,
            onPressed: () => _showMenu(context),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.cardPadding,
        0,
        AppSpacing.cardPadding,
        AppSpacing.sm,
      ),
      child: Text(
        moment.content,
        style: AppTypography.body(context),
        maxLines: 5,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildMedia(BuildContext context) {
    final urls = moment.mediaUrls;
    final count = urls.length;

    if (count == 0) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.cardPadding,
        0,
        AppSpacing.cardPadding,
        AppSpacing.sm,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child:
            count == 1 ? _buildSingleMedia(urls.first) : _buildMediaGrid(urls),
      ),
    );
  }

  Widget _buildSingleMedia(String url) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.cover,
        memCacheWidth: 600,
        placeholder: (_, __) => const AuraSkeleton(height: 200),
        errorWidget:
            (_, __, ___) => Container(
              color: AppColors.warmGray200,
              child: const Icon(
                Icons.broken_image,
                color: AppColors.warmGray400,
              ),
            ),
      ),
    );
  }

  Widget _buildMediaGrid(List<String> urls) {
    final displayUrls = urls.take(9).toList();
    final remaining = urls.length - 9;
    final columns = displayUrls.length == 2 ? 2 : 3;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
      ),
      itemCount: displayUrls.length,
      itemBuilder: (context, index) {
        final isLast = index == displayUrls.length - 1 && remaining > 0;

        return Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: displayUrls[index],
              fit: BoxFit.cover,
              memCacheWidth: 300,
              placeholder:
                  (_, __) => const AuraSkeleton(height: 100, borderRadius: 0),
              errorWidget:
                  (_, __, ___) => Container(
                    color: AppColors.warmGray200,
                    child: const Icon(
                      Icons.broken_image,
                      color: AppColors.warmGray400,
                    ),
                  ),
            ),
            if (isLast)
              Container(
                color: Colors.black.withValues(alpha: 0.5),
                child: Center(
                  child: Text(
                    '+$remaining',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.cardPadding,
        AppSpacing.xs,
        AppSpacing.cardPadding,
        AppSpacing.cardPadding,
      ),
      child: Row(
        children: [
          // Context tags
          if (moment.contextTags.isNotEmpty) ...[
            if (moment.contextTags.myMood != null)
              _buildTag(moment.contextTags.myMood!),
            if (moment.contextTags.atmosphere != null) ...[
              const SizedBox(width: AppSpacing.xs),
              _buildTag(moment.contextTags.atmosphere!),
            ],
          ],
          const Spacer(),
          // Actions
          _ActionButton(
            icon: moment.isFavorite ? Icons.favorite : Icons.favorite_border,
            isActive: moment.isFavorite,
            onTap: onFavorite,
          ),
          _ActionButton(
            icon: Icons.chat_bubble_outline_rounded,
            onTap: onComment,
          ),
          _ActionButton(icon: Icons.share_outlined, onTap: onShare),
        ],
      ),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.warmGray100,
        borderRadius: BorderRadius.circular(AppRadius.chip),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12, color: AppColors.warmGray600),
      ),
    );
  }

  void _showMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.edit_outlined),
                  title: const Text('编辑'),
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Navigate to edit
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.public_outlined),
                  title: const Text('分享到世界'),
                  onTap: () {
                    Navigator.pop(context);
                    onShare?.call();
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.delete_outline,
                    color: AppColors.dangerDark,
                  ),
                  title: Text(
                    '删除',
                    style: TextStyle(color: AppColors.dangerDark),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Show delete confirmation
                  },
                ),
              ],
            ),
          ),
    );
  }
}

/// Action button for feed card footer
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final VoidCallback? onTap;

  const _ActionButton({required this.icon, this.isActive = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          HapticFeedback.selectionClick();
          onTap!();
        }
      },
      child: SizedBox(
        width: 44, // Minimum touch target
        height: 44,
        child: Center(
          child: Icon(
            icon,
            size: 22,
            color: isActive ? AppColors.heart : AppColors.warmGray500,
          ),
        ),
      ),
    );
  }
}

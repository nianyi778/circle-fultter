import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:iconsax/iconsax.dart';
import 'dart:math' as math;

import '../../../core/theme/app_theme.dart';
import '../../../core/models/moment.dart';
import '../../../core/providers/app_providers.dart';

/// 检查是否为有效的网络 URL
bool _isNetworkUrl(String url) {
  if (url.isEmpty) return false;
  return url.startsWith('http://') || url.startsWith('https://');
}

/// 检查是否为本地文件路径
bool _isLocalFile(String path) {
  if (path.isEmpty) return false;
  return path.startsWith('/') || path.startsWith('file://');
}

/// 时间线卡片
class FeedCard extends ConsumerWidget {
  final Moment moment;
  final VoidCallback? onTap;

  const FeedCard({
    super.key,
    required this.moment,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: onTap,
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
                    child: ClipOval(
                      child: _isNetworkUrl(moment.author.avatar)
                          ? CachedNetworkImage(
                              imageUrl: moment.author.avatar,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: AppColors.warmGray200,
                              ),
                              errorWidget: (context, url, error) => _buildAvatarPlaceholder(),
                            )
                          : _buildAvatarPlaceholder(),
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
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          moment.childAgeLabel,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.warmGray400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // 更多按钮
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Iconsax.more),
                    color: AppColors.warmGray300,
                    iconSize: 20,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                  ),
                ],
              ),
            ),

            // 媒体区
            _buildMediaSection(context),

            // 文字内容
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Text(
                moment.content,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  height: 1.6,
                ),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // 语境标签
            if (moment.contextTags.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: moment.contextTags.map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.warmGray100,
                        borderRadius: BorderRadius.circular(AppRadius.full),
                        border: Border.all(
                          color: AppColors.warmGray200.withValues(alpha: 0.5),
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
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppColors.warmGray600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),

            // 操作区
            Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: AppColors.warmGray100,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  // 共鸣按钮
                  _ActionButton(
                    icon: moment.isFavorite ? Iconsax.heart5 : Iconsax.heart,
                    label: '共鸣',
                    isActive: moment.isFavorite,
                    activeColor: AppColors.heart,
                    onTap: () {
                      ref.read(momentsProvider.notifier).toggleFavorite(moment.id);
                    },
                  ),
                  const SizedBox(width: 24),
                  
                  // 留言按钮
                  _ActionButton(
                    icon: Iconsax.message,
                    label: '留言',
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaSection(BuildContext context) {
    switch (moment.mediaType) {
      case MediaType.image:
        if (moment.mediaUrl == null || moment.mediaUrl!.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: AspectRatio(
              aspectRatio: 1,
              child: _buildImageWidget(moment.mediaUrl!),
            ),
          ),
        );
        
      case MediaType.video:
        if (moment.mediaUrl == null || moment.mediaUrl!.isEmpty) return const SizedBox.shrink();
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
                      // 假波形
                      SizedBox(
                        height: 24,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(20, (index) {
                            final height = 8.0 + (math.Random(index).nextDouble() * 16);
                            return Container(
                              width: 3,
                              height: height,
                              decoration: BoxDecoration(
                                color: AppColors.warmOrangeDeep.withValues(alpha: 0.5),
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
}

/// 操作按钮
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final Color? activeColor;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    this.isActive = false,
    this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive 
        ? (activeColor ?? AppColors.warmGray800)
        : AppColors.warmGray400;
        
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// 构建头像占位符
Widget _buildAvatarPlaceholder() {
  return Container(
    color: AppColors.warmGray200,
    child: const Icon(
      Icons.person,
      color: AppColors.warmGray400,
      size: 18,
    ),
  );
}

/// 构建图片组件（支持网络和本地）
Widget _buildImageWidget(String url) {
  if (_isLocalFile(url)) {
    return Image.file(
      File(url),
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        color: AppColors.warmGray100,
        child: const Icon(Iconsax.image, color: AppColors.warmGray300),
      ),
    );
  } else if (_isNetworkUrl(url)) {
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(color: AppColors.warmGray100),
      errorWidget: (context, url, error) => Container(
        color: AppColors.warmGray100,
        child: const Icon(Iconsax.image, color: AppColors.warmGray300),
      ),
    );
  } else {
    return Container(
      color: AppColors.warmGray100,
      child: const Icon(Iconsax.image, color: AppColors.warmGray300),
    );
  }
}

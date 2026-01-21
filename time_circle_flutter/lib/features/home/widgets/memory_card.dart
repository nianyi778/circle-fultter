import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/theme/app_theme.dart';
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

/// 去年的今天 - 回忆卡片
class MemoryCard extends ConsumerWidget {
  const MemoryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final moments = ref.watch(momentsProvider);
    
    // 模拟获取去年今天的记录（实际应该筛选日期匹配的）
    // 这里先展示第一条有媒体的记录作为示例
    final featuredMoment = moments.firstWhere(
      (m) => m.mediaUrl != null,
      orElse: () => moments.first,
    );

    return Container(
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
          // 标题区
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.warmPeachDeep,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '去年的今天',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.warmGray600,
                    letterSpacing: 1,
                  ),
                ),
                const Spacer(),
                Icon(
                  Iconsax.arrow_right_3,
                  size: 16,
                  color: AppColors.warmGray400,
                ),
              ],
            ),
          ),

          // 图片区
          if (featuredMoment.mediaUrl != null && featuredMoment.mediaUrl!.isNotEmpty)
            ClipRRect(
              child: AspectRatio(
                aspectRatio: 16 / 10,
                child: _buildMediaImage(featuredMoment.mediaUrl!),
              ),
            ),

          // 内容区
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  featuredMoment.content,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    height: 1.6,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      featuredMoment.childAgeLabel,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.warmGray400,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 3,
                      height: 3,
                      decoration: const BoxDecoration(
                        color: AppColors.warmGray300,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      featuredMoment.author.name,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.warmGray400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建图片组件（支持网络和本地）
  Widget _buildMediaImage(String url) {
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
}

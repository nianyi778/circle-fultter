import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:math' as math;

import '../../core/theme/app_theme.dart';
import '../../core/models/moment.dart';

/// 媒体内容统一渲染组件
/// 支持图片、视频、音频的展示
class MediaViewer extends StatelessWidget {
  final MediaType mediaType;
  final String? mediaUrl;
  final double? aspectRatio;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;

  const MediaViewer({
    super.key,
    required this.mediaType,
    this.mediaUrl,
    this.aspectRatio,
    this.borderRadius,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (mediaType == MediaType.text || mediaUrl == null) {
      return const SizedBox.shrink();
    }

    final radius = borderRadius ?? BorderRadius.circular(AppRadius.md);

    return GestureDetector(
      onTap: onTap,
      child: switch (mediaType) {
        MediaType.image => _ImageViewer(
            url: mediaUrl!,
            borderRadius: radius,
          ),
        MediaType.video => _VideoViewer(
            url: mediaUrl!,
            borderRadius: radius,
            aspectRatio: aspectRatio ?? 16 / 9,
          ),
        MediaType.audio => const _AudioViewer(),
        MediaType.text => const SizedBox.shrink(),
      },
    );
  }
}

/// 图片查看器
class _ImageViewer extends StatelessWidget {
  final String url;
  final BorderRadius borderRadius;

  const _ImageViewer({
    required this.url,
    required this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.cover,
        width: double.infinity,
        placeholder: (context, url) => Container(
          height: 200,
          color: AppColors.warmGray100,
          child: const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.warmGray300,
            ),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          height: 200,
          color: AppColors.warmGray100,
          child: const Center(
            child: Icon(
              Iconsax.image,
              color: AppColors.warmGray300,
              size: 48,
            ),
          ),
        ),
      ),
    );
  }
}

/// 视频查看器
class _VideoViewer extends StatelessWidget {
  final String url;
  final BorderRadius borderRadius;
  final double aspectRatio;

  const _VideoViewer({
    required this.url,
    required this.borderRadius,
    required this.aspectRatio,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: AppShadows.soft,
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: AspectRatio(
          aspectRatio: aspectRatio,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.cover,
                width: double.infinity,
                color: Colors.black.withValues(alpha: 0.2),
                colorBlendMode: BlendMode.darken,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Iconsax.play5,
                      color: AppColors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '那一刻，被你记录下来了。',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 音频查看器
class _AudioViewer extends StatelessWidget {
  const _AudioViewer();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.warmOrange,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: AppColors.warmOrangeDeep.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.warmOrangeDeep.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Iconsax.play5,
              color: AppColors.warmOrangeDark,
              size: 32,
            ),
          ),
          const SizedBox(height: 20),
          // 波形
          const AudioWaveform(),
          const SizedBox(height: 16),
          Text(
            '0:24',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.warmOrangeDark,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// 音频波形组件
class AudioWaveform extends StatelessWidget {
  final int barCount;
  final double maxHeight;
  final double minHeight;
  final Color? color;

  const AudioWaveform({
    super.key,
    this.barCount = 30,
    this.maxHeight = 48,
    this.minHeight = 12,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: maxHeight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(barCount, (index) {
          final height = minHeight + (math.Random(index).nextDouble() * (maxHeight - minHeight));
          return Container(
            width: 4,
            height: height,
            decoration: BoxDecoration(
              color: color ?? AppColors.warmOrangeDeep.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(2),
            ),
          );
        }),
      ),
    );
  }
}

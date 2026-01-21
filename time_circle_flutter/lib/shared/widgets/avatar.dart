import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../core/theme/app_theme.dart';

/// 圆形头像组件
class CircleAvatar extends StatelessWidget {
  final String imageUrl;
  final double size;
  final String? badge;
  final Color? borderColor;
  final double borderWidth;

  const CircleAvatar({
    super.key,
    required this.imageUrl,
    this.size = 40,
    this.badge,
    this.borderColor,
    this.borderWidth = 2,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: borderColor != null
                ? Border.all(color: borderColor!, width: borderWidth)
                : null,
            boxShadow: AppShadows.subtle,
          ),
          child: ClipOval(
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: AppColors.warmGray200,
              ),
              errorWidget: (context, url, error) => Container(
                color: AppColors.warmGray200,
                child: Icon(
                  Icons.person,
                  color: AppColors.warmGray400,
                  size: size * 0.5,
                ),
              ),
            ),
          ),
        ),
        if (badge != null)
          Positioned(
            bottom: -2,
            right: -2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.warmGray800,
                borderRadius: BorderRadius.circular(AppRadius.full),
                border: Border.all(
                  color: AppColors.white,
                  width: 1.5,
                ),
              ),
              child: Text(
                badge!,
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// 头像叠放组件
class AvatarStack extends StatelessWidget {
  final List<String> avatarUrls;
  final double size;
  final double overlap;
  final int maxDisplay;

  const AvatarStack({
    super.key,
    required this.avatarUrls,
    this.size = 24,
    this.overlap = 8,
    this.maxDisplay = 3,
  });

  @override
  Widget build(BuildContext context) {
    final displayCount = avatarUrls.length > maxDisplay 
        ? maxDisplay 
        : avatarUrls.length;
    
    return SizedBox(
      width: size + (displayCount - 1) * (size - overlap),
      height: size,
      child: Stack(
        children: [
          for (int i = 0; i < displayCount; i++)
            Positioned(
              left: i * (size - overlap),
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.white,
                    width: 1.5,
                  ),
                ),
                child: ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: avatarUrls[i],
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: AppColors.warmGray300,
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: AppColors.warmGray300,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

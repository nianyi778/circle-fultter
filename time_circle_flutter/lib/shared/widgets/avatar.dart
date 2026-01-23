import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/image_utils.dart';

/// 圆形头像组件
/// 注意：重命名为 AppAvatar 以避免与 Flutter 内置 CircleAvatar 冲突
class AppAvatar extends StatelessWidget {
  final String imageUrl;
  final double size;
  final String? badge;
  final Color? borderColor;
  final double borderWidth;

  const AppAvatar({
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
            border:
                borderColor != null
                    ? Border.all(color: borderColor!, width: borderWidth)
                    : null,
            boxShadow: AppShadows.subtle,
          ),
          child: ImageUtils.buildAvatar(url: imageUrl, size: size),
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
                border: Border.all(color: AppColors.white, width: 1.5),
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
    final displayCount =
        avatarUrls.length > maxDisplay ? maxDisplay : avatarUrls.length;

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
                  border: Border.all(color: AppColors.white, width: 1.5),
                ),
                child: ImageUtils.buildAvatar(url: avatarUrls[i], size: size),
              ),
            ),
        ],
      ),
    );
  }
}

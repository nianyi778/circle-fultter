import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:iconsax/iconsax.dart';

import '../theme/app_theme.dart';

/// 图片/URL 工具类
/// 统一处理网络图片、本地图片的加载和验证
class ImageUtils {
  ImageUtils._();

  /// 检查是否为有效的网络 URL
  static bool isNetworkUrl(String? url) {
    if (url == null || url.isEmpty) return false;
    return url.startsWith('http://') || url.startsWith('https://');
  }

  /// 检查是否为本地文件路径
  static bool isLocalFile(String? path) {
    if (path == null || path.isEmpty) return false;
    return path.startsWith('/') || path.startsWith('file://');
  }

  /// 检查 URL 是否有效（包含 scheme 和 authority）
  static bool isValidUrl(String? url) {
    if (url == null || url.isEmpty) return false;
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && uri.hasAuthority;
    } catch (_) {
      return false;
    }
  }

  /// 构建图片 Widget（自动判断网络/本地）
  static Widget buildImage({
    required String? url,
    BoxFit fit = BoxFit.cover,
    double? width,
    double? height,
    BorderRadius? borderRadius,
    Widget? placeholder,
    Widget? errorWidget,
    int? memCacheWidth,
    int? memCacheHeight,
  }) {
    final defaultPlaceholder = placeholder ?? _buildDefaultPlaceholder();
    final defaultError = errorWidget ?? _buildDefaultError();

    Widget image;

    if (url == null || url.isEmpty) {
      image = defaultError;
    } else if (isLocalFile(url)) {
      image = Image.file(
        File(url),
        fit: fit,
        width: width,
        height: height,
        cacheWidth: memCacheWidth,
        cacheHeight: memCacheHeight,
        errorBuilder: (context, error, stackTrace) => defaultError,
      );
    } else if (isNetworkUrl(url)) {
      image = CachedNetworkImage(
        imageUrl: url,
        fit: fit,
        width: width,
        height: height,
        memCacheWidth: memCacheWidth,
        memCacheHeight: memCacheHeight,
        placeholder: (context, url) => defaultPlaceholder,
        errorWidget: (context, url, error) => defaultError,
      );
    } else {
      image = defaultError;
    }

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius, child: image);
    }

    return image;
  }

  /// 构建头像 Widget
  static Widget buildAvatar({
    required String? url,
    required double size,
    Widget? placeholder,
  }) {
    final defaultPlaceholder =
        placeholder ??
        Container(
          color: AppColors.warmGray200,
          child: Icon(
            Icons.person,
            color: AppColors.warmGray400,
            size: size * 0.5,
          ),
        );

    if (url == null || url.isEmpty || !isValidUrl(url)) {
      return ClipOval(
        child: SizedBox(width: size, height: size, child: defaultPlaceholder),
      );
    }

    return ClipOval(
      child: SizedBox(
        width: size,
        height: size,
        child: CachedNetworkImage(
          imageUrl: url,
          fit: BoxFit.cover,
          memCacheWidth: (size * 2).toInt(),
          memCacheHeight: (size * 2).toInt(),
          placeholder:
              (context, url) => Container(color: AppColors.warmGray200),
          errorWidget: (context, url, error) => defaultPlaceholder,
        ),
      ),
    );
  }

  static Widget _buildDefaultPlaceholder() {
    return Container(
      color: AppColors.warmGray100,
      child: const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: AppColors.warmGray300,
        ),
      ),
    );
  }

  static Widget _buildDefaultError() {
    return Container(
      color: AppColors.warmGray100,
      child: const Center(
        child: Icon(Iconsax.image, color: AppColors.warmGray300, size: 32),
      ),
    );
  }
}

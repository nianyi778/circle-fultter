import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// 念念 App Logo 组件
///
/// 支持多种尺寸：
/// - small: 24x24 (导航栏等小图标)
/// - medium: 40x40 (默认，右上角等)
/// - large: 64x64 (设置页等)
/// - custom: 自定义尺寸
class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.size = AppLogoSize.medium,
    this.customSize,
    this.onTap,
  });

  /// Logo 尺寸
  final AppLogoSize size;

  /// 自定义尺寸（当 size 为 custom 时使用）
  final double? customSize;

  /// 点击回调
  final VoidCallback? onTap;

  double get _size {
    switch (size) {
      case AppLogoSize.small:
        return 24;
      case AppLogoSize.medium:
        return 40;
      case AppLogoSize.large:
        return 64;
      case AppLogoSize.custom:
        return customSize ?? 40;
    }
  }

  @override
  Widget build(BuildContext context) {
    final logo = SvgPicture.asset(
      'assets/images/logo.svg',
      width: _size,
      height: _size,
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: logo,
      );
    }

    return logo;
  }
}

/// Logo 尺寸枚举
enum AppLogoSize { small, medium, large, custom }

// Aura 页面转场动画
//
// 提供统一的页面转场效果
// 符合 Aura 设计系统的动效规范

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../animations/animation_config.dart';

/// Aura 页面转场
class AuraPageTransitions {
  AuraPageTransitions._();

  /// 标准向前导航 - 柔和上滑 + 渐显
  ///
  /// 用于大多数页面跳转
  static Page<T> slideUp<T>({
    required Widget child,
    required LocalKey key,
    String? name,
    Object? arguments,
    String? restorationId,
  }) {
    return CustomTransitionPage<T>(
      key: key,
      child: child,
      name: name,
      arguments: arguments,
      restorationId: restorationId,
      transitionDuration: AuraDurations.pageTransition,
      reverseTransitionDuration: AuraDurations.normal,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // 无障碍模式
        if (AuraAnimationConfig.shouldReduceMotion(context)) {
          return FadeTransition(opacity: animation, child: child);
        }

        final slideAnimation = Tween<Offset>(
          begin: const Offset(0, 0.05),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: AuraCurves.enter));

        final fadeAnimation = CurvedAnimation(
          parent: animation,
          curve: AuraCurves.enter,
        );

        return FadeTransition(
          opacity: fadeAnimation,
          child: SlideTransition(position: slideAnimation, child: child),
        );
      },
    );
  }

  /// 淡入淡出 - 用于 Tab 切换
  static Page<T> fade<T>({
    required Widget child,
    required LocalKey key,
    String? name,
    Object? arguments,
  }) {
    return CustomTransitionPage<T>(
      key: key,
      child: child,
      name: name,
      arguments: arguments,
      transitionDuration: AuraDurations.normal,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: AuraCurves.standard,
          ),
          child: child,
        );
      },
    );
  }

  /// 模态页面 - 从底部弹起
  ///
  /// 用于创建页、详情页等全屏模态
  static Page<T> modal<T>({
    required Widget child,
    required LocalKey key,
    String? name,
    Object? arguments,
    bool barrierDismissible = true,
  }) {
    return CustomTransitionPage<T>(
      key: key,
      child: child,
      name: name,
      arguments: arguments,
      opaque: false,
      barrierColor: Colors.black54,
      barrierDismissible: barrierDismissible,
      transitionDuration: AuraDurations.pageTransition,
      reverseTransitionDuration: AuraDurations.normal,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        if (AuraAnimationConfig.shouldReduceMotion(context)) {
          return FadeTransition(opacity: animation, child: child);
        }

        final slideAnimation = Tween<Offset>(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: animation,
            curve: AuraCurves.enter,
            reverseCurve: AuraCurves.exit,
          ),
        );

        return SlideTransition(position: slideAnimation, child: child);
      },
    );
  }

  /// 缩放 + 渐显 - 用于对话框
  static Page<T> scale<T>({
    required Widget child,
    required LocalKey key,
    String? name,
    Object? arguments,
  }) {
    return CustomTransitionPage<T>(
      key: key,
      child: child,
      name: name,
      arguments: arguments,
      opaque: false,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      barrierDismissible: true,
      transitionDuration: AuraDurations.normal,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        if (AuraAnimationConfig.shouldReduceMotion(context)) {
          return FadeTransition(opacity: animation, child: child);
        }

        final scaleAnimation = Tween<double>(
          begin: 0.9,
          end: 1.0,
        ).animate(CurvedAnimation(parent: animation, curve: AuraCurves.gentle));

        final fadeAnimation = CurvedAnimation(
          parent: animation,
          curve: AuraCurves.enter,
        );

        return FadeTransition(
          opacity: fadeAnimation,
          child: ScaleTransition(scale: scaleAnimation, child: child),
        );
      },
    );
  }

  /// 共享元素转场 - Hero 动画增强
  static Page<T> hero<T>({
    required Widget child,
    required LocalKey key,
    String? name,
    Object? arguments,
  }) {
    return CustomTransitionPage<T>(
      key: key,
      child: child,
      name: name,
      arguments: arguments,
      transitionDuration: AuraDurations.slow,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: const Interval(0.0, 0.5),
          ),
          child: child,
        );
      },
    );
  }

  /// 无动画
  static Page<T> none<T>({
    required Widget child,
    required LocalKey key,
    String? name,
    Object? arguments,
  }) {
    return CustomTransitionPage<T>(
      key: key,
      child: child,
      name: name,
      arguments: arguments,
      transitionDuration: Duration.zero,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return child;
      },
    );
  }
}

/// 转场动画构建器函数
///
/// 用于 GoRouter 的 transitionsBuilder 参数
class AuraTransitionBuilders {
  AuraTransitionBuilders._();

  /// 淡入淡出
  static Widget fadeTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: AuraCurves.standard),
      child: child,
    );
  }

  /// 上滑 + 渐显
  static Widget slideUpTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (AuraAnimationConfig.shouldReduceMotion(context)) {
      return FadeTransition(opacity: animation, child: child);
    }

    final slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: animation, curve: AuraCurves.enter));

    final fadeAnimation = CurvedAnimation(
      parent: animation,
      curve: AuraCurves.enter,
    );

    return FadeTransition(
      opacity: fadeAnimation,
      child: SlideTransition(position: slideAnimation, child: child),
    );
  }

  /// 从底部弹起（模态）
  static Widget modalTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (AuraAnimationConfig.shouldReduceMotion(context)) {
      return FadeTransition(opacity: animation, child: child);
    }

    final slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: animation,
        curve: AuraCurves.enter,
        reverseCurve: AuraCurves.exit,
      ),
    );

    return SlideTransition(position: slideAnimation, child: child);
  }

  /// 缩放 + 渐显
  static Widget scaleTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (AuraAnimationConfig.shouldReduceMotion(context)) {
      return FadeTransition(opacity: animation, child: child);
    }

    final scaleAnimation = Tween<double>(
      begin: 0.92,
      end: 1.0,
    ).animate(CurvedAnimation(parent: animation, curve: AuraCurves.gentle));

    final fadeAnimation = CurvedAnimation(
      parent: animation,
      curve: AuraCurves.enter,
    );

    return FadeTransition(
      opacity: fadeAnimation,
      child: ScaleTransition(scale: scaleAnimation, child: child),
    );
  }
}

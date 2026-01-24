import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';

/// TimeCircle 动效工具类
/// 设计原则：慢一点、轻一点、永远不打断情绪
class AnimationUtils {
  AnimationUtils._();

  /// 呼吸动效 - 用于按钮、图标等需要吸引注意力的元素
  /// 缓慢的呼吸感，不急躁
  static Widget breathe(
    Widget child, {
    double minScale = 0.96,
    double maxScale = 1.0,
    Duration? duration,
  }) {
    return child
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .scale(
          begin: Offset(minScale, minScale),
          end: Offset(maxScale, maxScale),
          duration: duration ?? AppDurations.breathing,
          curve: AppCurves.breathing,
        );
  }

  /// 轻柔脉冲 - 比呼吸更微妙
  static Widget pulse(
    Widget child, {
    double minOpacity = 0.7,
    double maxOpacity = 1.0,
    Duration? duration,
  }) {
    return child
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .fade(
          begin: minOpacity,
          end: maxOpacity,
          duration: duration ?? AppDurations.breathing,
          curve: AppCurves.breathing,
        );
  }

  /// 向上浮起 - 用于入场动画
  static Widget floatUp(
    Widget child, {
    double distance = 16.0,
    Duration? duration,
    Duration? delay,
    Curve? curve,
  }) {
    return child
        .animate(delay: delay)
        .fadeIn(
          duration: duration ?? AppDurations.slow,
          curve: curve ?? AppCurves.enter,
        )
        .slideY(
          begin: distance / 100,
          end: 0,
          duration: duration ?? AppDurations.slow,
          curve: curve ?? AppCurves.enter,
        );
  }

  /// 纸张翻折感 - 用于卡片入场
  static Widget paperFold(Widget child, {Duration? duration, Duration? delay}) {
    return child
        .animate(delay: delay)
        .fadeIn(
          duration: duration ?? AppDurations.ceremony,
          curve: AppCurves.enter,
        )
        .scale(
          begin: const Offset(0.95, 0.95),
          end: const Offset(1.0, 1.0),
          duration: duration ?? AppDurations.ceremony,
          curve: AppCurves.enter,
        )
        .slideY(
          begin: 0.03,
          end: 0,
          duration: duration ?? AppDurations.ceremony,
          curve: AppCurves.enter,
        );
  }

  /// 交错入场 - 用于列表项
  static Widget staggered(
    Widget child, {
    required int index,
    int baseDelayMs = 80,
    Duration? duration,
  }) {
    return child
        .animate(delay: Duration(milliseconds: baseDelayMs * index))
        .fadeIn(duration: duration ?? AppDurations.slow, curve: AppCurves.enter)
        .slideY(
          begin: 0.05,
          end: 0,
          duration: duration ?? AppDurations.slow,
          curve: AppCurves.enter,
        );
  }

  /// 柔和缩放 - 用于按钮点击反馈
  static Widget tapScale(
    Widget child, {
    double scale = 0.95,
    Duration? duration,
  }) {
    return child.animate().scale(
      begin: const Offset(1.0, 1.0),
      end: Offset(scale, scale),
      duration: duration ?? AppDurations.instant,
      curve: AppCurves.standard,
    );
  }

  /// 轻微摇晃 - 用于错误提示
  static Widget shake(Widget child, {double offset = 8.0, Duration? duration}) {
    return child.animate().shake(
      hz: 4,
      offset: Offset(offset, 0),
      duration: duration ?? AppDurations.normal,
    );
  }

  /// 渐显线条 - 用于分隔线
  static Widget revealLine(
    Widget child, {
    Duration? duration,
    Duration? delay,
    Alignment alignment = Alignment.centerLeft,
  }) {
    return child
        .animate(delay: delay)
        .scaleX(
          begin: 0,
          end: 1,
          alignment: alignment,
          duration: duration ?? AppDurations.slow,
          curve: AppCurves.enter,
        );
  }
}

/// 封装常用动画组合的扩展
extension TimeCircleAnimateExtension on Widget {
  /// 温柔的入场动画
  Widget gentleEntrance({Duration? delay, Duration? duration}) {
    return animate(delay: delay)
        .fadeIn(duration: duration ?? AppDurations.slow, curve: AppCurves.enter)
        .slideY(
          begin: 0.04,
          end: 0,
          duration: duration ?? AppDurations.slow,
          curve: AppCurves.enter,
        );
  }

  /// 卡片入场
  Widget cardEntrance({Duration? delay, Duration? duration}) {
    return animate(delay: delay)
        .fadeIn(
          duration: duration ?? AppDurations.ceremony,
          curve: AppCurves.enter,
        )
        .scale(
          begin: const Offset(0.97, 0.97),
          end: const Offset(1.0, 1.0),
          duration: duration ?? AppDurations.ceremony,
          curve: AppCurves.enter,
        );
  }

  /// 列表项交错入场
  Widget listItemEntrance(int index, {int baseDelayMs = 60}) {
    return animate(delay: Duration(milliseconds: baseDelayMs * index))
        .fadeIn(duration: AppDurations.slow, curve: AppCurves.enter)
        .slideX(
          begin: 0.03,
          end: 0,
          duration: AppDurations.slow,
          curve: AppCurves.enter,
        );
  }
}

/// 页面转场动画构建器
class TimeCirclePageTransition {
  /// 柔和的从下往上滑入
  static Route<T> slideUp<T>({required Widget page, Duration? duration}) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration ?? AppDurations.pageTransition,
      reverseTransitionDuration: duration ?? AppDurations.pageTransition,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final tween = Tween(
          begin: const Offset(0.0, 0.08),
          end: Offset.zero,
        ).chain(CurveTween(curve: AppCurves.enter));

        final fadeTween = Tween(
          begin: 0.0,
          end: 1.0,
        ).chain(CurveTween(curve: AppCurves.standard));

        return SlideTransition(
          position: animation.drive(tween),
          child: FadeTransition(
            opacity: animation.drive(fadeTween),
            child: child,
          ),
        );
      },
    );
  }

  /// 渐变转场（用于 tab 切换）
  static Route<T> fade<T>({required Widget page, Duration? duration}) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration ?? AppDurations.normal,
      reverseTransitionDuration: duration ?? AppDurations.normal,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation.drive(
            Tween(
              begin: 0.0,
              end: 1.0,
            ).chain(CurveTween(curve: AppCurves.standard)),
          ),
          child: child,
        );
      },
    );
  }

  /// 全屏 Modal 转场（用于发布页）
  static Route<T> fullScreenModal<T>({
    required Widget page,
    Duration? duration,
  }) {
    return PageRouteBuilder<T>(
      opaque: false,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration ?? AppDurations.pageTransition,
      reverseTransitionDuration: duration ?? AppDurations.pageTransition,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final slideTween = Tween(
          begin: const Offset(0.0, 1.0),
          end: Offset.zero,
        ).chain(CurveTween(curve: AppCurves.enter));

        return SlideTransition(
          position: animation.drive(slideTween),
          child: child,
        );
      },
    );
  }
}

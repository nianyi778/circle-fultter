// Aura 动画配置系统
//
// 提供统一的动画时长、曲线和无障碍支持

import 'package:flutter/material.dart';

/// 动画配置中心
class AuraAnimationConfig {
  AuraAnimationConfig._();

  /// 检查是否应该禁用/减弱动画
  static bool shouldReduceMotion(BuildContext context) {
    return MediaQuery.of(context).disableAnimations;
  }

  /// 根据无障碍设置调整时长
  static Duration adaptedDuration(BuildContext context, Duration duration) {
    if (shouldReduceMotion(context)) {
      return duration ~/ 2; // 减半
    }
    return duration;
  }

  /// 根据无障碍设置调整曲线
  static Curve adaptedCurve(BuildContext context, Curve curve) {
    if (shouldReduceMotion(context)) {
      return Curves.linear;
    }
    return curve;
  }

  /// 获取动画时长 (自动适配无障碍)
  static Duration getDuration(
    BuildContext context, {
    required Duration normal,
    Duration? reduced,
  }) {
    if (shouldReduceMotion(context)) {
      return reduced ?? (normal ~/ 2);
    }
    return normal;
  }
}

/// 动画时长 Token
///
/// 基于 Aura 设计系统的动画时长规范
/// - 慢即仪式：动画节奏偏慢 (250-600ms)
/// - 不追求操作效率，追求"动作的重量感"
class AuraDurations {
  AuraDurations._();

  /// 瞬间反馈 - 按下效果
  static const instant = Duration(milliseconds: 100);

  /// 快速交互 - 开关切换
  static const fast = Duration(milliseconds: 150);

  /// 标准动画 - 大多数场景
  static const normal = Duration(milliseconds: 250);

  /// 页面切换
  static const pageTransition = Duration(milliseconds: 300);

  /// 缓慢出现 - 重要内容
  static const slow = Duration(milliseconds: 400);

  /// 仪式动画 - 封存、发布
  static const ceremony = Duration(milliseconds: 600);

  /// 页面入场 - 首次加载
  static const entrance = Duration(milliseconds: 800);

  /// 呼吸循环
  static const breathing = Duration(milliseconds: 2000);

  /// 根据场景选择时长
  ///
  /// ```
  /// 操作反馈（点击、切换）     → instant / fast    (100-150ms)
  /// 状态变化（展开、收起）     → normal            (250ms)
  /// 页面切换                   → pageTransition    (300ms)
  /// 内容入场                   → slow              (400ms)
  /// 重要仪式（封存、发布）     → ceremony          (600ms)
  /// 首次入场（启动页）         → entrance          (800ms)
  /// ```
  static Duration forScenario(AnimationScenario scenario) {
    return switch (scenario) {
      AnimationScenario.feedback => instant,
      AnimationScenario.toggle => fast,
      AnimationScenario.stateChange => normal,
      AnimationScenario.pageTransition => pageTransition,
      AnimationScenario.entrance => slow,
      AnimationScenario.ceremony => ceremony,
      AnimationScenario.splash => entrance,
      AnimationScenario.breathing => breathing,
    };
  }
}

/// 动画场景枚举
enum AnimationScenario {
  feedback, // 点击反馈
  toggle, // 开关切换
  stateChange, // 状态变化
  pageTransition, // 页面切换
  entrance, // 内容入场
  ceremony, // 仪式动画
  splash, // 启动动画
  breathing, // 呼吸循环
}

/// 动画曲线 Token
///
/// 基于 Aura 设计系统的曲线规范
/// - 禁止 bounce/elastic 等活跃曲线
/// - 使用自然、柔和的缓动
class AuraCurves {
  AuraCurves._();

  /// 默认缓动 - 通用
  static const standard = Curves.easeOutCubic;

  /// 进入动画 - 柔和开始，自然结束
  static const enter = Cubic(0.0, 0.0, 0.2, 1.0);

  /// 退出动画 - 快速开始，自然结束
  static const exit = Cubic(0.4, 0.0, 1.0, 1.0);

  /// 呼吸循环 - 平滑往复
  static const breathing = Cubic(0.4, 0.0, 0.6, 1.0);

  /// 柔和弹性 - 克制的弹跳，不夸张
  static const gentle = Cubic(0.34, 1.56, 0.64, 1.0);

  /// 缓入缓出 - 进出对称
  static const smooth = Curves.easeInOutCubic;

  /// 根据动画方向选择曲线
  ///
  /// ```
  /// 元素进入画面           → enter      (柔和开始，自然结束)
  /// 元素离开画面           → exit       (快速开始，自然结束)
  /// 状态切换               → standard   (通用缓动)
  /// 呼吸/循环动画          → breathing  (平滑往复)
  /// 需要轻微弹性           → gentle     (克制的弹跳，不夸张)
  /// 对称动画               → smooth     (进出对称)
  /// ```
  static Curve forDirection(AnimationDirection direction) {
    return switch (direction) {
      AnimationDirection.enter => enter,
      AnimationDirection.exit => exit,
      AnimationDirection.toggle => standard,
      AnimationDirection.loop => breathing,
      AnimationDirection.bounce => gentle,
      AnimationDirection.symmetric => smooth,
    };
  }
}

/// 动画方向枚举
enum AnimationDirection {
  enter, // 进入
  exit, // 退出
  toggle, // 切换
  loop, // 循环
  bounce, // 弹性
  symmetric, // 对称
}

/// 弹簧物理配置
///
/// 用于更自然的物理动画效果
class AuraSpringConfig {
  AuraSpringConfig._();

  /// 轻柔弹簧 - 用于微交互
  static const gentle = SpringDescription(
    mass: 1.0,
    stiffness: 300.0,
    damping: 20.0,
  );

  /// 标准弹簧 - 用于页面转场
  static const standard = SpringDescription(
    mass: 1.0,
    stiffness: 400.0,
    damping: 25.0,
  );

  /// 响应弹簧 - 用于按钮反馈
  static const responsive = SpringDescription(
    mass: 1.0,
    stiffness: 600.0,
    damping: 30.0,
  );

  /// 缓慢弹簧 - 用于仪式感动画
  static const slow = SpringDescription(
    mass: 1.5,
    stiffness: 200.0,
    damping: 18.0,
  );
}

/// 列表入场动画配置
class StaggerConfig {
  /// 基础延迟
  final Duration baseDelay;

  /// 单项动画时长
  final Duration itemDuration;

  /// 最大延迟项数（超过后不再增加延迟）
  final int maxDelayItems;

  /// 滑动偏移
  final Offset slideOffset;

  const StaggerConfig({
    this.baseDelay = const Duration(milliseconds: 60),
    this.itemDuration = const Duration(milliseconds: 400),
    this.maxDelayItems = 5,
    this.slideOffset = const Offset(0.03, 0),
  });

  /// 默认配置
  static const standard = StaggerConfig();

  /// 快速配置 - 更短的延迟
  static const fast = StaggerConfig(
    baseDelay: Duration(milliseconds: 40),
    itemDuration: Duration(milliseconds: 300),
    maxDelayItems: 3,
  );

  /// 慢速配置 - 更有仪式感
  static const slow = StaggerConfig(
    baseDelay: Duration(milliseconds: 80),
    itemDuration: Duration(milliseconds: 500),
    maxDelayItems: 6,
  );

  /// 计算指定索引的延迟
  Duration delayForIndex(int index) {
    final clampedIndex = index.clamp(0, maxDelayItems);
    return baseDelay * clampedIndex;
  }
}

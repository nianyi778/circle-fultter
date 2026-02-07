// Aura 呼吸动效组件
//
// 实现轻柔的呼吸缩放动画，用于吸引注意力
// 符合 Aura 设计系统的动效规范：
// - 整个页面最多1处呼吸动效
// - 极其克制地使用

import 'package:flutter/material.dart';
import '../../../../core/animations/animation_config.dart';

/// 呼吸动效组件
///
/// 使用示例:
/// ```dart
/// AuraBreathing(
///   child: LetterCard(),
/// )
///
/// // 控制启用/禁用
/// AuraBreathing(
///   enabled: shouldShowHint,
///   child: HintIcon(),
/// )
/// ```
class AuraBreathing extends StatefulWidget {
  /// 子组件
  final Widget child;

  /// 最小缩放值
  final double minScale;

  /// 最大缩放值
  final double maxScale;

  /// 动画周期
  final Duration duration;

  /// 是否启用动画
  final bool enabled;

  /// 是否在暂停后从头开始
  final bool resetOnDisable;

  const AuraBreathing({
    super.key,
    required this.child,
    this.minScale = 0.96,
    this.maxScale = 1.0,
    this.duration = AuraDurations.breathing,
    this.enabled = true,
    this.resetOnDisable = false,
  });

  @override
  State<AuraBreathing> createState() => _AuraBreathingState();
}

class _AuraBreathingState extends State<AuraBreathing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: widget.duration);

    _setupAnimation();

    if (widget.enabled) {
      _controller.repeat(reverse: true);
    }
  }

  void _setupAnimation() {
    _scaleAnimation = Tween<double>(
      begin: widget.maxScale,
      end: widget.minScale,
    ).animate(
      CurvedAnimation(parent: _controller, curve: AuraCurves.breathing),
    );
  }

  @override
  void didUpdateWidget(AuraBreathing oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 重新设置动画（如果参数变化）
    if (oldWidget.minScale != widget.minScale ||
        oldWidget.maxScale != widget.maxScale ||
        oldWidget.duration != widget.duration) {
      _controller.duration = widget.duration;
      _setupAnimation();
    }

    // 处理启用/禁用
    if (widget.enabled && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.enabled && _controller.isAnimating) {
      _controller.stop();
      if (widget.resetOnDisable) {
        _controller.value = 0;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 无障碍模式下禁用呼吸动效
    if (AuraAnimationConfig.shouldReduceMotion(context) || !widget.enabled) {
      return widget.child;
    }

    return ScaleTransition(scale: _scaleAnimation, child: widget.child);
  }
}

/// 脉冲动效组件
///
/// 比呼吸更微妙的提示，使用透明度变化
///
/// 使用示例:
/// ```dart
/// AuraPulse(
///   child: NotificationDot(),
/// )
/// ```
class AuraPulse extends StatefulWidget {
  /// 子组件
  final Widget child;

  /// 最小透明度
  final double minOpacity;

  /// 最大透明度
  final double maxOpacity;

  /// 动画周期
  final Duration duration;

  /// 是否启用动画
  final bool enabled;

  const AuraPulse({
    super.key,
    required this.child,
    this.minOpacity = 0.7,
    this.maxOpacity = 1.0,
    this.duration = AuraDurations.breathing,
    this.enabled = true,
  });

  @override
  State<AuraPulse> createState() => _AuraPulseState();
}

class _AuraPulseState extends State<AuraPulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: widget.duration);

    _opacityAnimation = Tween<double>(
      begin: widget.maxOpacity,
      end: widget.minOpacity,
    ).animate(
      CurvedAnimation(parent: _controller, curve: AuraCurves.breathing),
    );

    if (widget.enabled) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(AuraPulse oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.enabled && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.enabled && _controller.isAnimating) {
      _controller.stop();
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (AuraAnimationConfig.shouldReduceMotion(context) || !widget.enabled) {
      return widget.child;
    }

    return FadeTransition(opacity: _opacityAnimation, child: widget.child);
  }
}

/// 光效呼吸组件
///
/// 用于信件卡片等需要光效的场景
///
/// 使用示例:
/// ```dart
/// AuraGlow(
///   color: AppColors.primary,
///   child: LetterCard(),
/// )
/// ```
class AuraGlow extends StatefulWidget {
  /// 子组件
  final Widget child;

  /// 光效颜色
  final Color color;

  /// 最小光效半径
  final double minBlur;

  /// 最大光效半径
  final double maxBlur;

  /// 最小扩散
  final double minSpread;

  /// 最大扩散
  final double maxSpread;

  /// 动画周期
  final Duration duration;

  /// 是否启用动画
  final bool enabled;

  const AuraGlow({
    super.key,
    required this.child,
    required this.color,
    this.minBlur = 10,
    this.maxBlur = 20,
    this.minSpread = 0,
    this.maxSpread = 5,
    this.duration = AuraDurations.breathing,
    this.enabled = true,
  });

  @override
  State<AuraGlow> createState() => _AuraGlowState();
}

class _AuraGlowState extends State<AuraGlow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _blurAnimation;
  late Animation<double> _spreadAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: widget.duration);

    final curve = CurvedAnimation(
      parent: _controller,
      curve: AuraCurves.breathing,
    );

    _blurAnimation = Tween<double>(
      begin: widget.minBlur,
      end: widget.maxBlur,
    ).animate(curve);

    _spreadAnimation = Tween<double>(
      begin: widget.minSpread,
      end: widget.maxSpread,
    ).animate(curve);

    if (widget.enabled) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(AuraGlow oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.enabled && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.enabled && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (AuraAnimationConfig.shouldReduceMotion(context) || !widget.enabled) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: 0.15),
                blurRadius: _blurAnimation.value,
                spreadRadius: _spreadAnimation.value,
              ),
            ],
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

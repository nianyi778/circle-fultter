// Aura 仪式感动画组件
//
// 实现封存、发布等重要操作的仪式感动画
// 符合 Aura 设计哲学："慢即仪式"

import 'package:flutter/material.dart';
import '../../../../core/animations/animation_config.dart';
import '../../../../core/haptics/haptic_service.dart';

/// 封存信件动画
///
/// 实现信件封存时的下落 + 缩放 + 光效动画
///
/// 使用示例:
/// ```dart
/// LetterSealAnimation(
///   onComplete: () {
///     // 导航到信件列表
///   },
///   child: LetterPreviewCard(),
/// )
/// ```
class LetterSealAnimation extends StatefulWidget {
  /// 子组件（信件卡片）
  final Widget child;

  /// 动画完成回调
  final VoidCallback onComplete;

  /// 动画时长
  final Duration duration;

  /// 是否包含触觉反馈
  final bool withHaptics;

  const LetterSealAnimation({
    super.key,
    required this.child,
    required this.onComplete,
    this.duration = AuraDurations.ceremony,
    this.withHaptics = true,
  });

  @override
  State<LetterSealAnimation> createState() => _LetterSealAnimationState();
}

class _LetterSealAnimationState extends State<LetterSealAnimation>
    with TickerProviderStateMixin {
  late final AnimationController _mainController;
  late final AnimationController _glowController;

  late final Animation<double> _scaleAnimation;
  late final Animation<double> _translateAnimation;
  late final Animation<double> _opacityAnimation;
  late final Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    // 主动画控制器
    _mainController = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    // 光效控制器
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    // 缩小动画 (0% - 60%)
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.6, curve: AuraCurves.gentle),
      ),
    );

    // 下沉动画 (20% - 80%)
    _translateAnimation = Tween<double>(begin: 0, end: 20).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.2, 0.8, curve: AuraCurves.gentle),
      ),
    );

    // 淡出动画 (60% - 100%)
    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.6, 1.0, curve: AuraCurves.exit),
      ),
    );

    // 光效动画
    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _glowController, curve: Curves.easeOut));

    _startAnimation();
  }

  Future<void> _startAnimation() async {
    // 触觉反馈开始
    if (widget.withHaptics) {
      await HapticService.mediumTap();
    }

    // 播放光效
    await _glowController.forward();

    // 播放主动画
    await _mainController.forward();

    // 最终触觉反馈
    if (widget.withHaptics) {
      await HapticService.ceremony();
    }

    widget.onComplete();
  }

  @override
  void dispose() {
    _mainController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_mainController, _glowController]),
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // 光效层
            if (_glowAnimation.value > 0) _buildGlow(),

            // 信件内容
            Transform.translate(
              offset: Offset(0, _translateAnimation.value),
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Opacity(
                  opacity: _opacityAnimation.value,
                  child: widget.child,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildGlow() {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFDF8020).withValues(
              alpha: 0.3 * _glowAnimation.value * (1 - _opacityAnimation.value),
            ),
            blurRadius: 60 * _glowAnimation.value,
            spreadRadius: 20 * _glowAnimation.value,
          ),
        ],
      ),
    );
  }
}

/// 发布成功动画
///
/// 实现记录发布成功时的上升 + 渐隐动画
///
/// 使用示例:
/// ```dart
/// MomentPublishAnimation(
///   onComplete: () {
///     Navigator.pop(context);
///   },
///   child: MomentPreview(),
/// )
/// ```
class MomentPublishAnimation extends StatefulWidget {
  /// 子组件
  final Widget child;

  /// 动画完成回调
  final VoidCallback onComplete;

  /// 动画时长
  final Duration duration;

  /// 是否包含触觉反馈
  final bool withHaptics;

  const MomentPublishAnimation({
    super.key,
    required this.child,
    required this.onComplete,
    this.duration = const Duration(milliseconds: 500),
    this.withHaptics = true,
  });

  @override
  State<MomentPublishAnimation> createState() => _MomentPublishAnimationState();
}

class _MomentPublishAnimationState extends State<MomentPublishAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _translateAnimation;
  late final Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: widget.duration);

    // 轻微放大 (0% - 40%)
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: AuraCurves.gentle),
      ),
    );

    // 上移动画 (0% - 100%)
    _translateAnimation = Tween<double>(
      begin: 0,
      end: -30,
    ).animate(CurvedAnimation(parent: _controller, curve: AuraCurves.exit));

    // 淡出动画 (40% - 100%)
    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1.0, curve: AuraCurves.exit),
      ),
    );

    _startAnimation();
  }

  Future<void> _startAnimation() async {
    if (widget.withHaptics) {
      await HapticService.success();
    }

    await _controller.forward();

    widget.onComplete();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _translateAnimation.value),
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: _opacityAnimation.value,
              child: widget.child,
            ),
          ),
        );
      },
    );
  }
}

/// 打开信件动画
///
/// 实现信件解锁时的展开动画
class LetterOpenAnimation extends StatefulWidget {
  /// 子组件（信件内容）
  final Widget child;

  /// 动画完成回调
  final VoidCallback? onComplete;

  /// 动画时长
  final Duration duration;

  const LetterOpenAnimation({
    super.key,
    required this.child,
    this.onComplete,
    this.duration = AuraDurations.ceremony,
  });

  @override
  State<LetterOpenAnimation> createState() => _LetterOpenAnimationState();
}

class _LetterOpenAnimationState extends State<LetterOpenAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: widget.duration);

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: AuraCurves.gentle));

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: AuraCurves.enter),
      ),
    );

    _startAnimation();
  }

  Future<void> _startAnimation() async {
    await HapticService.mediumTap();

    await _controller.forward();

    await HapticService.lightTap();

    widget.onComplete?.call();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(opacity: _opacityAnimation.value, child: widget.child),
        );
      },
    );
  }
}

/// 数字滚动动画
///
/// 用于首页天数显示
class NumberRollAnimation extends StatefulWidget {
  /// 目标数字
  final int targetNumber;

  /// 文本样式
  final TextStyle? style;

  /// 动画时长
  final Duration duration;

  /// 是否仅首次播放
  final bool playOnce;

  const NumberRollAnimation({
    super.key,
    required this.targetNumber,
    this.style,
    this.duration = const Duration(milliseconds: 800),
    this.playOnce = true,
  });

  @override
  State<NumberRollAnimation> createState() => _NumberRollAnimationState();
}

class _NumberRollAnimationState extends State<NumberRollAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<int> _numberAnimation;

  static final Set<int> _playedNumbers = {};

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: widget.duration);

    _numberAnimation = IntTween(
      begin: 0,
      end: widget.targetNumber,
    ).animate(CurvedAnimation(parent: _controller, curve: AuraCurves.smooth));

    _startAnimation();
  }

  void _startAnimation() {
    if (widget.playOnce && _playedNumbers.contains(widget.targetNumber)) {
      _controller.value = 1.0;
      return;
    }

    _controller.forward();

    if (widget.playOnce) {
      _playedNumbers.add(widget.targetNumber);
    }
  }

  @override
  void didUpdateWidget(NumberRollAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.targetNumber != widget.targetNumber) {
      _numberAnimation = IntTween(
        begin: oldWidget.targetNumber,
        end: widget.targetNumber,
      ).animate(CurvedAnimation(parent: _controller, curve: AuraCurves.smooth));

      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Text(_numberAnimation.value.toString(), style: widget.style);
      },
    );
  }
}

// Aura 交错入场列表组件
//
// 实现列表项的交错入场动画效果
// 符合 Aura 设计系统的动效规范

import 'package:flutter/material.dart';
import '../../../../core/animations/animation_config.dart';

/// 交错入场列表
///
/// 使用示例:
/// ```dart
/// AuraStaggerList(
///   children: [
///     CardWidget(),
///     CardWidget(),
///     CardWidget(),
///   ],
/// )
/// ```
class AuraStaggerList extends StatelessWidget {
  /// 子组件列表
  final List<Widget> children;

  /// 基础延迟 (每项之间的延迟)
  final Duration baseDelay;

  /// 单项动画时长
  final Duration itemDuration;

  /// 最大延迟项数 (超过后不再增加延迟)
  final int maxDelayItems;

  /// 滑动偏移
  final Offset slideOffset;

  /// 是否启用动画
  final bool animate;

  const AuraStaggerList({
    super.key,
    required this.children,
    this.baseDelay = const Duration(milliseconds: 60),
    this.itemDuration = const Duration(milliseconds: 400),
    this.maxDelayItems = 5,
    this.slideOffset = const Offset(0.03, 0),
    this.animate = true,
  });

  @override
  Widget build(BuildContext context) {
    final reduceMotion = AuraAnimationConfig.shouldReduceMotion(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < children.length; i++)
          _StaggerItem(
            index: i,
            baseDelay: baseDelay,
            duration: itemDuration,
            maxDelayItems: maxDelayItems,
            slideOffset: slideOffset,
            reduceMotion: reduceMotion || !animate,
            child: children[i],
          ),
      ],
    );
  }
}

/// 单个交错入场项
class _StaggerItem extends StatefulWidget {
  final int index;
  final Duration baseDelay;
  final Duration duration;
  final int maxDelayItems;
  final Offset slideOffset;
  final bool reduceMotion;
  final Widget child;

  const _StaggerItem({
    required this.index,
    required this.baseDelay,
    required this.duration,
    required this.maxDelayItems,
    required this.slideOffset,
    required this.reduceMotion,
    required this.child,
  });

  @override
  State<_StaggerItem> createState() => _StaggerItemState();
}

class _StaggerItemState extends State<_StaggerItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: widget.reduceMotion ? Duration.zero : widget.duration,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: AuraCurves.enter,
    );

    _slideAnimation = Tween<Offset>(
      begin: widget.slideOffset,
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: AuraCurves.enter));

    _startAnimation();
  }

  Future<void> _startAnimation() async {
    if (widget.reduceMotion) {
      _controller.value = 1.0;
      return;
    }

    // 计算延迟
    final delayIndex = widget.index.clamp(0, widget.maxDelayItems);
    final delay = widget.baseDelay * delayIndex;

    await Future.delayed(delay);

    if (mounted) {
      await _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.reduceMotion) {
      return widget.child;
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(position: _slideAnimation, child: widget.child),
    );
  }
}

/// 交错入场列表构建器
///
/// 用于 ListView.builder 等场景
///
/// 使用示例:
/// ```dart
/// ListView.builder(
///   itemCount: items.length,
///   itemBuilder: (context, index) {
///     return AuraStaggerItem(
///       index: index,
///       child: ItemWidget(item: items[index]),
///     );
///   },
/// )
/// ```
class AuraStaggerItem extends StatefulWidget {
  /// 项目索引
  final int index;

  /// 子组件
  final Widget child;

  /// 动画配置
  final StaggerConfig config;

  /// 是否启用动画
  final bool animate;

  const AuraStaggerItem({
    super.key,
    required this.index,
    required this.child,
    this.config = StaggerConfig.standard,
    this.animate = true,
  });

  @override
  State<AuraStaggerItem> createState() => _AuraStaggerItemState();
}

class _AuraStaggerItemState extends State<AuraStaggerItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: widget.config.itemDuration,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: AuraCurves.enter,
    );

    _slideAnimation = Tween<Offset>(
      begin: widget.config.slideOffset,
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: AuraCurves.enter));

    _startAnimation();
  }

  Future<void> _startAnimation() async {
    if (!widget.animate) {
      _controller.value = 1.0;
      return;
    }

    // 检查无障碍设置
    final reduceMotion =
        WidgetsBinding
            .instance
            .platformDispatcher
            .accessibilityFeatures
            .reduceMotion;

    if (reduceMotion) {
      _controller.value = 1.0;
      return;
    }

    // 计算延迟
    final delay = widget.config.delayForIndex(widget.index);

    await Future.delayed(delay);

    if (mounted) {
      await _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.animate || AuraAnimationConfig.shouldReduceMotion(context)) {
      return widget.child;
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(position: _slideAnimation, child: widget.child),
    );
  }
}

/// Sliver 版本的交错入场列表
///
/// 用于 CustomScrollView 中
class SliverAuraStaggerList extends StatelessWidget {
  /// 项目数量
  final int itemCount;

  /// 项目构建器
  final Widget Function(BuildContext context, int index) itemBuilder;

  /// 动画配置
  final StaggerConfig config;

  const SliverAuraStaggerList({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.config = StaggerConfig.standard,
  });

  @override
  Widget build(BuildContext context) {
    return SliverList.builder(
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return AuraStaggerItem(
          index: index,
          config: config,
          child: itemBuilder(context, index),
        );
      },
    );
  }
}

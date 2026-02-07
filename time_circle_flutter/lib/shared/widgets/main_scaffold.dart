import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../core/theme/app_theme.dart';
import '../../core/haptics/haptic_service.dart';
import '../../features/create/views/create_moment_view.dart';
import '../../presentation/shared/widgets/connectivity_indicator.dart';

/// 当前导航索引 Provider
final navigationIndexProvider = StateProvider<int>((ref) => 0);

/// 主界面 Scaffold，包含底部导航
class MainScaffold extends ConsumerWidget {
  final Widget child;

  const MainScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navigationIndexProvider);

    return Scaffold(
      body: Column(
        children: [
          // 离线状态横幅
          const OfflineBanner(),
          // 主内容
          Expanded(child: child),
        ],
      ),
      extendBody: true,
      bottomNavigationBar: _BottomNavBar(
        currentIndex: currentIndex,
        onTabChanged: (index) {
          ref.read(navigationIndexProvider.notifier).state = index;
          switch (index) {
            case 0:
              context.go('/home');
              break;
            case 1:
              context.go('/timeline');
              break;
            case 2:
              context.go('/letters');
              break;
            case 3:
              context.go('/world');
              break;
          }
        },
        onComposeTap: () => _showCreateModal(context),
      ),
    );
  }

  /// 显示创建时刻的全屏浮层
  void _showCreateModal(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: false,
        pageBuilder: (context, animation, secondaryAnimation) {
          return const CreateMomentModal();
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.05),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: animation, curve: AppCurves.enter),
              ),
              child: child,
            ),
          );
        },
        transitionDuration: AppDurations.pageTransition,
        reverseTransitionDuration: AppDurations.normal,
      ),
    );
  }
}

/// 底部导航栏 - 纯图标模式 + 毛玻璃效果
class _BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabChanged;
  final VoidCallback onComposeTap;

  const _BottomNavBar({
    required this.currentIndex,
    required this.onTabChanged,
    required this.onComposeTap,
  });

  @override
  Widget build(BuildContext context) {
    // 获取底部安全区域高度（手势栏高度）
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: BoxDecoration(boxShadow: AppShadows.navigation),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            // 背景色延伸到手势栏区域
            color: AppColors.white.withValues(alpha: 0.92),
            // 总高度 = 导航栏高度 + 底部安全区域
            padding: EdgeInsets.only(bottom: bottomPadding),
            child: Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // 回忆
                  _NavItem(
                    icon: Iconsax.home_2,
                    activeIcon: Iconsax.home_25,
                    isActive: currentIndex == 0,
                    onTap: () => onTabChanged(0),
                  ),

                  // 时间线
                  _NavItem(
                    icon: Iconsax.clock,
                    activeIcon: Iconsax.clock5,
                    isActive: currentIndex == 1,
                    onTap: () => onTabChanged(1),
                  ),

                  // 中央发布按钮（带呼吸动效）
                  _ComposeButton(onTap: onComposeTap),

                  // 信
                  _NavItem(
                    icon: Iconsax.sms,
                    activeIcon: Iconsax.sms5,
                    isActive: currentIndex == 2,
                    onTap: () => onTabChanged(2),
                  ),

                  // 世界
                  _NavItem(
                    icon: Iconsax.global,
                    activeIcon: Iconsax.global5,
                    isActive: currentIndex == 3,
                    onTap: () => onTabChanged(3),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 导航项 - 纯图标模式，带选中指示器
class _NavItem extends StatefulWidget {
  final IconData icon;
  final IconData activeIcon;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppDurations.instant,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(parent: _controller, curve: AppCurves.standard));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
    HapticService.lightTap();
    widget.onTap();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(scale: _scaleAnimation.value, child: child);
        },
        child: Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: AppDurations.fast,
                child: Icon(
                  widget.isActive ? widget.activeIcon : widget.icon,
                  key: ValueKey(widget.isActive),
                  size: 24,
                  color:
                      widget.isActive
                          ? AppColors.warmGray800
                          : AppColors.warmGray400,
                ),
              ),
              const SizedBox(height: 4),
              // 选中指示器小圆点
              AnimatedContainer(
                duration: AppDurations.fast,
                curve: AppCurves.standard,
                width: widget.isActive ? 4 : 0,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.warmGray800,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 中央发布按钮 - 带呼吸脉动效果
class _ComposeButton extends StatefulWidget {
  final VoidCallback onTap;

  const _ComposeButton({required this.onTap});

  @override
  State<_ComposeButton> createState() => _ComposeButtonState();
}

class _ComposeButtonState extends State<_ComposeButton>
    with TickerProviderStateMixin {
  late AnimationController _breathController;
  late Animation<double> _breathAnimation;
  late AnimationController _tapController;
  late Animation<double> _tapAnimation;

  @override
  void initState() {
    super.initState();

    // 呼吸动效
    _breathController = AnimationController(
      duration: AppDurations.breathing,
      vsync: this,
    );
    _breathAnimation = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(parent: _breathController, curve: AppCurves.breathing),
    );
    _breathController.repeat(reverse: true);

    // 点击动效
    _tapController = AnimationController(
      duration: AppDurations.instant,
      vsync: this,
    );
    _tapAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _tapController, curve: AppCurves.standard),
    );
  }

  @override
  void dispose() {
    _breathController.dispose();
    _tapController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _tapController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _tapController.reverse();
    HapticService.mediumTap();
    widget.onTap();
  }

  void _handleTapCancel() {
    _tapController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedBuilder(
        animation: Listenable.merge([_breathAnimation, _tapAnimation]),
        builder: (context, child) {
          return Transform.scale(
            scale: _breathAnimation.value * _tapAnimation.value,
            child: child,
          );
        },
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.warmGray800,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.warmGray800.withValues(alpha: 0.25),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Iconsax.add, color: AppColors.white, size: 24),
        ),
      ),
    );
  }
}

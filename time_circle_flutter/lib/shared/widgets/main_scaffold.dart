import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../core/theme/app_theme.dart';
import '../../features/create/views/create_moment_view.dart';

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
      body: child,
      extendBody: true,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.95),
          boxShadow: [
            BoxShadow(
              color: AppColors.warmGray900.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // 回忆
                _NavItem(
                  icon: Iconsax.home_2,
                  activeIcon: Iconsax.home_25,
                  label: '回忆',
                  isActive: currentIndex == 0,
                  onTap: () {
                    ref.read(navigationIndexProvider.notifier).state = 0;
                    context.go('/home');
                  },
                ),
                
                // 时间线
                _NavItem(
                  icon: Iconsax.clock,
                  activeIcon: Iconsax.clock5,
                  label: '时间线',
                  isActive: currentIndex == 1,
                  onTap: () {
                    ref.read(navigationIndexProvider.notifier).state = 1;
                    context.go('/timeline');
                  },
                ),
                
                // 中央发布按钮
                _ComposeButton(
                  onTap: () => _showCreateModal(context),
                ),
                
                // 信
                _NavItem(
                  icon: Iconsax.sms,
                  activeIcon: Iconsax.sms5,
                  label: '信',
                  isActive: currentIndex == 2,
                  onTap: () {
                    ref.read(navigationIndexProvider.notifier).state = 2;
                    context.go('/letters');
                  },
                ),
                
                // 世界
                _NavItem(
                  icon: Iconsax.global,
                  activeIcon: Iconsax.global5,
                  label: '世界',
                  isActive: currentIndex == 3,
                  onTap: () {
                    ref.read(navigationIndexProvider.notifier).state = 3;
                    context.go('/world');
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 显示创建时刻的底部浮层
  void _showCreateModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: AppColors.warmGray900.withValues(alpha: 0.4),
      builder: (context) => const CreateMomentModal(),
    );
  }
}

/// 导航项
class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: AppDurations.fast,
        curve: AppCurves.standard,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: AppDurations.fast,
              child: Icon(
                isActive ? activeIcon : icon,
                key: ValueKey(isActive),
                size: 24,
                color: isActive 
                    ? AppColors.warmGray800 
                    : AppColors.warmGray400,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: isActive 
                    ? AppColors.warmGray800 
                    : AppColors.warmGray500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 中央发布按钮
class _ComposeButton extends StatefulWidget {
  final VoidCallback onTap;

  const _ComposeButton({required this.onTap});

  @override
  State<_ComposeButton> createState() => _ComposeButtonState();
}

class _ComposeButtonState extends State<_ComposeButton> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppDurations.fast,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _controller, curve: AppCurves.standard),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: Container(
          width: 56,
          height: 56,
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: AppColors.warmGray800,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.warmGray800.withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Iconsax.add,
            color: AppColors.white,
            size: 28,
          ),
        ),
      ),
    );
  }
}

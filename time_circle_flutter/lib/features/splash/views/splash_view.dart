import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/providers/auth_providers.dart';
import '../../../core/theme/app_theme.dart';

/// Aura 启动页
///
/// 设计理念：
/// - 毛玻璃光圈 Logo 形成 "A" 字意象
/// - 中心橙色光晕脉动动画
/// - 整体浮动动画
/// - 温暖的品牌色调
class SplashView extends ConsumerStatefulWidget {
  const SplashView({super.key});

  @override
  ConsumerState<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends ConsumerState<SplashView>
    with TickerProviderStateMixin {
  late AnimationController _floatController;
  late AnimationController _pulseController;
  late AnimationController _progressController;
  late AnimationController _fadeController;

  late Animation<double> _floatAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _progressAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // 浮动动画 - 6秒循环
    _floatController = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: 0, end: -10).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    // 脉动动画 - 4秒循环
    _pulseController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // 进度条动画 - 2.5秒完成
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    _progressAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeOut),
    );

    // 淡出动画
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 1,
      end: 0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    // 开始进度动画
    _progressController.forward();

    // 使用 addPostFrameCallback 延迟初始化，避免在 widget 树构建期间修改 provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initAuthAndNavigate();
    });
  }

  Future<void> _initAuthAndNavigate() async {
    try {
      // 初始化认证状态，添加超时保护
      await ref
          .read(authProvider.notifier)
          .init()
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              debugPrint('Auth init timeout, proceeding as unauthenticated');
            },
          );
    } catch (e) {
      debugPrint('Auth init error: $e');
      // 出错时继续导航到登录页
    }

    // 等待动画完成
    await Future.delayed(const Duration(milliseconds: 2800));

    if (!mounted) return;

    // 淡出并导航
    await _fadeController.forward();

    if (!mounted) return;

    // 根据认证状态导航
    final authState = ref.read(authProvider);

    switch (authState.status) {
      case AuthStatus.authenticated:
        context.go('/home');
        break;
      case AuthStatus.noCircle:
        context.go('/circle-setup');
        break;
      case AuthStatus.unauthenticated:
      case AuthStatus.initial:
        // 如果还是初始状态或未认证，都去登录页
        context.go('/login');
        break;
    }
  }

  @override
  void dispose() {
    _floatController.dispose();
    _pulseController.dispose();
    _progressController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Scaffold(
            backgroundColor: AppColors.timeBeige,
            body: Stack(
              children: [
                // 背景光晕
                _buildBackgroundGlows(),

                // 主内容
                SafeArea(
                  child: Column(
                    children: [
                      const Spacer(),
                      // Logo 组合
                      _buildLogoComposition(),
                      const SizedBox(height: 40),
                      // 文字
                      _buildTypography(),
                      const Spacer(),
                      // 底部进度
                      _buildBottomLoader(),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 背景光晕效果
  Widget _buildBackgroundGlows() {
    return Stack(
      children: [
        // 左上光晕
        Positioned(
          top: -80,
          left: -80,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.12),
                  AppColors.primary.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ),
        // 右下光晕
        Positioned(
          bottom: -100,
          right: -100,
          child: Container(
            width: 400,
            height: 400,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.08),
                  AppColors.primary.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Logo 组合（毛玻璃光圈）
  Widget _buildLogoComposition() {
    return AnimatedBuilder(
      animation: _floatAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatAnimation.value),
          child: SizedBox(
            width: 200,
            height: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 中心光晕（脉动）
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Container(
                      width: 80 * _pulseAnimation.value,
                      height: 80 * _pulseAnimation.value,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.5),
                            blurRadius: 50,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                    );
                  },
                ),

                // 次级光晕
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.primaryMuted.withValues(alpha: 0.4),
                        AppColors.primary.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),

                // 左叶片（A 的左腿）
                Positioned(
                  child: Transform.rotate(
                    angle: -20 * math.pi / 180,
                    child: Transform.translate(
                      offset: const Offset(-12, 4),
                      child: _buildGlassBlade(width: 50, height: 110),
                    ),
                  ),
                ),

                // 右叶片（A 的右腿）
                Positioned(
                  child: Transform.rotate(
                    angle: 20 * math.pi / 180,
                    child: Transform.translate(
                      offset: const Offset(12, 4),
                      child: _buildGlassBlade(width: 50, height: 110),
                    ),
                  ),
                ),

                // 横杠（A 的横杠 / 光圈底部）
                Positioned(
                  child: Transform.translate(
                    offset: const Offset(0, 32),
                    child: _buildGlassBlade(width: 70, height: 40),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 毛玻璃叶片
  Widget _buildGlassBlade({required double width, required double height}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(width / 2),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(width / 2),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.45),
                Colors.white.withValues(alpha: 0.15),
              ],
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.5),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.12),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              // 高光反射
              Positioned(
                top: 4,
                left: 4,
                right: 4,
                child: Container(
                  height: height * 0.35,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(width / 2),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withValues(alpha: 0.5),
                        Colors.white.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 文字排版
  Widget _buildTypography() {
    return Column(
      children: [
        // Aura
        Text(
          'Aura',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 42,
            fontWeight: FontWeight.w700,
            letterSpacing: 4,
            color: AppColors.warmGray850,
            shadows: [
              Shadow(
                color: AppColors.primary.withValues(alpha: 0.2),
                blurRadius: 20,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // 分隔线 + 拾光
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 32,
              height: 1,
              color: AppColors.primary.withValues(alpha: 0.4),
            ),
            const SizedBox(width: 12),
            Text(
              '拾光',
              style: GoogleFonts.notoSerifSc(
                fontSize: 22,
                fontWeight: FontWeight.w500,
                letterSpacing: 6,
                color: AppColors.warmGray700,
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 32,
              height: 1,
              color: AppColors.primary.withValues(alpha: 0.4),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Tagline
        Text(
          'SOULFUL LIFE-LOGGING',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.w400,
            letterSpacing: 3,
            color: AppColors.warmGray500,
          ),
        ),
      ],
    );
  }

  /// 底部加载区域
  Widget _buildBottomLoader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: Column(
        children: [
          // 进度条
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return Container(
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.warmGray200,
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: _progressAnimation.value,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(2),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.5),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          // 文字
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              final progress = (_progressAnimation.value * 100).toInt();
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Loading Memories...',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: AppColors.warmGray400,
                    ),
                  ),
                  Text(
                    '$progress%',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: AppColors.warmGray400,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

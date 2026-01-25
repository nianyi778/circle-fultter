import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/providers/auth_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_snackbar.dart';

/// 登录页面
///
/// 设计理念：
/// - 简洁优雅，与 Splash 保持一致的视觉风格
/// - 表单居中，背景有柔和光晕
/// - 支持键盘避让
class LoginView extends ConsumerStatefulWidget {
  const LoginView({super.key});

  @override
  ConsumerState<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends ConsumerState<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  bool _obscurePassword = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isSubmitting) return;

    setState(() => _isSubmitting = true);

    try {
      await ref
          .read(authProvider.notifier)
          .login(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );

      if (!mounted) return;

      final authState = ref.read(authProvider);

      if (authState.status == AuthStatus.authenticated) {
        context.go('/home');
      } else if (authState.status == AuthStatus.noCircle) {
        context.go('/circle-setup');
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.showError(context, e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.timeBeige,
      body: Stack(
        children: [
          // 背景光晕
          _buildBackgroundGlows(),

          // 主内容
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight:
                      MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 60),

                    // Logo 和标题
                    _buildHeader(),

                    const SizedBox(height: 48),

                    // 登录表单
                    _buildLoginForm(),

                    const SizedBox(height: 24),

                    // 注册链接
                    _buildRegisterLink(),

                    const SizedBox(height: 60),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
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

  /// 头部 Logo 和标题
  Widget _buildHeader() {
    return Column(
      children: [
        // Logo
        _buildSimpleLogo(),

        const SizedBox(height: 24),

        // Aura
        Text(
          'Aura',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 36,
            fontWeight: FontWeight.w700,
            letterSpacing: 3,
            color: AppColors.warmGray850,
          ),
        ),

        const SizedBox(height: 4),

        // 拾光
        Text(
          '拾光',
          style: GoogleFonts.notoSerifSc(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            letterSpacing: 4,
            color: AppColors.warmGray700,
          ),
        ),

        const SizedBox(height: 8),

        // 副标题
        Text(
          '欢迎回来',
          style: GoogleFonts.notoSansSc(
            fontSize: 14,
            color: AppColors.warmGray500,
          ),
        ),
      ],
    );
  }

  /// 简化的 Logo（毛玻璃效果）
  Widget _buildSimpleLogo() {
    return SizedBox(
      width: 80,
      height: 80,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 中心光晕
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.5),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
          ),

          // 毛玻璃圆环
          ClipOval(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: 0.4),
                      Colors.white.withValues(alpha: 0.15),
                    ],
                  ),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 登录表单
  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // 邮箱输入框
          _buildTextField(
            controller: _emailController,
            focusNode: _emailFocusNode,
            hintText: '邮箱',
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            prefixIcon: Icons.mail_outline_rounded,
            onFieldSubmitted: (_) {
              FocusScope.of(context).requestFocus(_passwordFocusNode);
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '请输入邮箱';
              }
              if (!RegExp(
                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
              ).hasMatch(value)) {
                return '请输入有效的邮箱地址';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // 密码输入框
          _buildTextField(
            controller: _passwordController,
            focusNode: _passwordFocusNode,
            hintText: '密码',
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
            prefixIcon: Icons.lock_outline_rounded,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: AppColors.warmGray400,
                size: 20,
              ),
              onPressed: () {
                setState(() => _obscurePassword = !_obscurePassword);
              },
            ),
            onFieldSubmitted: (_) => _handleLogin(),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '请输入密码';
              }
              if (value.length < 6) {
                return '密码至少6位';
              }
              return null;
            },
          ),

          const SizedBox(height: 32),

          // 登录按钮
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _handleLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.warmGray800,
                foregroundColor: AppColors.white,
                disabledBackgroundColor: AppColors.warmGray400,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child:
                  _isSubmitting
                      ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.white,
                          ),
                        ),
                      )
                      : Text(
                        '登录',
                        style: GoogleFonts.notoSansSc(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
            ),
          ),
        ],
      ),
    );
  }

  /// 通用输入框
  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hintText,
    required IconData prefixIcon,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    bool obscureText = false,
    Widget? suffixIcon,
    void Function(String)? onFieldSubmitted,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      onFieldSubmitted: onFieldSubmitted,
      validator: validator,
      style: GoogleFonts.notoSansSc(fontSize: 16, color: AppColors.warmGray800),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.notoSansSc(
          fontSize: 16,
          color: AppColors.warmGray400,
        ),
        prefixIcon: Icon(prefixIcon, color: AppColors.warmGray400, size: 22),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.warmGray250, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.warmGray250, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.warmGray400, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.dangerDark, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.dangerDark, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }

  /// 注册链接
  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '还没有账号？',
          style: GoogleFonts.notoSansSc(
            fontSize: 14,
            color: AppColors.warmGray500,
          ),
        ),
        TextButton(
          onPressed: () => context.go('/register'),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            '立即注册',
            style: GoogleFonts.notoSansSc(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}

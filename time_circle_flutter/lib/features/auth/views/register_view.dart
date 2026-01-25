import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/providers/auth_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_snackbar.dart';

/// 注册页面
///
/// 设计理念：
/// - 与登录页保持一致的视觉风格
/// - 简洁的注册流程：邮箱 + 密码 + 昵称
class RegisterView extends ConsumerStatefulWidget {
  const RegisterView({super.key});

  @override
  ConsumerState<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends ConsumerState<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();

  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();
  final _nameFocusNode = FocusNode();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isSubmitting) return;

    setState(() => _isSubmitting = true);

    try {
      await ref
          .read(authProvider.notifier)
          .register(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            name: _nameController.text.trim(),
          );

      if (!mounted) return;

      final authState = ref.read(authProvider);

      if (authState.status == AuthStatus.noCircle) {
        // 新用户需要创建或加入圈子
        context.go('/circle-setup');
      } else if (authState.status == AuthStatus.authenticated) {
        context.go('/home');
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
                    const SizedBox(height: 40),

                    // Logo 和标题
                    _buildHeader(),

                    const SizedBox(height: 40),

                    // 注册表单
                    _buildRegisterForm(),

                    const SizedBox(height: 24),

                    // 登录链接
                    _buildLoginLink(),

                    const SizedBox(height: 40),
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
          '开始记录你的时光',
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

  /// 注册表单
  Widget _buildRegisterForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // 昵称输入框
          _buildTextField(
            controller: _nameController,
            focusNode: _nameFocusNode,
            hintText: '昵称',
            textInputAction: TextInputAction.next,
            prefixIcon: Icons.person_outline_rounded,
            onFieldSubmitted: (_) {
              FocusScope.of(context).requestFocus(_emailFocusNode);
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '请输入昵称';
              }
              if (value.length < 2) {
                return '昵称至少2个字符';
              }
              if (value.length > 20) {
                return '昵称最多20个字符';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

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
            textInputAction: TextInputAction.next,
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
            onFieldSubmitted: (_) {
              FocusScope.of(context).requestFocus(_confirmPasswordFocusNode);
            },
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

          const SizedBox(height: 16),

          // 确认密码输入框
          _buildTextField(
            controller: _confirmPasswordController,
            focusNode: _confirmPasswordFocusNode,
            hintText: '确认密码',
            obscureText: _obscureConfirmPassword,
            textInputAction: TextInputAction.done,
            prefixIcon: Icons.lock_outline_rounded,
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirmPassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: AppColors.warmGray400,
                size: 20,
              ),
              onPressed: () {
                setState(
                  () => _obscureConfirmPassword = !_obscureConfirmPassword,
                );
              },
            ),
            onFieldSubmitted: (_) => _handleRegister(),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '请确认密码';
              }
              if (value != _passwordController.text) {
                return '两次密码输入不一致';
              }
              return null;
            },
          ),

          const SizedBox(height: 32),

          // 注册按钮
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _handleRegister,
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
                        '注册',
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

  /// 登录链接
  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '已有账号？',
          style: GoogleFonts.notoSansSc(
            fontSize: 14,
            color: AppColors.warmGray500,
          ),
        ),
        TextButton(
          onPressed: () => context.go('/login'),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            '立即登录',
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

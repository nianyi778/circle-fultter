import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/theme/app_theme.dart';

/// 设置页面统一的 AppBar
class SettingsAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onBack;

  const SettingsAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showBackButton = true,
    this.onBack,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.timeBeige,
      elevation: 0,
      leading:
          showBackButton
              ? IconButton(
                onPressed: onBack ?? () => context.pop(),
                icon: const Icon(
                  Iconsax.arrow_left_2,
                  color: AppColors.warmGray700,
                ),
              )
              : null,
      title: Text(
        title,
        style: AppTypography.title(
          context,
        ).copyWith(fontSize: 18, fontWeight: FontWeight.w600),
      ),
      centerTitle: true,
      actions: actions,
    );
  }
}

/// 设置页面 AppBar 的保存按钮
class SettingsSaveButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  final String label;

  const SettingsSaveButton({
    super.key,
    this.onPressed,
    this.isLoading = false,
    this.label = '保存',
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: isLoading ? null : onPressed,
      child:
          isLoading
              ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE8A87C)),
                ),
              )
              : Text(
                label,
                style: const TextStyle(
                  color: Color(0xFFE8A87C),
                  fontWeight: FontWeight.w600,
                ),
              ),
    );
  }
}

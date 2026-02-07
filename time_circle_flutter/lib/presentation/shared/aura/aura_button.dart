import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_theme.dart';

/// Button variants for different use cases
enum AuraButtonVariant {
  /// Primary action - filled with primary color
  primary,

  /// Secondary action - outlined style
  secondary,

  /// Ghost/text button - transparent background
  ghost,

  /// Danger action - for destructive operations
  danger,
}

/// Button sizes
enum AuraButtonSize {
  /// Small buttons for compact spaces
  small,

  /// Medium (default) for most use cases
  medium,

  /// Large for prominent CTAs
  large,
}

/// Aura Design System Button
///
/// A customizable button component following the Aura design guidelines.
/// Supports multiple variants, sizes, icons, and loading state.
///
/// Touch target: Always >= 48px (Android guideline)
class AuraButton extends StatelessWidget {
  /// Button label text
  final String label;

  /// Callback when button is pressed (null = disabled)
  final VoidCallback? onPressed;

  /// Visual variant of the button
  final AuraButtonVariant variant;

  /// Size of the button
  final AuraButtonSize size;

  /// Optional leading icon
  final IconData? icon;

  /// Optional trailing icon
  final IconData? trailingIcon;

  /// Show loading indicator
  final bool isLoading;

  /// Expand to full width
  final bool fullWidth;

  /// Enable haptic feedback
  final bool enableHaptic;

  const AuraButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AuraButtonVariant.primary,
    this.size = AuraButtonSize.medium,
    this.icon,
    this.trailingIcon,
    this.isLoading = false,
    this.fullWidth = false,
    this.enableHaptic = true,
  });

  /// Factory for primary button
  factory AuraButton.primary({
    Key? key,
    required String label,
    VoidCallback? onPressed,
    AuraButtonSize size = AuraButtonSize.medium,
    IconData? icon,
    bool isLoading = false,
    bool fullWidth = false,
  }) => AuraButton(
    key: key,
    label: label,
    onPressed: onPressed,
    variant: AuraButtonVariant.primary,
    size: size,
    icon: icon,
    isLoading: isLoading,
    fullWidth: fullWidth,
  );

  /// Factory for secondary button
  factory AuraButton.secondary({
    Key? key,
    required String label,
    VoidCallback? onPressed,
    AuraButtonSize size = AuraButtonSize.medium,
    IconData? icon,
    bool isLoading = false,
    bool fullWidth = false,
  }) => AuraButton(
    key: key,
    label: label,
    onPressed: onPressed,
    variant: AuraButtonVariant.secondary,
    size: size,
    icon: icon,
    isLoading: isLoading,
    fullWidth: fullWidth,
  );

  /// Factory for ghost/text button
  factory AuraButton.ghost({
    Key? key,
    required String label,
    VoidCallback? onPressed,
    AuraButtonSize size = AuraButtonSize.medium,
    IconData? icon,
    bool isLoading = false,
  }) => AuraButton(
    key: key,
    label: label,
    onPressed: onPressed,
    variant: AuraButtonVariant.ghost,
    size: size,
    icon: icon,
    isLoading: isLoading,
  );

  /// Factory for danger button
  factory AuraButton.danger({
    Key? key,
    required String label,
    VoidCallback? onPressed,
    AuraButtonSize size = AuraButtonSize.medium,
    IconData? icon,
    bool isLoading = false,
    bool fullWidth = false,
  }) => AuraButton(
    key: key,
    label: label,
    onPressed: onPressed,
    variant: AuraButtonVariant.danger,
    size: size,
    icon: icon,
    isLoading: isLoading,
    fullWidth: fullWidth,
  );

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null || isLoading;

    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: _getHeight(),
      child: Material(
        color: _getBackgroundColor(isDisabled),
        borderRadius: BorderRadius.circular(_getBorderRadius()),
        child: InkWell(
          onTap:
              isDisabled
                  ? null
                  : () {
                    if (enableHaptic) {
                      HapticFeedback.lightImpact();
                    }
                    onPressed!();
                  },
          borderRadius: BorderRadius.circular(_getBorderRadius()),
          splashColor: _getSplashColor(),
          child: Container(
            padding: _getPadding(),
            decoration: _getBorderDecoration(isDisabled),
            child: Row(
              mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading) ...[
                  SizedBox(
                    width: _getIconSize(),
                    height: _getIconSize(),
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(
                        _getTextColor(isDisabled),
                      ),
                    ),
                  ),
                ] else ...[
                  if (icon != null) ...[
                    Icon(
                      icon,
                      size: _getIconSize(),
                      color: _getTextColor(isDisabled),
                    ),
                    SizedBox(width: _getIconSpacing()),
                  ],
                  Text(label, style: _getTextStyle(isDisabled)),
                  if (trailingIcon != null) ...[
                    SizedBox(width: _getIconSpacing()),
                    Icon(
                      trailingIcon,
                      size: _getIconSize(),
                      color: _getTextColor(isDisabled),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  double _getHeight() {
    switch (size) {
      case AuraButtonSize.small:
        return 36;
      case AuraButtonSize.medium:
        return 48; // Minimum touch target
      case AuraButtonSize.large:
        return 56;
    }
  }

  double _getBorderRadius() {
    switch (size) {
      case AuraButtonSize.small:
        return AppRadius.xs;
      case AuraButtonSize.medium:
        return AppRadius.sm;
      case AuraButtonSize.large:
        return AppRadius.md;
    }
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case AuraButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
      case AuraButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 20, vertical: 12);
      case AuraButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 16);
    }
  }

  double _getIconSize() {
    switch (size) {
      case AuraButtonSize.small:
        return 16;
      case AuraButtonSize.medium:
        return 20;
      case AuraButtonSize.large:
        return 24;
    }
  }

  double _getIconSpacing() {
    switch (size) {
      case AuraButtonSize.small:
        return 6;
      case AuraButtonSize.medium:
        return 8;
      case AuraButtonSize.large:
        return 10;
    }
  }

  Color _getBackgroundColor(bool isDisabled) {
    if (isDisabled && variant != AuraButtonVariant.ghost) {
      return AppColors.warmGray200;
    }

    switch (variant) {
      case AuraButtonVariant.primary:
        return AppColors.primary;
      case AuraButtonVariant.secondary:
        return Colors.transparent;
      case AuraButtonVariant.ghost:
        return Colors.transparent;
      case AuraButtonVariant.danger:
        return AppColors.dangerDark;
    }
  }

  Color _getTextColor(bool isDisabled) {
    if (isDisabled) {
      return AppColors.warmGray400;
    }

    switch (variant) {
      case AuraButtonVariant.primary:
        return AppColors.white;
      case AuraButtonVariant.secondary:
        return AppColors.warmGray700;
      case AuraButtonVariant.ghost:
        return AppColors.warmGray700;
      case AuraButtonVariant.danger:
        return AppColors.white;
    }
  }

  Color _getSplashColor() {
    switch (variant) {
      case AuraButtonVariant.primary:
        return AppColors.white.withValues(alpha: 0.15);
      case AuraButtonVariant.secondary:
        return AppColors.warmGray500.withValues(alpha: 0.1);
      case AuraButtonVariant.ghost:
        return AppColors.warmGray500.withValues(alpha: 0.1);
      case AuraButtonVariant.danger:
        return AppColors.white.withValues(alpha: 0.15);
    }
  }

  BoxDecoration? _getBorderDecoration(bool isDisabled) {
    if (variant != AuraButtonVariant.secondary) {
      return null;
    }

    return BoxDecoration(
      borderRadius: BorderRadius.circular(_getBorderRadius()),
      border: Border.all(
        color: isDisabled ? AppColors.warmGray300 : AppColors.warmGray400,
        width: 1.5,
      ),
    );
  }

  TextStyle _getTextStyle(bool isDisabled) {
    final baseStyle = TextStyle(
      color: _getTextColor(isDisabled),
      fontWeight: FontWeight.w600,
      letterSpacing: 0.2,
    );

    switch (size) {
      case AuraButtonSize.small:
        return baseStyle.copyWith(fontSize: 13);
      case AuraButtonSize.medium:
        return baseStyle.copyWith(fontSize: 15);
      case AuraButtonSize.large:
        return baseStyle.copyWith(fontSize: 16);
    }
  }
}

/// Aura Icon Button
///
/// A circular icon button for actions like close, edit, delete.
/// Touch target: Always 48px minimum.
class AuraIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final Color? color;
  final Color? backgroundColor;
  final bool enableHaptic;
  final String? tooltip;

  const AuraIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.size = 24,
    this.color,
    this.backgroundColor,
    this.enableHaptic = true,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null;
    final iconColor =
        isDisabled ? AppColors.warmGray400 : (color ?? AppColors.warmGray600);

    Widget button = Material(
      color: backgroundColor ?? Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        onTap:
            isDisabled
                ? null
                : () {
                  if (enableHaptic) {
                    HapticFeedback.lightImpact();
                  }
                  onPressed!();
                },
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 48, // Minimum touch target
          height: 48,
          child: Center(child: Icon(icon, size: size, color: iconColor)),
        ),
      ),
    );

    if (tooltip != null) {
      button = Tooltip(message: tooltip!, child: button);
    }

    return button;
  }
}

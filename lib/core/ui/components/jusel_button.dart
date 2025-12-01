import 'package:flutter/material.dart';
import 'package:jusel_app/core/utils/theme.dart';

enum JuselButtonVariant { primary, secondary, outline, ghost }
enum JuselButtonSize { small, medium, large }

class JuselButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final JuselButtonVariant variant;
  final JuselButtonSize size;
  final bool isFullWidth;
  final IconData? icon;

  const JuselButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = JuselButtonVariant.primary,
    this.size = JuselButtonSize.medium,
    this.isFullWidth = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final buttonStyle = _getButtonStyle();
    final padding = _getPadding();
    final textStyle = _getTextStyle();

    Widget button = ElevatedButton(
      onPressed: onPressed,
      style: buttonStyle,
      child: Padding(
        padding: padding,
        child: Row(
          mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: _getIconSize()),
              const SizedBox(width: JuselSpacing.s8),
            ],
            Text(label, style: textStyle),
          ],
        ),
      ),
    );

    if (isFullWidth) {
      button = SizedBox(width: double.infinity, child: button);
    }

    return button;
  }

  ButtonStyle _getButtonStyle() {
    switch (variant) {
      case JuselButtonVariant.primary:
        return ElevatedButton.styleFrom(
          backgroundColor: JuselColors.primary,
          foregroundColor: JuselColors.primaryForeground,
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(JuselRadii.medium),
          ),
        );
      case JuselButtonVariant.secondary:
        return ElevatedButton.styleFrom(
          backgroundColor: JuselColors.secondary,
          foregroundColor: JuselColors.secondaryForeground,
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(JuselRadii.medium),
          ),
        );
      case JuselButtonVariant.outline:
        return ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: JuselColors.primary,
          elevation: 0,
          side: const BorderSide(color: JuselColors.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(JuselRadii.medium),
          ),
        );
      case JuselButtonVariant.ghost:
        return ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: JuselColors.foreground,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(JuselRadii.medium),
          ),
        );
    }
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case JuselButtonSize.small:
        return const EdgeInsets.symmetric(
          horizontal: JuselSpacing.s12,
          vertical: JuselSpacing.s8,
        );
      case JuselButtonSize.medium:
        return const EdgeInsets.symmetric(
          horizontal: JuselSpacing.s16,
          vertical: JuselSpacing.s12,
        );
      case JuselButtonSize.large:
        return const EdgeInsets.symmetric(
          horizontal: JuselSpacing.s20,
          vertical: JuselSpacing.s16,
        );
    }
  }

  TextStyle _getTextStyle() {
    switch (size) {
      case JuselButtonSize.small:
        return JuselTextStyles.bodySmall.copyWith(
          fontWeight: FontWeight.w600,
        );
      case JuselButtonSize.medium:
        return JuselTextStyles.bodyMedium.copyWith(
          fontWeight: FontWeight.w600,
        );
      case JuselButtonSize.large:
        return JuselTextStyles.bodyLarge.copyWith(
          fontWeight: FontWeight.w600,
        );
    }
  }

  double _getIconSize() {
    switch (size) {
      case JuselButtonSize.small:
        return 16;
      case JuselButtonSize.medium:
        return 18;
      case JuselButtonSize.large:
        return 20;
    }
  }
}


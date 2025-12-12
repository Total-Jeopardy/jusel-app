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
    final buttonStyle = _getButtonStyle(context);
    final padding = _getPadding();
    final textStyle = _getTextStyle(context);

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

  ButtonStyle _getButtonStyle(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    switch (variant) {
      case JuselButtonVariant.primary:
        return ElevatedButton.styleFrom(
          backgroundColor: JuselColors.primaryColor(context),
          foregroundColor: JuselColors.primaryForeground,
          elevation: isDark ? 0 : 1,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(JuselRadii.medium),
          ),
        );
      case JuselButtonVariant.secondary:
        return ElevatedButton.styleFrom(
          backgroundColor: JuselColors.secondaryColor(context),
          foregroundColor: JuselColors.secondaryForeground,
          elevation: isDark ? 0 : 1,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(JuselRadii.medium),
          ),
        );
      case JuselButtonVariant.outline:
        return ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: JuselColors.primaryColor(context),
          elevation: 0,
          side: BorderSide(color: JuselColors.primaryColor(context)),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(JuselRadii.medium),
          ),
        );
      case JuselButtonVariant.ghost:
        return ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: JuselColors.foreground(context),
          elevation: 0,
          shape: const RoundedRectangleBorder(
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

  TextStyle _getTextStyle(BuildContext context) {
    switch (size) {
      case JuselButtonSize.small:
        return JuselTextStyles.bodySmall(context).copyWith(
          fontWeight: FontWeight.w600,
        );
      case JuselButtonSize.medium:
        return JuselTextStyles.bodyMedium(context).copyWith(
          fontWeight: FontWeight.w600,
        );
      case JuselButtonSize.large:
        return JuselTextStyles.bodyLarge(context).copyWith(
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

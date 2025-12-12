import 'package:flutter/material.dart';
import 'package:jusel_app/core/utils/theme.dart';

enum JuselCardPadding { none, sm, md, lg }

class JuselCard extends StatelessWidget {
  final Widget child;
  final JuselCardPadding padding;
  final Color? backgroundColor;
  final EdgeInsets? customPadding;
  final bool elevated;

  const JuselCard({
    super.key,
    required this.child,
    this.padding = JuselCardPadding.md,
    this.backgroundColor,
    this.customPadding,
    this.elevated = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Card(
      color: backgroundColor ?? 
        (elevated && isDark 
          ? JuselColors.cardElevated(context)
          : JuselColors.card(context)),
      elevation: isDark ? 0 : 1,
      shadowColor: isDark 
        ? Colors.transparent 
        : Colors.black.withOpacity(0.12),
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(JuselRadii.large),
        side: isDark && !elevated
          ? BorderSide(
              color: JuselColors.border(context).withOpacity(0.3),
              width: 1,
            )
          : BorderSide.none,
      ),
      child: Padding(
        padding: customPadding ?? _getPadding(),
        child: child,
      ),
    );
  }

  EdgeInsets _getPadding() {
    switch (padding) {
      case JuselCardPadding.none:
        return EdgeInsets.zero;
      case JuselCardPadding.sm:
        return const EdgeInsets.all(JuselSpacing.s12);
      case JuselCardPadding.md:
        return const EdgeInsets.all(JuselSpacing.s16);
      case JuselCardPadding.lg:
        return const EdgeInsets.all(JuselSpacing.s24);
    }
  }
}

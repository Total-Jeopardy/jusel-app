import 'package:flutter/material.dart';
import 'package:jusel_app/core/utils/theme.dart';

enum JuselCardPadding { none, sm, md, lg }

class JuselCard extends StatelessWidget {
  final Widget child;
  final JuselCardPadding padding;
  final Color? backgroundColor;
  final EdgeInsets? customPadding;

  const JuselCard({
    super.key,
    required this.child,
    this.padding = JuselCardPadding.md,
    this.backgroundColor,
    this.customPadding,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: backgroundColor ?? JuselColors.card,
      elevation: 1,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(JuselRadii.large),
      ),
      child: Padding(padding: customPadding ?? _getPadding(), child: child),
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

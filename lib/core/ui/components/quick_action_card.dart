import 'package:flutter/material.dart';
import 'package:jusel_app/core/utils/theme.dart';

class QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final List<Color>? gradientColors;
  final Color? iconColor;

  const QuickActionCard({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.gradientColors,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = JuselColors.primaryColor(context);
    
    final colors = gradientColors ??
        [
          primaryColor.withOpacity(isDark ? 0.2 : 0.12),
          primaryColor.withOpacity(isDark ? 0.1 : 0.06),
        ];

    return Material(
      color: JuselColors.card(context),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 110,
          padding: const EdgeInsets.symmetric(
            horizontal: JuselSpacing.s12,
            vertical: JuselSpacing.s16,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: JuselColors.border(context).withOpacity(0.9),
              width: 1.1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: colors),
                ),
                child: Icon(
                  icon,
                  color: iconColor ?? primaryColor,
                ),
              ),
              const SizedBox(height: JuselSpacing.s12),
              Text(
                label,
                style: JuselTextStyles.bodyMedium(context).copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

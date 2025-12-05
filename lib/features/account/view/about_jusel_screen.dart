import 'package:flutter/material.dart';
import 'package:jusel_app/core/utils/navigation_helper.dart';
import 'package:jusel_app/core/utils/theme.dart';

class AboutJuselScreen extends StatelessWidget {
  const AboutJuselScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => safePop(context, fallbackRoute: '/boss-dashboard'),
        ),
        title: const Text(
          'About Jusel',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 420;
          final horizontalPadding = isNarrow ? 16.0 : 24.0;
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  24,
                  horizontalPadding,
                  28,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: JuselSpacing.s8),
                    _AppIcon(),
                    const SizedBox(height: JuselSpacing.s16),
                    Text(
                      'Jusel',
                      style: JuselTextStyles.headlineLarge.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 30,
                      ),
                    ),
                    const SizedBox(height: JuselSpacing.s8),
                    Text(
                      'Inventory and sales manager for\nsmall shops',
                      textAlign: TextAlign.center,
                      style: JuselTextStyles.bodySmall.copyWith(
                        color: JuselColors.mutedForeground,
                        fontWeight: FontWeight.w400,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: JuselSpacing.s12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text(
                        'Version 1.2.0 (Build 45)',
                        style: TextStyle(
                          color: JuselColors.mutedForeground,
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    const SizedBox(height: JuselSpacing.s20),
                    _LinksCard(),
                    const SizedBox(height: JuselSpacing.s20),
                    Column(
                      children: [
                        Text(
                          '© 2023 JuiceNa Technologies',
                          style: JuselTextStyles.bodySmall.copyWith(
                            color: JuselColors.mutedForeground,
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: JuselSpacing.s8),
                        Text(
                          'Powered by Total_Jeopardy from JuiceNa Technologies',
                          textAlign: TextAlign.center,
                          style: JuselTextStyles.bodySmall.copyWith(
                            color: JuselColors.mutedForeground.withOpacity(0.9),
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _AppIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [Color(0xFF1F6BFF), Color(0xFF6A63FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1F6BFF).withOpacity(0.25),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Center(
        child: Icon(
          Icons.store_mall_directory_rounded,
          color: Colors.white,
          size: 60,
        ),
      ),
    );
  }
}

class _LinksCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final items = [
      _LinkItem(label: 'Privacy Policy', onTap: () {}),
      _LinkItem(label: 'Terms of Service', onTap: () {}),
      _LinkItem(label: 'Open Source Licenses', onTap: () {}),
    ];

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final isLast = entry.key == items.length - 1;
          return Column(
            children: [
              entry.value,
              if (!isLast) const Divider(height: 1, color: Color(0xFFE5E7EB)),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _LinkItem extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _LinkItem({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: JuselSpacing.s12,
          vertical: JuselSpacing.s20,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: JuselTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                  color: JuselColors.foreground,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: JuselColors.mutedForeground),
          ],
        ),
      ),
    );
  }
}

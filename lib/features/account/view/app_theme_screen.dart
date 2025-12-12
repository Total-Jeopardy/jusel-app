import 'package:flutter/material.dart';
import 'package:jusel_app/core/utils/navigation_helper.dart';
import 'package:jusel_app/core/utils/theme.dart';

enum _ThemeOption { light, dark, system }

class AppThemeScreen extends StatefulWidget {
  const AppThemeScreen({super.key});

  @override
  State<AppThemeScreen> createState() => _AppThemeScreenState();
}

class _AppThemeScreenState extends State<AppThemeScreen> {
  _ThemeOption _selected = _ThemeOption.light;

  void _select(_ThemeOption option) {
    setState(() => _selected = option);
  }

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
          'App Theme',
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
                  12,
                  horizontalPadding,
                  28,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: JuselSpacing.s8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _ThemePreviewCard(
                          label: 'Light',
                          selected: _selected == _ThemeOption.light,
                          onTap: () => _select(_ThemeOption.light),
                          isDark: false,
                        ),
                        const SizedBox(width: JuselSpacing.s12),
                        _ThemePreviewCard(
                          label: 'Dark',
                          selected: _selected == _ThemeOption.dark,
                          onTap: () => _select(_ThemeOption.dark),
                          isDark: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: JuselSpacing.s16),
                    _SettingsSection(
                      title: 'APPEARANCE',
                      children: [
                        _ThemeOptionTile(
                          icon: Icons.wb_sunny_outlined,
                          label: 'Light',
                          selected: _selected == _ThemeOption.light,
                          onTap: () => _select(_ThemeOption.light),
                        ),
                        _ThemeOptionTile(
                          icon: Icons.nightlight_outlined,
                          label: 'Dark',
                          selected: _selected == _ThemeOption.dark,
                          onTap: () => _select(_ThemeOption.dark),
                        ),
                        _ThemeOptionTile(
                          icon: Icons.smartphone_outlined,
                          label: 'System Default',
                          selected: _selected == _ThemeOption.system,
                          onTap: () => _select(_ThemeOption.system),
                        ),
                      ],
                    ),
                    const SizedBox(height: JuselSpacing.s12),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: Text(
                        '"System Default" will automatically adjust the appearance based on your device\'s display settings.',
                        style: JuselTextStyles.bodySmall(context).copyWith(
                          color: JuselColors.mutedForeground(context),
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.left,
                      ),
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

class _ThemePreviewCard extends StatelessWidget {
  final bool selected;
  final bool isDark;
  final String label;
  final VoidCallback onTap;

  const _ThemePreviewCard({
    required this.selected,
    required this.isDark,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = selected
        ? JuselColors.primaryColor(context)
        : JuselColors.border(context);
    final overlayColor = selected
        ? JuselColors.primaryColor(context).withOpacity(0.08)
        : Colors.transparent;
    final bgColor = isDark
        ? JuselColors.background(context)
        : JuselColors.card(context);
    final placeholder = JuselColors.muted(context);

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor, width: selected ? 2 : 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              foregroundDecoration: BoxDecoration(
                color: overlayColor,
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(JuselSpacing.s12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 10,
                    width: 90,
                    decoration: BoxDecoration(
                      color: placeholder.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: JuselSpacing.s12),
                  Container(
                    height: 12,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: placeholder,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: JuselSpacing.s8),
                  Container(
                    height: 12,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: placeholder,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: JuselSpacing.s8),
                  Container(
                    height: 12,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: placeholder,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: JuselSpacing.s8),
                  Container(
                    height: 12,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: placeholder,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: JuselSpacing.s8),
            Text(
              label,
              style: JuselTextStyles.bodyMedium(context).copyWith(
                fontWeight: FontWeight.w700,
                color: JuselColors.foreground(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _SettingsSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: JuselSpacing.s12),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: JuselTextStyles.bodySmall(context).copyWith(
                color: JuselColors.mutedForeground(context),
                fontWeight: FontWeight.w700,
                fontSize: 14,
                letterSpacing: 0.1,
              ),
            ),
            const SizedBox(height: JuselSpacing.s8),
            Container(
              decoration: BoxDecoration(
                color: JuselColors.card(context),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: JuselColors.border(context)),
              ),
              child: Column(
                children: children.asMap().entries.map((entry) {
                  final isLast = entry.key == children.length - 1;
                  return Column(
                    children: [
                      entry.value,
                      if (!isLast)
                        Divider(
                          height: 1,
                          color: JuselColors.border(context),
                          thickness: 1,
                        ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeOptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeOptionTile({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tileColor = selected
        ? JuselColors.primaryColor(context).withOpacity(0.12)
        : JuselColors.card(context);
    final borderColor = selected
        ? JuselColors.primaryColor(context).withOpacity(0.3)
        : JuselColors.border(context);

    return Material(
      color: tileColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: borderColor, width: selected ? 1 : 0),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: JuselSpacing.s12,
            vertical: JuselSpacing.s12,
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: selected
                      ? JuselColors.primaryColor(context).withOpacity(0.12)
                      : JuselColors.muted(context),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: selected
                      ? JuselColors.primaryColor(context)
                      : JuselColors.foreground(context),
                ),
              ),
              const SizedBox(width: JuselSpacing.s12),
              Expanded(
                child: Text(
                  label,
                  style: JuselTextStyles.bodyMedium(context).copyWith(
                    fontWeight: FontWeight.w700,
                    color: JuselColors.foreground(context),
                  ),
                ),
              ),
              if (selected) Icon(Icons.check, color: JuselColors.primaryColor(context)),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:jusel_app/core/utils/navigation_helper.dart';
import 'package:jusel_app/core/utils/theme.dart';

class NotificationsSettingsScreen extends StatefulWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  State<NotificationsSettingsScreen> createState() =>
      _NotificationsSettingsScreenState();
}

class _NotificationsSettingsScreenState
    extends State<NotificationsSettingsScreen> {
  bool _allowAll = true;
  bool _lowStock = true;
  bool _newSales = false;
  bool _dailySummary = true;
  bool _vibration = true;
  bool _syncStatus = true;
  bool _marketing = false;

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
          'Notifications',
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SystemStatusCard(
                      title: 'Allowed on this device',
                      subtitle: 'Notifications are enabled in system settings.',
                    ),
                    const SizedBox(height: JuselSpacing.s12),
                    _ToggleTile(
                      label: 'Allow All Notifications',
                      value: _allowAll,
                      onChanged: (val) => setState(() => _allowAll = val),
                    ),
                    const SizedBox(height: JuselSpacing.s12),
                    _Section(
                      title: 'INVENTORY & SALES',
                      children: [
                        _ToggleTile(
                          label: 'Low Stock Alerts',
                          description:
                              'Get notified when inventory drops below your set threshold.',
                          value: _lowStock,
                          onChanged: (val) => setState(() => _lowStock = val),
                        ),
                        _ToggleTile(
                          label: 'New Sales Alerts',
                          badge: 'BOSS ONLY',
                          description:
                              'Receive instant alerts for every new sale recorded.',
                          value: _newSales,
                          onChanged: (val) => setState(() => _newSales = val),
                        ),
                        _ToggleTile(
                          label: 'Daily Sales Summary',
                          description:
                              'Get a summary of the day\'s performance at closing time.',
                          value: _dailySummary,
                          onChanged: (val) =>
                              setState(() => _dailySummary = val),
                          footer: Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                size: 16,
                                color: JuselColors.successColor(context),
                              ),
                              const SizedBox(width: JuselSpacing.s6),
                              Text(
                                'Last sent: Today at 8:00 PM',
                                style: TextStyle(
                                  color: JuselColors.mutedForeground(context),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    _Section(
                      title: 'PREFERENCES',
                      children: [
                        _ToggleTile(
                          label: 'Vibration',
                          description: 'Vibrate when alerts are received.',
                          value: _vibration,
                          onChanged: (val) => setState(() => _vibration = val),
                        ),
                      ],
                    ),
                    _Section(
                      title: 'SYSTEM',
                      children: [
                        _ToggleTile(
                          label: 'Sync Status',
                          description:
                              'Know when your data is successfully synced or if sync fails.',
                          value: _syncStatus,
                          onChanged: (val) => setState(() => _syncStatus = val),
                        ),
                      ],
                    ),
                    _Section(
                      title: 'UPDATES',
                      children: [
                        _ToggleTile(
                          label: 'Marketing & Updates',
                          description:
                              'Stay updated with new features, tips, and special offers.',
                          value: _marketing,
                          onChanged: (val) => setState(() => _marketing = val),
                        ),
                      ],
                    ),
                    const SizedBox(height: JuselSpacing.s12),
                    Center(
                      child: TextButton(
                        onPressed: () {},
                        child: Text(
                          'Send Test Notification',
                          style: TextStyle(
                            color: JuselColors.primaryColor(context),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
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

class _SystemStatusCard extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SystemStatusCard({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(JuselSpacing.s12),
      decoration: BoxDecoration(
        color: JuselColors.successColor(context).withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: JuselColors.successColor(context).withOpacity(0.3),
        ),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: JuselColors.successColor(context).withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_active_outlined,
                color: JuselColors.successColor(context),
              ),
            ),
            const SizedBox(width: JuselSpacing.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: JuselTextStyles.bodyMedium(context).copyWith(
                      fontWeight: FontWeight.w700,
                      color: JuselColors.foreground(context),
                    ),
                  ),
                  const SizedBox(height: JuselSpacing.s4),
                  Text(
                    subtitle,
                    style: JuselTextStyles.bodySmall(context).copyWith(
                      color: JuselColors.mutedForeground(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _Section({required this.title, required this.children});

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

class _ToggleTile extends StatelessWidget {
  final String label;
  final String? description;
  final String? badge;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Widget? footer;

  const _ToggleTile({
    required this.label,
    required this.value,
    required this.onChanged,
    this.description,
    this.badge,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: JuselSpacing.s12,
        vertical: JuselSpacing.s12,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          label,
                          style: JuselTextStyles.bodyMedium(context).copyWith(
                            fontWeight: FontWeight.w700,
                            color: JuselColors.foreground(context),
                          ),
                        ),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: JuselSpacing.s6),
                        _Badge(label: badge!),
                      ],
                    ],
                  ),
                ),
                Switch(
                  value: value,
                  onChanged: onChanged,
                  activeThumbColor: JuselColors.primaryForeground,
                  activeTrackColor: JuselColors.primaryColor(context),
                ),
              ],
            ),
            if (description != null) ...[
              const SizedBox(height: JuselSpacing.s4),
              Text(
                description!,
                style: JuselTextStyles.bodySmall(context).copyWith(
                  color: JuselColors.mutedForeground(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            if (footer != null) ...[
              const SizedBox(height: JuselSpacing.s8),
              footer!,
            ],
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  const _Badge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: JuselColors.primaryColor(context).withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: JuselColors.primaryColor(context),
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
      ),
    );
  }
}

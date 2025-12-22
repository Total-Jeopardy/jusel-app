import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jusel_app/core/providers/global_providers.dart';
import 'package:jusel_app/core/utils/navigation_helper.dart';
import 'package:jusel_app/core/utils/theme.dart';

class NotificationsSettingsScreen extends ConsumerStatefulWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  ConsumerState<NotificationsSettingsScreen> createState() =>
      _NotificationsSettingsScreenState();
}

class _NotificationsSettingsScreenState
    extends ConsumerState<NotificationsSettingsScreen> {
  bool _allowAll = true;
  bool _lowStock = true;
  bool _newSales = false;
  bool _dailySummary = true;
  bool _vibration = true;
  bool _syncStatus = true;
  bool _marketing = false;
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _loadSettings();
  }
  
  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    try {
      final settingsService = await ref.read(settingsServiceProvider.future);
      final allowAll = await settingsService.getAllowAllNotifications();
      final lowStock = await settingsService.getLowStockAlerts();
      final newSales = await settingsService.getNewSalesAlerts();
      final dailySummary = await settingsService.getDailySummary();
      final vibration = await settingsService.getVibration();
      final syncStatus = await settingsService.getSyncStatusAlerts();
      final marketing = await settingsService.getMarketing();
      
      if (mounted) {
        setState(() {
          _allowAll = allowAll;
          _lowStock = lowStock;
          _newSales = newSales;
          _dailySummary = dailySummary;
          _vibration = vibration;
          _syncStatus = syncStatus;
          _marketing = marketing;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  
  Future<void> _updateSetting<T>(
    Future<void> Function(T) setter,
    T value,
  ) async {
    try {
      await setter(value);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update setting: $e'),
            backgroundColor: JuselColors.destructiveColor(context),
          ),
        );
      }
    }
  }
  
  Future<void> _handleAllowAllChanged(bool value) async {
    setState(() => _allowAll = value);
    final settingsService = await ref.read(settingsServiceProvider.future);
    await _updateSetting(settingsService.setAllowAllNotifications, value);
  }
  
  Future<void> _handleLowStockChanged(bool value) async {
    setState(() => _lowStock = value);
    final settingsService = await ref.read(settingsServiceProvider.future);
    await _updateSetting(settingsService.setLowStockAlerts, value);
  }
  
  Future<void> _handleNewSalesChanged(bool value) async {
    setState(() => _newSales = value);
    final settingsService = await ref.read(settingsServiceProvider.future);
    await _updateSetting(settingsService.setNewSalesAlerts, value);
  }
  
  Future<void> _handleDailySummaryChanged(bool value) async {
    setState(() => _dailySummary = value);
    final settingsService = await ref.read(settingsServiceProvider.future);
    await _updateSetting(settingsService.setDailySummary, value);
  }
  
  Future<void> _handleVibrationChanged(bool value) async {
    setState(() => _vibration = value);
    final settingsService = await ref.read(settingsServiceProvider.future);
    await _updateSetting(settingsService.setVibration, value);
  }
  
  Future<void> _handleSyncStatusChanged(bool value) async {
    setState(() => _syncStatus = value);
    final settingsService = await ref.read(settingsServiceProvider.future);
    await _updateSetting(settingsService.setSyncStatusAlerts, value);
  }
  
  Future<void> _handleMarketingChanged(bool value) async {
    setState(() => _marketing = value);
    final settingsService = await ref.read(settingsServiceProvider.future);
    await _updateSetting(settingsService.setMarketing, value);
  }
  
  Future<void> _sendTestNotification() async {
    try {
      // Show a local notification-like snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.notifications_active, color: Colors.white),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Test notification sent! Check your device notifications.',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            backgroundColor: JuselColors.successColor(context),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send test notification: $e'),
            backgroundColor: JuselColors.destructiveColor(context),
          ),
        );
      }
    }
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
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : Column(
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
                      onChanged: _handleAllowAllChanged,
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
                          onChanged: _handleLowStockChanged,
                        ),
                        _ToggleTile(
                          label: 'New Sales Alerts',
                          badge: 'BOSS ONLY',
                          description:
                              'Receive instant alerts for every new sale recorded.',
                          value: _newSales,
                          onChanged: _handleNewSalesChanged,
                        ),
                        _ToggleTile(
                          label: 'Daily Sales Summary',
                          description:
                              'Get a summary of the day\'s performance at closing time.',
                          value: _dailySummary,
                          onChanged: _handleDailySummaryChanged,
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
                          onChanged: _handleVibrationChanged,
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
                          onChanged: _handleSyncStatusChanged,
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
                          onChanged: _handleMarketingChanged,
                        ),
                      ],
                    ),
                    const SizedBox(height: JuselSpacing.s12),
                    Center(
                      child: TextButton(
                        onPressed: _isLoading ? null : _sendTestNotification,
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

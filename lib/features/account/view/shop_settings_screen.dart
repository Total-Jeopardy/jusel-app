import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:jusel_app/core/providers/global_providers.dart';
import 'package:jusel_app/core/sync/sync_orchestrator.dart';
import 'package:jusel_app/core/ui/components/success_overlay.dart';
import 'package:jusel_app/core/utils/navigation_helper.dart';
import 'package:jusel_app/core/utils/theme.dart';
import 'package:jusel_app/features/account/view/data_management_screen.dart';
import 'package:jusel_app/features/auth/viewmodel/auth_viewmodel.dart';

class ShopSettingsScreen extends ConsumerStatefulWidget {
  const ShopSettingsScreen({super.key});

  @override
  ConsumerState<ShopSettingsScreen> createState() => _ShopSettingsScreenState();
}

class _ShopSettingsScreenState extends ConsumerState<ShopSettingsScreen> {
  bool _autoSync = true;
  bool _isSyncing = false;
  DateTime? _lastSyncedAt;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settingsService = await ref.read(settingsServiceProvider.future);
    final autoSync = await settingsService.getAutoSync();
    final lastSynced = await settingsService.getLastSyncedAt();

    if (mounted) {
      setState(() {
        _autoSync = autoSync;
        _lastSyncedAt = lastSynced;
      });
    }
  }

  Future<void> _handleSyncNow() async {
    setState(() => _isSyncing = true);
    try {
      final orchestrator = ref.read(syncOrchestratorProvider);
      final user = ref.read(authViewModelProvider).value;

      if (user == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Please sign in to sync data'),
              backgroundColor: JuselColors.destructiveColor(context),
            ),
          );
        }
        return;
      }

      // Check connectivity before syncing
      if (!await orchestrator.isOnline()) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Device is offline. Please check your connection.',
              ),
              backgroundColor: JuselColors.destructiveColor(context),
            ),
          );
        }
        return;
      }

      // First pull down data from Firestore
      final pullResult = await orchestrator.pullAllForUser(user.uid);
      if (!mounted) return;

      // Then push local changes to Firestore
      final pushResult = await orchestrator.syncAll();
      if (!mounted) return;

      final totalSynced = pullResult.syncedCount + pushResult.syncedCount;
      final totalFailed = pullResult.failedCount + pushResult.failedCount;

      // Only update last synced timestamp if both operations succeeded
      // (or at least didn't fail completely)
      final bothSucceeded =
          pullResult.status != SyncStatus.error &&
          pushResult.status != SyncStatus.error &&
          pullResult.status != SyncStatus.offline &&
          pushResult.status != SyncStatus.offline;

      if (bothSucceeded) {
        final settingsService = await ref.read(settingsServiceProvider.future);
        final now = DateTime.now();
        await settingsService.setLastSyncedAt(now);
        if (!mounted) return;

        setState(() {
          _lastSyncedAt = now;
        });
      }

      if (totalFailed > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Synced: $totalSynced, Failed: $totalFailed'),
            backgroundColor: JuselColors.destructiveColor(context),
          ),
        );
      } else {
        SuccessOverlay.show(context, message: 'All items synced successfully!');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sync failed: $e'),
            backgroundColor: JuselColors.destructiveColor(context),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSyncing = false);
      }
    }
  }

  String _formatLastSynced(DateTime? dateTime) {
    if (dateTime == null) return 'Never';
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return DateFormat('MMM d, y • h:mm a').format(dateTime);
    }
  }

  Future<void> _saveSettings() async {
    final user = ref.read(authViewModelProvider).value;
    final isApprentice = user?.role == 'apprentice';

    final settingsService = await ref.read(settingsServiceProvider.future);

    // For apprentices, always save as true (mandatory)
    final autoSyncValue = isApprentice ? true : _autoSync;
    await settingsService.setAutoSync(autoSyncValue);

    // Periodic sync service will auto-restart via auth state listener
    // But we can also manually restart to ensure immediate effect
    try {
      final periodicSync = ref.read(periodicSyncServiceProvider);
      await periodicSync.restart();
    } catch (e) {
      // Ignore errors - service will restart on next auth check
      print('[ShopSettings] Failed to restart periodic sync: $e');
    }

    if (mounted) {
      SuccessOverlay.show(context, message: 'Settings saved successfully');
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
          'Shop Settings',
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
                    const SizedBox(height: JuselSpacing.s12),
                    const _ShopLogo(),
                    const SizedBox(height: JuselSpacing.s12),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        'Edit Shop Logo',
                        style: TextStyle(
                          color: JuselColors.primaryColor(context),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: JuselSpacing.s12),
                    _SettingsSection(
                      title: 'GENERAL INFO',
                      children: [
                        const _SettingTile(
                          label: 'Shop Name *',
                          value: 'Jusel Store',
                        ),
                        const _SettingTile(
                          label: 'Phone',
                          value: '+233 55 123 4567',
                        ),
                        _SettingTile(
                          label: 'Address',
                          value: 'Add address (Optional)',
                          valueStyle: JuselTextStyles.bodySmall(context)
                              .copyWith(
                                color: JuselColors.mutedForeground(context),
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        _SettingTile(
                          label: 'Currency',
                          value: 'GHS (Ghana Cedi)',
                          trailing: Icon(
                            Icons.chevron_right,
                            color: JuselColors.mutedForeground(context),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: JuselSpacing.s12),
                    _SettingsSection(
                      title: 'DATA & SYNC',
                      children: [
                        Consumer(
                          builder: (context, ref, _) {
                            final user = ref.watch(authViewModelProvider).value;
                            final isApprentice = user?.role == 'apprentice';

                            return _ToggleTile(
                              label: 'Auto Sync',
                              description: isApprentice
                                  ? 'Auto sync is mandatory for apprentices. All data must be synced.'
                                  : 'Enable auto sync to backup data whenever you are online.',
                              value: isApprentice ? true : _autoSync,
                              onChanged: isApprentice
                                  ? null
                                  : (val) => setState(() => _autoSync = val),
                            );
                          },
                        ),
                        _SyncTile(
                          lastSynced: _formatLastSynced(_lastSyncedAt),
                          isSyncing: _isSyncing,
                          onSyncNow: _handleSyncNow,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: JuselSpacing.s12,
                            vertical: JuselSpacing.s12,
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Enable auto sync to backup data whenever you are online.',
                              style: JuselTextStyles.bodySmall(context)
                                  .copyWith(
                                    color: JuselColors.mutedForeground(context),
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: JuselSpacing.s12),
                    _SettingsSection(
                      title: 'DATA MANAGEMENT',
                      children: [
                        _NavigationTile(
                          label: 'Backup & Restore',
                          icon: Icons.backup,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const DataManagementScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: JuselSpacing.s12),
                    _SettingsSection(
                      title: 'INVENTORY',
                      children: [
                        _NavigationTile(
                          icon: Icons.widgets_outlined,
                          label: 'Low Stock Threshold',
                          onTap: () {},
                        ),
                      ],
                    ),
                    const SizedBox(height: JuselSpacing.s20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveSettings,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: JuselSpacing.s12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor: JuselColors.primaryColor(context),
                          foregroundColor: JuselColors.primaryForeground,
                        ),
                        child: const Text(
                          'Save Changes',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
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

class _ShopLogo extends ConsumerWidget {
  const _ShopLogo();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<String?>(
      future: ref.read(settingsServiceProvider.future).then((s) => s.getShopLogoUrl()),
      builder: (context, snapshot) {
        final logoUrl = snapshot.data;
        final hasLogo = logoUrl != null && logoUrl.isNotEmpty;
        
        return Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            color: JuselColors.muted(context),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: hasLogo
              ? ClipOval(
                  child: Image.network(
                    logoUrl,
                    width: 96,
                    height: 96,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _PlaceholderShopLogo(context),
                  ),
                )
              : _PlaceholderShopLogo(context),
        );
      },
    );
  }
}

class _PlaceholderShopLogo extends StatelessWidget {
  final BuildContext context;
  
  const _PlaceholderShopLogo(this.context);

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.store,
      size: 48,
      color: JuselColors.mutedForeground(context),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _SettingsSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(JuselSpacing.s12),
      decoration: BoxDecoration(
        color: JuselColors.background(context),
        borderRadius: BorderRadius.circular(14),
      ),
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
    );
  }
}

class _SettingTile extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle? valueStyle;
  final Widget? trailing;

  const _SettingTile({
    required this.label,
    required this.value,
    this.valueStyle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: JuselSpacing.s12,
        vertical: JuselSpacing.s12,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: JuselTextStyles.bodySmall(context).copyWith(
                    color: JuselColors.mutedForeground(context),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: JuselSpacing.s4),
                Text(
                  value,
                  style:
                      valueStyle ??
                      JuselTextStyles.bodyMedium(context).copyWith(
                        fontWeight: FontWeight.w700,
                        color: JuselColors.foreground(context),
                      ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final String label;
  final String? description;
  final bool value;
  final ValueChanged<bool>? onChanged;
  const _ToggleTile({
    required this.label,
    this.description,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: JuselSpacing.s12,
        vertical: JuselSpacing.s12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: JuselTextStyles.bodyMedium(context).copyWith(
                    fontWeight: FontWeight.w700,
                    color: JuselColors.foreground(context),
                  ),
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
        ],
      ),
    );
  }
}

class _SyncTile extends StatelessWidget {
  final String lastSynced;
  final bool isSyncing;
  final VoidCallback onSyncNow;

  const _SyncTile({
    required this.lastSynced,
    required this.isSyncing,
    required this.onSyncNow,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: JuselSpacing.s12,
        vertical: JuselSpacing.s12,
      ),
      child: Row(
        children: [
          TextButton(
            onPressed: isSyncing ? null : onSyncNow,
            child: isSyncing
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        JuselColors.primaryColor(context),
                      ),
                    ),
                  )
                : Text(
                    'Sync Now',
                    style: TextStyle(
                      color: JuselColors.primaryColor(context),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
          const SizedBox(width: JuselSpacing.s8),
          Expanded(
            child: Text(
              'Last synced: $lastSynced',
              style: JuselTextStyles.bodySmall(context).copyWith(
                color: JuselColors.mutedForeground(context),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Icon(
            Icons.refresh,
            size: 18,
            color: JuselColors.mutedForeground(context),
          ),
        ],
      ),
    );
  }
}

class _NavigationTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _NavigationTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: JuselColors.card(context),
      borderRadius: BorderRadius.circular(0),
      child: InkWell(
        borderRadius: BorderRadius.circular(0),
        onTap: onTap,
        child: Padding(
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
                  color: JuselColors.muted(context),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: JuselColors.foreground(context)),
              ),
              const SizedBox(width: JuselSpacing.s12),
              Expanded(
                child: Text(
                  label,
                  style: JuselTextStyles.bodyMedium(
                    context,
                  ).copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: JuselColors.mutedForeground(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

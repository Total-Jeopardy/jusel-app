import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jusel_app/core/providers/global_providers.dart';
import 'package:jusel_app/core/services/backup_service.dart';
import 'package:jusel_app/core/services/reset_service.dart';
import 'package:jusel_app/core/sync/sync_orchestrator.dart';
import 'package:jusel_app/core/ui/components/success_overlay.dart';
import 'package:jusel_app/core/utils/navigation_helper.dart';
import 'package:jusel_app/core/utils/theme.dart';
import 'package:jusel_app/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:jusel_app/features/products/providers/products_provider.dart';

class DataManagementScreen extends ConsumerStatefulWidget {
  const DataManagementScreen({super.key});

  @override
  ConsumerState<DataManagementScreen> createState() =>
      _DataManagementScreenState();
}

class _DataManagementScreenState extends ConsumerState<DataManagementScreen> {
  bool _isResetting = false;
  bool _isBackingUp = false;
  bool _isRestoring = false;

  Future<void> _handleReset() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset All Data'),
        content: const Text(
          'This will delete all local data including:\n\n'
          '• All products\n'
          '• All sales records\n'
          '• All stock movements\n'
          '• All settings\n'
          '• You will be signed out\n\n'
          'This action cannot be undone!\n\n'
          'Are you sure you want to continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: JuselColors.destructiveColor(context),
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isResetting = true);
    try {
      final resetService = ref.read(resetServiceProvider);
      await resetService.resetAllData();

      if (!mounted) return;

      SuccessOverlay.show(context, message: 'All data has been reset');

      // Navigate to login after a delay
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil('/login', (route) => false);
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to reset data: $e'),
            backgroundColor: JuselColors.destructiveColor(context),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isResetting = false);
      }
    }
  }

  Future<void> _handleBackup() async {
    setState(() => _isBackingUp = true);
    try {
      final backupService = ref.read(backupServiceProvider);
      await backupService.exportBackup();

      if (!mounted) return;

      SuccessOverlay.show(
        context,
        message: 'Backup created and shared successfully',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create backup: $e'),
            backgroundColor: JuselColors.destructiveColor(context),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isBackingUp = false);
      }
    }
  }

  Future<void> _handleRestore() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restore Backup'),
        content: const Text(
          'This will replace all current data with the backup.\n\n'
          'All existing data will be lost!\n\n'
          'Are you sure you want to continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: JuselColors.primaryColor(context)),
            child: const Text('Restore'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isRestoring = true);
    try {
      final backupService = ref.read(backupServiceProvider);
      await backupService.importBackup();

      if (!mounted) return;

      SuccessOverlay.show(context, message: 'Backup restored successfully');

      // Refresh providers to show updated data
      ref.invalidate(productsRefreshTriggerProvider);
      await _runPostRestoreSync();

      // Navigate back after a short delay to allow UI to refresh
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          Navigator.of(context).pop();
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to restore backup: $e'),
            backgroundColor: JuselColors.destructiveColor(context),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isRestoring = false);
      }
    }
  }

  Future<void> _runPostRestoreSync() async {
    final orchestrator = ref.read(syncOrchestratorProvider);
    final user = ref.read(authViewModelProvider).value;
    if (user == null) return;

    // If offline, prompt user to sync later
    if (!await orchestrator.isOnline()) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Restore complete. Sync when back online to upload changes.',
            ),
            backgroundColor: JuselColors.successColor(context),
          ),
        );
      }
      return;
    }

    try {
      final pullResult = await orchestrator.pullAllForUser(user.uid);
      if (!mounted) return;
      final pushResult = await orchestrator.syncAll();
      if (!mounted) return;

      final bothSucceeded =
          pullResult.status != SyncStatus.error &&
          pullResult.status != SyncStatus.offline &&
          pushResult.status != SyncStatus.error &&
          pushResult.status != SyncStatus.offline;

      if (bothSucceeded) {
        final settingsService = await ref.read(settingsServiceProvider.future);
        await settingsService.setLastSyncedAt(DateTime.now());
        if (!mounted) return;

        SuccessOverlay.show(
          context,
          message: 'Cloud sync completed after restore',
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Restore done. Sync issues: pull ${pullResult.status.name}, push ${pushResult.status.name}',
            ),
            backgroundColor: JuselColors.destructiveColor(context),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Restore done, but sync failed: $e'),
            backgroundColor: JuselColors.destructiveColor(context),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: JuselColors.background(context),
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => safePop(context, fallbackRoute: '/boss-dashboard'),
        ),
        title: const Text(
          'Data Management',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(JuselSpacing.s16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _InfoBanner(
                text:
                    'Backup your data regularly to prevent data loss. '
                    'You can restore from a backup at any time.',
              ),
              const SizedBox(height: JuselSpacing.s24),
              _Section(
                title: 'BACKUP',
                children: [
                  _ActionTile(
                    icon: Icons.backup,
                    title: 'Create Backup',
                    description: 'Export all your data to a file',
                    onTap: _isBackingUp ? null : _handleBackup,
                    isLoading: _isBackingUp,
                    color: JuselColors.primaryColor(context),
                  ),
                  const SizedBox(height: JuselSpacing.s12),
                  _ActionTile(
                    icon: Icons.restore,
                    title: 'Restore Backup',
                    description: 'Import data from a backup file',
                    onTap: _isRestoring ? null : _handleRestore,
                    isLoading: _isRestoring,
                    color: JuselColors.successColor(context),
                  ),
                ],
              ),
              const SizedBox(height: JuselSpacing.s24),
              _Section(
                title: 'RESET',
                children: [
                  _ActionTile(
                    icon: Icons.delete_forever,
                    title: 'Reset All Data',
                    description: 'Delete all local data and sign out',
                    onTap: _isResetting ? null : _handleReset,
                    isLoading: _isResetting,
                    color: JuselColors.destructiveColor(context),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  final String text;
  const _InfoBanner({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(JuselSpacing.s12),
      decoration: BoxDecoration(
        color: JuselColors.primaryColor(context).withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 18, color: JuselColors.primaryColor(context)),
          const SizedBox(width: JuselSpacing.s8),
          Expanded(
            child: Text(
              text,
              style: JuselTextStyles.bodySmall(context).copyWith(
                color: JuselColors.foreground(context),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: JuselTextStyles.bodySmall(context).copyWith(
            color: JuselColors.mutedForeground(context),
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: JuselSpacing.s12),
        ...children,
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback? onTap;
  final bool isLoading;
  final Color color;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
    required this.isLoading,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: JuselColors.border(context)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(JuselSpacing.s16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
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
                      ),
                    ),
                    const SizedBox(height: JuselSpacing.s4),
                    Text(
                      description,
                      style: JuselTextStyles.bodySmall(context).copyWith(
                        color: JuselColors.mutedForeground(context),
                      ),
                    ),
                  ],
                ),
              ),
              if (isLoading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                Icon(Icons.chevron_right, color: JuselColors.mutedForeground(context)),
            ],
          ),
        ),
      ),
    );
  }
}

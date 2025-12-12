import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:jusel_app/core/providers/global_providers.dart';
import 'package:jusel_app/core/sync/sync_orchestrator.dart';
import 'package:jusel_app/core/ui/components/success_overlay.dart';
import 'package:jusel_app/core/utils/navigation_helper.dart';
import 'package:jusel_app/core/utils/theme.dart';
import 'package:jusel_app/features/account/view/pending_items_screen.dart';
import 'package:jusel_app/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:jusel_app/features/products/providers/products_provider.dart';

// Stable providers for sync status
final _syncStatusSummaryProvider =
    FutureProvider.autoDispose<SyncStatusSummary>((ref) async {
      final orchestrator = ref.read(syncOrchestratorProvider);
      return orchestrator.getStatusSummary();
    });

final _lastSyncedAtProvider = FutureProvider.autoDispose<DateTime?>((
  ref,
) async {
  final settingsService = await ref.read(settingsServiceProvider.future);
  return settingsService.getLastSyncedAt();
});

class SyncStatusScreen extends ConsumerStatefulWidget {
  const SyncStatusScreen({super.key});

  @override
  ConsumerState<SyncStatusScreen> createState() => _SyncStatusScreenState();
}

class _SyncStatusScreenState extends ConsumerState<SyncStatusScreen> {
  bool _isSyncing = false;

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
        await settingsService.setLastSyncedAt(DateTime.now());
        if (!mounted) return;
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

      // Refresh the screen data
      ref.invalidate(_syncStatusSummaryProvider);
      ref.invalidate(_lastSyncedAtProvider);

      // Trigger refresh of products and other data screens
      if (pullResult.syncedCount > 0) {
        ref.invalidate(productsRefreshTriggerProvider);
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
          'Sync Status',
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
                  20,
                  horizontalPadding,
                  28,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: JuselSpacing.s12),
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: JuselColors.successColor(context).withOpacity(
                          0.15,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.cloud_done_rounded,
                        color: JuselColors.successColor(context),
                        size: 44,
                      ),
                    ),
                    const SizedBox(height: JuselSpacing.s12),
                    Consumer(
                      builder: (context, ref, _) {
                        final statusSummaryAsync = ref.watch(
                          _syncStatusSummaryProvider,
                        );

                        return statusSummaryAsync.when(
                          loading: () => Column(
                            children: [
                              Text(
                                'Checking Sync Status',
                                style: JuselTextStyles.headlineLarge(
                                  context,
                                ).copyWith(fontWeight: FontWeight.w800),
                              ),
                              const SizedBox(height: JuselSpacing.s4),
                              Text(
                                'Please wait...',
                                textAlign: TextAlign.center,
                                style: JuselTextStyles.bodySmall(context)
                                    .copyWith(
                                      color: JuselColors.mutedForeground(
                                        context,
                                      ),
                                      fontWeight: FontWeight.w400,
                                      fontSize: 18,
                                    ),
                              ),
                            ],
                          ),
                          error: (_, __) => Column(
                            children: [
                              Text(
                                'Sync Error',
                                style: JuselTextStyles.headlineLarge(
                                  context,
                                ).copyWith(fontWeight: FontWeight.w800),
                              ),
                              const SizedBox(height: JuselSpacing.s4),
                              Text(
                                'Unable to check sync status.',
                                textAlign: TextAlign.center,
                                style: JuselTextStyles.bodySmall(context)
                                    .copyWith(
                                      color: JuselColors.mutedForeground(
                                        context,
                                      ),
                                      fontWeight: FontWeight.w400,
                                      fontSize: 18,
                                    ),
                              ),
                            ],
                          ),
                          data: (summary) {
                            final isAllSynced =
                                summary.totalPending == 0 &&
                                summary.failedCount == 0;
                            return Column(
                              children: [
                                Text(
                                  isAllSynced ? 'All Synced' : 'Sync Pending',
                                  style: JuselTextStyles.headlineLarge(
                                    context,
                                  ).copyWith(fontWeight: FontWeight.w800),
                                ),
                                const SizedBox(height: JuselSpacing.s4),
                                Text(
                                  isAllSynced
                                      ? 'Your data is safely backed up to the cloud.'
                                      : '${summary.totalPending} items pending sync.',
                                  textAlign: TextAlign.center,
                                  style: JuselTextStyles.bodySmall(context)
                                      .copyWith(
                                        color: JuselColors.mutedForeground(
                                          context,
                                        ),
                                        fontWeight: FontWeight.w400,
                                        fontSize: 18,
                                      ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: JuselSpacing.s40),
                    _StatusCard(),
                    const SizedBox(height: JuselSpacing.s16),
                    _InfoBanner(),
                    const SizedBox(height: JuselSpacing.s20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSyncing ? null : _handleSyncNow,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: JuselSpacing.s16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          backgroundColor: JuselColors.primaryColor(context),
                          foregroundColor: JuselColors.primaryForeground,
                        ),
                        child: _isSyncing
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    JuselColors.primaryForeground,
                                  ),
                                ),
                              )
                            : const Text(
                                'Sync Now',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 18,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: JuselSpacing.s12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const PendingItemsScreen(),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: JuselSpacing.s16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          side: BorderSide(color: JuselColors.border(context)),
                          backgroundColor: JuselColors.card(context),
                        ),
                        child: Text(
                          'View Pending Items',
                          style: TextStyle(
                            color: JuselColors.primaryColor(context),
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
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

class _StatusCard extends ConsumerWidget {
  const _StatusCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusSummaryAsync = ref.watch(_syncStatusSummaryProvider);
    final lastSyncedAsync = ref.watch(_lastSyncedAtProvider);
    final connectivityAsync = ref.watch(connectivityProvider);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: JuselColors.card(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: JuselColors.border(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          lastSyncedAsync.when(
            loading: () => const _StatusRow(
              label: 'Last Successful Sync',
              value: 'Loading...',
            ),
            error: (_, __) =>
                const _StatusRow(label: 'Last Successful Sync', value: 'Never'),
            data: (lastSynced) {
              final formatted = _formatLastSynced(lastSynced);
              return _StatusRow(
                label: 'Last Successful Sync',
                value: formatted,
              );
            },
          ),
          Divider(height: 1, color: JuselColors.border(context)),
          statusSummaryAsync.when(
            loading: () => const _StatusRow(
              label: 'Pending Operations',
              value: 'Loading...',
            ),
            error: (_, __) =>
                const _StatusRow(label: 'Pending Operations', value: '0 items'),
            data: (summary) => _StatusRow(
              label: 'Pending Operations',
              value: '${summary.totalPending} items',
            ),
          ),
          Divider(height: 1, color: JuselColors.border(context)),
          connectivityAsync.when(
            loading: () => const _StatusRow(
              label: 'Connection Status',
              value: 'Checking...',
            ),
            error: (_, __) => _StatusRow(
              label: 'Connection Status',
              value: 'Offline',
              valueColor: JuselColors.destructiveColor(context),
              showDot: true,
            ),
            data: (isOnline) => _StatusRow(
              label: 'Connection Status',
              value: isOnline ? 'Online' : 'Offline',
              valueColor: isOnline
                  ? JuselColors.successColor(context)
                  : JuselColors.destructiveColor(context),
              showDot: true,
            ),
          ),
        ],
      ),
    );
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
}

class _StatusRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool showDot;

  const _StatusRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.showDot = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: JuselSpacing.s12,
        vertical: JuselSpacing.s20,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: JuselTextStyles.bodyMedium(context).copyWith(
                fontWeight: FontWeight.w600,
                color: JuselColors.foreground(context),
                fontSize: 16,
              ),
            ),
          ),
          if (showDot) ...[
            Icon(Icons.circle, size: 10, color: JuselColors.successColor(
              context,
            )),
            const SizedBox(width: JuselSpacing.s6),
          ],
          Text(
            value,
            style: JuselTextStyles.bodySmall(context).copyWith(
              color: valueColor ?? JuselColors.mutedForeground(context),
              fontWeight: FontWeight.w400,
              fontSize: 17,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(JuselSpacing.s16),
      decoration: BoxDecoration(
        color: JuselColors.muted(context),
        borderRadius: BorderRadius.circular(14),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: JuselColors.card(context),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.wifi_off_outlined,
                color: JuselColors.mutedForeground(context),
              ),
            ),
            const SizedBox(width: JuselSpacing.s12),
            Expanded(
              child: Text(
                'Jusel is designed to work offline. Changes made without internet are saved locally and automatically synced when connection is restored.',
                style: JuselTextStyles.bodySmall(context).copyWith(
                  color: JuselColors.mutedForeground(context),
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

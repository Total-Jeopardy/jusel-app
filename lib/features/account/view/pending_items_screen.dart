import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:jusel_app/core/database/app_database.dart';
import 'package:jusel_app/core/providers/database_provider.dart';
import 'package:jusel_app/core/providers/global_providers.dart';
import 'package:jusel_app/core/sync/sync_orchestrator.dart';
import 'package:jusel_app/core/ui/components/success_overlay.dart';
import 'package:jusel_app/core/utils/theme.dart';
import 'package:jusel_app/core/utils/navigation_helper.dart';

final _pendingOpsProvider =
    FutureProvider.autoDispose<List<PendingSyncQueueTableData>>((ref) async {
      final dao = ref.read(pendingSyncQueueDaoProvider);
      return dao.getAllPendingOperations();
    });

class PendingItemsScreen extends ConsumerStatefulWidget {
  const PendingItemsScreen({super.key});

  @override
  ConsumerState<PendingItemsScreen> createState() => _PendingItemsScreenState();
}

class _PendingItemsScreenState extends ConsumerState<PendingItemsScreen> {
  bool _syncing = false;

  @override
  Widget build(BuildContext context) {
    final pendingAsync = ref.watch(_pendingOpsProvider);

    return Scaffold(
      backgroundColor: JuselColors.background(context),
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => safePop(context, fallbackRoute: '/boss-dashboard'),
        ),
        title: const Text(
          'Pending Items',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Consumer(
              builder: (context, ref, _) {
                final connectivityAsync = ref.watch(connectivityProvider);
                return connectivityAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => Container(
                    width: double.infinity,
                    color: JuselColors.warningColor(context).withOpacity(0.12),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            right: JuselSpacing.s8,
                          ),
                          child: Icon(
                            Icons.circle,
                            size: 10,
                            color: JuselColors.warningColor(context),
                          ),
                        ),
                        Text(
                          'Offline Mode',
                          style: JuselTextStyles.bodySmall(context).copyWith(
                            fontWeight: FontWeight.w700,
                            color: JuselColors.warningColor(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  data: (isOnline) {
                    if (isOnline) return const SizedBox.shrink();
                    return Container(
                      width: double.infinity,
                      color: JuselColors.warningColor(
                        context,
                      ).withOpacity(0.12),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              right: JuselSpacing.s8,
                            ),
                            child: Icon(
                              Icons.circle,
                              size: 10,
                              color: JuselColors.warningColor(context),
                            ),
                          ),
                          Text(
                            'Offline Mode',
                            style: JuselTextStyles.bodySmall(context).copyWith(
                              fontWeight: FontWeight.w700,
                              color: JuselColors.warningColor(context),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
            Expanded(
              child: pendingAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(JuselSpacing.s16),
                    child: Text(
                      'Failed to load pending items: $e',
                      style: JuselTextStyles.bodyMedium(context).copyWith(
                        color: JuselColors.destructiveColor(context),
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                data: (items) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _InfoBanner(
                          text:
                              'These operations are saved locally. Jusel will automatically attempt to sync them once an internet connection is detected.',
                        ),
                        const SizedBox(height: JuselSpacing.s16),
                        Text(
                          'WAITING TO SYNC (${items.length})',
                          style: JuselTextStyles.bodySmall(context).copyWith(
                            color: JuselColors.mutedForeground(context),
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: JuselSpacing.s12),
                        if (items.isEmpty)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(JuselSpacing.s12),
                            decoration: BoxDecoration(
                              color: JuselColors.card(context),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: JuselColors.border(context),
                              ),
                            ),
                            child: Text(
                              'No pending operations.',
                              style: JuselTextStyles.bodyMedium(context)
                                  .copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: JuselColors.mutedForeground(context),
                                  ),
                            ),
                          )
                        else
                          ...items
                              .map(
                                (item) => Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: JuselSpacing.s12,
                                  ),
                                  child: _PendingCard(item: item),
                                ),
                              )
                              .toList(),
                      ],
                    ),
                  );
                },
              ),
            ),
            SafeArea(
              top: false,
              minimum: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _syncing ? null : _handleSyncAll,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: JuselSpacing.s16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: JuselColors.primaryColor(context),
                    foregroundColor: JuselColors.primaryForeground,
                  ),
                  icon: _syncing
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(
                              JuselColors.primaryForeground,
                            ),
                          ),
                        )
                      : const Icon(Icons.sync),
                  label: Text(
                    _syncing ? 'Syncing...' : 'Sync All Now',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSyncAll() async {
    setState(() => _syncing = true);
    try {
      final orchestrator = ref.read(syncOrchestratorProvider);

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

      final result = await orchestrator.syncAll();
      if (!mounted) return;

      if (result.status == SyncStatus.allSynced) {
        if (mounted) {
          SuccessOverlay.show(
            context,
            message: 'All items synced successfully!',
          );
        }
      } else if (result.status == SyncStatus.offline) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Device is offline. Try again later.'),
            backgroundColor: JuselColors.destructiveColor(context),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Synced: ${result.syncedCount}, Failed: ${result.failedCount}',
            ),
            backgroundColor: JuselColors.destructiveColor(context),
          ),
        );
      }

      // Refresh the pending items list
      ref.invalidate(_pendingOpsProvider);
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
      if (mounted) setState(() => _syncing = false);
    }
  }
}

class _PendingCard extends StatelessWidget {
  final PendingSyncQueueTableData item;
  const _PendingCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final statusLabel = item.status.toUpperCase();
    final isRetrying = item.status == 'retrying';
    final statusColor = isRetrying
        ? JuselColors.warningColor(context)
        : JuselColors.mutedForeground(context);
    final statusBg = isRetrying
        ? JuselColors.warningColor(context).withOpacity(0.12)
        : JuselColors.muted(context);

    final subtitle =
        '${DateFormat('MMM d, h:mm a').format(item.createdAt)} · ${item.operationType}';
    final payloadPreview = _previewPayload(item.payload);

    return Container(
      decoration: BoxDecoration(
        color: JuselColors.card(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: JuselColors.border(context)),
      ),
      padding: const EdgeInsets.all(JuselSpacing.s12),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: JuselColors.primaryColor(context).withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.sync_alt,
              color: JuselColors.primaryColor(context),
            ),
          ),
          const SizedBox(width: JuselSpacing.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.operationType,
                  style: JuselTextStyles.bodyMedium(
                    context,
                  ).copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: JuselSpacing.s4),
                Text(
                  subtitle,
                  style: JuselTextStyles.bodySmall(context).copyWith(
                    color: JuselColors.mutedForeground(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (payloadPreview != null) ...[
                  const SizedBox(height: JuselSpacing.s4),
                  Text(
                    payloadPreview,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: JuselTextStyles.bodySmall(
                      context,
                    ).copyWith(color: JuselColors.mutedForeground(context)),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: JuselSpacing.s8),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: JuselSpacing.s12,
              vertical: JuselSpacing.s6,
            ),
            decoration: BoxDecoration(
              color: statusBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              statusLabel,
              style: JuselTextStyles.bodySmall(
                context,
              ).copyWith(color: statusColor, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }

  String? _previewPayload(String payload) {
    try {
      final decoded = jsonDecode(payload) as Map<String, dynamic>;

      // Format based on operation type
      if (decoded.containsKey('name')) {
        return 'Product: ${decoded['name']}';
      } else if (decoded.containsKey('quantity') &&
          decoded.containsKey('productId')) {
        final qty = decoded['quantity'];
        if (decoded.containsKey('unitSellingPrice')) {
          // Sale
          final price = decoded['unitSellingPrice'];
          return 'Qty: $qty @ GHS ${(price as num).toStringAsFixed(2)}';
        } else if (decoded.containsKey('costPerUnit')) {
          // Restock
          final cost = decoded['costPerUnit'];
          return 'Qty: $qty @ GHS ${(cost as num).toStringAsFixed(2)}/unit';
        }
      }

      // Fallback: show product ID if available
      if (decoded.containsKey('productId')) {
        return 'Product ID: ${decoded['productId']}';
      }

      return null; // Don't show preview if we can't format it nicely
    } catch (_) {
      return null;
    }
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
        color: JuselColors.primaryColor(context).withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            size: 18,
            color: JuselColors.primaryColor(context),
          ),
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

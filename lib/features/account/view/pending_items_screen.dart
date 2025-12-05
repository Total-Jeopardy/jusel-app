import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:jusel_app/core/database/app_database.dart';
import 'package:jusel_app/core/providers/database_provider.dart';
import 'package:jusel_app/core/providers/global_providers.dart';
import 'package:jusel_app/core/sync/sync_orchestrator.dart';
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
      backgroundColor: JuselColors.background,
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
            Container(
              width: double.infinity,
              color: const Color(0xFFFFF4CE),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(right: JuselSpacing.s8),
                    child: Icon(
                      Icons.circle,
                      size: 10,
                      color: Color(0xFFDAA200),
                    ),
                  ),
                  Text(
                    'Offline Mode',
                    style: JuselTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFDAA200),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: pendingAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(JuselSpacing.s16),
                    child: Text(
                      'Failed to load pending items: $e',
                      style: JuselTextStyles.bodyMedium.copyWith(
                        color: JuselColors.destructive,
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
                          style: JuselTextStyles.bodySmall.copyWith(
                            color: JuselColors.mutedForeground,
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
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: JuselColors.border),
                            ),
                            child: Text(
                              'No pending operations.',
                              style: JuselTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w700,
                                color: JuselColors.mutedForeground,
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
                    backgroundColor: JuselColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  icon: _syncing
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : const Icon(Icons.sync),
                  label: Text(
                    _syncing ? 'Syncing...' : 'Sync All Now',
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 16),
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
      final result = await orchestrator.syncAll();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.status == SyncStatus.allSynced
                ? 'All items synced.'
                : result.status == SyncStatus.offline
                    ? 'Device is offline. Try again later.'
                    : 'Synced: ${result.syncedCount}, Failed: ${result.failedCount}',
          ),
          backgroundColor: result.status == SyncStatus.allSynced
              ? JuselColors.success
              : JuselColors.destructive,
        ),
      );
      ref.invalidate(_pendingOpsProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sync failed: $e'),
            backgroundColor: JuselColors.destructive,
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
    final statusColor =
        isRetrying ? const Color(0xFFF97316) : JuselColors.mutedForeground;
    final statusBg =
        isRetrying ? const Color(0xFFFFF4E7) : const Color(0xFFF1F5F9);

    final subtitle =
        '${DateFormat('MMM d, h:mm a').format(item.createdAt)} · ${item.operationType}';
    final payloadPreview = _previewPayload(item.payload);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: JuselColors.border),
      ),
      padding: const EdgeInsets.all(JuselSpacing.s12),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFE9F0FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.sync_alt, color: JuselColors.primary),
          ),
          const SizedBox(width: JuselSpacing.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.operationType,
                  style: JuselTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: JuselSpacing.s4),
                Text(
                  subtitle,
                  style: JuselTextStyles.bodySmall.copyWith(
                    color: JuselColors.mutedForeground,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (payloadPreview != null) ...[
                  const SizedBox(height: JuselSpacing.s4),
                  Text(
                    payloadPreview,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: JuselTextStyles.bodySmall.copyWith(
                      color: JuselColors.mutedForeground,
                    ),
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
              style: JuselTextStyles.bodySmall.copyWith(
                color: statusColor,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String? _previewPayload(String payload) {
    try {
      final decoded = jsonDecode(payload);
      if (decoded is Map && decoded.containsKey('productName')) {
        return 'Product: ${decoded['productName']}';
      }
      return payload.length > 80 ? '${payload.substring(0, 80)}...' : payload;
    } catch (_) {
      return payload.length > 80 ? '${payload.substring(0, 80)}...' : payload;
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
        color: const Color(0xFFE9F0FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, size: 18, color: JuselColors.primary),
          const SizedBox(width: JuselSpacing.s8),
          Expanded(
            child: Text(
              text,
              style: JuselTextStyles.bodySmall.copyWith(
                color: JuselColors.foreground,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

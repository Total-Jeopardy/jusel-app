import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:jusel_app/core/database/app_database.dart';
import 'package:jusel_app/core/providers/database_provider.dart';
import 'package:jusel_app/core/utils/theme.dart';
import 'package:jusel_app/features/stock/view/stock_history_screen.dart';

final batchDetailProvider = FutureProvider.autoDispose
    .family<_BatchDetailData, int>((ref, batchId) async {
      final db = ref.read(appDatabaseProvider);

      final batch = await db.productionBatchesDao.getBatch(batchId);
      if (batch == null) {
        throw Exception('Batch not found');
      }

      final product = await db.productsDao.getProduct(batch.productId);
      if (product == null) {
        throw Exception('Product not found');
      }

      final movement =
          await (db.select(db.stockMovementsTable)
                ..where((tbl) => tbl.batchId.equals(batchId.toString()))
                ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)])
                ..limit(1))
              .getSingleOrNull();

      return _BatchDetailData(
        batch: batch,
        product: product,
        movement: movement,
      );
    });

class BatchDetailScreen extends ConsumerWidget {
  final int batchId;

  const BatchDetailScreen({super.key, required this.batchId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(batchDetailProvider(batchId));

    return Scaffold(
      backgroundColor: JuselColors.background(context),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: JuselColors.background(context),
        shape: Border(bottom: BorderSide(color: JuselColors.border(context))),
        leadingWidth: 64,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Container(
            decoration: BoxDecoration(
              color: JuselColors.muted(context),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),
        title: const Text(
          'Batch Detail',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: detail.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => _ErrorState(message: e.toString()),
          data: (data) {
            final batch = data.batch;
            final product = data.product;
            final movement = data.movement;

            final dateString = DateFormat(
              'MMM d, yyyy · h:mm a',
            ).format(batch.createdAt.toLocal());

            final costBreakdown = _buildCostBreakdown(batch);
            final badgeLabel = product.category.isNotEmpty
                ? product.category
                : 'Batch';

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Batch #${batch.id}',
                          style: JuselTextStyles.headlineMedium(context).copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: JuselColors.primaryColor(context).withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          badgeLabel.toUpperCase(),
                          style: JuselTextStyles.bodySmall(context).copyWith(
                            color: JuselColors.primaryColor(context),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: JuselSpacing.s8),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: JuselColors.mutedForeground(context),
                      ),
                      const SizedBox(width: JuselSpacing.s6),
                      Text(
                        dateString,
                        style: JuselTextStyles.bodySmall(context).copyWith(
                          color: JuselColors.mutedForeground(context),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: JuselSpacing.s8),
                  Row(
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 16,
                        color: JuselColors.mutedForeground(context),
                      ),
                      const SizedBox(width: JuselSpacing.s6),
                      Flexible(
                        child: Text(
                          product.name,
                          style: JuselTextStyles.bodySmall(context).copyWith(
                            color: JuselColors.foreground(context),
                            fontWeight: FontWeight.w700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: JuselSpacing.s16),
                  _StatGrid(
                    items: [
                      _StatItem(
                        label: 'Produced',
                        value: '${batch.quantityProduced} units',
                        valueColor: JuselColors.primaryColor(context),
                      ),
                      _StatItem(
                        label: 'Stock Add',
                        value: '+${batch.quantityProduced}',
                        valueColor: JuselColors.successColor(context),
                      ),
                      _StatItem(
                        label: 'Total Cost',
                        value: 'GHS ${batch.totalCost.toStringAsFixed(2)}',
                        bold: true,
                      ),
                      _StatItem(
                        label: 'Unit Cost',
                        value: 'GHS ${batch.unitCost.toStringAsFixed(2)}',
                        helper: 'Snapshot',
                        helperColor: JuselColors.mutedForeground(context),
                        showArrow: false,
                      ),
                    ],
                  ),
                  const SizedBox(height: JuselSpacing.s16),
                  Text(
                    'COST BREAKDOWN',
                    style: JuselTextStyles.bodySmall(context).copyWith(
                      color: JuselColors.mutedForeground(context),
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
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
                      children: [
                        ...costBreakdown.entries.map(
                          (entry) => Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: JuselSpacing.s16,
                                  vertical: JuselSpacing.s12,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      entry.key,
                                      style: JuselTextStyles.bodyMedium(context)
                                          .copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                    Text(
                                      'GHS ${entry.value.toStringAsFixed(2)}',
                                      style: JuselTextStyles.bodyMedium(context)
                                          .copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              if (entry.key != costBreakdown.keys.last)
                                Divider(
                                  height: 1,
                                  color: JuselColors.border(context),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: JuselSpacing.s16),
                  Text(
                    'NOTES',
                    style: JuselTextStyles.bodySmall(context).copyWith(
                      color: JuselColors.mutedForeground(context),
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: JuselSpacing.s8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(JuselSpacing.s12),
                    decoration: BoxDecoration(
                      color: JuselColors.card(context),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: JuselColors.border(context)),
                    ),
                    child: Text(
                      (batch.notes ?? '').isEmpty
                          ? 'No notes added.'
                          : batch.notes!,
                      style: JuselTextStyles.bodyMedium(context).copyWith(
                        color: JuselColors.foreground(context),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: JuselSpacing.s16),
                  Text(
                    'RELATED MOVEMENT',
                    style: JuselTextStyles.bodySmall(context).copyWith(
                      color: JuselColors.mutedForeground(context),
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: JuselSpacing.s8),
                  if (movement == null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(JuselSpacing.s12),
                      decoration: BoxDecoration(
                        color: JuselColors.card(context),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: JuselColors.border(context)),
                      ),
                      child: Text(
                        'No related movement found.',
                        style: JuselTextStyles.bodyMedium(context).copyWith(
                          color: JuselColors.mutedForeground(context),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    )
                  else
                    Material(
                      color: JuselColors.card(context),
                      borderRadius: BorderRadius.circular(14),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => StockHistoryScreen(
                                productId: product.id,
                                productName: product.name,
                                currentStock: product.currentStockQty,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: JuselColors.border(context)),
                          ),
                          padding: const EdgeInsets.all(JuselSpacing.s12),
                          child: Row(
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: JuselColors.primaryColor(context).withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.swap_horiz,
                                  color: JuselColors.primaryColor(context),
                                ),
                              ),
                              const SizedBox(width: JuselSpacing.s12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Movement ${movement.id}',
                                      style: JuselTextStyles.bodyMedium(context)
                                          .copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                    const SizedBox(height: JuselSpacing.s4),
                                    Text(
                                      'Stock Update · ${movement.quantityUnits > 0 ? '+' : ''}${movement.quantityUnits} units',
                                      style: JuselTextStyles.bodySmall(context).copyWith(
                                        color: JuselColors.mutedForeground(context),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
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
                    ),
                  const SizedBox(height: JuselSpacing.s20),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  const _ErrorState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(JuselSpacing.s16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: JuselColors.destructiveColor(context)),
            const SizedBox(height: JuselSpacing.s8),
            Text(
              'Failed to load batch',
              style: JuselTextStyles.bodyMedium(context).copyWith(
                fontWeight: FontWeight.w700,
                color: JuselColors.destructiveColor(context),
              ),
            ),
            const SizedBox(height: JuselSpacing.s6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: JuselTextStyles.bodySmall(context).copyWith(
                color: JuselColors.mutedForeground(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Map<String, double> _buildCostBreakdown(ProductionBatchesTableData batch) {
  double safe(double? v) => v ?? 0.0;
  return {
    'Ingredients': safe(batch.ingredientsCost),
    'Gas': safe(batch.gasCost),
    'Oil': safe(batch.oilCost),
    'Labor': safe(batch.laborCost),
    'Transport': safe(batch.transportCost),
    'Packaging': safe(batch.packagingCost),
    'Other': safe(batch.otherCost),
  };
}

class _BatchDetailData {
  final ProductionBatchesTableData batch;
  final ProductsTableData product;
  final StockMovementsTableData? movement;

  const _BatchDetailData({
    required this.batch,
    required this.product,
    required this.movement,
  });
}

class _StatGrid extends StatelessWidget {
  final List<_StatItem> items;
  const _StatGrid({required this.items});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: JuselSpacing.s12,
      runSpacing: JuselSpacing.s12,
      children: items
          .map(
            (item) => SizedBox(
              width:
                  (MediaQuery.of(context).size.width -
                      16 * 2 -
                      JuselSpacing.s12) /
                  2,
              child: _StatCard(item: item),
            ),
          )
          .toList(),
    );
  }
}

class _StatItem {
  final String label;
  final String value;
  final String? helper;
  final Color? valueColor;
  final Color? helperColor;
  final bool bold;
  final bool showArrow;

  const _StatItem({
    required this.label,
    required this.value,
    this.helper,
    this.valueColor,
    this.helperColor,
    this.bold = false,
    this.showArrow = false,
  });
}

class _StatCard extends StatelessWidget {
  final _StatItem item;
  const _StatCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(JuselSpacing.s12),
      decoration: BoxDecoration(
        color: JuselColors.card(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: JuselColors.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.label,
            style: JuselTextStyles.bodySmall(context).copyWith(
              color: JuselColors.mutedForeground(context),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: JuselSpacing.s6),
          Text(
            item.value,
            style: JuselTextStyles.bodyMedium(context).copyWith(
              fontWeight: item.bold ? FontWeight.w800 : FontWeight.w700,
              color: item.valueColor ?? JuselColors.foreground(context),
            ),
          ),
          if (item.helper != null) ...[
            const SizedBox(height: JuselSpacing.s6),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (item.showArrow)
                  Icon(
                    Icons.arrow_downward,
                    size: 14,
                    color: item.helperColor ?? JuselColors.successColor(context),
                  ),
                if (item.showArrow) const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: JuselSpacing.s8,
                    vertical: JuselSpacing.s4,
                  ),
                  decoration: BoxDecoration(
                    color: JuselColors.successColor(context).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    item.helper!,
                    style: JuselTextStyles.bodySmall(context).copyWith(
                      color: item.helperColor ?? JuselColors.successColor(context),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

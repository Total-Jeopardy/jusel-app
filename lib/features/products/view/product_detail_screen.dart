import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:jusel_app/core/database/app_database.dart';
import 'package:jusel_app/core/providers/database_provider.dart';
import 'package:jusel_app/core/providers/global_providers.dart';
import 'package:jusel_app/core/utils/theme.dart';
import 'package:jusel_app/features/dashboard/providers/dashboard_tab_provider.dart';
import 'package:jusel_app/features/stock/view/restock_screen.dart';

final productDetailProvider = FutureProvider.autoDispose
    .family<_ProductDetailData, String>((ref, productId) async {
      final db = ref.read(appDatabaseProvider);
      final inventory = ref.read(inventoryServiceProvider);

      final product = await db.productsDao.getProduct(productId);
      if (product == null) {
        throw Exception('Product not found');
      }

      final stock = await inventory.getCurrentStock(productId);
      final movements = await db.stockMovementsDao.getMovementsForProduct(
        productId,
      );

      return _ProductDetailData(
        product: product,
        stock: stock,
        movements: movements,
      );
    });

class ProductDetailScreen extends ConsumerWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(productDetailProvider(productId));

    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        if (!didPop && Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: JuselColors.background(context),
        appBar: AppBar(
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              } else {
                ref.read(dashboardTabProvider.notifier).goToDashboard();
              }
            },
          ),
          title: const Text(
            'Product Detail',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      body: detail.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(JuselSpacing.s16),
            child: Text(
              'Failed to load product: $e',
              style: JuselTextStyles.bodyMedium(context).copyWith(
                color: JuselColors.destructiveColor(context),
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (data) {
          final product = data.product;
          final stock = data.stock;
          final sellingPrice = product.currentSellingPrice;
          final costPrice = product.currentCostPrice;
          final margin = sellingPrice == 0
              ? 0
              : costPrice == 0
              ? 100
              : ((sellingPrice - costPrice!) / sellingPrice) * 100;

          final lastMovement = data.movements.isNotEmpty
              ? data.movements.first
              : null;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HeaderCard(product: product, stock: stock),
                const SizedBox(height: JuselSpacing.s12),
                _InfoCard(
                  children: [
                    _InfoRow(
                      label: 'Selling Price',
                      value: 'GHS ${sellingPrice.toStringAsFixed(2)}',
                      valueColor: JuselColors.primaryColor(context),
                      bold: true,
                      dense: true,
                    ),
                    _DividerRow(),
                    _InfoRow(
                      label: 'Cost Price',
                      value: costPrice == null
                          ? '--'
                          : 'GHS ${costPrice.toStringAsFixed(2)}',
                      helper: 'Margin: ${margin.toStringAsFixed(0)}%',
                      valueBold: true,
                      helperUnderValue: true,
                      dense: true,
                    ),
                    _DividerRow(),
                    _InfoRow(
                      label: 'Units per Pack',
                      value: product.unitsPerPack?.toString() ?? '--',
                      valueBold: true,
                      helperUnderValue: true,
                      dense: true,
                    ),
                  ],
                ),
                const SizedBox(height: JuselSpacing.s12),
                _InfoCard(
                  children: [
                    const _SectionTitle('Stock & Activity'),
                    _DividerRow(),
                    _InfoRow(
                      label: 'Current Stock',
                      value: '$stock units',
                      valueColor: stock <= 0
                          ? JuselColors.destructiveColor(context)
                          : JuselColors.foreground(context),
                      bold: true,
                    ),
                    _DividerRow(),
                    _InfoRow(
                      label: 'Status',
                      value: product.status,
                      valueColor: _statusColor(context, product.status),
                      showDot: true,
                      dense: true,
                    ),
                    _DividerRow(),
                    _InfoRow(
                      label: 'Last Movement',
                      value: lastMovement == null
                          ? 'No movements yet'
                          : '${DateFormat('MMM d, yyyy').format(lastMovement.createdAt)}',
                      dense: true,
                    ),
                  ],
                ),
                const SizedBox(height: JuselSpacing.s12),
                _InfoCard(
                  children: [
                    const _SectionTitle('Recent Movements'),
                    const SizedBox(height: JuselSpacing.s8),
                    if (data.movements.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: JuselSpacing.s8,
                        ),
                        child: Text(
                          'No movements recorded yet.',
                          style: JuselTextStyles.bodySmall(context).copyWith(
                            color: JuselColors.mutedForeground(context),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      )
                    else
                      ...data.movements.take(5).map((m) {
                        final sign = m.quantityUnits > 0 ? '+' : '';
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: JuselSpacing.s8,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    m.type,
                                    style: JuselTextStyles.bodyMedium(context).copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    DateFormat(
                                      'MMM d, h:mm a',
                                    ).format(m.createdAt),
                                    style: JuselTextStyles.bodySmall(context).copyWith(
                                      color: JuselColors.mutedForeground(context),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                '$sign${m.quantityUnits}',
                                style: JuselTextStyles.bodyMedium(context).copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: m.quantityUnits >= 0
                                      ? JuselColors.successColor(context)
                                      : JuselColors.destructiveColor(context),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                  ],
                ),
                const SizedBox(height: JuselSpacing.s12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => RestockScreen(
                            productId: product.id,
                            productName: product.name,
                            category: product.category,
                            currentStock: stock,
                          ),
                        ),
                      );
                    },
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_circle_outline, color: JuselColors.primaryForeground),
                        SizedBox(width: JuselSpacing.s8),
                        Text(
                          'Restock Product',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: JuselSpacing.s12),
                Column(
                  children: [
                    _NavTile(label: 'Edit Product', onTap: () {}),
                    const SizedBox(height: JuselSpacing.s12),
                    _NavTile(label: 'View Stock Movements', onTap: () {}),
                  ],
                ),
                const SizedBox(height: JuselSpacing.s12),
              ],
            ),
          );
        },
      ),
      ),
    );
  }
}

Color _statusColor(BuildContext context, String status) {
  final s = status.toLowerCase();
  if (s.contains('out')) return JuselColors.destructiveColor(context);
  if (s.contains('low')) return JuselColors.warningColor(context);
  if (s.contains('inactive')) return JuselColors.mutedForeground(context);
  return JuselColors.successColor(context);
}

class _ProductDetailData {
  final ProductsTableData product;
  final int stock;
  final List<StockMovementsTableData> movements;

  const _ProductDetailData({
    required this.product,
    required this.stock,
    required this.movements,
  });
}

class _HeaderCard extends StatelessWidget {
  final ProductsTableData product;
  final int stock;
  const _HeaderCard({required this.product, required this.stock});

  String _statusLabel() {
    if (stock <= 0) return 'Out of Stock';
    if (stock <= 10) return 'Low Stock ($stock)';
    return 'In Stock';
  }

  Color _statusColor(BuildContext context) {
    if (stock <= 0) return JuselColors.destructiveColor(context);
    if (stock <= 10) return JuselColors.warningColor(context);
    return JuselColors.successColor(context);
  }

  Color _statusBg(BuildContext context) {
    if (stock <= 0) return JuselColors.destructiveColor(context).withOpacity(0.12);
    if (stock <= 10) return JuselColors.warningColor(context).withOpacity(0.12);
    return JuselColors.successColor(context).withOpacity(0.12);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(JuselSpacing.s12),
      decoration: BoxDecoration(
        color: JuselColors.card(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: JuselColors.border(context)),
      ),
      child: Row(
        children: [
          Container(
            width: 86,
            height: 70,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: JuselColors.muted(context),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Icon(
                Icons.image_outlined,
                color: JuselColors.mutedForeground(context),
              ),
            ),
          ),
          const SizedBox(width: JuselSpacing.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StatusPill(
                  label: _statusLabel(),
                  color: _statusColor(context),
                  background: _statusBg(context),
                ),
                const SizedBox(height: JuselSpacing.s6),
                Text(
                  product.name,
                  style: JuselTextStyles.bodyLarge(context).copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: JuselSpacing.s4),
                Text(
                  'Category: ${product.category}',
                  style: JuselTextStyles.bodySmall(context).copyWith(
                    color: JuselColors.mutedForeground(context),
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;
  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(JuselSpacing.s12),
      decoration: BoxDecoration(
        color: JuselColors.card(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: JuselColors.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final String? helper;
  final Color? valueColor;
  final bool bold;
  final bool showDot;
  final bool dense;
  final bool valueBold;
  final bool helperUnderValue;

  const _InfoRow({
    required this.label,
    required this.value,
    this.helper,
    this.valueColor,
    this.bold = false,
    this.showDot = false,
    this.dense = false,
    this.valueBold = false,
    this.helperUnderValue = false,
  });

  @override
  Widget build(BuildContext context) {
    final vertical = dense ? JuselSpacing.s8 : JuselSpacing.s12;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: vertical),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: JuselTextStyles.bodySmall(context).copyWith(
                    color: JuselColors.mutedForeground(context),
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
                if (helper != null && !helperUnderValue)
                  Text(
                    helper!,
                    style: JuselTextStyles.bodySmall(context).copyWith(
                      color: JuselColors.mutedForeground(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ),
          if (showDot) ...[
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(right: JuselSpacing.s6),
              decoration: BoxDecoration(
                color: JuselColors.successColor(context),
                shape: BoxShape.circle,
              ),
            ),
          ],
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: JuselTextStyles.bodyMedium(context).copyWith(
                  fontWeight: (bold || valueBold)
                      ? FontWeight.w800
                      : FontWeight.w700,
                  color: valueColor ?? JuselColors.foreground(context),
                ),
              ),
              if (helper != null && helperUnderValue)
                Text(
                  helper!,
                  style: JuselTextStyles.bodySmall(context).copyWith(
                    color: JuselColors.mutedForeground(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DividerRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(height: 16, color: JuselColors.border(context), thickness: 1);
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: JuselSpacing.s6),
      child: Text(
        text,
        style: JuselTextStyles.bodyMedium(context).copyWith(
          fontWeight: FontWeight.w700,
          color: JuselColors.foreground(context),
        ),
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _NavTile({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: JuselColors.card(context),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: JuselSpacing.s16,
            vertical: JuselSpacing.s16,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: JuselTextStyles.bodyMedium(context).copyWith(
                    fontWeight: FontWeight.w700,
                    color: JuselColors.foreground(context),
                    fontSize: 15,
                  ),
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

class _StatusPill extends StatelessWidget {
  final String label;
  final Color color;
  final Color background;

  const _StatusPill({
    required this.label,
    required this.color,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:jusel_app/core/database/app_database.dart';
import 'package:jusel_app/core/providers/database_provider.dart';
import 'package:jusel_app/core/providers/global_providers.dart';
import 'package:jusel_app/core/utils/theme.dart';
import 'package:jusel_app/features/dashboard/providers/dashboard_tab_provider.dart';
import 'package:jusel_app/features/production/view/batch_screen.dart';
import 'package:jusel_app/features/products/view/product_detail_screen.dart';
import 'package:jusel_app/features/stock/view/restock_screen.dart';
import 'package:jusel_app/features/stock/view/stock_history_screen.dart';

/// Fetch a single product, its current stock, and recent movements.
final stockDetailProvider = FutureProvider.autoDispose
    .family<_StockDetailData, String>((ref, productId) async {
      final db = ref.read(appDatabaseProvider);
      final inventory = ref.read(inventoryServiceProvider);
      final product = await db.productsDao.getProduct(productId);
      if (product == null) {
        throw StateError('Product not found');
      }
      final stock = await inventory.getCurrentStock(productId);
      final movements = await db.stockMovementsDao.getMovementsForProduct(
        productId,
      );

      final trendPoints = _buildTrend(movements, stock);

      return _StockDetailData(
        product: product,
        stockUnits: stock,
        recentMovements: movements.take(5).toList(),
        trend: trendPoints,
      );
    });

String _stockStatus(int stock) {
  if (stock <= 0) return 'Out of Stock';
  if (stock <= 10) return 'Low Stock';
  return 'In Stock';
}

Color _statusColor(BuildContext context, String statusLabel, bool isBackground) {
  final lower = statusLabel.toLowerCase();
  final isOut = lower.contains('out');
  final isLow = lower.contains('low');

  final base = isOut
      ? JuselColors.destructiveColor(context)
      : isLow
          ? JuselColors.warningColor(context)
          : JuselColors.successColor(context);

  return isBackground ? base.withOpacity(0.12) : base;
}

int _reorderSuggestion(int stock) {
  // Simple heuristic: aim for 50 units; never suggest negative.
  final target = 50;
  return ((target - stock).clamp(10, target)).toInt();
}

class StockDetailScreen extends ConsumerWidget {
  final String productId;

  const StockDetailScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(stockDetailProvider(productId));

    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        if (!didPop && Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        } else if (!didPop) {
          ref.read(dashboardTabProvider.notifier).goToDashboard();
        }
      },
      child: Scaffold(
        backgroundColor: JuselColors.background(context),
        appBar: AppBar(
          elevation: 0,
          centerTitle: false,
          title: const Text(
            'Stock Detail',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
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
        ),
        body: detail.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(JuselSpacing.s16),
              child: Text(
                'Failed to load stock detail: $e',
                style: JuselTextStyles.bodyMedium(context).copyWith(
                  color: JuselColors.destructiveColor(context),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          data: (data) {
            final product = data.product;
            final stockUnits = data.stockUnits;
            final statusLabel = _stockStatus(stockUnits);
            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _HeaderCard(
                      category: product.category,
                      productName: product.name,
                      stockUnits: stockUnits,
                      unitCost: product.currentCostPrice,
                      statusLabel: statusLabel,
                      imageUrl: product.imageUrl,
                    ),
                    const SizedBox(height: JuselSpacing.s16),
                    _AlertCard(
                      stockUnits: stockUnits,
                      reorderSuggestion: _reorderSuggestion(stockUnits),
                    ),
                    const SizedBox(height: JuselSpacing.s16),
                    _TrendCard(points: data.trend),
                    const SizedBox(height: JuselSpacing.s16),
                    _RecentActivity(movements: data.recentMovements),
                    const SizedBox(height: JuselSpacing.s16),
                    _Actions(
                      product: product,
                      stockUnits: stockUnits,
                      isProduced: product.isProduced,
                    ),
                    const SizedBox(height: JuselSpacing.s12),
                    _LinkTile(
                      label: 'View Production Batches',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BatchScreen(productId: product.id),
                          ),
                        );
                      },
                    ),
                    _LinkTile(
                      label: 'View All Movements',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => StockHistoryScreen(
                              productId: product.id,
                              productName: product.name,
                              currentStock: stockUnits,
                            ),
                          ),
                        );
                      },
                    ),
                    _LinkTile(
                      label: 'View Product Details',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ProductDetailScreen(productId: product.id),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _StockDetailData {
  final ProductsTableData product;
  final int stockUnits;
  final List<StockMovementsTableData> recentMovements;
  final List<_TrendPoint> trend;

  const _StockDetailData({
    required this.product,
    required this.stockUnits,
    required this.recentMovements,
    required this.trend,
  });
}

class _TrendPoint {
  final DateTime date;
  final int stock;

  const _TrendPoint({required this.date, required this.stock});
}

List<_TrendPoint> _buildTrend(
  List<StockMovementsTableData> movements,
  int currentStock,
) {
  final now = DateTime.now();
  final start = DateTime(
    now.year,
    now.month,
    now.day,
  ).subtract(const Duration(days: 6));

  final recent = movements.where((m) => !m.createdAt.isBefore(start));

  if (recent.isEmpty) return [];

  final Map<DateTime, int> deltaByDay = {};
  for (final m in recent) {
    final day = DateTime(m.createdAt.year, m.createdAt.month, m.createdAt.day);
    final delta = _movementDelta(m);
    deltaByDay[day] = (deltaByDay[day] ?? 0) + delta;
  }

  final totalDelta = deltaByDay.values.fold<int>(0, (p, c) => p + c);
  final baseStock = currentStock - totalDelta;

  final List<_TrendPoint> points = [];
  var running = baseStock;
  for (var i = 0; i < 7; i++) {
    final day = start.add(Duration(days: i));
    running += deltaByDay[day] ?? 0;
    points.add(_TrendPoint(date: day, stock: running));
  }

  return points;
}

int _movementDelta(StockMovementsTableData m) {
  final type = m.type.toLowerCase();
  if (type == 'sale' || type == 'stock_out') {
    return -m.quantityUnits;
  }
  return m.quantityUnits;
}

class _HeaderCard extends StatelessWidget {
  final String category;
  final String productName;
  final int stockUnits;
  final double? unitCost;
  final String statusLabel;
  final String? imageUrl;

  const _HeaderCard({
    required this.category,
    required this.productName,
    required this.stockUnits,
    required this.unitCost,
    required this.statusLabel,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(JuselSpacing.s16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 64,
                  width: 64,
                  decoration: BoxDecoration(
                    color: JuselColors.muted(context),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: JuselColors.border(context), width: 1),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: (imageUrl?.isNotEmpty ?? false)
                        ? Image.network(
                            imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Icon(
                              Icons.inventory_2_outlined,
                              color: JuselColors.mutedForeground(context),
                              size: 28,
                            ),
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              );
                            },
                          )
                        : Icon(
                            Icons.inventory_2_outlined,
                            color: JuselColors.mutedForeground(context),
                            size: 28,
                          ),
                  ),
                ),
                const SizedBox(width: JuselSpacing.s12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: JuselSpacing.s8,
                        runSpacing: JuselSpacing.s6,
                        children: [
                          _Pill(text: category),
                          _Pill(
                            text: statusLabel,
                            color: _statusColor(context, statusLabel, true),
                            textColor: _statusColor(context, statusLabel, false),
                          ),
                        ],
                      ),
                      const SizedBox(height: JuselSpacing.s8),
                      Text(
                        productName,
                        style: JuselTextStyles.headlineSmall(context).copyWith(
                          fontWeight: FontWeight.w800,
                          color: JuselColors.foreground(context),
                        ),
                      ),
                      const SizedBox(height: JuselSpacing.s6),
                      Text(
                        unitCost == null
                            ? 'Cost: N/A'
                            : 'Cost: GHS ${unitCost!.toStringAsFixed(2)} / unit',
                        style: JuselTextStyles.bodySmall(context).copyWith(
                          color: unitCost == null
                              ? JuselColors.mutedForeground(context).withOpacity(0.7)
                              : JuselColors.mutedForeground(context),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: JuselSpacing.s16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Stock',
                      style: JuselTextStyles.bodySmall(context).copyWith(
                        color: JuselColors.mutedForeground(context),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: JuselSpacing.s4),
                    Text(
                      '$stockUnits units',
                      style: JuselTextStyles.headlineLarge(context).copyWith(
                        fontWeight: FontWeight.w900,
                        color: JuselColors.foreground(context),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: JuselSpacing.s12,
                    vertical: JuselSpacing.s12,
                  ),
                  decoration: BoxDecoration(
                    color: JuselColors.primaryColor(context).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: JuselColors.primaryColor(context).withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.trending_up,
                        size: 18,
                        color: JuselColors.primaryColor(context),
                      ),
                      const SizedBox(width: JuselSpacing.s6),
                      Text(
                        'Stable',
                        style: JuselTextStyles.bodySmall(context).copyWith(
                          fontWeight: FontWeight.w700,
                          color: JuselColors.primaryColor(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  final int stockUnits;
  final int reorderSuggestion;

  const _AlertCard({required this.stockUnits, required this.reorderSuggestion});

  @override
  Widget build(BuildContext context) {
    final isLow = stockUnits <= 10;
    final textColor = isLow
        ? JuselColors.destructiveColor(context)
        : JuselColors.successColor(context);
    final bg = textColor.withOpacity(0.12);
    final icon = isLow ? Icons.warning_amber_rounded : Icons.check_circle;

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Container(
        padding: const EdgeInsets.all(JuselSpacing.s16),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: textColor.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: textColor),
                const SizedBox(width: JuselSpacing.s8),
                Expanded(
                  child: Text(
                    isLow
                        ? 'Stock is below the minimum threshold.'
                        : 'Stock is healthy.',
                    style: JuselTextStyles.bodyMedium(context).copyWith(
                      fontWeight: FontWeight.w800,
                      color: textColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: JuselSpacing.s8),
            Text(
              isLow
                  ? 'Recommended reorder: $reorderSuggestion units'
                  : 'Keep monitoring demand to stay ahead of stock-outs.',
              style: JuselTextStyles.bodySmall(context).copyWith(
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
            const SizedBox(height: JuselSpacing.s12),
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  color: textColor.withOpacity(0.9),
                  size: 18,
                ),
                const SizedBox(width: JuselSpacing.s6),
                Text(
                  'Estimated days until out-of-stock:',
                  style: JuselTextStyles.bodySmall(context).copyWith(
                    color: textColor.withOpacity(0.9),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: JuselSpacing.s6),
                Text(
                  _daysRemaining(stockUnits),
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _daysRemaining(int stock) {
    if (stock <= 0) return '<1 day';
    // Very rough heuristic; replace with real consumption data when available.
    final days = (stock / 4).clamp(0, 30); // assume ~4 units/day usage
    return '~${days.toStringAsFixed(1)} days';
  }
}

class _TrendCard extends StatelessWidget {
  final List<_TrendPoint> points;
  const _TrendCard({required this.points});

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Stock Trend (Last 7 Days)',
            style: JuselTextStyles.bodySmall(context).copyWith(
              fontWeight: FontWeight.w700,
              color: JuselColors.foreground(context),
            ),
          ),
          const SizedBox(height: JuselSpacing.s8),
          Card(
            elevation: 0,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(JuselSpacing.s16),
              decoration: BoxDecoration(
                color: JuselColors.card(context),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: JuselColors.border(context)),
              ),
              child: Text(
                'No movements in the last 7 days.',
                style: JuselTextStyles.bodySmall(context).copyWith(
                  color: JuselColors.mutedForeground(context),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      );
    }

    final maxStock = points.map((p) => p.stock).reduce(math.max).toDouble();
    final minStock = points.map((p) => p.stock).reduce(math.min).toDouble();
    final yRange = (maxStock - minStock).abs() < 1 ? 1.0 : maxStock - minStock;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Stock Trend (Last 7 Days)',
          style: JuselTextStyles.bodySmall(context).copyWith(
            fontWeight: FontWeight.w700,
            color: JuselColors.foreground(context),
          ),
        ),
        const SizedBox(height: JuselSpacing.s8),
        Card(
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(JuselSpacing.s16),
            decoration: BoxDecoration(
              color: JuselColors.card(context),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: JuselColors.border(context)),
            ),
            child: SizedBox(
              height: 140,
              child: CustomPaint(
                painter: _TrendPainter(
                  points: points,
                  minY: minStock,
                  rangeY: yRange,
                  primaryColor: JuselColors.primaryColor(context),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TrendPainter extends CustomPainter {
  final List<_TrendPoint> points;
  final double minY;
  final double rangeY;
  final Color primaryColor;

  _TrendPainter({
    required this.points,
    required this.minY,
    required this.rangeY,
    required this.primaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = primaryColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    if (points.isEmpty) return;

    double dxForIndex(int i) {
      if (points.length == 1) return size.width / 2;
      final step = size.width / (points.length - 1);
      return step * i;
    }

    double dyForValue(int i) {
      final val = points[i].stock.toDouble();
      final normalized = (val - minY) / rangeY;
      return size.height - (normalized * size.height);
    }

    final path = Path()..moveTo(dxForIndex(0), dyForValue(0));
    for (var i = 1; i < points.length; i++) {
      path.lineTo(dxForIndex(i), dyForValue(i));
    }
    canvas.drawPath(path, paint);

    final dotPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;
    for (var i = 0; i < points.length; i++) {
      canvas.drawCircle(Offset(dxForIndex(i), dyForValue(i)), 3, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RecentActivity extends StatelessWidget {
  final List<StockMovementsTableData> movements;

  const _RecentActivity({required this.movements});

  @override
  Widget build(BuildContext context) {
    final items = movements
        .map(
          (m) => _Activity(
            _titleForMovement(m),
            DateFormat('MMM d, h:mm a').format(m.createdAt),
            m.quantityUnits,
          ),
        )
        .toList();
    if (items.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Activity',
            style: JuselTextStyles.bodySmall(context).copyWith(
              fontWeight: FontWeight.w700,
              color: JuselColors.foreground(context),
            ),
          ),
          const SizedBox(height: JuselSpacing.s8),
          Card(
            elevation: 0,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(JuselSpacing.s12),
              decoration: BoxDecoration(
                color: JuselColors.card(context),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: JuselColors.border(context)),
              ),
              child: Text(
                'No movements recorded yet.',
                style: JuselTextStyles.bodySmall(context).copyWith(
                  color: JuselColors.mutedForeground(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: JuselTextStyles.bodySmall(context).copyWith(
            fontWeight: FontWeight.w700,
            color: JuselColors.foreground(context),
          ),
        ),
        const SizedBox(height: JuselSpacing.s8),
        Card(
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: JuselColors.card(context),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: JuselColors.border(context)),
            ),
            child: Column(
              children: items
                  .map(
                    (item) => Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: JuselSpacing.s12,
                            vertical: JuselSpacing.s16,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.title,
                                    style: JuselTextStyles.bodyMedium(context).copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: JuselSpacing.s4),
                                  Text(
                                    item.subtitle,
                                    style: JuselTextStyles.bodySmall(context).copyWith(
                                      color: JuselColors.mutedForeground(context),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: JuselSpacing.s12,
                                  vertical: JuselSpacing.s6,
                                ),
                                decoration: BoxDecoration(
                                  color: item.delta >= 0
                                      ? JuselColors.successColor(context).withOpacity(0.12)
                                      : JuselColors.destructiveColor(context).withOpacity(
                                          0.12,
                                        ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  (item.delta > 0 ? '+' : '') +
                                      item.delta.toString(),
                                  style: JuselTextStyles.bodyMedium(context).copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: item.delta >= 0
                                        ? JuselColors.successColor(context)
                                        : JuselColors.destructiveColor(context),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (item != items.last)
                          Divider(height: 1, color: JuselColors.border(context)),
                      ],
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  String _titleForMovement(StockMovementsTableData movement) {
    switch (movement.type) {
      case 'sale':
        return 'Sale';
      case 'stock_in':
        return 'Restock';
      case 'stock_out':
        return 'Adjustment';
      default:
        return movement.type;
    }
  }
}

class _Activity {
  final String title;
  final String subtitle;
  final int delta;
  _Activity(this.title, this.subtitle, this.delta);
}

class _Pill extends StatelessWidget {
  final String text;
  final Color? color;
  final Color? textColor;
  const _Pill({required this.text, this.color, this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: JuselSpacing.s12,
        vertical: JuselSpacing.s6,
      ),
      decoration: BoxDecoration(
        color: color ?? JuselColors.muted(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: JuselTextStyles.bodySmall(context).copyWith(
          fontWeight: FontWeight.w800,
          color: textColor ?? JuselColors.mutedForeground(context),
        ),
      ),
    );
  }
}

class _Actions extends StatelessWidget {
  final ProductsTableData product;
  final int stockUnits;
  final bool isProduced;

  const _Actions({
    required this.product,
    required this.stockUnits,
    required this.isProduced,
  });

  @override
  Widget build(BuildContext context) {
    final restockDisabled = isProduced;
    final helperText = restockDisabled
        ? 'Restock is disabled for locally produced items. Use Add Batch instead.'
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Opacity(
                opacity: restockDisabled ? 0.45 : 1,
                child: ElevatedButton(
                  onPressed: restockDisabled
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => RestockScreen(
                                productId: product.id,
                                productName: product.name,
                                category: product.category,
                                currentStock: stockUnits,
                              ),
                            ),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: JuselColors.primaryColor(context),
                    foregroundColor: JuselColors.primaryForeground,
                    padding: const EdgeInsets.symmetric(
                      vertical: JuselSpacing.s16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Restock',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                ),
              ),
            ),
            const SizedBox(width: JuselSpacing.s12),
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BatchScreen(productId: product.id),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: JuselSpacing.s16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(color: JuselColors.border(context)),
                  backgroundColor: JuselColors.card(context),
                ),
                child: Text(
                  'Add Batch',
                  style: JuselTextStyles.bodyMedium(context).copyWith(
                    fontWeight: FontWeight.w700,
                    color: JuselColors.foreground(context),
                  ),
                ),
              ),
            ),
          ],
        ),
        if (helperText != null) ...[
          const SizedBox(height: JuselSpacing.s8),
          Text(
            helperText,
            style: JuselTextStyles.bodySmall(context).copyWith(
              color: JuselColors.mutedForeground(context),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ],
    );
  }
}

class _LinkTile extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _LinkTile({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: JuselSpacing.s8),
      decoration: BoxDecoration(
        color: JuselColors.card(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: JuselColors.border(context)),
      ),
      child: ListTile(
        title: Text(
          label,
          style: JuselTextStyles.bodyMedium(context).copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: JuselColors.mutedForeground(context),
        ),
        onTap: onTap,
      ),
    );
  }
}

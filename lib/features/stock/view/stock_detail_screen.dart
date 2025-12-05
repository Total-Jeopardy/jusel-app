import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:jusel_app/core/database/app_database.dart';
import 'package:jusel_app/core/providers/database_provider.dart';
import 'package:jusel_app/core/providers/global_providers.dart';
import 'package:jusel_app/core/utils/theme.dart';
import 'package:jusel_app/features/production/view/batch_screen.dart';
import 'package:jusel_app/features/products/view/product_detail_screen.dart';
import 'package:jusel_app/features/stock/view/restock_screen.dart';
import 'package:jusel_app/features/stock/view/stock_history_screen.dart';
import 'package:jusel_app/core/utils/navigation_helper.dart';

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

    return Scaffold(
      backgroundColor: const Color(0xFFF6F9FF),
      appBar: AppBar(
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Stock Detail',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => safePop(context, fallbackRoute: '/boss-dashboard'),
        ),
      ),
      body: detail.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(JuselSpacing.s16),
            child: Text(
              'Failed to load stock detail: $e',
              style: JuselTextStyles.bodyMedium.copyWith(
                color: JuselColors.destructive,
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
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HeaderCard(
                    category: product.category,
                    productName: product.name,
                    stockUnits: stockUnits,
                    unitCost: product.currentCostPrice,
                    statusLabel: statusLabel,
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
                  ElevatedButton(
                    onPressed: () {
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
                      backgroundColor: JuselColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: JuselSpacing.s16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Restock Product',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: JuselSpacing.s12),
                  _GhostButton(
                    label: 'Add to Purchase List',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Purchase list is coming soon.'),
                        ),
                      );
                    },
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
  final double unitCost;
  final String statusLabel;

  const _HeaderCard({
    required this.category,
    required this.productName,
    required this.stockUnits,
    required this.unitCost,
    required this.statusLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(JuselSpacing.s16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: JuselColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: JuselSpacing.s12,
                  vertical: JuselSpacing.s6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  category.toUpperCase(),
                  style: JuselTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.w800,
                    color: JuselColors.mutedForeground,
                  ),
                ),
              ),
              const SizedBox(width: JuselSpacing.s8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: JuselSpacing.s12,
                  vertical: JuselSpacing.s6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF4D6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  statusLabel,
                  style: JuselTextStyles.bodySmall.copyWith(
                    color: const Color(0xFFB45309),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: JuselSpacing.s8),
          Text(
            productName,
            style: JuselTextStyles.headlineMedium.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: JuselSpacing.s6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$stockUnits units',
                style: JuselTextStyles.headlineLarge.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: JuselSpacing.s12,
                  vertical: JuselSpacing.s6,
                ),
                decoration: BoxDecoration(
                  color: JuselColors.muted,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Cost: GHS ${unitCost.toStringAsFixed(2)} / unit',
                  style: JuselTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.w800,
                    color: JuselColors.foreground,
                  ),
                ),
              ),
            ],
          ),
        ],
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
    return Container(
      padding: const EdgeInsets.all(JuselSpacing.s12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF8E7C6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Color(0xFFB45309)),
              const SizedBox(width: JuselSpacing.s8),
              Expanded(
                child: Text(
                  stockUnits <= 10
                      ? 'Stock level is below the minimum threshold of 10 units.'
                      : 'Stock level is above the minimum threshold.',
                  style: JuselTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFFB45309),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: JuselSpacing.s6),
          if (stockUnits <= 10)
            Text(
              'Recommended reorder: $reorderSuggestion units',
              style: JuselTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w800,
                color: const Color(0xFFB45309),
              ),
            ),
          const SizedBox(height: JuselSpacing.s12),
          Row(
            children: [
              const Icon(Icons.schedule, color: Color(0xFFB45309), size: 18),
              const SizedBox(width: JuselSpacing.s6),
              Text(
                'Estimated days until out-of-stock:',
                style: JuselTextStyles.bodySmall.copyWith(
                  color: const Color(0xFFB45309),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: JuselSpacing.s6),
              Text(
                _daysRemaining(stockUnits),
                style: const TextStyle(
                  color: Color(0xFFB45309),
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
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
            style: JuselTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.w700,
              color: JuselColors.foreground,
            ),
          ),
          const SizedBox(height: JuselSpacing.s8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(JuselSpacing.s12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: JuselColors.border),
            ),
            child: Text(
              'No movements in the last 7 days.',
              style: JuselTextStyles.bodySmall.copyWith(
                color: JuselColors.mutedForeground,
                fontWeight: FontWeight.w700,
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
          style: JuselTextStyles.bodySmall.copyWith(
            fontWeight: FontWeight.w700,
            color: JuselColors.foreground,
          ),
        ),
        const SizedBox(height: JuselSpacing.s8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(JuselSpacing.s12),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F8FB),
            borderRadius: BorderRadius.circular(12),
          ),
          child: SizedBox(
            height: 120,
            child: CustomPaint(
              painter: _TrendPainter(
                points: points,
                minY: minStock,
                rangeY: yRange,
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

  _TrendPainter({
    required this.points,
    required this.minY,
    required this.rangeY,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFFA500)
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
      ..color = const Color(0xFFFFA500)
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
            style: JuselTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.w700,
              color: JuselColors.foreground,
            ),
          ),
          const SizedBox(height: JuselSpacing.s8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(JuselSpacing.s12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: JuselColors.border),
            ),
            child: Text(
              'No movements recorded yet.',
              style: JuselTextStyles.bodySmall.copyWith(
                color: JuselColors.mutedForeground,
                fontWeight: FontWeight.w600,
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
          style: JuselTextStyles.bodySmall.copyWith(
            fontWeight: FontWeight.w700,
            color: JuselColors.foreground,
          ),
        ),
        const SizedBox(height: JuselSpacing.s8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: JuselColors.border),
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
                                  style: JuselTextStyles.bodyMedium.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: JuselSpacing.s4),
                                Text(
                                  item.subtitle,
                                  style: JuselTextStyles.bodySmall.copyWith(
                                    color: JuselColors.mutedForeground,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              (item.delta > 0 ? '+' : '') +
                                  item.delta.toString(),
                              style: JuselTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w700,
                                color: item.delta >= 0
                                    ? JuselColors.success
                                    : JuselColors.destructive,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (item != items.last)
                        const Divider(height: 1, color: JuselColors.border),
                    ],
                  ),
                )
                .toList(),
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

class _GhostButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _GhostButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: JuselSpacing.s16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: const BorderSide(color: JuselColors.border),
        backgroundColor: Colors.white,
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          color: JuselColors.foreground,
        ),
      ),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: JuselColors.border),
      ),
      child: ListTile(
        title: Text(
          label,
          style: JuselTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: JuselColors.mutedForeground,
        ),
        onTap: onTap,
      ),
    );
  }
}

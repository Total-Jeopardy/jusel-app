import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jusel_app/core/providers/database_provider.dart';
import 'package:jusel_app/core/services/inventory_service.dart';
import 'package:jusel_app/features/dashboard/providers/period_filter_provider.dart';

class TopProductMetric {
  final String name;
  final double revenue;

  TopProductMetric({required this.name, required this.revenue});
}

class DashboardMetrics {
  final double salesTotal;
  final double profitTotal;
  final double inventoryValue;
  final double productionValue;
  final int lowStockCount;
  final int pendingSyncCount;
  final List<TopProductMetric> topProducts;
  final List<double>
  trendValues; // revenue per day for last N days (oldest -> newest)

  DashboardMetrics({
    required this.salesTotal,
    required this.profitTotal,
    required this.inventoryValue,
    required this.productionValue,
    required this.lowStockCount,
    required this.pendingSyncCount,
    required this.topProducts,
    required this.trendValues,
  });
}

final dashboardProvider = FutureProvider<DashboardMetrics>((ref) async {
  final db = ref.watch(appDatabaseProvider);
  final inventoryService = InventoryService(db);
  final pendingDao = ref.watch(pendingSyncQueueDaoProvider);

  // Get date range from period filter state
  final filterNotifier = ref.read(periodFilterProvider.notifier);
  final dateRange = filterNotifier.getDateRange();

  // Products cache
  final products = await db.productsDao.getAllProducts();
  final productMap = {for (var p in products) p.id: p};

  // Sales movements filtered by date range (inclusive) at the DB level
  final salesMovements = await db.stockMovementsDao.getSalesByDateRange(
    startDate: dateRange.start,
    endDate: dateRange.end,
  );
  final now = DateTime.now();
  final trendStart = DateTime(
    now.year,
    now.month,
    now.day,
  ).subtract(const Duration(days: 6));
  final trendMovements = await db.stockMovementsDao.getSalesByDateRange(
    startDate: trendStart,
    endDate: now,
  );

  double salesTotal = 0;
  double profitTotal = 0;
  Map<String, double> revenueByProduct = {};

  for (final m in salesMovements) {
    final product = productMap[m.productId];
    if (product == null) continue;
    final qty = m.quantityUnits.toDouble();
    final revenue =
        m.totalRevenue ??
        (m.sellingPricePerUnit != null
            ? m.sellingPricePerUnit! * qty
            : product.currentSellingPrice * qty);
    final cost =
        m.totalCost ??
        (m.costPerUnit != null
            ? m.costPerUnit! * qty
            : (product.currentCostPrice ?? 0) * qty);
    salesTotal += revenue;
    profitTotal += (revenue - cost);
    revenueByProduct[m.productId] =
        (revenueByProduct[m.productId] ?? 0) + revenue;
  }

  // Trend over the date range (daily breakdown)
  const trendDays = 7;
  final trendBuckets = List<double>.filled(trendDays, 0);
  for (final m in trendMovements) {
    final product = productMap[m.productId];
    if (product == null) continue;
    final dayDiff = m.createdAt.difference(trendStart).inDays;
    if (dayDiff >= 0 && dayDiff < trendDays) {
      final qty = m.quantityUnits.toDouble();
      final revenue =
          m.totalRevenue ??
          (m.sellingPricePerUnit != null
              ? m.sellingPricePerUnit! * qty
              : product.currentSellingPrice * qty);
      trendBuckets[dayDiff] += revenue;
    }
  }

  // Top products (by revenue)
  final topProducts =
      revenueByProduct.entries
          .map(
            (e) => TopProductMetric(
              name: productMap[e.key]?.name ?? 'Unknown',
              revenue: e.value,
            ),
          )
          .toList()
        ..sort((a, b) => b.revenue.compareTo(a.revenue));
  final top3 = topProducts.take(3).toList();

  // Inventory & production
  final inventoryValue = await inventoryService.getTotalInventoryValue();
  final productionBatches = await db.productionBatchesDao.getAllBatches();
  final productionValue = productionBatches.fold<double>(
    0,
    (sum, b) => sum + b.totalCost,
  );

  // Low stock
  final lowStock = await inventoryService.getLowStockProducts();

  // Pending sync
  final pending = await pendingDao.getAllPendingOperations();

  return DashboardMetrics(
    salesTotal: salesTotal,
    profitTotal: profitTotal,
    inventoryValue: inventoryValue,
    productionValue: productionValue,
    lowStockCount: lowStock.length,
    pendingSyncCount: pending.length,
    topProducts: top3,
    trendValues: trendBuckets,
  );
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jusel_app/core/providers/database_provider.dart';
import 'package:jusel_app/core/services/inventory_service.dart';

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

  // Products cache
  final products = await db.productsDao.getAllProducts();
  final productMap = {for (var p in products) p.id: p};

  // Sales movements (approx revenue using current selling price)
  final movements = await db.stockMovementsDao.getAllMovements();
  final salesMovements = movements
      .where((m) => m.type.toLowerCase() == 'sale')
      .toList();

  double salesTotal = 0;
  double profitTotal = 0;
  Map<String, double> revenueByProduct = {};

  for (final m in salesMovements) {
    final product = productMap[m.productId];
    if (product == null) continue;
    final qty = m.quantityUnits;
    final revenue = m.totalRevenue ?? (product.currentSellingPrice * qty);
    final cost = m.totalCost ?? (product.currentCostPrice * qty);
    salesTotal += revenue;
    profitTotal += (revenue - cost);
    revenueByProduct[m.productId] =
        (revenueByProduct[m.productId] ?? 0) + revenue;
  }

  // Trend over last 7 days
  const daysWindow = 7;
  final now = DateTime.now();
  final trendBuckets = List<double>.filled(daysWindow, 0);
  for (final m in salesMovements) {
    final product = productMap[m.productId];
    if (product == null) continue;
    final dayDiff = now.difference(m.createdAt).inDays;
    if (dayDiff >= 0 && dayDiff < daysWindow) {
      final revenue =
          m.totalRevenue ?? (product.currentSellingPrice * m.quantityUnits);
      trendBuckets[daysWindow - 1 - dayDiff] += revenue;
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

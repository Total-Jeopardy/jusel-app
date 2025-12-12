import 'package:flutter/material.dart';
import 'package:jusel_app/core/database/app_database.dart';
import 'package:jusel_app/features/reports/models/report_models.dart';

/// Service for generating sales reports and analytics
class ReportsService {
  final AppDatabase db;

  ReportsService(this.db);

  /// Generate a comprehensive sales report for a given period
  Future<SalesReport> generateSalesReport({
    required DateTimeRange period,
    String? productId, // optional filter by product
    String? category, // optional filter by category
    String? paymentMethod, // optional filter by payment method
    String? userId, // optional filter by user/staff
  }) async {
    // Get all products
    final products = await db.productsDao.getAllProducts();
    final productMap = {for (var p in products) p.id: p};

    // Use optimized DAO method to get sales by date range with filters
    final filteredMovements = await db.stockMovementsDao.getSalesByDateRange(
      startDate: period.start,
      endDate: period.end,
      productId: productId,
      category: category,
      paymentMethod: paymentMethod,
      userId: userId,
    );

    // Calculate totals
    double totalSales = 0;
    double totalProfit = 0;
    int totalTransactions = filteredMovements.length;

    // Group by product for product breakdown
    final productMetrics = <String, _ProductMetrics>{};
    final paymentMethodTotals = <String, double>{};
    final paymentMethodCounts = <String, int>{};

    for (final m in filteredMovements) {
      final product = productMap[m.productId];
      if (product == null) continue;

      // Use movement prices (snapshot at time of sale) when available,
      // fall back to totalRevenue/totalCost, then current product prices as last resort
      final revenue =
          m.totalRevenue ??
          (m.sellingPricePerUnit != null
              ? m.sellingPricePerUnit! * m.quantityUnits.toDouble()
              : product.currentSellingPrice * m.quantityUnits.toDouble());

      final cost =
          m.totalCost ??
          (m.costPerUnit != null
              ? m.costPerUnit! * m.quantityUnits.toDouble()
              : (product.currentCostPrice ?? 0) * m.quantityUnits.toDouble());

      final profit = revenue - cost;

      totalSales += revenue;
      totalProfit += profit;

      // Track by product
      if (!productMetrics.containsKey(m.productId)) {
        productMetrics[m.productId] = _ProductMetrics(
          productId: m.productId,
          productName: product.name,
        );
      }
      final metrics = productMetrics[m.productId]!;
      metrics.quantitySold += m.quantityUnits;
      metrics.revenue += revenue;
      metrics.profit += profit;

      // Track by payment method - use actual stored value
      final paymentMethod = m.paymentMethod ?? 'cash';
      paymentMethodTotals[paymentMethod] =
          (paymentMethodTotals[paymentMethod] ?? 0) + revenue;
      paymentMethodCounts[paymentMethod] =
          (paymentMethodCounts[paymentMethod] ?? 0) + 1;
    }

    // Build product breakdown
    final productBreakdown = productMetrics.values.map((m) {
      final profitMargin = m.revenue > 0 ? (m.profit / m.revenue) * 100 : 0.0;
      return ProductSalesMetric(
        productId: m.productId,
        productName: m.productName,
        quantitySold: m.quantitySold,
        revenue: m.revenue,
        profit: m.profit,
        profitMargin: profitMargin,
      );
    }).toList()..sort((a, b) => b.revenue.compareTo(a.revenue));

    // Top products (by revenue)
    final topProducts = productBreakdown.take(10).toList();

    // Daily breakdown
    final dailyBreakdown = _calculateDailyBreakdown(
      filteredMovements,
      productMap,
      period,
    );

    return SalesReport(
      totalSales: totalSales,
      totalProfit: totalProfit,
      totalTransactions: totalTransactions,
      salesByPaymentMethod: paymentMethodTotals,
      transactionsByPaymentMethod: paymentMethodCounts,
      topProducts: topProducts,
      dailyBreakdown: dailyBreakdown,
      productBreakdown: productBreakdown,
      period: period,
    );
  }

  /// Get top products by sales revenue
  Future<List<ProductSalesMetric>> getTopProductsBySales({
    required DateTimeRange period,
    int limit = 10,
    String? productId,
    String? category,
    String? paymentMethod,
    String? userId,
  }) async {
    final report = await generateSalesReport(
      period: period,
      productId: productId,
      category: category,
      paymentMethod: paymentMethod,
      userId: userId,
    );
    return report.topProducts.take(limit).toList();
  }

  /// Get top products by profit
  Future<List<ProductSalesMetric>> getTopProductsByProfit({
    required DateTimeRange period,
    int limit = 10,
    String? productId,
    String? category,
    String? paymentMethod,
    String? userId,
  }) async {
    final report = await generateSalesReport(
      period: period,
      productId: productId,
      category: category,
      paymentMethod: paymentMethod,
      userId: userId,
    );
    final sorted = List<ProductSalesMetric>.from(report.productBreakdown)
      ..sort((a, b) => b.profit.compareTo(a.profit));
    return sorted.take(limit).toList();
  }

  /// Get sales breakdown by payment method
  Future<Map<String, double>> getSalesByPaymentMethod({
    required DateTimeRange period,
    String? productId,
    String? category,
    String? paymentMethod,
    String? userId,
  }) async {
    final report = await generateSalesReport(
      period: period,
      productId: productId,
      category: category,
      paymentMethod: paymentMethod,
      userId: userId,
    );
    return report.salesByPaymentMethod;
  }

  /// Get daily sales breakdown
  Future<List<DailySalesMetric>> getDailyBreakdown({
    required DateTimeRange period,
    String? productId,
    String? category,
    String? paymentMethod,
    String? userId,
  }) async {
    final report = await generateSalesReport(
      period: period,
      productId: productId,
      category: category,
      paymentMethod: paymentMethod,
      userId: userId,
    );
    return report.dailyBreakdown;
  }

  /// Get product breakdown
  Future<List<ProductSalesMetric>> getProductBreakdown({
    required DateTimeRange period,
  }) async {
    final report = await generateSalesReport(period: period);
    return report.productBreakdown;
  }

  /// Get category contribution breakdown
  Future<Map<String, CategoryMetrics>> getCategoryContribution({
    required DateTimeRange period,
    String? productId,
    String? category,
    String? paymentMethod,
    String? userId,
  }) async {
    final products = await db.productsDao.getAllProducts();
    final productMap = {for (var p in products) p.id: p};

    final filteredMovements = await db.stockMovementsDao.getSalesByDateRange(
      startDate: period.start,
      endDate: period.end,
      productId: productId,
      category: category,
      paymentMethod: paymentMethod,
      userId: userId,
    );

    final categoryMetrics = <String, CategoryMetrics>{};

    for (final m in filteredMovements) {
      final product = productMap[m.productId];
      if (product == null) continue;

      final revenue =
          m.totalRevenue ??
          (m.sellingPricePerUnit != null
              ? m.sellingPricePerUnit! * m.quantityUnits.toDouble()
              : product.currentSellingPrice * m.quantityUnits.toDouble());

      final cost =
          m.totalCost ??
          (m.costPerUnit != null
              ? m.costPerUnit! * m.quantityUnits.toDouble()
              : (product.currentCostPrice ?? 0) * m.quantityUnits.toDouble());

      final profit = revenue - cost;
      final cat = product.category;

      if (!categoryMetrics.containsKey(cat)) {
        categoryMetrics[cat] = CategoryMetrics(
          category: cat,
          revenue: 0,
          profit: 0,
          quantitySold: 0,
          transactionCount: 0,
        );
      }

      final metrics = categoryMetrics[cat]!;
      metrics.revenue += revenue;
      metrics.profit += profit;
      metrics.quantitySold += m.quantityUnits;
      metrics.transactionCount += 1;
    }

    return categoryMetrics;
  }

  /// Get payment method trends over time
  Future<Map<DateTime, Map<String, double>>> getPaymentMethodTrends({
    required DateTimeRange period,
    String? productId,
    String? category,
    String? paymentMethod,
    String? userId,
  }) async {
    final products = await db.productsDao.getAllProducts();
    final productMap = {for (var p in products) p.id: p};

    final filteredMovements = await db.stockMovementsDao.getSalesByDateRange(
      startDate: period.start,
      endDate: period.end,
      productId: productId,
      category: category,
      paymentMethod: paymentMethod,
      userId: userId,
    );

    final trends = <DateTime, Map<String, double>>{};

    for (final m in filteredMovements) {
      final product = productMap[m.productId];
      if (product == null) continue;

      final dayStart = DateTime(
        m.createdAt.year,
        m.createdAt.month,
        m.createdAt.day,
      );

      if (!trends.containsKey(dayStart)) {
        trends[dayStart] = <String, double>{};
      }

      final paymentMethodKey = m.paymentMethod ?? 'cash';

      // Use movement prices (snapshot at time of sale) when available,
      // fall back to totalRevenue/totalCost, then current product prices as last resort
      final revenue =
          m.totalRevenue ??
          (m.sellingPricePerUnit != null
              ? m.sellingPricePerUnit! * m.quantityUnits.toDouble()
              : product.currentSellingPrice * m.quantityUnits.toDouble());

      trends[dayStart]![paymentMethodKey] =
          (trends[dayStart]![paymentMethodKey] ?? 0) + revenue;
    }

    return trends;
  }

  /// Calculate daily breakdown from movements
  List<DailySalesMetric> _calculateDailyBreakdown(
    List<StockMovementsTableData> salesMovements,
    Map<String, ProductsTableData> productMap,
    DateTimeRange period,
  ) {
    final dailyMap = <DateTime, _DailyMetrics>{};
    final daysInRange = period.end.difference(period.start).inDays + 1;

    // Initialize all days in range
    for (int i = 0; i < daysInRange; i++) {
      final date = period.start.add(Duration(days: i));
      final dayStart = DateTime(date.year, date.month, date.day);
      dailyMap[dayStart] = _DailyMetrics();
    }

    // Aggregate sales by day
    for (final m in salesMovements) {
      final product = productMap[m.productId];
      if (product == null) continue;

      final dayStart = DateTime(
        m.createdAt.year,
        m.createdAt.month,
        m.createdAt.day,
      );

      if (!dailyMap.containsKey(dayStart)) {
        dailyMap[dayStart] = _DailyMetrics();
      }

      final metrics = dailyMap[dayStart]!;

      // Use movement prices (snapshot at time of sale) when available
      final revenue =
          m.totalRevenue ??
          (m.sellingPricePerUnit != null
              ? m.sellingPricePerUnit! * m.quantityUnits.toDouble()
              : product.currentSellingPrice * m.quantityUnits.toDouble());

      final cost =
          m.totalCost ??
          (m.costPerUnit != null
              ? m.costPerUnit! * m.quantityUnits.toDouble()
              : (product.currentCostPrice ?? 0) * m.quantityUnits.toDouble());

      metrics.sales += revenue;
      metrics.profit += (revenue - cost);
      metrics.transactions += 1;
    }

    // Convert to list and sort by date
    return dailyMap.entries
        .map(
          (e) => DailySalesMetric(
            date: e.key,
            sales: e.value.sales,
            profit: e.value.profit,
            transactions: e.value.transactions,
          ),
        )
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  /// Get price override/discount report
  Future<List<PriceOverrideEntry>> getPriceOverrides({
    required DateTimeRange period,
    String? productId,
    String? userId,
  }) async {
    final movements = await db.stockMovementsDao.getSalesByDateRange(
      startDate: period.start,
      endDate: period.end,
      productId: productId,
      userId: userId,
    );

    final products = await db.productsDao.getAllProducts();
    final productMap = {for (var p in products) p.id: p};

    final users = await db.usersDao.getAllUsers();
    final userMap = {for (var u in users) u.id: u};

    final overrides = <PriceOverrideEntry>[];

    for (final movement in movements) {
      // Check if this sale had a price override
      // Override exists if: reason is not null/empty AND not 'sale'
      final product = productMap[movement.productId];
      if (product == null) continue;

      final hasOverride =
          movement.reason != null &&
          movement.reason!.isNotEmpty &&
          movement.reason != 'sale';

      if (hasOverride && movement.sellingPricePerUnit != null) {
        // Get the price that was effective at the time of sale
        // Check price history to find the price before this sale
        // Query from far back to ensure we get the most recent price change before the sale
        final priceHistory = await db.productPriceHistoryDao
            .getHistoryForProductInRange(
              movement.productId,
              startDate: DateTime(
                2000,
                1,
                1,
              ), // Far back date to get all history
              endDate: movement.createdAt,
            );

        // Find the price that was effective just before this sale
        double originalPrice = product.currentSellingPrice;
        if (priceHistory.isNotEmpty) {
          // Get the most recent price change before this sale
          final priceBeforeSale = priceHistory
              .where((h) => h.createdAt.isBefore(movement.createdAt))
              .toList();
          if (priceBeforeSale.isNotEmpty) {
            // Use the new selling price from the most recent change before the sale
            originalPrice =
                priceBeforeSale.first.newSellingPrice ??
                priceBeforeSale.first.oldSellingPrice ??
                product.currentSellingPrice;
          } else {
            // No price change before sale, use the first historical entry's old price
            // or fall back to current price
            originalPrice =
                priceHistory.last.oldSellingPrice ??
                product.currentSellingPrice;
          }
        }

        final overridePrice = movement.sellingPricePerUnit!;
        final discountAmount =
            (originalPrice - overridePrice) * movement.quantityUnits;

        // Only add if there's actually a discount (override price < original price)
        if (overridePrice < originalPrice) {
          final user = userMap[movement.createdByUserId];
          overrides.add(
            PriceOverrideEntry(
              movementId: movement.id,
              productId: movement.productId,
              productName: product.name,
              date: movement.createdAt,
              originalPrice: originalPrice,
              overridePrice: overridePrice,
              discountAmount: discountAmount,
              quantity: movement.quantityUnits,
              reason: movement.reason,
              staffName: user?.name ?? 'Unknown',
              staffId: movement.createdByUserId,
            ),
          );
        }
      } else if (!hasOverride && movement.sellingPricePerUnit != null) {
        // Check if price differs significantly from the price at time of sale
        // Get price history to find effective price at sale time
        // Query from far back to ensure we get the most recent price change before the sale
        final priceHistory = await db.productPriceHistoryDao
            .getHistoryForProductInRange(
              movement.productId,
              startDate: DateTime(
                2000,
                1,
                1,
              ), // Far back date to get all history
              endDate: movement.createdAt,
            );

        double originalPrice = product.currentSellingPrice;
        if (priceHistory.isNotEmpty) {
          final priceBeforeSale = priceHistory
              .where((h) => h.createdAt.isBefore(movement.createdAt))
              .toList();
          if (priceBeforeSale.isNotEmpty) {
            originalPrice =
                priceBeforeSale.first.newSellingPrice ??
                priceBeforeSale.first.oldSellingPrice ??
                product.currentSellingPrice;
          } else {
            originalPrice =
                priceHistory.last.oldSellingPrice ??
                product.currentSellingPrice;
          }
        }

        final overridePrice = movement.sellingPricePerUnit!;
        final priceDiff = (overridePrice - originalPrice).abs();

        // Check if price differs significantly (more than 1% tolerance)
        if (priceDiff > originalPrice * 0.01 && overridePrice < originalPrice) {
          final user = userMap[movement.createdByUserId];
          final discountAmount =
              (originalPrice - overridePrice) * movement.quantityUnits;

          overrides.add(
            PriceOverrideEntry(
              movementId: movement.id,
              productId: movement.productId,
              productName: product.name,
              date: movement.createdAt,
              originalPrice: originalPrice,
              overridePrice: overridePrice,
              discountAmount: discountAmount,
              quantity: movement.quantityUnits,
              reason: movement.reason,
              staffName: user?.name ?? 'Unknown',
              staffId: movement.createdByUserId,
            ),
          );
        }
      }
    }

    // Sort by date (newest first)
    overrides.sort((a, b) => b.date.compareTo(a.date));
    return overrides;
  }

  /// Get low stock and stock-out history
  Future<List<StockAlertEntry>> getStockAlerts({
    required DateTimeRange period,
    String? productId,
    String? category,
    required int lowStockThreshold,
  }) async {
    // Get all products
    final products = productId != null
        ? [await db.productsDao.getProduct(productId)]
        : category != null
        ? await db.productsDao.getProductsByCategory(category)
        : await db.productsDao.getAllProducts();

    final validProducts = products.whereType<ProductsTableData>().toList();

    // Get ALL stock movements (sales, stock_in, production_output, etc.) in the period
    final movements = await db.stockMovementsDao.getAllMovementsByDateRange(
      startDate: period.start,
      endDate: period.end,
      productId: productId,
      category: category,
    );

    // Group movements by product
    final productMovements = <String, List<StockMovementsTableData>>{};
    for (final m in movements) {
      productMovements.putIfAbsent(m.productId, () => []).add(m);
    }

    final alerts = <StockAlertEntry>[];

    // For each product, check stock levels over time
    for (final product in validProducts) {
      final productMovs = productMovements[product.id] ?? [];

      // Get initial stock at start of period (need to calculate backwards from current stock)
      // Start with current stock and work backwards through movements before period start
      final movementsBeforePeriod = await db.stockMovementsDao
          .getAllMovementsByDateRange(
            startDate: DateTime(2000, 1, 1), // Far back date
            endDate: period.start.subtract(const Duration(seconds: 1)),
            productId: product.id,
          );

      int initialStock = product.currentStockQty;
      for (final mov in movementsBeforePeriod.reversed) {
        if (mov.type == 'sale') {
          initialStock += mov.quantityUnits;
        } else if (mov.type == 'stock_in' || mov.type == 'production_output') {
          initialStock -= mov.quantityUnits;
        } else if (mov.type == 'stock_out') {
          // Manual stock-out adjustments are decrements
          initialStock += mov.quantityUnits;
        }
      }

      // Track stock level changes through the period
      int currentStock = initialStock;
      DateTime? lastLowStockDate;
      DateTime? lastStockOutDate;
      int? daysOutOfStock;
      DateTime? restockDate;
      int? restockQuantity;

      // Process movements chronologically
      final sortedMovs = List<StockMovementsTableData>.from(productMovs)
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

      for (final mov in sortedMovs) {
        // Update stock level based on movement type
        if (mov.type == 'sale') {
          currentStock -= mov.quantityUnits;
        } else if (mov.type == 'stock_in' || mov.type == 'production_output') {
          currentStock += mov.quantityUnits;
          // If we were out of stock, record restock
          if (lastStockOutDate != null && restockDate == null) {
            restockDate = mov.createdAt;
            restockQuantity = mov.quantityUnits;
            daysOutOfStock = mov.createdAt.difference(lastStockOutDate).inDays;
          }
        } else if (mov.type == 'stock_out') {
          // Manual stock-out adjustments are decrements
          currentStock -= mov.quantityUnits;
        }

        // Check thresholds
        const stockOutThreshold = 0;

        if (currentStock <= stockOutThreshold && lastStockOutDate == null) {
          lastStockOutDate = mov.createdAt;
        } else if (currentStock <= lowStockThreshold &&
            lastLowStockDate == null) {
          lastLowStockDate = mov.createdAt;
        }
      }

      // Create alert entries
      if (lastStockOutDate != null) {
        alerts.add(
          StockAlertEntry(
            productId: product.id,
            productName: product.name,
            category: product.category,
            alertDate: lastStockOutDate,
            stockLevel: 0,
            alertType: 'stock_out',
            restockedDate: restockDate,
            restockedQuantity: restockQuantity,
            daysOutOfStock: daysOutOfStock,
          ),
        );
      } else if (lastLowStockDate != null) {
        alerts.add(
          StockAlertEntry(
            productId: product.id,
            productName: product.name,
            category: product.category,
            alertDate: lastLowStockDate,
            stockLevel: currentStock,
            alertType: 'low_stock',
          ),
        );
      }
    }

    // Sort by alert date (newest first)
    alerts.sort((a, b) => b.alertDate.compareTo(a.alertDate));
    return alerts;
  }

  /// Get production batch efficiency report
  Future<List<ProductionBatchEfficiency>> getProductionBatchEfficiency({
    required DateTimeRange period,
    String? productId,
  }) async {
    final batches = productId != null
        ? await db.productionBatchesDao.getBatchesForProduct(productId)
        : await db.productionBatchesDao.getAllBatches();

    // Filter by period with inclusive boundaries
    final startOfDay = DateTime(
      period.start.year,
      period.start.month,
      period.start.day,
    );
    final endOfDay = DateTime(
      period.end.year,
      period.end.month,
      period.end.day,
      23,
      59,
      59,
      999,
    );

    final filteredBatches = batches
        .where(
          (b) =>
              !b.createdAt.isBefore(startOfDay) &&
              !b.createdAt.isAfter(endOfDay),
        )
        .toList();

    final products = await db.productsDao.getAllProducts();
    final productMap = {for (var p in products) p.id: p};

    final efficiencyList = <ProductionBatchEfficiency>[];

    for (final batch in filteredBatches) {
      final product = productMap[batch.productId];
      if (product == null) continue;

      // Get the selling price that was effective when the batch was produced
      // Check price history to find the price at batch creation time
      final priceHistory = await db.productPriceHistoryDao
          .getHistoryForProductInRange(
            batch.productId,
            startDate: DateTime(2000, 1, 1), // Far back date
            endDate: batch.createdAt,
          );

      double sellingPrice = product.currentSellingPrice;
      if (priceHistory.isNotEmpty) {
        // Get the most recent price change before or at batch creation
        final priceAtBatchTime = priceHistory
            .where((h) => !h.createdAt.isAfter(batch.createdAt))
            .toList();
        if (priceAtBatchTime.isNotEmpty) {
          // Use the new selling price from the most recent change
          sellingPrice =
              priceAtBatchTime.first.newSellingPrice ??
              priceAtBatchTime.first.oldSellingPrice ??
              product.currentSellingPrice;
        } else {
          // No price change before batch, use the first historical entry's old price
          sellingPrice =
              priceHistory.last.oldSellingPrice ?? product.currentSellingPrice;
        }
      }

      final totalRevenue = sellingPrice * batch.quantityProduced;
      final profit = totalRevenue - batch.totalCost;
      final profitMargin = totalRevenue > 0
          ? (profit / totalRevenue) * 100
          : null;

      // yield is a reserved keyword in Dart, so we need to construct the object differently
      final efficiency = ProductionBatchEfficiency(
        batchId: batch.id,
        productId: batch.productId,
        productName: product.name,
        productionDate: batch.createdAt,
        quantityProduced: batch.quantityProduced,
        totalCost: batch.totalCost,
        unitCost: batch.unitCost,
        batchProfit: batch.batchProfit,
        sellingPrice: sellingPrice,
        profitMargin: profitMargin,
        costBreakdown: {
          'ingredients': batch.ingredientsCost,
          'gas': batch.gasCost,
          'oil': batch.oilCost,
          'labor': batch.laborCost,
          'transport': batch.transportCost,
          'packaging': batch.packagingCost,
          'other': batch.otherCost,
        },
      );
      // yield is a reserved keyword, so we can't set it via named parameter
      // It will remain null (the default value)
      efficiencyList.add(efficiency);
    }

    // Sort by date (newest first)
    efficiencyList.sort((a, b) => b.productionDate.compareTo(a.productionDate));
    return efficiencyList;
  }
}

// Helper classes for internal calculations
class _ProductMetrics {
  final String productId;
  final String productName;
  int quantitySold = 0;
  double revenue = 0;
  double profit = 0;

  _ProductMetrics({required this.productId, required this.productName});
}

class _DailyMetrics {
  double sales = 0;
  double profit = 0;
  int transactions = 0;
}

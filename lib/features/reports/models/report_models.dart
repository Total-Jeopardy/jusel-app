import 'package:flutter/material.dart';

class SalesReport {
  final double totalSales;
  final double totalProfit;
  final int totalTransactions;
  final Map<String, double> salesByPaymentMethod; // 'cash': 1000, 'mobile_money': 500
  final Map<String, int> transactionsByPaymentMethod; // 'cash': 50, 'mobile_money': 30
  final List<ProductSalesMetric> topProducts;
  final List<DailySalesMetric> dailyBreakdown;
  final List<ProductSalesMetric> productBreakdown;
  final DateTimeRange period;

  SalesReport({
    required this.totalSales,
    required this.totalProfit,
    required this.totalTransactions,
    required this.salesByPaymentMethod,
    required this.transactionsByPaymentMethod,
    required this.topProducts,
    required this.dailyBreakdown,
    required this.productBreakdown,
    required this.period,
  });

  double get profitMargin => totalSales > 0 ? (totalProfit / totalSales) * 100 : 0;
}

class ProductSalesMetric {
  final String productId;
  final String productName;
  final int quantitySold;
  final double revenue;
  final double profit;
  final double profitMargin; // percentage

  ProductSalesMetric({
    required this.productId,
    required this.productName,
    required this.quantitySold,
    required this.revenue,
    required this.profit,
    required this.profitMargin,
  });
}

class DailySalesMetric {
  final DateTime date;
  final double sales;
  final double profit;
  final int transactions;

  DailySalesMetric({
    required this.date,
    required this.sales,
    required this.profit,
    required this.transactions,
  });
}

class PaymentMethodBreakdown {
  final String method; // 'cash' or 'mobile_money'
  final double amount;
  final int transactionCount;
  final double percentage; // of total sales

  PaymentMethodBreakdown({
    required this.method,
    required this.amount,
    required this.transactionCount,
    required this.percentage,
  });

  String get displayName {
    switch (method) {
      case 'cash':
        return 'Cash';
      case 'mobile_money':
        return 'Mobile Money';
      default:
        return method;
    }
  }
}

class CategoryMetrics {
  final String category;
  double revenue;
  double profit;
  int quantitySold;
  int transactionCount;

  CategoryMetrics({
    required this.category,
    required this.revenue,
    required this.profit,
    required this.quantitySold,
    required this.transactionCount,
  });

  double get profitMargin => revenue > 0 ? (profit / revenue) * 100 : 0.0;
  double get averageOrderValue => transactionCount > 0 ? revenue / transactionCount : 0.0;
}

/// Price override/discount report entry
class PriceOverrideEntry {
  final String movementId;
  final String productId;
  final String productName;
  final DateTime date;
  final double originalPrice;
  final double overridePrice;
  final double discountAmount;
  final int quantity;
  final String? reason;
  final String staffName;
  final String staffId;

  PriceOverrideEntry({
    required this.movementId,
    required this.productId,
    required this.productName,
    required this.date,
    required this.originalPrice,
    required this.overridePrice,
    required this.discountAmount,
    required this.quantity,
    this.reason,
    required this.staffName,
    required this.staffId,
  });
}

/// Low stock/stock-out history entry
class StockAlertEntry {
  final String productId;
  final String productName;
  final String category;
  final DateTime alertDate;
  final int stockLevel;
  final String alertType; // 'low_stock' or 'stock_out'
  final DateTime? restockedDate;
  final int? restockedQuantity;
  final int? daysOutOfStock;

  StockAlertEntry({
    required this.productId,
    required this.productName,
    required this.category,
    required this.alertDate,
    required this.stockLevel,
    required this.alertType,
    this.restockedDate,
    this.restockedQuantity,
    this.daysOutOfStock,
  });
}

/// Production batch efficiency metrics
class ProductionBatchEfficiency {
  final int batchId;
  final String productId;
  final String productName;
  final DateTime productionDate;
  final int quantityProduced;
  final double totalCost;
  final double unitCost;
  final double? batchProfit;
  final double sellingPrice;
  final double? profitMargin;
  final double? yield; // percentage of expected vs actual
  final Map<String, double?> costBreakdown; // ingredients, gas, oil, labor, etc.

  ProductionBatchEfficiency({
    required this.batchId,
    required this.productId,
    required this.productName,
    required this.productionDate,
    required this.quantityProduced,
    required this.totalCost,
    required this.unitCost,
    this.batchProfit,
    required this.sellingPrice,
    this.profitMargin,
    this.yield,
    required this.costBreakdown,
  });
}


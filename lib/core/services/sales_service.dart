import 'dart:convert';

import 'package:jusel_app/core/database/app_database.dart';
import 'package:jusel_app/core/database/daos/pending_sync_queue_dao.dart';
import 'inventory_service.dart';

class SaleSummary {
  final int quantity;
  final double unitSellingPrice;
  final double unitCostPrice;
  final double totalRevenue;
  final double totalCost;
  final double profit;

  SaleSummary({
    required this.quantity,
    required this.unitSellingPrice,
    required this.unitCostPrice,
    required this.totalRevenue,
    required this.totalCost,
    required this.profit,
  });
}

/// Handles selling items: stock checks, logging, and profit estimate.
class SalesService {
  final AppDatabase db;
  final InventoryService inventoryService;
  final PendingSyncQueueDao syncQueueDao;

  SalesService({
    required this.db,
    required this.inventoryService,
    required this.syncQueueDao,
  });

  /// Sell a product and return a summary (revenue, cost, profit).
  ///
  /// This:
  ///  - checks stock
  ///  - records a stock movement of type 'sale' with price snapshots
  ///  - calculates profit using stored prices
  Future<SaleSummary> sellProduct({
    required String productId,
    required int quantity,
    required String createdByUserId,
    String? paymentMethod,
    double? overriddenPrice,
    String? priceOverrideReason,
  }) async {
    if (quantity <= 0) {
      throw Exception('Quantity must be greater than zero');
    }

    final product = await db.productsDao.getProduct(productId);
    if (product == null) {
      throw Exception('Product not found');
    }

    if (product.status != 'active') {
      throw Exception('Product is inactive');
    }

    final currentStock = await inventoryService.getCurrentStock(productId);
    if (currentStock < quantity) {
      throw Exception('Not enough stock to complete sale');
    }

    final unitSellingPrice = overriddenPrice ?? product.currentSellingPrice;
    final unitCostPrice = product.currentCostPrice;

    final totalRevenue = unitSellingPrice * quantity;
    final totalCost = unitCostPrice! * quantity;
    final profit = totalRevenue - totalCost;

    final movementId = await db.stockMovementsDao.recordSale(
      productId: productId,
      quantity: quantity,
      createdByUserId: createdByUserId,
      unitSellingPrice: unitSellingPrice,
      unitCostPrice: unitCostPrice,
      paymentMethod: paymentMethod ?? 'cash',
      reason: priceOverrideReason,
    );

    final payload = {
      'id': movementId,
      'productId': productId,
      'quantity': quantity,
      'unitSellingPrice': unitSellingPrice,
      'unitCostPrice': unitCostPrice,
      'totalRevenue': totalRevenue,
      'totalCost': totalCost,
      'profit': profit,
      'paymentMethod': paymentMethod ?? 'cash',
      'createdByUserId': createdByUserId,
      'createdAt': DateTime.now().toIso8601String(),
      'priceOverrideReason': priceOverrideReason,
    };

    await syncQueueDao.enqueueOperation(
      id: movementId,
      operationType: 'sale',
      payload: jsonEncode(payload),
    );

    return SaleSummary(
      quantity: quantity,
      unitSellingPrice: unitSellingPrice,
      unitCostPrice: unitCostPrice,
      totalRevenue: totalRevenue,
      totalCost: totalCost,
      profit: profit,
    );
  }
}

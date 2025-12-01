import 'dart:convert';

import 'package:jusel_app/core/database/app_database.dart';
import 'package:jusel_app/core/database/daos/pending_sync_queue_dao.dart';

class RestockService {
  final AppDatabase db;
  final PendingSyncQueueDao syncQueueDao;

  RestockService(this.db, this.syncQueueDao);

  /// RESTOCK BY PACKS (Option A)
  ///
  /// Example:
  /// - product.unitsPerPack = 12
  /// - packCount = 3
  /// - packPrice = 20.0 (for ONE pack)
  ///
  /// totalUnits = 3 * 12 = 36
  /// costPerUnit = 20 / 12
  Future<void> restockFromPacks({
    required String productId,
    required int packCount,
    required double packPrice, // price per single pack
    required String createdByUserId,
  }) async {
    if (packCount <= 0) {
      throw Exception('Pack count must be greater than zero');
    }
    if (packPrice <= 0) {
      throw Exception('Pack price must be greater than zero');
    }

    final product = await db.productsDao.getProduct(productId);
    if (product == null) {
      throw Exception('Product not found');
    }

    if (product.status != 'active') {
      throw Exception('Product is not active');
    }

    final unitsPerPack = product.unitsPerPack;
    if (unitsPerPack == null || unitsPerPack <= 0) {
      throw Exception('This product is not configured with unitsPerPack');
    }

    final totalUnits = unitsPerPack * packCount;
    final costPerUnit = packPrice / unitsPerPack;

    final movementId = await db.stockMovementsDao.recordPurchase(
      productId: productId,
      quantity: totalUnits,
      costPerUnit: costPerUnit,
      createdByUserId: createdByUserId,
    );

    final payload = {
      'id': movementId,
      'productId': productId,
      'quantity': totalUnits,
      'costPerUnit': costPerUnit,
      'totalCost': totalUnits * costPerUnit,
      'createdByUserId': createdByUserId,
      'createdAt': DateTime.now().toIso8601String(),
    };

    await syncQueueDao.enqueueOperation(
      id: movementId,
      operationType: 'restock',
      payload: jsonEncode(payload),
    );
  }

  /// RESTOCK BY UNITS (for when she buys loose items or special cases)
  Future<void> restockByUnits({
    required String productId,
    required int units,
    required double costPerUnit,
    required String createdByUserId,
  }) async {
    if (units <= 0) {
      throw Exception('Units must be greater than zero');
    }
    if (costPerUnit <= 0) {
      throw Exception('Cost per unit must be greater than zero');
    }

    final product = await db.productsDao.getProduct(productId);
    if (product == null) {
      throw Exception('Product not found');
    }

    if (product.status != 'active') {
      throw Exception('Product is not active');
    }

    final movementId = await db.stockMovementsDao.recordPurchase(
      productId: productId,
      quantity: units,
      costPerUnit: costPerUnit,
      createdByUserId: createdByUserId,
    );

    final payload = {
      'id': movementId,
      'productId': productId,
      'quantity': units,
      'costPerUnit': costPerUnit,
      'totalCost': units * costPerUnit,
      'createdByUserId': createdByUserId,
      'createdAt': DateTime.now().toIso8601String(),
    };

    await syncQueueDao.enqueueOperation(
      id: movementId,
      operationType: 'restock',
      payload: jsonEncode(payload),
    );
  }
}

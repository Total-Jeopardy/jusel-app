import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:jusel_app/core/database/app_database.dart';
import 'package:jusel_app/core/database/daos/pending_sync_queue_dao.dart';

/// Service for handling price overrides by boss users.
/// Logs all overrides and queues them for sync.
class PriceOverrideService {
  final AppDatabase db;
  final PendingSyncQueueDao syncQueueDao;

  PriceOverrideService({required this.db, required this.syncQueueDao});

  /// Apply a price override for a product (boss only).
  ///
  /// This will:
  /// 1. Update the product's selling price
  /// 2. Log the price change in history
  /// 3. Create a stock movement entry (type: price_change)
  /// 4. Queue the operation for sync
  Future<void> applyOverride({
    required String productId,
    required double newPrice,
    required String bossUserId,
    String? reason,
  }) async {
    print(
      '[PRICE_OVERRIDE] Starting override for product: $productId, new price: $newPrice',
    );

    if (newPrice <= 0) {
      throw Exception('Price must be greater than zero');
    }

    try {
      // 1. Get current product
      final product = await db.productsDao.getProduct(productId);
      if (product == null) {
        throw Exception('Product not found');
      }

      final oldSellingPrice = product.currentSellingPrice;
      final oldCostPrice = product.currentCostPrice;

      // 2. Update product selling price
      await db.productsDao.updateProduct(
        id: productId,
        newSellingPrice: newPrice,
      );

      print(
        '[PRICE_OVERRIDE] Updated product price from $oldSellingPrice to $newPrice',
      );

      // 3. Log price change in history
      final historyId = DateTime.now().millisecondsSinceEpoch.toString();
      await db.productPriceHistoryDao.logPriceChange(
        ProductPriceHistoryTableCompanion.insert(
          id: historyId,
          productId: productId,
          oldSellingPrice: Value(oldSellingPrice),
          newSellingPrice: Value(newPrice),
          oldCostPrice: Value(oldCostPrice),
          newCostPrice: Value(oldCostPrice), // Cost price unchanged
          changeType: 'selling_price',
          reason: Value(reason ?? 'boss_override'),
          createdAt: DateTime.now(),
        ),
      );

      print('[PRICE_OVERRIDE] Logged price change to history');

      // 4. Note: Price changes don't create stock movements
      // They're tracked in ProductPriceHistoryTable only

      // 5. Queue for sync
      final syncPayload = {
        'id': historyId,
        'productId': productId,
        'oldSellingPrice': oldSellingPrice,
        'newSellingPrice': newPrice,
        'oldCostPrice': oldCostPrice,
        'newCostPrice': oldCostPrice,
        'changeType': 'selling_price',
        'reason': reason ?? 'boss_override',
        'createdByUserId': bossUserId,
        'createdAt': DateTime.now().toIso8601String(),
        'productName': product.name,
      };

      await syncQueueDao.enqueueOperation(
        id: historyId,
        operationType: 'price_change',
        payload: jsonEncode(syncPayload),
      );

      print('[PRICE_OVERRIDE] Queued for sync: $historyId');
    } catch (e, st) {
      print('[PRICE_OVERRIDE] Error: $e');
      print('[PRICE_OVERRIDE] Stack trace: $st');
      rethrow;
    }
  }

  /// Validate if user can override prices (boss only)
  Future<bool> canOverridePrice(String userId) async {
    final user = await db.usersDao.getUserById(userId);
    return user?.role == 'boss' && (user?.isActive ?? false);
  }
}

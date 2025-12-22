import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/drift.dart';
import 'package:jusel_app/core/database/app_database.dart';
import 'package:jusel_app/core/database/daos/pending_sync_queue_dao.dart';

/// Status of the sync process
enum SyncStatus { idle, syncing, allSynced, offline, error }

/// Orchestrates syncing of local Drift data to Firestore.
/// Handles queue management, retries, and conflict resolution.
class SyncOrchestrator {
  final AppDatabase db;
  final FirebaseFirestore firestore;
  final PendingSyncQueueDao syncQueueDao;

  SyncOrchestrator({
    required this.db,
    required this.firestore,
    required this.syncQueueDao,
  });

  /// Check if device is online
  Future<bool> isOnline() async {
    try {
      await firestore
          .collection('products')
          .limit(1)
          .get(const GetOptions(source: Source.server));
      return true;
    } on FirebaseException catch (e) {
      // If we got a permission error, treat as online to avoid blocking sync.
      if (e.code == 'permission-denied') return true;
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Sync all pending operations
  Future<SyncResult> syncAll({int maxRetries = 3}) async {
    // Check connectivity
    if (!await isOnline()) {
      return SyncResult(
        status: SyncStatus.offline,
        syncedCount: 0,
        failedCount: 0,
        error: 'Device is offline',
      );
    }

    final pendingOps = await syncQueueDao.getAllPendingOperations();
    if (pendingOps.isEmpty) {
      return SyncResult(
        status: SyncStatus.allSynced,
        syncedCount: 0,
        failedCount: 0,
      );
    }

    int syncedCount = 0;
    int failedCount = 0;
    String? lastError;

    for (var operation in pendingOps) {
      // Skip if already exceeded max retries
      if (operation.retries >= maxRetries) {
        await syncQueueDao.markAsFailed(operation.id, 'Max retries exceeded');
        failedCount++;
        continue;
      }

      try {
        // Mark as retrying
        await syncQueueDao.markAsRetrying(operation.id);

        // Sync based on operation type
        await _syncOperation(operation);

        // Mark as synced
        await syncQueueDao.markAsSynced(operation.id);
        syncedCount++;
      } catch (e) {
        lastError = e.toString();
        await syncQueueDao.incrementRetries(operation.id);

        // If exceeded max retries, mark as failed
        final updatedOp = await syncQueueDao.getOperationById(operation.id);
        if (updatedOp != null && updatedOp.retries >= maxRetries) {
          await syncQueueDao.markAsFailed(operation.id, e.toString());
          failedCount++;
        }
      }
    }

    return SyncResult(
      status: failedCount > 0 ? SyncStatus.error : SyncStatus.allSynced,
      syncedCount: syncedCount,
      failedCount: failedCount,
      error: lastError,
    );
  }

  /// Sync a single operation
  Future<void> _syncOperation(PendingSyncQueueTableData operation) async {
    final payload = jsonDecode(operation.payload) as Map<String, dynamic>;

    switch (operation.operationType) {
      case 'sale':
        await _syncSale(payload);
        break;
      case 'restock':
        await _syncRestock(payload);
        break;
      case 'production':
        await _syncProduction(payload);
        break;
      case 'price_change':
        await _syncPriceChange(payload);
        break;
      case 'product_create':
        await _syncProductCreate(payload);
        break;
      case 'product_update':
        await _syncProductUpdate(payload);
        break;
      default:
        throw Exception('Unknown operation type: ${operation.operationType}');
    }
  }

  /// Sync a sale to Firestore
  Future<void> _syncSale(Map<String, dynamic> payload) async {
    await firestore.collection('sales').doc(payload['id'] as String).set({
      'productId': payload['productId'],
      'quantity': payload['quantity'],
      'unitSellingPrice': payload['unitSellingPrice'],
      'unitCostPrice': payload['unitCostPrice'],
      'totalRevenue': payload['totalRevenue'],
      'totalCost': payload['totalCost'],
      'profit': payload['profit'],
      'paymentMethod': payload['paymentMethod'] ?? 'cash',
      'createdByUserId': payload['createdByUserId'],
      'createdAt': Timestamp.fromDate(
        DateTime.parse(payload['createdAt'] as String),
      ),
    });
  }

  /// Sync a restock to Firestore
  Future<void> _syncRestock(Map<String, dynamic> payload) async {
    await firestore.collection('restocks').doc(payload['id'] as String).set({
      'productId': payload['productId'],
      'quantity': payload['quantity'],
      'costPerUnit': payload['costPerUnit'],
      'totalCost': payload['totalCost'],
      'createdByUserId': payload['createdByUserId'],
      'createdAt': Timestamp.fromDate(
        DateTime.parse(payload['createdAt'] as String),
      ),
    });
  }

  /// Sync a production batch to Firestore
  Future<void> _syncProduction(Map<String, dynamic> payload) async {
    await firestore
        .collection('production_batches')
        .doc(payload['id'].toString())
        .set({
          'productId': payload['productId'],
          'quantityProduced': payload['quantityProduced'],
          'totalCost': payload['totalCost'],
          'unitCost': payload['unitCost'],
          'ingredientsCost': payload['ingredientsCost'],
          'gasCost': payload['gasCost'],
          'oilCost': payload['oilCost'],
          'laborCost': payload['laborCost'],
          'transportCost': payload['transportCost'],
          'packagingCost': payload['packagingCost'],
          'otherCost': payload['otherCost'],
          'notes': payload['notes'],
          'createdByUserId': payload['createdByUserId'],
          'createdAt': Timestamp.fromDate(
            DateTime.parse(payload['createdAt'] as String),
          ),
        });
  }

  /// Sync a price change to Firestore
  Future<void> _syncPriceChange(Map<String, dynamic> payload) async {
    await firestore
        .collection('price_changes')
        .doc(payload['id'] as String)
        .set({
          'productId': payload['productId'],
          'oldSellingPrice': payload['oldSellingPrice'],
          'newSellingPrice': payload['newSellingPrice'],
          'oldCostPrice': payload['oldCostPrice'],
          'newCostPrice': payload['newCostPrice'],
          'changeType': payload['changeType'],
          'reason': payload['reason'],
          'createdByUserId': payload['createdByUserId'],
          'createdAt': Timestamp.fromDate(
            DateTime.parse(payload['createdAt'] as String),
          ),
        });
  }

  /// Sync product creation to Firestore
  Future<void> _syncProductCreate(Map<String, dynamic> payload) async {
    await firestore.collection('products').doc(payload['id'] as String).set({
      'name': payload['name'],
      'category': payload['category'],
      'subcategory': payload['subcategory'],
      'isProduced': payload['isProduced'],
      'currentSellingPrice': payload['currentSellingPrice'],
      'unitsPerPack': payload['unitsPerPack'],
      'imageUrl': payload['imageUrl'],
      'status': payload['status'],
      'createdAt': Timestamp.fromDate(
        DateTime.parse(payload['createdAt'] as String),
      ),
      'updatedAt': payload['updatedAt'] != null
          ? Timestamp.fromDate(DateTime.parse(payload['updatedAt'] as String))
          : null,
    });
  }

  /// Sync product update to Firestore
  Future<void> _syncProductUpdate(Map<String, dynamic> payload) async {
    final updateData = <String, dynamic>{'updatedAt': Timestamp.now()};

    if (payload.containsKey('name')) updateData['name'] = payload['name'];
    if (payload.containsKey('category')) {
      updateData['category'] = payload['category'];
    }
    if (payload.containsKey('subcategory')) {
      updateData['subcategory'] = payload['subcategory'];
    }
    if (payload.containsKey('currentSellingPrice')) {
      updateData['currentSellingPrice'] = payload['currentSellingPrice'];
    }
    if (payload.containsKey('currentCostPrice')) {
      updateData['currentCostPrice'] = payload['currentCostPrice'];
    }
    if (payload.containsKey('status')) {
      updateData['status'] = payload['status'];
    }

    await firestore
        .collection('products')
        .doc(payload['id'] as String)
        .update(updateData);
  }

  /// Retry failed operations
  Future<SyncResult> retryFailed({int maxRetries = 3}) async {
    final failedOps = await syncQueueDao.getFailedOperations();
    if (failedOps.isEmpty) {
      return SyncResult(
        status: SyncStatus.allSynced,
        syncedCount: 0,
        failedCount: 0,
      );
    }

    // Reset status to queued for retry
    for (var op in failedOps) {
      await syncQueueDao.resetFailedToQueued(op.id);
    }

    return syncAll(maxRetries: maxRetries);
  }

  /// Get sync status summary
  Future<SyncStatusSummary> getStatusSummary() async {
    final queued = await syncQueueDao.getQueuedOperations();
    final retrying = await syncQueueDao.getRetryingOperations();
    final failed = await syncQueueDao.getFailedOperations();
    final isOnline = await this.isOnline();

    return SyncStatusSummary(
      isOnline: isOnline,
      queuedCount: queued.length,
      retryingCount: retrying.length,
      failedCount: failed.length,
      totalPending: queued.length + retrying.length,
    );
  }

  /// Pull down data from Firestore for the current user and hydrate local DB.
  /// This complements the push sync so a fresh device has data after login.
  /// 
  /// Note: Pulls ALL data (not filtered by userId) to ensure all devices see all shop data.
  Future<SyncResult> pullAllForUser(String userId) async {
    if (!await isOnline()) {
      return SyncResult(
        status: SyncStatus.offline,
        syncedCount: 0,
        failedCount: 0,
        error: 'Device is offline',
      );
    }

    int synced = 0;
    int failed = 0;
    String? lastError;

    try {
      // Products - Pull ALL products (not filtered by userId) so all devices see all shop data
      final productsSnap = await firestore
          .collection('products')
          .get(const GetOptions(source: Source.server));
      
      print('[SyncOrchestrator] Pulling ${productsSnap.docs.length} products from Firestore');

      await db.transaction(() async {
        for (final doc in productsSnap.docs) {
          try {
            final data = doc.data();
            if (data['name'] == null || data['category'] == null) {
              failed++;
              lastError = 'Missing product fields for ${doc.id}';
              continue;
            }
            await db
                .into(db.productsTable)
                .insertOnConflictUpdate(
                  ProductsTableCompanion.insert(
                    id: doc.id,
                    name: data['name'] as String,
                    category: data['category'] as String,
                    subcategory: Value(data['subcategory'] as String?),
                    imageUrl: Value(data['imageUrl'] as String?),
                    isProduced: data['isProduced'] as bool? ?? false,
                    currentSellingPrice: (data['currentSellingPrice'] as num)
                        .toDouble(),
                    unitsPerPack: Value(
                      (data['unitsPerPack'] as num?)?.toInt(),
                    ),
                    status: Value(data['status'] as String? ?? 'active'),
                    currentCostPrice: Value(
                      (data['currentCostPrice'] as num?)?.toDouble(),
                    ),
                    createdAt:
                        (data['createdAt'] as Timestamp?)?.toDate() ??
                        DateTime.now(),
                    updatedAt: Value(
                      (data['updatedAt'] as Timestamp?)?.toDate(),
                    ),
                  ),
                );
            synced++;
          } catch (e) {
            failed++;
            lastError = e.toString();
          }
        }
      });

      // Sales -> stock movements (type: sale) - Pull ALL sales
      final salesSnap = await firestore
          .collection('sales')
          .get(const GetOptions(source: Source.server));
      
      print('[SyncOrchestrator] Pulling ${salesSnap.docs.length} sales from Firestore');
      await db.transaction(() async {
        for (final doc in salesSnap.docs) {
          try {
            final data = doc.data();
            if (data['productId'] == null || data['quantity'] == null) {
              failed++;
              lastError = 'Missing sale fields for ${doc.id}';
              continue;
            }
            await db
                .into(db.stockMovementsTable)
                .insertOnConflictUpdate(
                  StockMovementsTableCompanion.insert(
                    id: doc.id,
                    productId: data['productId'] as String,
                    type: 'sale',
                    quantityUnits: (data['quantity'] as num).toInt(),
                    sellingPricePerUnit: Value(
                      (data['unitSellingPrice'] as num).toDouble(),
                    ),
                    costPerUnit: Value(
                      (data['unitCostPrice'] as num).toDouble(),
                    ),
                    totalRevenue: Value(
                      (data['totalRevenue'] as num).toDouble(),
                    ),
                    totalCost: Value((data['totalCost'] as num).toDouble()),
                    profit: Value((data['profit'] as num).toDouble()),
                    paymentMethod: Value(
                      data['paymentMethod'] as String? ?? 'cash',
                    ),
                    createdByUserId: data['createdByUserId'] as String,
                    createdAt:
                        (data['createdAt'] as Timestamp?)?.toDate() ??
                        DateTime.now(),
                  ),
                );
            synced++;
          } catch (e) {
            failed++;
            lastError = e.toString();
          }
        }
      });

      // Restocks -> stock movements (type: stock_in) - Pull ALL restocks
      final restocksSnap = await firestore
          .collection('restocks')
          .get(const GetOptions(source: Source.server));
      
      print('[SyncOrchestrator] Pulling ${restocksSnap.docs.length} restocks from Firestore');
      await db.transaction(() async {
        for (final doc in restocksSnap.docs) {
          try {
            final data = doc.data();
            if (data['productId'] == null || data['quantity'] == null) {
              failed++;
              lastError = 'Missing restock fields for ${doc.id}';
              continue;
            }
            final qty = (data['quantity'] as num).toInt();
            final costPerUnit = (data['costPerUnit'] as num).toDouble();
            await db
                .into(db.stockMovementsTable)
                .insertOnConflictUpdate(
                  StockMovementsTableCompanion.insert(
                    id: doc.id,
                    productId: data['productId'] as String,
                    type: 'stock_in',
                    quantityUnits: qty,
                    costPerUnit: Value(costPerUnit),
                    totalCost: Value((data['totalCost'] as num).toDouble()),
                    createdByUserId: data['createdByUserId'] as String,
                    createdAt:
                        (data['createdAt'] as Timestamp?)?.toDate() ??
                        DateTime.now(),
                    reason: const Value('purchase'),
                  ),
                );
            // Also update latest cost on product
            await (db.update(db.productsTable)
                  ..where((tbl) => tbl.id.equals(data['productId'] as String)))
                .write(
                  ProductsTableCompanion(
                    currentCostPrice: Value(costPerUnit),
                    updatedAt: Value(DateTime.now()),
                  ),
                );
            synced++;
          } catch (e) {
            failed++;
            lastError = e.toString();
          }
        }
      });

      // Production batches -> stock movements (type: production_output) - Pull ALL batches
      final productionSnap = await firestore
          .collection('production_batches')
          .get(const GetOptions(source: Source.server));
      
      print('[SyncOrchestrator] Pulling ${productionSnap.docs.length} production batches from Firestore');
      await db.transaction(() async {
        for (final doc in productionSnap.docs) {
          try {
            final data = doc.data();
            if (data['productId'] == null || data['quantityProduced'] == null) {
              failed++;
              lastError = 'Missing production fields for ${doc.id}';
              continue;
            }
            await db
                .into(db.stockMovementsTable)
                .insertOnConflictUpdate(
                  StockMovementsTableCompanion.insert(
                    id: doc.id,
                    productId: data['productId'] as String,
                    type: 'production_output',
                    quantityUnits:
                        (data['quantityProduced'] as num?)?.toInt() ?? 0,
                    costPerUnit: Value((data['unitCost'] as num?)?.toDouble()),
                    totalCost: Value((data['totalCost'] as num?)?.toDouble()),
                    createdByUserId: data['createdByUserId'] as String,
                    createdAt:
                        (data['createdAt'] as Timestamp?)?.toDate() ??
                        DateTime.now(),
                    batchId: Value(doc.id),
                  ),
                );
            synced++;
          } catch (e) {
            failed++;
            lastError = e.toString();
          }
        }
      });
    } catch (e) {
      failed++;
      lastError = e.toString();
    }

    final result = SyncResult(
      status: failed > 0 ? SyncStatus.error : SyncStatus.allSynced,
      syncedCount: synced,
      failedCount: failed,
      error: lastError,
    );
    
    print('[SyncOrchestrator] Pull completed: ${result.syncedCount} synced, ${result.failedCount} failed, status: ${result.status}');
    
    return result;
  }
}

// ============================================================
// DATA CLASSES
// ============================================================

class SyncResult {
  final SyncStatus status;
  final int syncedCount;
  final int failedCount;
  final String? error;

  SyncResult({
    required this.status,
    required this.syncedCount,
    required this.failedCount,
    this.error,
  });
}

class SyncStatusSummary {
  final bool isOnline;
  final int queuedCount;
  final int retryingCount;
  final int failedCount;
  final int totalPending;

  SyncStatusSummary({
    required this.isOnline,
    required this.queuedCount,
    required this.retryingCount,
    required this.failedCount,
    required this.totalPending,
  });
}

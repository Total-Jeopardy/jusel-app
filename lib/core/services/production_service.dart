// lib/core/services/production_service.dart

import 'dart:async';

import 'dart:convert';

import '../database/app_database.dart';
import '../database/daos/pending_sync_queue_dao.dart';
import '../database/daos/production_batches_dao.dart';

/// Thrown when production input or processing fails in a business-logic way
/// (validation, impossible values, etc.).
class ProductionServiceException implements Exception {
  final String message;
  ProductionServiceException(this.message);

  @override
  String toString() => 'ProductionServiceException: $message';
}

/// Summary of a created production batch.
class ProductionBatchSummary {
  final int batchId;
  final String productId;
  final int quantityProduced;
  final double totalCost;
  final double unitCost;

  ProductionBatchSummary({
    required this.batchId,
    required this.productId,
    required this.quantityProduced,
    required this.totalCost,
    required this.unitCost,
  });
}

/// High-level, UI-facing abstraction for production / batch operations.
///
/// This wraps [ProductionBatchesDao] and adds:
/// - Input validation
/// - Friendly error messages
/// - Aggregation helpers (average cost, total production value)
class ProductionService {
  final ProductionBatchesDao _productionBatchesDao;
  final PendingSyncQueueDao _syncQueueDao;
  final AppDatabase _db;

  ProductionService(this._productionBatchesDao, this._syncQueueDao, this._db);

  // -----------------------------
  // PUBLIC API
  // -----------------------------

  /// Create a new production batch with detailed cost breakdown.
  ///
  /// - Validates that:
  ///   - [productId] is not empty
  ///   - [quantityProduced] > 0
  ///   - At least one cost component is provided and > 0
  /// - Delegates to [ProductionBatchesDao.createBatch] (or equivalent).
  Future<ProductionBatchSummary> createBatch({
    required String productId,
    required int quantityProduced,
    double? ingredientsCost,
    double? gasCost,
    double? oilCost,
    double? laborCost,
    double? transportCost,
    double? packagingCost,
    double? otherCost,
    String? notes,
    required String createdByUserId,
  }) async {
    // --- Basic validation ---
    if (productId.trim().isEmpty) {
      throw ProductionServiceException('Product ID is required.');
    }

    if (quantityProduced <= 0) {
      throw ProductionServiceException(
        'Quantity produced must be greater than zero.',
      );
    }

    final totalCost = _calculateTotalCost(
      ingredientsCost: ingredientsCost,
      gasCost: gasCost,
      oilCost: oilCost,
      laborCost: laborCost,
      transportCost: transportCost,
      packagingCost: packagingCost,
      otherCost: otherCost,
    );

    if (totalCost <= 0) {
      throw ProductionServiceException(
        'Total batch cost must be greater than zero. '
        'Please enter at least one cost component.',
      );
    }

    try {
      final batchId = await _productionBatchesDao.insertBatch(
        productId: productId,
        quantityProduced: quantityProduced,
        totalCost: totalCost,
        ingredientsCost: ingredientsCost,
        gasCost: gasCost,
        oilCost: oilCost,
        laborCost: laborCost,
        transportCost: transportCost,
        packagingCost: packagingCost,
        otherCost: otherCost,
        notes: notes,
        createdByUserId: createdByUserId,
      );

      final unitCost = totalCost / quantityProduced;

      final product = await _db.productsDao.getProduct(productId);
      final payload = {
        'id': batchId,
        'productId': productId,
        'quantityProduced': quantityProduced,
        'totalCost': totalCost,
        'unitCost': unitCost,
        'ingredientsCost': ingredientsCost,
        'gasCost': gasCost,
        'oilCost': oilCost,
        'laborCost': laborCost,
        'transportCost': transportCost,
        'packagingCost': packagingCost,
        'otherCost': otherCost,
        'notes': notes,
        'productName': product?.name,
        'createdByUserId': createdByUserId,
        'createdAt': DateTime.now().toIso8601String(),
      };

      await _syncQueueDao.enqueueOperation(
        id: batchId.toString(),
        operationType: 'production',
        payload: jsonEncode(payload),
      );

      return ProductionBatchSummary(
        batchId: batchId,
        productId: productId,
        quantityProduced: quantityProduced,
        totalCost: totalCost,
        unitCost: unitCost,
      );
    } catch (e) {
      // Let low-level exceptions bubble up wrapped in a domain-specific one.
      throw ProductionServiceException('Failed to create production batch: $e');
    }
  }

  /// Returns all batch rows for a given product.
  ///
  /// This is a thin wrapper around the DAO; it can be used by ViewModels
  /// to show batch history in the UI.
  Future<List<ProductionBatchesTableData>> getBatchHistory(
    String productId,
  ) async {
    if (productId.trim().isEmpty) {
      throw ProductionServiceException('Product ID is required.');
    }

    try {
      // Assumes your DAO exposes something like:
      //   Future<List<ProductionBatchesTableData>> getBatchesForProduct(String productId);
      return _productionBatchesDao.getBatchesForProduct(productId);
    } catch (e) {
      throw ProductionServiceException('Failed to load batch history: $e');
    }
  }

  /// Computes the *weighted average cost per unit* for all batches
  /// of a given product.
  ///
  /// Formula:
  ///   avgCostPerUnit = SUM(batchTotalCost) / SUM(quantityProduced)
  ///
  /// If there are no batches, returns 0.0.
  Future<double> getAverageBatchCost(String productId) async {
    final batches = await getBatchHistory(productId);

    if (batches.isEmpty) return 0.0;

    double totalUnits = 0;
    double totalCost = 0;

    for (final batch in batches) {
      final units = batch.quantityProduced;
      if (units <= 0) continue;

      final cost = _calculateTotalCostFromRow(batch);

      totalUnits += units;
      totalCost += cost;
    }

    if (totalUnits == 0) return 0.0;

    return totalCost / totalUnits;
  }

  /// Computes the *total production value* across **all** batches,
  /// using the sum of each batch's total cost.
  ///
  /// If no batches exist, returns 0.0.
  Future<double> getTotalProductionValue() async {
    try {
      final allBatches = await _productionBatchesDao.getAllBatches();

      if (allBatches.isEmpty) return 0.0;

      double total = 0;
      for (final batch in allBatches) {
        total += _calculateTotalCostFromRow(batch);
      }

      return total;
    } catch (e) {
      throw ProductionServiceException(
        'Failed to compute total production value: $e',
      );
    }
  }

  // -----------------------------
  // INTERNAL HELPERS
  // -----------------------------

  double _calculateTotalCost({
    double? ingredientsCost,
    double? gasCost,
    double? oilCost,
    double? laborCost,
    double? transportCost,
    double? packagingCost,
    double? otherCost,
  }) {
    double safe(double? v) => v ?? 0.0;

    return safe(ingredientsCost) +
        safe(gasCost) +
        safe(oilCost) +
        safe(laborCost) +
        safe(transportCost) +
        safe(packagingCost) +
        safe(otherCost);
  }

  /// Rebuilds the batch total cost from the row's individual cost columns.
  ///
  /// Falls back to the stored `totalCost` if individual costs are not available.
  double _calculateTotalCostFromRow(ProductionBatchesTableData row) {
    // If individual costs are available, use them (more accurate)
    final hasIndividualCosts =
        row.ingredientsCost != null ||
        row.gasCost != null ||
        row.oilCost != null ||
        row.laborCost != null ||
        row.transportCost != null ||
        row.packagingCost != null ||
        row.otherCost != null;

    if (hasIndividualCosts) {
      double safe(double? v) => v ?? 0.0;
      return safe(row.ingredientsCost) +
          safe(row.gasCost) +
          safe(row.oilCost) +
          safe(row.laborCost) +
          safe(row.transportCost) +
          safe(row.packagingCost) +
          safe(row.otherCost);
    }

    // Otherwise, use the stored totalCost
    return row.totalCost;
  }
}

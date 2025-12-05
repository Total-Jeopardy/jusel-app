import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/production_batches_table.dart';
import '../tables/products_table.dart';
import '../tables/stock_movements_table.dart';

part 'production_batches_dao.g.dart';

@DriftAccessor(
  tables: [ProductionBatchesTable, ProductsTable, StockMovementsTable],
)
class ProductionBatchesDao extends DatabaseAccessor<AppDatabase>
    with _$ProductionBatchesDaoMixin {
  ProductionBatchesDao(AppDatabase db) : super(db);

  /// Insert a new production batch and auto-update product cost + stock.
  Future<int> insertBatch({
    required String productId,
    required int quantityProduced,
    required double totalCost,
    required String createdByUserId,
    double? ingredientsCost,
    double? gasCost,
    double? oilCost,
    double? laborCost,
    double? transportCost,
    double? packagingCost,
    double? otherCost,
    String? notes,
  }) async {
    final unitCost = totalCost / quantityProduced;

    return transaction(() async {
      // 1️⃣ Insert the batch
      final batchId = await into(productionBatchesTable).insert(
        ProductionBatchesTableCompanion.insert(
          productId: productId,
          quantityProduced: quantityProduced,
          ingredientsCost: Value(ingredientsCost),
          gasCost: Value(gasCost),
          oilCost: Value(oilCost),
          laborCost: Value(laborCost),
          transportCost: Value(transportCost),
          packagingCost: Value(packagingCost),
          otherCost: Value(otherCost),
          totalCost: totalCost,
          unitCost: unitCost,
          notes: Value(notes),
        ),
      );

      // 2️⃣ Update the product's current cost price
      await (update(productsTable)..where((p) => p.id.equals(productId))).write(
        ProductsTableCompanion(
          currentCostPrice: Value(unitCost),
          updatedAt: Value(DateTime.now()),
        ),
      );

      // 3️⃣ Auto-create stock movement (Reason = production)
      await into(stockMovementsTable).insert(
        StockMovementsTableCompanion.insert(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          productId: productId,
          type: 'production_output',
          quantityUnits: quantityProduced,
          batchId: Value(batchId.toString()),
          costPerUnit: Value(unitCost),
          totalCost: Value(totalCost),
          reason: const Value('production'),
          createdByUserId: createdByUserId,
          createdAt: DateTime.now(),
        ),
      );

      return batchId;
    });
  }

  /// Fetch all batches for a product (newest first)
  Future<List<ProductionBatchesTableData>> getBatchesForProduct(
    String productId,
  ) {
    return (select(productionBatchesTable)
          ..where((tbl) => tbl.productId.equals(productId))
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]))
        .get();
  }

  /// Fetch all batches across all products (newest first)
  Future<List<ProductionBatchesTableData>> getAllBatches() {
    return (select(
      productionBatchesTable,
    )..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)])).get();
  }

  /// Fetch a single batch by id.
  Future<ProductionBatchesTableData?> getBatch(int id) {
    return (select(productionBatchesTable)..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();
  }
}

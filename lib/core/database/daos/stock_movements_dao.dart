import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/stock_movements_table.dart';
import '../tables/products_table.dart';

part 'stock_movements_dao.g.dart';

@DriftAccessor(tables: [StockMovementsTable, ProductsTable])
class StockMovementsDao extends DatabaseAccessor<AppDatabase>
    with _$StockMovementsDaoMixin {
  StockMovementsDao(AppDatabase db) : super(db);

  /// ----------------------------------------------------
  /// RECORD A SALE
  /// ----------------------------------------------------
  Future<String> recordSale({
    required String productId,
    required int quantity,
    required String createdByUserId,
    required double unitSellingPrice,
    required double unitCostPrice,
    String? movementId,
    DateTime? createdAt,
  }) async {
    final id = movementId ?? DateTime.now().millisecondsSinceEpoch.toString();
    final timestamp = createdAt ?? DateTime.now();
    final totalRevenue = unitSellingPrice * quantity;
    final totalCost = unitCostPrice * quantity;
    final profit = totalRevenue - totalCost;

    await transaction(() async {
      await into(stockMovementsTable).insert(
        StockMovementsTableCompanion.insert(
          id: id,
          productId: productId,
          type: 'sale',
          quantityUnits: quantity,
          sellingPricePerUnit: Value(unitSellingPrice),
          totalRevenue: Value(totalRevenue),
          costPerUnit: Value(unitCostPrice),
          totalCost: Value(totalCost),
          profit: Value(profit),
          reason: const Value('sale'),
          createdByUserId: createdByUserId,
          createdAt: timestamp,
        ),
      );
    });

    return id;
  }

  /// ----------------------------------------------------
  /// RECORD A PURCHASE (restock)
  /// ----------------------------------------------------
  Future<String> recordPurchase({
    required String productId,
    required int quantity,
    required double costPerUnit,
    required String createdByUserId,
    String? movementId,
    DateTime? createdAt,
  }) async {
    final id = movementId ?? DateTime.now().millisecondsSinceEpoch.toString();
    final timestamp = createdAt ?? DateTime.now();

    await transaction(() async {
      final totalCost = quantity * costPerUnit;

      await into(stockMovementsTable).insert(
        StockMovementsTableCompanion.insert(
          id: id,
          productId: productId,
          type: 'stock_in',
          quantityUnits: quantity,
          costPerUnit: Value(costPerUnit),
          totalCost: Value(totalCost),
          reason: const Value('purchase'),
          createdByUserId: createdByUserId,
          createdAt: timestamp,
        ),
      );

      await (update(
        productsTable,
      )..where((tbl) => tbl.id.equals(productId))).write(
        ProductsTableCompanion(
          currentCostPrice: Value(costPerUnit),
          updatedAt: Value(DateTime.now()),
        ),
      );
    });

    return id;
  }

  /// ----------------------------------------------------
  /// MANUAL STOCK ADJUSTMENTS (admin only)
  /// ----------------------------------------------------
  Future<void> increaseStock({
    required String productId,
    required int quantity,
    required String createdByUserId,
    String? movementId,
    DateTime? createdAt,
  }) async {
    final id = movementId ?? DateTime.now().millisecondsSinceEpoch.toString();
    final timestamp = createdAt ?? DateTime.now();

    await into(stockMovementsTable).insert(
      StockMovementsTableCompanion.insert(
        id: id,
        productId: productId,
        type: 'stock_in',
        quantityUnits: quantity,
        reason: const Value('manual_adjustment'),
        createdByUserId: createdByUserId,
        createdAt: timestamp,
      ),
    );
  }

  Future<void> decreaseStock({
    required String productId,
    required int quantity,
    required String createdByUserId,
    String? movementId,
    DateTime? createdAt,
  }) async {
    final id = movementId ?? DateTime.now().millisecondsSinceEpoch.toString();
    final timestamp = createdAt ?? DateTime.now();

    await into(stockMovementsTable).insert(
      StockMovementsTableCompanion.insert(
        id: id,
        productId: productId,
        type: 'stock_out',
        quantityUnits: quantity,
        reason: const Value('manual_adjustment'),
        createdByUserId: createdByUserId,
        createdAt: timestamp,
      ),
    );
  }

  /// ----------------------------------------------------
  /// GET MOVEMENTS FOR A PRODUCT
  /// ----------------------------------------------------
  Future<List<StockMovementsTableData>> getMovementsForProduct(
    String productId,
  ) {
    return (select(stockMovementsTable)
          ..where((tbl) => tbl.productId.equals(productId))
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]))
        .get();
  }

  /// ----------------------------------------------------
  /// GET ALL MOVEMENTS
  /// ----------------------------------------------------
  Future<List<StockMovementsTableData>> getAllMovements() {
    return (select(
      stockMovementsTable,
    )..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)])).get();
  }
}

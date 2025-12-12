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
    String? paymentMethod,
    String? movementId,
    DateTime? createdAt,
    String? reason,
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
          paymentMethod: Value(paymentMethod ?? 'cash'),
          reason: Value(reason ?? 'sale'),
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
  /// GET MOVEMENTS FOR A USER
  /// ----------------------------------------------------
  Future<List<StockMovementsTableData>> getMovementsForUser(String userId) {
    return (select(stockMovementsTable)
          ..where((tbl) => tbl.createdByUserId.equals(userId))
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

  /// ----------------------------------------------------
  /// GET SALES MOVEMENTS BY DATE RANGE
  /// ----------------------------------------------------
  Future<List<StockMovementsTableData>> getSalesByDateRange({
    required DateTime startDate,
    required DateTime endDate,
    String? productId,
    String? category,
    String? paymentMethod,
    String? userId,
  }) async {
    // Normalize dates to start/end of day for inclusive range
    final startOfDay = DateTime(startDate.year, startDate.month, startDate.day);
    final endOfDay = DateTime(
      endDate.year,
      endDate.month,
      endDate.day,
      23,
      59,
      59,
      999,
    );

    final joins = <Join>[];
    if (category != null) {
      joins.add(
        innerJoin(
          productsTable,
          productsTable.id.equalsExp(stockMovementsTable.productId),
        ),
      );
    }

    final query = select(stockMovementsTable).join(joins);

    final predicates = <Expression<bool>>[
      stockMovementsTable.type.equals('sale'),
      stockMovementsTable.createdAt.isBiggerOrEqualValue(startOfDay),
      stockMovementsTable.createdAt.isSmallerOrEqualValue(endOfDay),
    ];

    if (productId != null) {
      predicates.add(stockMovementsTable.productId.equals(productId));
    }
    if (paymentMethod != null) {
      predicates.add(stockMovementsTable.paymentMethod.equals(paymentMethod));
    }
    if (userId != null) {
      predicates.add(stockMovementsTable.createdByUserId.equals(userId));
    }
    if (category != null) {
      predicates.add(productsTable.category.equals(category));
    }

    query.where(predicates.reduce((a, b) => a & b));
    query.orderBy([OrderingTerm.desc(stockMovementsTable.createdAt)]);

    final rows = await query.get();
    return rows.map((row) => row.readTable(stockMovementsTable)).toList();
  }

  /// Get all stock movements (sales, stock_in, production_output, etc.) by date range
  Future<List<StockMovementsTableData>> getAllMovementsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
    String? productId,
    String? category,
  }) async {
    // Normalize dates to start/end of day for inclusive range
    final startOfDay = DateTime(startDate.year, startDate.month, startDate.day);
    final endOfDay = DateTime(
      endDate.year,
      endDate.month,
      endDate.day,
      23,
      59,
      59,
      999,
    );

    final joins = <Join>[];
    if (category != null) {
      joins.add(
        innerJoin(
          productsTable,
          productsTable.id.equalsExp(stockMovementsTable.productId),
        ),
      );
    }

    final query = select(stockMovementsTable).join(joins);

    final predicates = <Expression<bool>>[
      stockMovementsTable.createdAt.isBiggerOrEqualValue(startOfDay),
      stockMovementsTable.createdAt.isSmallerOrEqualValue(endOfDay),
    ];

    if (productId != null) {
      predicates.add(stockMovementsTable.productId.equals(productId));
    }
    if (category != null) {
      predicates.add(productsTable.category.equals(category));
    }

    query.where(predicates.reduce((a, b) => a & b));
    query.orderBy([OrderingTerm.asc(stockMovementsTable.createdAt)]);

    final rows = await query.get();
    return rows.map((row) => row.readTable(stockMovementsTable)).toList();
  }
}

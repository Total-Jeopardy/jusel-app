import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/products_table.dart';
import '../tables/stock_movements_table.dart';

part 'products_dao.g.dart';

@DriftAccessor(tables: [ProductsTable, StockMovementsTable])
class ProductsDao extends DatabaseAccessor<AppDatabase>
    with _$ProductsDaoMixin {
  ProductsDao(AppDatabase db) : super(db);

  /// ----------------------------------------------------
  /// CREATE PRODUCT
  /// ----------------------------------------------------
  Future<String> createProduct({
    required String id,
    required String name,
    required String category,
    required String? subcategory,
    required bool isProduced,
    required double? currentCostPrice,
    required double sellingPrice,
    required int? unitsPerPack,
    required String createdByUserId,
    required int initialStock,
    String status = 'active',
  }) async {
    await into(productsTable).insert(
      ProductsTableCompanion.insert(
        id: id,
        name: name,
        category: category,
        subcategory: Value(subcategory),
        isProduced: isProduced,
        currentCostPrice: currentCostPrice ?? 0.0,
        currentSellingPrice: sellingPrice,
        unitsPerPack: Value(unitsPerPack),
        status: Value(status),
        createdAt: DateTime.now(),
      ),
    );

    // Add initial stock movement if not zero
    if (initialStock != 0) {
      await into(stockMovementsTable).insert(
        StockMovementsTableCompanion.insert(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          productId: id,
          type: 'stock_in',
          quantityUnits: initialStock,
          reason: const Value('initial_stock'),
          createdByUserId: createdByUserId,
          createdAt: DateTime.now(),
        ),
      );
    }

    return id;
  }

  /// ----------------------------------------------------
  /// UPDATE PRODUCT (name, price, status, etc.)
  /// ----------------------------------------------------
  Future<void> updateProduct({
    required String id,
    String? name,
    String? category,
    String? subcategory,
    double? newCostPrice,
    double? newSellingPrice,
    String? status,
  }) async {
    await (update(productsTable)..where((tbl) => tbl.id.equals(id))).write(
      ProductsTableCompanion(
        name: name != null ? Value(name) : const Value.absent(),
        category: category != null ? Value(category) : const Value.absent(),
        subcategory: subcategory != null
            ? Value(subcategory)
            : const Value.absent(),
        currentCostPrice: newCostPrice != null
            ? Value(newCostPrice)
            : const Value.absent(),
        currentSellingPrice: newSellingPrice != null
            ? Value(newSellingPrice)
            : const Value.absent(),
        status: status != null ? Value(status) : const Value.absent(),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// ----------------------------------------------------
  /// STOCK ADJUSTMENTS
  /// ----------------------------------------------------
  Future<void> increaseStock(
    String productId,
    int qty,
    String createdByUserId,
  ) async {
    await into(stockMovementsTable).insert(
      StockMovementsTableCompanion.insert(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        productId: productId,
        type: 'stock_in',
        quantityUnits: qty,
        reason: const Value('manual_adjustment'),
        createdByUserId: createdByUserId,
        createdAt: DateTime.now(),
      ),
    );
  }

  Future<void> decreaseStock(
    String productId,
    int qty,
    String createdByUserId,
  ) async {
    await into(stockMovementsTable).insert(
      StockMovementsTableCompanion.insert(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        productId: productId,
        type: 'stock_out',
        quantityUnits: -qty, // Negative for decrease
        reason: const Value('manual_adjustment'),
        createdByUserId: createdByUserId,
        createdAt: DateTime.now(),
      ),
    );
  }

  /// ----------------------------------------------------
  /// GETTERS
  /// ----------------------------------------------------
  Future<ProductsTableData?> getProduct(String id) async {
    return (select(productsTable)
          ..where((tbl) => tbl.id.equals(id))
          ..limit(1))
        .getSingleOrNull();
  }

  Future<List<ProductsTableData>> getAllProducts() {
    return (select(
      productsTable,
    )..orderBy([(tbl) => OrderingTerm.asc(tbl.name)])).get();
  }

  Future<List<ProductsTableData>> getProductsByCategory(String category) {
    return (select(
      productsTable,
    )..where((tbl) => tbl.category.equals(category))).get();
  }
}

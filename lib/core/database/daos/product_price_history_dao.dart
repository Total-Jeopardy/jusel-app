import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/product_price_history_table.dart';

part 'product_price_history_dao.g.dart';

@DriftAccessor(tables: [ProductPriceHistoryTable])
class ProductPriceHistoryDao extends DatabaseAccessor<AppDatabase>
    with _$ProductPriceHistoryDaoMixin {
  ProductPriceHistoryDao(AppDatabase db) : super(db);

  /// Log a price change to history
  Future<void> logPriceChange(ProductPriceHistoryTableCompanion entry) async {
    await into(productPriceHistoryTable).insert(entry);
  }

  /// Get all price history for a product (newest first)
  Future<List<ProductPriceHistoryTableData>> getHistoryForProduct(
    String productId,
  ) {
    return (select(productPriceHistoryTable)
          ..where((tbl) => tbl.productId.equals(productId))
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]))
        .get();
  }

  /// Get price history for a product within a date range
  Future<List<ProductPriceHistoryTableData>> getHistoryForProductInRange(
    String productId, {
    required DateTime startDate,
    required DateTime endDate,
  }) {
    return (select(productPriceHistoryTable)
          ..where(
            (tbl) =>
                tbl.productId.equals(productId) &
                tbl.createdAt.isBiggerOrEqualValue(startDate) &
                tbl.createdAt.isSmallerOrEqualValue(endDate),
          )
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]))
        .get();
  }

  /// Get average selling price for a product (from history)
  Future<double> getAverageSellingPrice(String productId) async {
    final history = await getHistoryForProduct(productId);

    if (history.isEmpty) return 0.0;

    double total = 0.0;
    int count = 0;

    for (var entry in history) {
      if (entry.newSellingPrice != null) {
        total += entry.newSellingPrice!;
        count++;
      }
    }

    return count > 0 ? total / count : 0.0;
  }

  /// Get latest price change for a product
  Future<ProductPriceHistoryTableData?> getLatestPriceChange(String productId) {
    return (select(productPriceHistoryTable)
          ..where((tbl) => tbl.productId.equals(productId))
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)])
          ..limit(1))
        .getSingleOrNull();
  }

  /// Get price changes in last N days
  Future<List<ProductPriceHistoryTableData>> getRecentPriceChanges({
    int days = 30,
  }) async {
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    return (select(productPriceHistoryTable)
          ..where((tbl) => tbl.createdAt.isBiggerOrEqualValue(cutoffDate))
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]))
        .get();
  }
}

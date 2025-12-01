import 'package:jusel_app/core/database/app_database.dart';

/// InventoryService = read-only calculations based on products + stock movements.
/// This is the "brain" to calculate current stock and inventory value.
class InventoryService {
  final AppDatabase db;

  InventoryService(this.db);

  /// ------------------------------------------------------------
  /// CALCULATE CURRENT STOCK FOR ONE PRODUCT
  /// ------------------------------------------------------------
  Future<int> getCurrentStock(String productId) async {
    final movements = await db.stockMovementsDao.getMovementsForProduct(
      productId,
    );

    int stock = 0;

    for (var mv in movements) {
      // Stock additions
      if (mv.type == 'stock_in' || mv.type == 'production_output') {
        stock += mv.quantityUnits;
      }
      // Stock subtractions
      else if (mv.type == 'stock_out' ||
          mv.type == 'sale' ||
          mv.type == 'adjustment' ||
          mv.type == 'wastage' ||
          mv.type == 'return') {
        stock -= mv.quantityUnits;
      }
    }

    return stock;
  }

  /// ------------------------------------------------------------
  /// CALCULATE CURRENT STOCK FOR ALL PRODUCTS
  /// ------------------------------------------------------------
  Future<Map<String, int>> getAllCurrentStock() async {
    final products = await db.productsDao.getAllProducts();
    final Map<String, int> stockMap = {};

    for (var product in products) {
      stockMap[product.id] = await getCurrentStock(product.id);
    }

    return stockMap;
  }

  /// ------------------------------------------------------------
  /// TOTAL INVENTORY VALUE (cost-based)
  /// ------------------------------------------------------------
  Future<double> getTotalInventoryValue() async {
    final products = await db.productsDao.getAllProducts();

    double total = 0.0;

    for (var product in products) {
      final stock = await getCurrentStock(product.id);
      // currentCostPrice is not nullable, but can be 0.0 if not set
      if (product.currentCostPrice > 0) {
        total += stock * product.currentCostPrice;
      }
    }

    return total;
  }

  /// ------------------------------------------------------------
  /// LOW-STOCK DETECTION (threshold will come from Settings later)
  /// ------------------------------------------------------------
  Future<List<ProductsTableData>> getLowStockProducts({
    int threshold = 5,
  }) async {
    final products = await db.productsDao.getAllProducts();

    List<ProductsTableData> low = [];

    for (var p in products) {
      final stock = await getCurrentStock(p.id);
      if (stock <= threshold) {
        low.add(p);
      }
    }

    return low;
  }
}

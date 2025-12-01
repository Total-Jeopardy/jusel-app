import 'package:jusel_app/core/database/app_database.dart';
import 'package:jusel_app/core/services/inventory_service.dart';

/// Metrics/analytics helpers for dashboards.
class MetricsService {
  final AppDatabase db;
  final InventoryService _inventoryService;

  MetricsService(this.db) : _inventoryService = InventoryService(db);

  Future<int> totalProducts() async {
    final products = await db.productsDao.getAllProducts();
    return products.length;
  }

  Future<int> totalUsers() async {
    final users = await db.usersDao.getAllUsers();
    return users.length;
  }

  Future<double> totalInventoryValue() {
    return _inventoryService.getTotalInventoryValue();
  }

  Future<List<ProductsTableData>> lowStock({int threshold = 5}) {
    return _inventoryService.getLowStockProducts(threshold: threshold);
  }

  Future<int> pendingSyncCount() async {
    final pending = await db.pendingSyncQueueDao.getAllPendingOperations();
    return pending.length;
  }

  Future<int> failedSyncCount() async {
    final failed = await db.pendingSyncQueueDao.getFailedOperations();
    return failed.length;
  }
}

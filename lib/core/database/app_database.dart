import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables/users_table.dart';
import 'tables/products_table.dart';
import 'tables/product_price_history_table.dart';
import 'tables/stock_movements_table.dart';
import 'tables/production_batches_table.dart';
import 'tables/pending_sync_queue_table.dart';
import 'daos/users_dao.dart';
import 'daos/production_batches_dao.dart';
import 'daos/products_dao.dart';
import 'daos/stock_movements_dao.dart';
import 'daos/pending_sync_queue_dao.dart';
import 'daos/product_price_history_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    UsersTable,
    ProductsTable,
    ProductPriceHistoryTable,
    StockMovementsTable,
    ProductionBatchesTable,
    PendingSyncQueueTable,
  ],
  daos: [
    UsersDao,
    ProductionBatchesDao,
    ProductsDao,
    StockMovementsDao,
    PendingSyncQueueDao,
    ProductPriceHistoryDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.addColumn(productsTable, productsTable.imageUrl);
          }

          if (from < 3) {
            // Recreate products table to make currentCostPrice nullable
            // Access the underlying database connection to execute custom SQL
            final db = m.database as dynamic;
            await db.customStatement(
              'ALTER TABLE products_table RENAME TO products_table_old;',
            );
            await m.createTable(productsTable);
            await db.customStatement('''
              INSERT INTO products_table (
                id, name, category, subcategory, image_url, is_produced,
                current_selling_price, current_cost_price, current_stock_qty,
                units_per_pack, status, created_at, updated_at
              )
              SELECT
                id, name, category, subcategory, image_url, is_produced,
                current_selling_price, current_cost_price, current_stock_qty,
                units_per_pack, status, created_at, updated_at
              FROM products_table_old;
            ''');
            await db.customStatement('DROP TABLE products_table_old;');
          }

          if (from < 4) {
            // Add paymentMethod column to stock_movements_table
            await m.addColumn(
              stockMovementsTable,
              stockMovementsTable.paymentMethod,
            );
            // Set default value for existing sale records
            await (m.database as dynamic).customStatement(
              "UPDATE stock_movements_table SET payment_method = 'cash' WHERE type = 'sale' AND payment_method IS NULL;",
            );
          }

          // Ensure all tables exist (in case new tables are added later)
          await m.createAll();
        },
      );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, 'jusel_app.db');
    return NativeDatabase(File(path));
  });
}

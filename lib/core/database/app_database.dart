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
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          // Simple destructive-safe strategy for now: ensure all tables exist.
          // For future schema changes, add targeted migrations here.
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

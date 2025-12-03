import 'package:drift/drift.dart';

class PendingSyncQueueTable extends Table {
  TextColumn get id => text()(); // Operation ID

  TextColumn get operationType => text()(); // sale, restock, production, price_change, product_create, product_update

  TextColumn get payload => text()(); // JSON string containing operation data

  TextColumn get status => text().withDefault(
    const Constant('queued'),
  )(); // queued, retrying, synced, failed

  IntColumn get retries => integer().withDefault(const Constant(0))();

  TextColumn get errorMessage => text().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  DateTimeColumn get lastRetryAt => dateTime().nullable()();

  DateTimeColumn get syncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}






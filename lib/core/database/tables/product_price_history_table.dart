import 'package:drift/drift.dart';

class ProductPriceHistoryTable extends Table {
  // Unique ID for each history entry
  TextColumn get id => text()();

  // The product this change belongs to
  TextColumn get productId => text()();

  // Old and new selling price
  RealColumn get oldSellingPrice => real().nullable()();
  RealColumn get newSellingPrice => real().nullable()();

  // Old and new cost price
  RealColumn get oldCostPrice => real().nullable()();
  RealColumn get newCostPrice => real().nullable()();

  // Type of change: selling_price, cost_price, both
  TextColumn get changeType => text()();

  // Optional: notes or reason (e.g. "new supplier", "price inflation")
  TextColumn get reason => text().nullable()();

  // When the change happened
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

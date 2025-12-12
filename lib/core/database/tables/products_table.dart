import 'package:drift/drift.dart';

class ProductsTable extends Table {
  TextColumn get id => text()(); // Firestore product ID

  TextColumn get name => text()();
  TextColumn get category => text()(); // snack, drink, water
  TextColumn get subcategory => text().nullable()();
  // e.g. locally_made, purchased, sachet_water, bottle
  TextColumn get imageUrl => text().nullable()();

  BoolColumn get isProduced => boolean()();
  // true = snacks and locally made drinks

  RealColumn get currentSellingPrice => real()();
  RealColumn get currentCostPrice => real().nullable()();
  // Set by restock/production; null until first cost is recorded

  IntColumn get currentStockQty =>
      integer().withDefault(const Constant(0))(); // in units

  IntColumn get unitsPerPack => integer().nullable()();
  // for drinks/water packs; null for snacks

  TextColumn get status => text().withDefault(
    const Constant('active'),
  )(); // active/inactive/sold_out

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

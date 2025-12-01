import 'package:drift/drift.dart';

class ProductsTable extends Table {
  TextColumn get id => text()(); // Firestore product ID

  TextColumn get name => text()();
  TextColumn get category => text()(); // snack, drink, water
  TextColumn get subcategory => text().nullable()();
  // soft_drink, local_drink (for drinks only)

  BoolColumn get isProduced => boolean()();
  // true = locally made snacks / local drinks (juices)

  RealColumn get currentSellingPrice => real()();
  RealColumn get currentCostPrice => real()();
  // Last batch cost (Option B)

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

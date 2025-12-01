import 'package:drift/drift.dart';

class ProductionBatchesTable extends Table {
  IntColumn get id => integer().autoIncrement()();

  // Product reference
  TextColumn get productId => text()();

  // How many units were produced in this batch
  IntColumn get quantityProduced => integer()();

  // -----------------------------
  // ADVANCED COST BREAKDOWN
  // -----------------------------

  // Raw ingredients (flour, sugar, milk, etc.)
  RealColumn get ingredientsCost => real().nullable()();

  // Cooking gas / electricity
  RealColumn get gasCost => real().nullable()();

  // Oil (for frying)
  RealColumn get oilCost => real().nullable()();

  // Labor (helper/apprentice time)
  RealColumn get laborCost => real().nullable()();

  // Transportation (to market or suppliers)
  RealColumn get transportCost => real().nullable()();

  // Packaging (rubber, boxes, wrappers)
  RealColumn get packagingCost => real().nullable()();

  // Any other cost
  RealColumn get otherCost => real().nullable()();

  // -----------------------------
  // AGGREGATED FIELDS
  // -----------------------------

  // Total of all cost components
  RealColumn get totalCost => real()();

  // Cost per one item (totalCost / quantityProduced)
  RealColumn get unitCost => real()();

  // Profit per batch (optional, computed at time of creation)
  RealColumn get batchProfit => real().nullable()();

  // Timestamp
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  // Notes / description
  TextColumn get notes => text().nullable()();
}

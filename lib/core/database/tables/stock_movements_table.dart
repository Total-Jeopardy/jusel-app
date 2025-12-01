import 'package:drift/drift.dart';

class StockMovementsTable extends Table {
  TextColumn get id => text()(); // Movement ID (UUID)

  TextColumn get productId => text()(); // FK → ProductsTable

  // Movement type: stock_in, production_output, sale, adjustment, wastage, return
  TextColumn get type => text()();

  // Quantity in units (positive for addition, negative for subtraction)
  IntColumn get quantityUnits => integer()();

  // For drinks/water: number of packs (nullable)
  IntColumn get quantityPacks => integer().nullable()();

  // For snacks/local drinks: which production batch created the stock?
  TextColumn get batchId => text().nullable()();

  // Cost per unit at the time of movement (optional)
  RealColumn get costPerUnit => real().nullable()();

  // Total cost = quantityUnits * costPerUnit
  RealColumn get totalCost => real().nullable()();

  // Selling price snapshot per unit (for sales)
  RealColumn get sellingPricePerUnit => real().nullable()();

  // Total revenue for sales
  RealColumn get totalRevenue => real().nullable()();

  // Profit for sales
  RealColumn get profit => real().nullable()();

  // Optional reason (e.g., "expired", "correction", "apprentice return")
  TextColumn get reason => text().nullable()();

  // Who performed the action
  TextColumn get createdByUserId => text()();

  // Timestamp
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}


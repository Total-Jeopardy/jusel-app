import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jusel_app/core/database/app_database.dart';
import 'package:jusel_app/core/providers/database_provider.dart';
import 'package:collection/collection.dart';

class SalesHistoryEntry {
  final String productId;
  final int totalSold;
  final DateTime? lastSoldAt;

  const SalesHistoryEntry({
    required this.productId,
    required this.totalSold,
    required this.lastSoldAt,
  });
}

/// Aggregated sales history for filtering/sorting products on the sales screen.
final salesHistoryProvider =
    FutureProvider<List<SalesHistoryEntry>>((ref) async {
  final db = ref.read(appDatabaseProvider);
  final movements = await db.stockMovementsDao.getAllMovements();
  final salesMovements =
      movements.where((m) => m.type == 'sale').toList(growable: false);

  final grouped = groupBy<StockMovementsTableData, String>(
    salesMovements,
    (m) => m.productId,
  );

  return grouped.entries.map((entry) {
    final totalQty =
        entry.value.fold<int>(0, (sum, m) => sum + m.quantityUnits);
    final lastDate = entry.value
        .map((m) => m.createdAt)
        .whereType<DateTime>()
        .fold<DateTime?>(null, (prev, curr) {
      if (prev == null) return curr;
      return curr.isAfter(prev) ? curr : prev;
    });
    return SalesHistoryEntry(
      productId: entry.key,
      totalSold: totalQty.abs(),
      lastSoldAt: lastDate,
    );
  }).toList();
});

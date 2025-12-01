import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jusel_app/core/services/inventory_service.dart';
import 'package:jusel_app/core/services/metrics_service.dart';
import 'package:jusel_app/core/services/restock_service.dart';
import 'package:jusel_app/core/services/sales_service.dart';
import 'package:jusel_app/core/sync/sync_orchestrator.dart';
import 'package:jusel_app/core/utils/theme.dart';
import 'package:jusel_app/core/providers/database_provider.dart';

/// Theme state class
class ThemeState {
  final AppThemeMode mode;

  ThemeState({required this.mode});

  ThemeState copyWith({AppThemeMode? mode}) {
    return ThemeState(mode: mode ?? this.mode);
  }
}

/// Theme provider
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<ThemeState> {
  ThemeNotifier() : super(ThemeState(mode: AppThemeMode.system));

  void setThemeMode(AppThemeMode mode) {
    state = state.copyWith(mode: mode);
  }
}

// Router provider is imported from router.dart

/// Sync orchestrator (Firestore + Drift queue)
final syncOrchestratorProvider = Provider<SyncOrchestrator>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final syncDao = ref.watch(pendingSyncQueueDaoProvider);
  return SyncOrchestrator(
    db: db,
    firestore: FirebaseFirestore.instance,
    syncQueueDao: syncDao,
  );
});

/// Inventory and metrics helpers
final inventoryServiceProvider = Provider<InventoryService>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return InventoryService(db);
});

final metricsServiceProvider = Provider<MetricsService>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return MetricsService(db);
});

/// Sales and restock services wired to sync queue
final salesServiceProvider = Provider<SalesService>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final inventory = ref.watch(inventoryServiceProvider);
  final syncDao = ref.watch(pendingSyncQueueDaoProvider);
  return SalesService(db: db, inventoryService: inventory, syncQueueDao: syncDao);
});

final restockServiceProvider = Provider<RestockService>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final syncDao = ref.watch(pendingSyncQueueDaoProvider);
  return RestockService(db, syncDao);
});


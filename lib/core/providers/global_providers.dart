import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jusel_app/core/services/inventory_service.dart';
import 'package:jusel_app/core/services/metrics_service.dart';
import 'package:jusel_app/core/services/periodic_sync_service.dart';
import 'package:jusel_app/core/services/restock_service.dart';
import 'package:jusel_app/core/services/sales_service.dart';
import 'package:jusel_app/core/services/settings_service.dart';
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
  ThemeNotifier() : super(ThemeState(mode: AppThemeMode.system)) {
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedMode = prefs.getString('theme_mode');
      if (savedMode != null) {
        final mode = _parseThemeMode(savedMode);
        if (mode != null) {
          state = ThemeState(mode: mode);
        }
      }
    } catch (e) {
      // If loading fails, keep default (system)
      print('Failed to load theme preference: $e');
    }
  }

  AppThemeMode? _parseThemeMode(String value) {
    switch (value) {
      case 'light':
        return AppThemeMode.light;
      case 'dark':
        return AppThemeMode.dark;
      case 'system':
        return AppThemeMode.system;
      default:
        return null;
    }
  }

  String _themeModeToString(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return 'light';
      case AppThemeMode.dark:
        return 'dark';
      case AppThemeMode.system:
        return 'system';
    }
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    state = state.copyWith(mode: mode);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('theme_mode', _themeModeToString(mode));
    } catch (e) {
      print('Failed to save theme preference: $e');
      // Continue anyway - theme is still updated in memory
    }
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
  return SalesService(
    db: db,
    inventoryService: inventory,
    syncQueueDao: syncDao,
  );
});

final restockServiceProvider = Provider<RestockService>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final syncDao = ref.watch(pendingSyncQueueDaoProvider);
  return RestockService(db, syncDao);
});

/// SharedPreferences provider
final sharedPreferencesProvider = FutureProvider<SharedPreferences>((
  ref,
) async {
  return SharedPreferences.getInstance();
});

/// SettingsService provider
final settingsServiceProvider = FutureProvider<SettingsService>((ref) async {
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  return SettingsService(prefs);
});

/// Connectivity provider - checks if device is online
final connectivityProvider = StreamProvider.autoDispose<bool>((ref) {
  final controller = StreamController<bool>.broadcast();
  Timer? timer;

  controller.add(true); // Assume online initially

  Future.microtask(() async {
    await Future.delayed(const Duration(milliseconds: 1000)); // Delay check
    final syncOrchestrator = ref.read(syncOrchestratorProvider);

    timer = Timer.periodic(const Duration(seconds: 3), (t) async {
      if (controller.isClosed) {
        t.cancel();
        return;
      }
      try {
        final isOnline = await syncOrchestrator.isOnline();
        if (!controller.isClosed) {
          controller.add(isOnline);
        }
      } catch (e) {
        if (!controller.isClosed) {
          controller.add(false);
        }
      }
    });
  });

  ref.onDispose(() {
    timer?.cancel();
    controller.close();
  });

  return controller.stream;
});

/// Periodic sync service provider
final periodicSyncServiceProvider = Provider<PeriodicSyncService>((ref) {
  final service = PeriodicSyncService(ref);

  // Auto-start when provider is created (after first frame to avoid blocking)
  // Use a delayed future to ensure it doesn't block app startup
  Future.delayed(const Duration(milliseconds: 500), () {
    service.start();
  });

  // Clean up when provider is disposed
  ref.onDispose(() {
    service.dispose();
  });

  return service;
});

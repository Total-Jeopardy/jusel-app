import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jusel_app/core/database/app_database.dart';
import 'package:jusel_app/core/providers/database_provider.dart';
import 'package:jusel_app/core/providers/global_providers.dart';
import 'package:jusel_app/features/auth/viewmodel/auth_viewmodel.dart';

/// Service for resetting/clearing all app data
class ResetService {
  final AppDatabase _db;
  final Ref _ref;

  ResetService(this._db, this._ref);

  /// Reset all app data (local database, settings, and sign out)
  /// 
  /// This will:
  /// 1. Stop periodic sync and cancel all timers
  /// 2. Clear all local database tables (transactional)
  /// 3. Clear SharedPreferences (settings)
  /// 4. Delete database file
  /// 5. Sign out the current user
  /// 
  /// WARNING: This action cannot be undone!
  Future<void> resetAllData() async {
    try {
      // 1. Stop periodic sync FIRST to prevent any background operations
      try {
        final periodicSync = _ref.read(periodicSyncServiceProvider);
        periodicSync.stop();
      } catch (_) {
        // Ignore if service not initialized
      }

      // 2. Clear all database tables (transactional for atomicity)
      await _clearDatabase();

      // 3. Clear SharedPreferences
      await _clearSharedPreferences();

      // 4. Delete database file (after clearing to ensure clean state)
      await _deleteDatabaseFile();

      // 5. Sign out user (last step to ensure clean logout)
      try {
        final authViewModel = _ref.read(authViewModelProvider.notifier);
        await authViewModel.signOut();
      } catch (_) {
        // Try Firebase auth directly if viewmodel fails
        await FirebaseAuth.instance.signOut();
      }
    } catch (e) {
      print('[ResetService] Error during reset: $e');
      rethrow;
    }
  }

  /// Clear all data from database tables
  Future<void> _clearDatabase() async {
    await _db.transaction(() async {
      // Delete all records from all tables
      await _db.delete(_db.usersTable).go();
      await _db.delete(_db.productsTable).go();
      await _db.delete(_db.stockMovementsTable).go();
      await _db.delete(_db.productionBatchesTable).go();
      await _db.delete(_db.pendingSyncQueueTable).go();
      await _db.delete(_db.productPriceHistoryTable).go();
    });
  }

  /// Clear all SharedPreferences
  Future<void> _clearSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  /// Delete the database file
  Future<void> _deleteDatabaseFile() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final dbPath = p.join(dir.path, 'jusel_app.db');
      final dbFile = File(dbPath);
      if (await dbFile.exists()) {
        await dbFile.delete();
      }
    } catch (e) {
      // Database file might not exist or already deleted
      print('[ResetService] Could not delete database file: $e');
    }
  }

  /// Reset only local database (keep settings and auth)
  Future<void> resetDatabaseOnly() async {
    try {
      await _clearDatabase();
    } catch (e) {
      print('[ResetService] Error resetting database: $e');
      rethrow;
    }
  }
}

/// Provider for ResetService
final resetServiceProvider = Provider<ResetService>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return ResetService(db, ref);
});


import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:jusel_app/core/database/app_database.dart';
import 'package:jusel_app/core/providers/database_provider.dart';
import 'package:jusel_app/core/providers/global_providers.dart';
import 'package:jusel_app/core/sync/sync_orchestrator.dart';
import 'package:jusel_app/features/auth/viewmodel/auth_viewmodel.dart';

/// Service for backing up and restoring app data
class BackupService {
  final AppDatabase _db;
  final Ref _ref;

  BackupService(this._db, this._ref);

  static const String _backupVersion = '1.0';
  static const int _maxBackupSizeMB = 50; // Max 50MB backup file

  /// Create a backup of all app data
  /// Returns the backup data as a JSON string
  /// Includes current user ID for validation on restore
  Future<String> createBackup() async {
    try {
      // Get current user ID for scoping
      final user = _ref.read(authViewModelProvider).value;
      if (user == null) {
        throw Exception('Must be signed in to create backup');
      }

      // Fetch all data from database
      final users = await _db.usersDao.getAllUsers();
      final products = await _db.productsDao.getAllProducts();
      final stockMovements = await _db.stockMovementsDao.getAllMovements();
      final productionBatches = await _db.productionBatchesDao.getAllBatches();
      final priceHistory = await _db.productPriceHistoryDao.getAllHistory();
      // Note: We exclude pendingSync from backup to avoid resending stale operations

      // Convert to JSON-serializable format
      final backupData = {
        'version': _backupVersion,
        'createdAt': DateTime.now().toIso8601String(),
        'userId': user.uid, // Scope backup to current user
        'userEmail': user.email, // For display purposes only
        'data': {
          'users': users.map((u) => _userToJson(u)).toList(),
          'products': products.map((p) => _productToJson(p)).toList(),
          'stockMovements': stockMovements.map((m) => _stockMovementToJson(m)).toList(),
          'productionBatches': productionBatches.map((b) => _productionBatchToJson(b)).toList(),
          'priceHistory': priceHistory.map((h) => _priceHistoryToJson(h)).toList(),
          // Intentionally exclude pendingSync to avoid resending stale operations
        },
      };

      final jsonString = jsonEncode(backupData);
      
      // Calculate checksum for integrity verification
      final bytes = utf8.encode(jsonString);
      final digest = sha256.convert(bytes);
      final checksum = digest.toString();

      // Add checksum to backup
      final backupWithChecksum = {
        ...backupData,
        'checksum': checksum,
      };

      return jsonEncode(backupWithChecksum);
    } catch (e) {
      throw Exception('Failed to create backup: $e');
    }
  }

  /// Save backup to a file and share it
  Future<void> exportBackup() async {
    try {
      final backupJson = await createBackup();
      
      // Check file size
      final sizeInMB = utf8.encode(backupJson).length / (1024 * 1024);
      if (sizeInMB > _maxBackupSizeMB) {
        throw Exception(
          'Backup file is too large (${sizeInMB.toStringAsFixed(1)}MB). '
          'Maximum size is ${_maxBackupSizeMB}MB.',
        );
      }
      
      // Get temporary directory
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final fileName = 'jusel_backup_$timestamp.json';
      final file = File('${tempDir.path}/$fileName');
      
      // Write backup to file
      await file.writeAsString(backupJson);
      
      // Share the file
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Jusel App Backup',
      );
    } catch (e) {
      throw Exception('Failed to export backup: $e');
    }
  }

  /// Import backup from a file
  Future<void> importBackup() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.single.path == null) {
        throw Exception('No file selected');
      }

      final file = File(result.files.single.path!);
      
      // Check file size before reading
      final fileSize = await file.length();
      final sizeInMB = fileSize / (1024 * 1024);
      if (sizeInMB > _maxBackupSizeMB) {
        throw Exception(
          'Backup file is too large (${sizeInMB.toStringAsFixed(1)}MB). '
          'Maximum size is ${_maxBackupSizeMB}MB.',
        );
      }

      final backupJson = await file.readAsString();
      
      await restoreBackup(backupJson);
    } on FileSystemException catch (e) {
      throw Exception('Failed to read backup file. Please check file permissions: $e');
    } catch (e) {
      if (e.toString().contains('too large')) {
        rethrow;
      }
      throw Exception('Failed to import backup: $e');
    }
  }

  /// Restore data from a backup JSON string
  Future<void> restoreBackup(String backupJson) async {
    try {
      // Validate JSON format
      Map<String, dynamic> backupData;
      try {
        backupData = jsonDecode(backupJson) as Map<String, dynamic>;
      } catch (e) {
        throw Exception('Invalid JSON format: $e');
      }
      
      // Validate backup structure
      if (backupData['version'] == null) {
        throw Exception('Invalid backup: missing version');
      }
      if (backupData['data'] == null) {
        throw Exception('Invalid backup: missing data');
      }

      // Validate version compatibility
      final version = backupData['version'] as String;
      if (version != _backupVersion) {
        throw Exception(
          'Backup version mismatch. Expected $_backupVersion, got $version. '
          'Please use a backup created with this app version.',
        );
      }

      // Validate checksum if present
      if (backupData['checksum'] != null) {
        final expectedChecksum = backupData['checksum'] as String;
        
        // Recalculate without checksum field for validation
        final dataWithoutChecksum = Map<String, dynamic>.from(backupData);
        dataWithoutChecksum.remove('checksum');
        final jsonWithoutChecksum = jsonEncode(dataWithoutChecksum);
        final bytesWithoutChecksum = utf8.encode(jsonWithoutChecksum);
        final digestWithoutChecksum = sha256.convert(bytesWithoutChecksum);
        final calculatedChecksum = digestWithoutChecksum.toString();
        
        if (expectedChecksum != calculatedChecksum) {
          throw Exception('Backup file is corrupted or modified. Checksum mismatch.');
        }
      }

      // Validate user scoping
      final currentUser = _ref.read(authViewModelProvider).value;
      if (currentUser == null) {
        throw Exception('Must be signed in to restore backup');
      }

      final backupUserId = backupData['userId'] as String?;
      if (backupUserId != null && backupUserId != currentUser.uid) {
        final backupEmail = backupData['userEmail'] as String? ?? 'unknown';
        throw Exception(
          'This backup belongs to a different user ($backupEmail). '
          'You can only restore backups created by your account.',
        );
      }

      final data = backupData['data'] as Map<String, dynamic>;

      // Restore in transaction
      await _db.transaction(() async {
        // Clear existing data first (including pending sync queue to avoid stale operations)
        await _db.delete(_db.usersTable).go();
        await _db.delete(_db.productsTable).go();
        await _db.delete(_db.stockMovementsTable).go();
        await _db.delete(_db.productionBatchesTable).go();
        await _db.delete(_db.pendingSyncQueueTable).go(); // Clear to avoid resending stale operations
        await _db.delete(_db.productPriceHistoryTable).go();

        // Restore users
        if (data['users'] != null) {
          final users = data['users'] as List;
          for (final userJson in users) {
            await _db.into(_db.usersTable).insertOnConflictUpdate(_userFromJson(userJson));
          }
        }

        // Restore products
        if (data['products'] != null) {
          final products = data['products'] as List;
          for (final productJson in products) {
            await _db.into(_db.productsTable).insertOnConflictUpdate(_productFromJson(productJson));
          }
        }

        // Restore stock movements
        if (data['stockMovements'] != null) {
          final movements = data['stockMovements'] as List;
          for (final movementJson in movements) {
            await _db.into(_db.stockMovementsTable).insertOnConflictUpdate(_stockMovementFromJson(movementJson));
          }
        }

        // Restore production batches
        if (data['productionBatches'] != null) {
          final batches = data['productionBatches'] as List;
          for (final batchJson in batches) {
            await _db.into(_db.productionBatchesTable).insertOnConflictUpdate(_productionBatchFromJson(batchJson));
          }
        }

        // Restore price history
        if (data['priceHistory'] != null) {
          final history = data['priceHistory'] as List;
          for (final historyJson in history) {
            await _db.into(_db.productPriceHistoryTable).insertOnConflictUpdate(_priceHistoryFromJson(historyJson));
          }
        }

        // Intentionally skip restoring pendingSync queue to avoid resending stale operations
        // The sync queue will be rebuilt as new operations are performed
      });

      // Trigger post-restore actions
      await _postRestoreActions();
    } catch (e) {
      throw Exception('Failed to restore backup: $e');
    }
  }

  /// Post-restore actions: trigger sync and refresh providers
  Future<void> _postRestoreActions() async {
    try {
      final user = _ref.read(authViewModelProvider).value;
      if (user == null) return;

      final orchestrator = _ref.read(syncOrchestratorProvider);
      
      // If online, trigger a full sync to push restored data to Firestore
      if (await orchestrator.isOnline()) {
        // Pull first to get latest from Firestore, then push local changes
        final pullResult = await orchestrator.pullAllForUser(user.uid);
        final pushResult = await orchestrator.syncAll();
        
        // Only update timestamp if both operations succeeded
        final bothSucceeded = pullResult.status != SyncStatus.error &&
            pullResult.status != SyncStatus.offline &&
            pushResult.status != SyncStatus.error &&
            pushResult.status != SyncStatus.offline;
        
        if (bothSucceeded) {
          final settingsService = await _ref.read(settingsServiceProvider.future);
          await settingsService.setLastSyncedAt(DateTime.now());
        }
      }

      // Invalidate providers to refresh UI
      // Note: This will be handled by the UI layer calling ref.invalidate()
    } catch (e) {
      // Log but don't fail restore
      print('[BackupService] Post-restore sync failed: $e');
    }
  }

  // JSON conversion helpers
  Map<String, dynamic> _userToJson(dynamic user) {
    return {
      'id': user.id,
      'name': user.name,
      'phone': user.phone,
      'email': user.email,
      'role': user.role,
      'isActive': user.isActive ? 1 : 0,
      'createdAt': user.createdAt.toIso8601String(),
      'updatedAt': user.updatedAt?.toIso8601String(),
    };
  }

  UsersTableCompanion _userFromJson(Map<String, dynamic> json) {
    return UsersTableCompanion.insert(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      isActive: Value((json['isActive'] as num) == 1),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? Value(DateTime.parse(json['updatedAt'] as String))
          : const Value.absent(),
    );
  }

  Map<String, dynamic> _productToJson(dynamic product) {
    return {
      'id': product.id,
      'name': product.name,
      'category': product.category,
      'subcategory': product.subcategory,
      'imageUrl': product.imageUrl,
      'isProduced': product.isProduced,
      'currentSellingPrice': product.currentSellingPrice,
      'currentCostPrice': product.currentCostPrice,
      'currentStockQty': product.currentStockQty,
      'unitsPerPack': product.unitsPerPack,
      'status': product.status,
      'createdAt': product.createdAt.toIso8601String(),
      'updatedAt': product.updatedAt?.toIso8601String(),
    };
  }

  ProductsTableCompanion _productFromJson(Map<String, dynamic> json) {
    return ProductsTableCompanion.insert(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      subcategory: Value(json['subcategory'] as String?),
      imageUrl: Value(json['imageUrl'] as String?),
      isProduced: json['isProduced'] as bool? ?? false,
      currentSellingPrice: (json['currentSellingPrice'] as num).toDouble(),
      currentCostPrice: Value((json['currentCostPrice'] as num?)?.toDouble()),
      currentStockQty: Value((json['currentStockQty'] as num).toInt()),
      unitsPerPack: Value((json['unitsPerPack'] as num?)?.toInt()),
      status: Value(json['status'] as String? ?? 'active'),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? Value(DateTime.parse(json['updatedAt'] as String))
          : const Value.absent(),
    );
  }

  Map<String, dynamic> _stockMovementToJson(dynamic movement) {
    return {
      'id': movement.id,
      'productId': movement.productId,
      'type': movement.type,
      'quantityUnits': movement.quantityUnits,
      'sellingPricePerUnit': movement.sellingPricePerUnit,
      'costPerUnit': movement.costPerUnit,
      'totalRevenue': movement.totalRevenue,
      'totalCost': movement.totalCost,
      'profit': movement.profit,
      'paymentMethod': movement.paymentMethod,
      'reason': movement.reason,
      'createdByUserId': movement.createdByUserId,
      'createdAt': movement.createdAt.toIso8601String(),
      'batchId': movement.batchId,
    };
  }

  StockMovementsTableCompanion _stockMovementFromJson(Map<String, dynamic> json) {
    return StockMovementsTableCompanion.insert(
      id: json['id'] as String,
      productId: json['productId'] as String,
      type: json['type'] as String,
      quantityUnits: (json['quantityUnits'] as num).toInt(),
      sellingPricePerUnit: Value((json['sellingPricePerUnit'] as num?)?.toDouble()),
      costPerUnit: Value((json['costPerUnit'] as num?)?.toDouble()),
      totalRevenue: Value((json['totalRevenue'] as num?)?.toDouble()),
      totalCost: Value((json['totalCost'] as num?)?.toDouble()),
      profit: Value((json['profit'] as num?)?.toDouble()),
      paymentMethod: Value(json['paymentMethod'] as String?),
      reason: Value(json['reason'] as String?),
      createdByUserId: json['createdByUserId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      batchId: Value(json['batchId'] as String?),
    );
  }

  Map<String, dynamic> _productionBatchToJson(dynamic batch) {
    return {
      'id': batch.id,
      'productId': batch.productId,
      'quantityProduced': batch.quantityProduced,
      'ingredientsCost': batch.ingredientsCost,
      'gasCost': batch.gasCost,
      'oilCost': batch.oilCost,
      'laborCost': batch.laborCost,
      'transportCost': batch.transportCost,
      'packagingCost': batch.packagingCost,
      'otherCost': batch.otherCost,
      'unitCost': batch.unitCost,
      'totalCost': batch.totalCost,
      'batchProfit': batch.batchProfit,
      'notes': batch.notes,
      'createdAt': batch.createdAt.toIso8601String(),
    };
  }

  ProductionBatchesTableCompanion _productionBatchFromJson(Map<String, dynamic> json) {
    return ProductionBatchesTableCompanion.insert(
      productId: json['productId'] as String,
      quantityProduced: (json['quantityProduced'] as num).toInt(),
      ingredientsCost: Value((json['ingredientsCost'] as num?)?.toDouble()),
      gasCost: Value((json['gasCost'] as num?)?.toDouble()),
      oilCost: Value((json['oilCost'] as num?)?.toDouble()),
      laborCost: Value((json['laborCost'] as num?)?.toDouble()),
      transportCost: Value((json['transportCost'] as num?)?.toDouble()),
      packagingCost: Value((json['packagingCost'] as num?)?.toDouble()),
      otherCost: Value((json['otherCost'] as num?)?.toDouble()),
      unitCost: (json['unitCost'] as num).toDouble(),
      totalCost: (json['totalCost'] as num).toDouble(),
      batchProfit: Value((json['batchProfit'] as num?)?.toDouble()),
      notes: Value(json['notes'] as String?),
      createdAt: Value(DateTime.parse(json['createdAt'] as String)),
    );
  }

  Map<String, dynamic> _priceHistoryToJson(dynamic history) {
    return {
      'id': history.id,
      'productId': history.productId,
      'oldSellingPrice': history.oldSellingPrice,
      'newSellingPrice': history.newSellingPrice,
      'oldCostPrice': history.oldCostPrice,
      'newCostPrice': history.newCostPrice,
      'changeType': history.changeType,
      'reason': history.reason,
      'createdAt': history.createdAt.toIso8601String(),
    };
  }

  ProductPriceHistoryTableCompanion _priceHistoryFromJson(Map<String, dynamic> json) {
    return ProductPriceHistoryTableCompanion.insert(
      id: json['id'] as String,
      productId: json['productId'] as String,
      oldSellingPrice: Value((json['oldSellingPrice'] as num?)?.toDouble()),
      newSellingPrice: Value((json['newSellingPrice'] as num?)?.toDouble()),
      oldCostPrice: Value((json['oldCostPrice'] as num?)?.toDouble()),
      newCostPrice: Value((json['newCostPrice'] as num?)?.toDouble()),
      changeType: json['changeType'] as String,
      reason: Value(json['reason'] as String?),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

}

/// Provider for BackupService
final backupServiceProvider = Provider<BackupService>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return BackupService(db, ref);
});


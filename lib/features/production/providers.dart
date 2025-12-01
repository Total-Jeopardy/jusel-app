import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/production_service.dart';
import '../../../core/database/daos/production_batches_dao.dart';
import '../../../core/providers/database_provider.dart';
import 'viewmodel/production_state.dart';
import 'viewmodel/production_viewmodel.dart';

// Database DAO provider
final productionBatchesDaoProvider = Provider<ProductionBatchesDao>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return ProductionBatchesDao(db);
});

// ProductionService provider
final productionServiceProvider = Provider<ProductionService>((ref) {
  final dao = ref.watch(productionBatchesDaoProvider);
  final syncDao = ref.watch(pendingSyncQueueDaoProvider);
  final db = ref.watch(appDatabaseProvider);
  return ProductionService(dao, syncDao, db);
});

// ViewModel provider
final productionViewModelProvider =
    StateNotifierProvider<ProductionViewModel, ProductionState>((ref) {
      final service = ref.watch(productionServiceProvider);
      return ProductionViewModel(service);
    });

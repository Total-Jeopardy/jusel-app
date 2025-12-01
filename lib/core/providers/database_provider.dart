import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jusel_app/core/database/app_database.dart';
import 'package:jusel_app/core/database/daos/users_dao.dart';
import 'package:jusel_app/core/database/daos/pending_sync_queue_dao.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

final usersDaoProvider = Provider<UsersDao>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return UsersDao(db);
});

final pendingSyncQueueDaoProvider = Provider<PendingSyncQueueDao>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return PendingSyncQueueDao(db);
});

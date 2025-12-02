import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/pending_sync_queue_table.dart';

part 'pending_sync_queue_dao.g.dart';

@DriftAccessor(tables: [PendingSyncQueueTable])
class PendingSyncQueueDao extends DatabaseAccessor<AppDatabase>
    with _$PendingSyncQueueDaoMixin {
  PendingSyncQueueDao(AppDatabase db) : super(db);

  /// Get all pending operations (queued or retrying)
  Future<List<PendingSyncQueueTableData>> getAllPendingOperations() async {
    return (select(pendingSyncQueueTable)
          ..where((t) => t.status.isIn(['queued', 'retrying']))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();
  }

  /// Get queued operations
  Future<List<PendingSyncQueueTableData>> getQueuedOperations() async {
    return (select(pendingSyncQueueTable)
          ..where((t) => t.status.equals('queued'))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();
  }

  /// Get retrying operations
  Future<List<PendingSyncQueueTableData>> getRetryingOperations() async {
    return (select(pendingSyncQueueTable)
          ..where((t) => t.status.equals('retrying'))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();
  }

  /// Get failed operations
  Future<List<PendingSyncQueueTableData>> getFailedOperations() async {
    return (select(pendingSyncQueueTable)
          ..where((t) => t.status.equals('failed'))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();
  }

  /// Get operation by ID
  Future<PendingSyncQueueTableData?> getOperationById(String id) async {
    return (select(pendingSyncQueueTable)
          ..where((t) => t.id.equals(id))
          ..limit(1))
        .getSingleOrNull();
  }

  /// Mark operation as retrying
  Future<void> markAsRetrying(String id) async {
    await (update(pendingSyncQueueTable)..where((t) => t.id.equals(id))).write(
      PendingSyncQueueTableCompanion(
        status: const Value('retrying'),
        lastRetryAt: Value(DateTime.now()),
      ),
    );
  }

  /// Mark operation as synced
  Future<void> markAsSynced(String id) async {
    await (update(pendingSyncQueueTable)..where((t) => t.id.equals(id))).write(
      PendingSyncQueueTableCompanion(
        status: const Value('synced'),
        syncedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Mark operation as failed
  Future<void> markAsFailed(String id, String errorMessage) async {
    await (update(pendingSyncQueueTable)..where((t) => t.id.equals(id))).write(
      PendingSyncQueueTableCompanion(
        status: const Value('failed'),
        errorMessage: Value(errorMessage),
      ),
    );
  }

  /// Increment retry count
  Future<void> incrementRetries(String id) async {
    final operation = await getOperationById(id);
    if (operation != null) {
      await (update(
        pendingSyncQueueTable,
      )..where((t) => t.id.equals(id))).write(
        PendingSyncQueueTableCompanion(
          retries: Value(operation.retries + 1),
          lastRetryAt: Value(DateTime.now()),
        ),
      );
    }
  }

  /// Reset failed operation to queued for retry
  Future<void> resetFailedToQueued(String id) async {
    await (update(pendingSyncQueueTable)..where((t) => t.id.equals(id))).write(
      const PendingSyncQueueTableCompanion(
        status: Value('queued'),
        retries: Value(0),
        errorMessage: Value.absent(),
      ),
    );
  }

  /// Add a new operation to the queue
  Future<void> enqueueOperation({
    required String id,
    required String operationType,
    required String payload,
  }) async {
    await into(pendingSyncQueueTable).insert(
      PendingSyncQueueTableCompanion.insert(
        id: id,
        operationType: operationType,
        payload: payload,
        status: const Value('queued'),
        retries: const Value(0),
      ),
    );
  }
}



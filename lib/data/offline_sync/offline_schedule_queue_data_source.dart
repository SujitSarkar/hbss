import 'package:maori_health/data/objectbox/entities.dart';
import 'package:maori_health/data/objectbox/objectbox_stores.dart';
import 'package:maori_health/objectbox.g.dart';

/// Pending schedule actions in [offline_db] for sequential sync.
abstract class OfflineScheduleQueueDataSource {
  Future<void> enqueue({
    required int scheduleId,
    required int actionType,
    String? cancelPayloadJson,
    String? scheduleSnapshotJson,
  });

  Future<List<PendingScheduleSyncEntity>> getPendingSorted();

  Future<void> remove(int objectId);

  Future<bool> get hasPending;
}

class OfflineScheduleQueueDataSourceImpl implements OfflineScheduleQueueDataSource {
  OfflineScheduleQueueDataSourceImpl(this._stores);

  final ObjectBoxStores _stores;

  @override
  Future<void> enqueue({
    required int scheduleId,
    required int actionType,
    String? cancelPayloadJson,
    String? scheduleSnapshotJson,
  }) async {
    final box = _stores.offlineStore.box<PendingScheduleSyncEntity>();
    box.put(
      PendingScheduleSyncEntity(
        scheduleId: scheduleId,
        actionType: actionType,
        cancelPayloadJson: cancelPayloadJson,
        scheduleSnapshotJson: scheduleSnapshotJson,
        createdAtMs: DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  @override
  Future<List<PendingScheduleSyncEntity>> getPendingSorted() async {
    final box = _stores.offlineStore.box<PendingScheduleSyncEntity>();
    // Sync contract: all pending **starts** (0), then **finishes** (1), then **cancels** (2);
    // within each phase, FIFO by [createdAtMs].
    final q = box
        .query()
        .order(PendingScheduleSyncEntity_.actionType)
        .order(PendingScheduleSyncEntity_.createdAtMs)
        .build();
    final list = q.find();
    q.close();
    assert(_isSortedStartThenFinishThenCancel(list));
    return list;
  }

  /// Invariant enforced by [getPendingSorted] query + checked in debug builds.
  static bool _isSortedStartThenFinishThenCancel(List<PendingScheduleSyncEntity> items) {
    for (var i = 1; i < items.length; i++) {
      final prev = items[i - 1];
      final cur = items[i];
      if (cur.actionType < prev.actionType) return false;
      if (cur.actionType == prev.actionType && cur.createdAtMs < prev.createdAtMs) return false;
    }
    return true;
  }

  @override
  Future<void> remove(int objectId) async {
    _stores.offlineStore.box<PendingScheduleSyncEntity>().remove(objectId);
  }

  @override
  Future<bool> get hasPending async {
    return _stores.offlineStore.box<PendingScheduleSyncEntity>().count() > 0;
  }
}

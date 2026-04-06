import 'package:maori_health/data/objectbox/entities.dart';
import 'package:maori_health/data/objectbox/objectbox_stores.dart';
import 'package:maori_health/objectbox.g.dart';

/// Pending schedule actions in [offline_db] for sequential sync.
abstract class OfflineScheduleQueueDataSource {
  Future<void> enqueue({required int scheduleId, required int actionType, String? cancelPayloadJson});

  Future<List<PendingScheduleSyncEntity>> getPendingSorted();

  Future<void> remove(int objectId);

  Future<bool> get hasPending;
}

class OfflineScheduleQueueDataSourceImpl implements OfflineScheduleQueueDataSource {
  OfflineScheduleQueueDataSourceImpl(this._stores);

  final ObjectBoxStores _stores;

  @override
  Future<void> enqueue({required int scheduleId, required int actionType, String? cancelPayloadJson}) async {
    final box = _stores.offlineStore.box<PendingScheduleSyncEntity>();
    box.put(
      PendingScheduleSyncEntity(
        scheduleId: scheduleId,
        actionType: actionType,
        cancelPayloadJson: cancelPayloadJson,
        createdAtMs: DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  @override
  Future<List<PendingScheduleSyncEntity>> getPendingSorted() async {
    final box = _stores.offlineStore.box<PendingScheduleSyncEntity>();
    final q = box
        .query()
        .order(PendingScheduleSyncEntity_.actionType)
        .order(PendingScheduleSyncEntity_.createdAtMs)
        .build();
    final list = q.find();
    q.close();
    return list;
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

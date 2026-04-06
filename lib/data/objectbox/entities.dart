import 'package:objectbox/objectbox.dart';

/// Normalized schedule row in local ObjectBox storage (`cache_db`). Upsert by [scheduleId].
@Entity()
class LocalStorageScheduleEntity {
  LocalStorageScheduleEntity({this.id = 0, required this.scheduleId, required this.jsonPayload});

  @Id()
  int id;

  @Unique()
  int scheduleId;

  String jsonPayload;
}

@Entity()
class DashboardStatsEntity {
  DashboardStatsEntity({this.id = 0, required this.localStorageKey, required this.jsonPayload});

  @Id()
  int id;

  @Unique()
  String localStorageKey;

  String jsonPayload;
}

/// 0 = availableJobs, 1 = todaysSchedules, 2 = upcomingSchedules
@Entity()
class DashboardSectionLinkEntity {
  DashboardSectionLinkEntity({this.id = 0, required this.section, required this.orderIndex, required this.scheduleId});

  @Id()
  int id;

  int section;
  int orderIndex;
  int scheduleId;
}

/// 0 = next schedule pointer, 1 = current schedule pointer
@Entity()
class DashboardPointerEntity {
  DashboardPointerEntity({this.id = 0, required this.pointerKind, this.scheduleId});

  @Id()
  int id;

  @Unique()
  int pointerKind;

  int? scheduleId;
}

@Entity()
class ScheduleListSnapshotEntity {
  ScheduleListSnapshotEntity({
    this.id = 0,
    required this.localStorageKey,
    required this.jsonPayload,
    required this.currentPage,
    required this.lastPage,
  });

  @Id()
  int id;

  @Unique()
  String localStorageKey;

  String jsonPayload;
  int currentPage;
  int lastPage;
}

/// [offline_db] — sync order: actionType asc (start=0, finish=1, cancel=2), then [createdAtMs].
@Entity()
class PendingScheduleSyncEntity {
  PendingScheduleSyncEntity({
    this.id = 0,
    required this.scheduleId,
    required this.actionType,
    this.cancelPayloadJson,
    required this.createdAtMs,
  });

  @Id()
  int id;

  int scheduleId;

  /// 0 = start, 1 = finish, 2 = cancel
  int actionType;

  String? cancelPayloadJson;

  int createdAtMs;
}

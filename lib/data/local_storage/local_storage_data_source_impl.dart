import 'dart:convert';

import 'package:maori_health/data/dashboard/models/dashboard_response_model.dart';
import 'package:maori_health/data/dashboard/models/schedule_model.dart';
import 'package:maori_health/data/dashboard/models/stats_model.dart';
import 'package:maori_health/data/local_storage/dashboard_local_storage_constants.dart';
import 'package:maori_health/data/local_storage/local_storage_data_source.dart';
import 'package:maori_health/data/objectbox/entities.dart';
import 'package:maori_health/data/objectbox/objectbox_stores.dart';
import 'package:maori_health/data/schedule/models/paginated_schedule_response.dart';
import 'package:maori_health/objectbox.g.dart';

class LocalStorageDataSourceImpl implements LocalStorageDataSource {
  LocalStorageDataSourceImpl(this._stores);

  final ObjectBoxStores _stores;

  void _upsertDashboardStats(String jsonPayload) {
    final box = _stores.localStorageStore.box<DashboardStatsEntity>();
    final q = box.query(DashboardStatsEntity_.localStorageKey.equals('stats')).build();
    final row = q.findFirst();
    q.close();
    if (row != null) {
      row.jsonPayload = jsonPayload;
      box.put(row);
    } else {
      box.put(DashboardStatsEntity(localStorageKey: 'stats', jsonPayload: jsonPayload));
    }
  }

  void _upsertScheduleListSnapshot({
    required String localStorageKey,
    required String jsonPayload,
    required int currentPage,
    required int lastPage,
  }) {
    final box = _stores.localStorageStore.box<ScheduleListSnapshotEntity>();
    final q = box.query(ScheduleListSnapshotEntity_.localStorageKey.equals(localStorageKey)).build();
    final row = q.findFirst();
    q.close();
    if (row != null) {
      row.jsonPayload = jsonPayload;
      row.currentPage = currentPage;
      row.lastPage = lastPage;
      box.put(row);
    } else {
      box.put(
        ScheduleListSnapshotEntity(
          localStorageKey: localStorageKey,
          jsonPayload: jsonPayload,
          currentPage: currentPage,
          lastPage: lastPage,
        ),
      );
    }
  }

  @override
  Future<void> persistDashboard(DashboardResponseModel response) async {
    final store = _stores.localStorageStore;

    for (final s in response.availableJobs) {
      await upsertSchedule(s as ScheduleModel);
    }
    for (final s in response.todaysSchedules) {
      await upsertSchedule(s as ScheduleModel);
    }
    for (final s in response.upcomingSchedules) {
      await upsertSchedule(s as ScheduleModel);
    }
    if (response.nextSchedule != null) {
      await upsertSchedule(response.nextSchedule! as ScheduleModel);
    }
    if (response.currentSchedule != null) {
      await upsertSchedule(response.currentSchedule! as ScheduleModel);
    }

    _upsertDashboardStats(jsonEncode((response.stats as StatsModel).toJson()));

    final linkBox = store.box<DashboardSectionLinkEntity>();
    linkBox.removeMany(linkBox.getAll().map((e) => e.id).toList());

    void putSection(int section, List<ScheduleModel> list) {
      for (var i = 0; i < list.length; i++) {
        linkBox.put(DashboardSectionLinkEntity(section: section, orderIndex: i, scheduleId: list[i].id));
      }
    }

    putSection(DashboardLocalStorageSection.availableJobs, response.availableJobs.cast<ScheduleModel>());
    putSection(DashboardLocalStorageSection.todaysSchedules, response.todaysSchedules.cast<ScheduleModel>());
    putSection(DashboardLocalStorageSection.upcomingSchedules, response.upcomingSchedules.cast<ScheduleModel>());

    final ptrBox = store.box<DashboardPointerEntity>();
    for (final kind in [DashboardPointerKind.nextSchedule, DashboardPointerKind.currentSchedule]) {
      final q = ptrBox.query(DashboardPointerEntity_.pointerKind.equals(kind)).build();
      final old = q.findFirst();
      q.close();
      if (old != null) ptrBox.remove(old.id);
    }
    ptrBox.put(
      DashboardPointerEntity(pointerKind: DashboardPointerKind.nextSchedule, scheduleId: response.nextSchedule?.id),
    );
    ptrBox.put(
      DashboardPointerEntity(
        pointerKind: DashboardPointerKind.currentSchedule,
        scheduleId: response.currentSchedule?.id,
      ),
    );
  }

  @override
  Future<DashboardResponseModel?> readDashboard() async {
    final store = _stores.localStorageStore;
    final statsBox = store.box<DashboardStatsEntity>();
    final statsEntity = statsBox.query(DashboardStatsEntity_.localStorageKey.equals('stats')).build().findFirst();
    if (statsEntity == null) return null;

    final stats = StatsModel.fromJson(jsonDecode(statsEntity.jsonPayload) as Map<String, dynamic>);

    Future<List<ScheduleModel>> loadSection(int section) async {
      final linkBox = store.box<DashboardSectionLinkEntity>();
      final q = linkBox
          .query(DashboardSectionLinkEntity_.section.equals(section))
          .order(DashboardSectionLinkEntity_.orderIndex)
          .build();
      final links = q.find();
      q.close();
      final out = <ScheduleModel>[];
      for (final link in links) {
        final sch = await getScheduleById(link.scheduleId);
        if (sch != null) out.add(sch);
      }
      return out;
    }

    final availableJobs = await loadSection(DashboardLocalStorageSection.availableJobs);
    final todaysSchedules = await loadSection(DashboardLocalStorageSection.todaysSchedules);
    final upcomingSchedules = await loadSection(DashboardLocalStorageSection.upcomingSchedules);

    ScheduleModel? nextSchedule;
    ScheduleModel? currentSchedule;
    final ptrBox = store.box<DashboardPointerEntity>();
    for (final kind in [DashboardPointerKind.nextSchedule, DashboardPointerKind.currentSchedule]) {
      final q = ptrBox.query(DashboardPointerEntity_.pointerKind.equals(kind)).build();
      final p = q.findFirst();
      q.close();
      final sid = p?.scheduleId;
      if (sid == null) continue;
      final sch = await getScheduleById(sid);
      if (kind == DashboardPointerKind.nextSchedule) {
        nextSchedule = sch;
      } else {
        currentSchedule = sch;
      }
    }

    return DashboardResponseModel(
      availableJobs: availableJobs,
      todaysSchedules: todaysSchedules,
      upcomingSchedules: upcomingSchedules,
      nextSchedule: nextSchedule,
      currentSchedule: currentSchedule,
      stats: stats,
    );
  }

  @override
  Future<void> upsertSchedule(ScheduleModel schedule) async {
    final box = _stores.localStorageStore.box<LocalStorageScheduleEntity>();
    final q = box.query(LocalStorageScheduleEntity_.scheduleId.equals(schedule.id)).build();
    final existing = q.findFirst();
    q.close();
    final payload = jsonEncode(schedule.toJson());
    if (existing != null) {
      existing.jsonPayload = payload;
      box.put(existing);
    } else {
      box.put(LocalStorageScheduleEntity(scheduleId: schedule.id, jsonPayload: payload));
    }
  }

  @override
  Future<ScheduleModel?> getScheduleById(int scheduleId) async {
    final box = _stores.localStorageStore.box<LocalStorageScheduleEntity>();
    final q = box.query(LocalStorageScheduleEntity_.scheduleId.equals(scheduleId)).build();
    final e = q.findFirst();
    q.close();
    if (e == null) return null;
    return ScheduleModel.fromJson(jsonDecode(e.jsonPayload) as Map<String, dynamic>);
  }

  @override
  Future<void> persistScheduleList({
    required String localStorageKey,
    required PaginatedScheduleResponse page,
    required bool append,
  }) async {
    final box = _stores.localStorageStore.box<ScheduleListSnapshotEntity>();

    for (final s in page.schedules) {
      await upsertSchedule(s);
    }

    if (!append) {
      _upsertScheduleListSnapshot(
        localStorageKey: localStorageKey,
        jsonPayload: jsonEncode(page.toJson()),
        currentPage: page.currentPage,
        lastPage: page.lastPage,
      );
      return;
    }

    final q = box.query(ScheduleListSnapshotEntity_.localStorageKey.equals(localStorageKey)).build();
    final existing = q.findFirst();
    q.close();
    if (existing == null) {
      await persistScheduleList(localStorageKey: localStorageKey, page: page, append: false);
      return;
    }

    final prev = PaginatedScheduleResponse.fromJson(jsonDecode(existing.jsonPayload) as Map<String, dynamic>);
    final merged = PaginatedScheduleResponse(
      schedules: [...prev.schedules, ...page.schedules],
      currentPage: page.currentPage,
      lastPage: page.lastPage,
    );

    _upsertScheduleListSnapshot(
      localStorageKey: localStorageKey,
      jsonPayload: jsonEncode(merged.toJson()),
      currentPage: merged.currentPage,
      lastPage: merged.lastPage,
    );
  }

  @override
  Future<PaginatedScheduleResponse?> readScheduleList(String localStorageKey) async {
    final box = _stores.localStorageStore.box<ScheduleListSnapshotEntity>();
    final q = box.query(ScheduleListSnapshotEntity_.localStorageKey.equals(localStorageKey)).build();
    final e = q.findFirst();
    q.close();
    if (e == null) return null;
    return PaginatedScheduleResponse.fromJson(jsonDecode(e.jsonPayload) as Map<String, dynamic>);
  }
}

import 'package:maori_health/data/dashboard/models/dashboard_response_model.dart';
import 'package:maori_health/data/dashboard/models/schedule_model.dart';
import 'package:maori_health/data/schedule/models/paginated_schedule_response.dart';

/// Local read-through storage backed by ObjectBox (`cache_db`).
abstract class LocalStorageDataSource {
  Future<void> persistDashboard(DashboardResponseModel response);

  Future<DashboardResponseModel?> readDashboard();

  Future<void> upsertSchedule(ScheduleModel schedule);

  Future<ScheduleModel?> getScheduleById(int scheduleId);

  Future<void> persistScheduleList({
    required String localStorageKey,
    required PaginatedScheduleResponse page,
    required bool append,
  });

  Future<PaginatedScheduleResponse?> readScheduleList(String localStorageKey);
}

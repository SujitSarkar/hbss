import 'package:maori_health/core/error/failures.dart';
import 'package:maori_health/core/result/result.dart';

import 'package:maori_health/data/dashboard/models/schedule_model.dart';
import 'package:maori_health/data/schedule/models/paginated_schedule_response.dart';

abstract class ScheduleRepository {
  Future<Result<AppError, PaginatedScheduleResponse>> getSchedules({
    required int page,
    int? clientUserId,
    String? startDate,
    String? endDate,
  });
  Future<Result<AppError, ScheduleModel>> getScheduleById({required int scheduleId});
  Future<Result<AppError, ScheduleModel>> acceptSchedule({required int scheduleId});
  Future<Result<AppError, ScheduleModel>> startSchedule({required int scheduleId});
  Future<Result<AppError, ScheduleModel>> finishSchedule({required int scheduleId});
  Future<Result<AppError, ScheduleModel>> cancelSchedule({
    required int scheduleId,
    required String cancelBy,
    required String? cancelReason,
    required int hour,
    required int minute,
    required String reason,
  });
}

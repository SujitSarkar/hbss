import 'package:maori_health/core/error/failures.dart';
import 'package:maori_health/core/result/result.dart';

import 'package:maori_health/data/dashboard/models/job_model.dart';

abstract class ScheduleRepository {
  Future<Result<AppError, JobModel>> getScheduleById({required int scheduleId});
}

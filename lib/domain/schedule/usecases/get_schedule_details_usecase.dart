import 'package:maori_health/core/error/failures.dart';
import 'package:maori_health/core/result/result.dart';

import 'package:maori_health/data/dashboard/models/job_model.dart';
import 'package:maori_health/domain/schedule/repositories/schedule_repository.dart';

class GetScheduleDetailsUsecase {
  final ScheduleRepository _repository;

  GetScheduleDetailsUsecase({required ScheduleRepository repository}) : _repository = repository;

  Future<Result<AppError, JobModel>> call({required int scheduleId}) async {
    return _repository.getScheduleById(scheduleId: scheduleId);
  }
}

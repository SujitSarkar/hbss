import 'package:maori_health/core/error/failures.dart';
import 'package:maori_health/core/result/result.dart';

import 'package:maori_health/data/dashboard/models/schedule_model.dart';
import 'package:maori_health/domain/schedule/repositories/schedule_repository.dart';

class FinishScheduleUsecase {
  final ScheduleRepository _repository;

  FinishScheduleUsecase({required ScheduleRepository repository}) : _repository = repository;

  Future<Result<AppError, ScheduleModel>> call({required int scheduleId}) async {
    return _repository.finishSchedule(scheduleId: scheduleId);
  }
}

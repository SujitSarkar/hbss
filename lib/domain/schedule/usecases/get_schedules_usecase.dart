import 'package:maori_health/core/error/failures.dart';
import 'package:maori_health/core/result/result.dart';

import 'package:maori_health/data/schedule/models/paginated_schedule_response.dart';
import 'package:maori_health/domain/schedule/repositories/schedule_repository.dart';

class GetSchedulesUsecase {
  final ScheduleRepository _repository;

  GetSchedulesUsecase({required ScheduleRepository repository}) : _repository = repository;

  Future<Result<AppError, PaginatedScheduleResponse>> call({
    required int page,
    int? clientUserId,
    String? startDate,
    String? endDate,
  }) async {
    return _repository.getSchedules(page: page, clientUserId: clientUserId, startDate: startDate, endDate: endDate);
  }
}

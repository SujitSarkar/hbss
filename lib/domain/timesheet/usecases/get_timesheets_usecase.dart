import 'package:maori_health/core/error/failures.dart';
import 'package:maori_health/core/result/result.dart';
import 'package:maori_health/data/timesheet/models/timesheet_response_model.dart';
import 'package:maori_health/domain/timesheet/repositories/timesheet_repository.dart';

class GetTimeSheetsUsecase {
  final TimeSheetRepository _repository;

  GetTimeSheetsUsecase({required TimeSheetRepository repository}) : _repository = repository;

  Future<Result<AppError, TimesheetResponseModel>> call({
    int? clientUserId,
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
  }) {
    return _repository.getTimeSheets(clientUserId: clientUserId, startDate: startDate, endDate: endDate, page: page);
  }
}

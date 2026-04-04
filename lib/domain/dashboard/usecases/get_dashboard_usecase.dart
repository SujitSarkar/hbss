import 'package:maori_health/core/error/failures.dart';
import 'package:maori_health/core/result/result.dart';
import 'package:maori_health/domain/dashboard/entities/dashboard_response.dart';
import 'package:maori_health/domain/dashboard/repositories/dashboard_repository.dart';

class GetDashboardUsecase {
  final DashboardRepository _repository;

  GetDashboardUsecase({required DashboardRepository repository}) : _repository = repository;

  Future<Result<AppError, DashboardResponse>> call() {
    return _repository.getDashboard();
  }
}

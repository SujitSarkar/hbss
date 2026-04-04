import 'package:maori_health/core/error/failures.dart';
import 'package:maori_health/core/result/result.dart';
import 'package:maori_health/domain/employee/entities/employee.dart';
import 'package:maori_health/domain/employee/repositories/employee_repository.dart';

class GetEmployeesUsecase {
  final EmployeeRepository _repository;

  GetEmployeesUsecase({required EmployeeRepository repository}) : _repository = repository;

  Future<Result<AppError, List<Employee>>> call({int page = 1}) {
    return _repository.getEmployees(page: page);
  }
}

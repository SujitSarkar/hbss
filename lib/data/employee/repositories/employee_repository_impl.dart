import 'package:maori_health/core/error/exceptions.dart';
import 'package:maori_health/core/error/failures.dart';
import 'package:maori_health/core/network/network_checker.dart';
import 'package:maori_health/core/result/result.dart';
import 'package:maori_health/core/storage/local_cache_service.dart';

import 'package:maori_health/data/employee/datasources/employee_remote_data_source.dart';
import 'package:maori_health/domain/employee/entities/employee.dart';
import 'package:maori_health/domain/employee/repositories/employee_repository.dart';

class EmployeeRepositoryImpl implements EmployeeRepository {
  final EmployeeRemoteDataSource _remoteDataSource;
  final NetworkChecker _networkChecker;
  final LocalCacheService _localCache;

  EmployeeRepositoryImpl({
    required EmployeeRemoteDataSource remoteDataSource,
    required NetworkChecker networkChecker,
    required LocalCacheService localCache,
  }) : _remoteDataSource = remoteDataSource,
       _networkChecker = networkChecker,
       _localCache = localCache;

  @override
  Future<Result<AppError, List<Employee>>> getEmployees({int page = 1}) async {
    if (!await _networkChecker.hasConnection) {
      final cached = _localCache.getCachedEmployees();
      if (cached != null && cached.isNotEmpty) {
        return SuccessResult(cached);
      }
      return const ErrorResult(NetworkError());
    }
    try {
      final employees = await _remoteDataSource.getEmployees(page: page);
      await _localCache.setCachedEmployees(employees);
      return SuccessResult(employees);
    } on ApiException catch (e) {
      return ErrorResult(ApiError(errorCode: e.statusCode, errorMessage: e.message));
    } catch (e) {
      return ErrorResult(ApiError(errorCode: 0, errorMessage: e.toString()));
    }
  }
}

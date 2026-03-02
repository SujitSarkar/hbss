import 'package:maori_health/core/error/exceptions.dart';
import 'package:maori_health/core/error/failures.dart';
import 'package:maori_health/core/network/network_checker.dart';
import 'package:maori_health/core/result/result.dart';

import 'package:maori_health/data/dashboard/datasources/dashboard_remote_data_source.dart';
import 'package:maori_health/domain/dashboard/entities/dashboard_response.dart';
import 'package:maori_health/domain/dashboard/repositories/dashboard_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource _remoteDataSource;
  final NetworkChecker _networkChecker;

  DashboardRepositoryImpl({required DashboardRemoteDataSource remoteDataSource, required NetworkChecker networkChecker})
    : _remoteDataSource = remoteDataSource,
      _networkChecker = networkChecker;

  @override
  Future<Result<AppError, DashboardResponse>> getDashboard() async {
    if (!await _networkChecker.hasConnection) {
      return const ErrorResult(NetworkError());
    }

    try {
      final response = await _remoteDataSource.getDashboard();
      return SuccessResult(response);
    } on ApiException catch (e) {
      return ErrorResult(ApiError(errorCode: e.statusCode, errorMessage: e.message));
    } catch (e) {
      return ErrorResult(ApiError(errorCode: 0, errorMessage: e.toString()));
    }
  }
}

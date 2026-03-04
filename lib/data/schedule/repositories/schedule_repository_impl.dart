import 'package:maori_health/core/error/exceptions.dart';
import 'package:maori_health/core/error/failures.dart';
import 'package:maori_health/core/network/network_checker.dart';
import 'package:maori_health/core/result/result.dart';

import 'package:maori_health/data/dashboard/models/job_model.dart';
import 'package:maori_health/data/schedule/datasources/schedule_remote_datasource.dart';
import 'package:maori_health/domain/schedule/repositories/schedule_repository.dart';

class ScheduleRepositoryImpl implements ScheduleRepository {
  final ScheduleRemoteDataSource _remoteDataSource;
  final NetworkChecker _networkChecker;

  ScheduleRepositoryImpl({required ScheduleRemoteDataSource remoteDataSource, required NetworkChecker networkChecker})
    : _remoteDataSource = remoteDataSource,
      _networkChecker = networkChecker;

  @override
  Future<Result<AppError, JobModel>> getScheduleById({required int scheduleId}) async {
    if (!await _networkChecker.hasConnection) return const ErrorResult(NetworkError());
    try {
      final result = await _remoteDataSource.getScheduleById(scheduleId: scheduleId);
      return SuccessResult(result);
    } on ApiException catch (e) {
      return ErrorResult(ApiError(errorCode: e.statusCode, errorMessage: e.message));
    } catch (e) {
      return ErrorResult(ApiError(errorCode: 0, errorMessage: e.toString()));
    }
  }
}

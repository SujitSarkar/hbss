import 'package:maori_health/core/error/exceptions.dart';
import 'package:maori_health/core/error/failures.dart';
import 'package:maori_health/core/network/network_checker.dart';
import 'package:maori_health/core/result/result.dart';

import 'package:maori_health/data/dashboard/models/schedule_model.dart';
import 'package:maori_health/data/schedule/datasources/schedule_remote_datasource.dart';
import 'package:maori_health/data/schedule/models/paginated_schedule_response.dart';
import 'package:maori_health/domain/schedule/repositories/schedule_repository.dart';

class ScheduleRepositoryImpl implements ScheduleRepository {
  final ScheduleRemoteDataSource _remoteDataSource;
  final NetworkChecker _networkChecker;

  ScheduleRepositoryImpl({required ScheduleRemoteDataSource remoteDataSource, required NetworkChecker networkChecker})
    : _remoteDataSource = remoteDataSource,
      _networkChecker = networkChecker;

  @override
  Future<Result<AppError, PaginatedScheduleResponse>> getSchedules({
    required int page,
    int? clientUserId,
    String? startDate,
    String? endDate,
  }) async {
    if (!await _networkChecker.hasConnection) return const ErrorResult(NetworkError());
    try {
      final result = await _remoteDataSource.getSchedules(
        page: page,
        clientUserId: clientUserId,
        startDate: startDate,
        endDate: endDate,
      );
      return SuccessResult(result);
    } on ApiException catch (e) {
      return ErrorResult(ApiError(errorCode: e.statusCode, errorMessage: e.message));
    } catch (e) {
      return ErrorResult(ApiError(errorCode: 0, errorMessage: e.toString()));
    }
  }

  @override
  Future<Result<AppError, ScheduleModel>> getScheduleById({required int scheduleId}) async {
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

  @override
  Future<Result<AppError, ScheduleModel>> acceptSchedule({required int scheduleId}) async {
    if (!await _networkChecker.hasConnection) return const ErrorResult(NetworkError());
    try {
      final result = await _remoteDataSource.acceptSchedule(scheduleId: scheduleId);
      return SuccessResult(result);
    } on ApiException catch (e) {
      return ErrorResult(ApiError(errorCode: e.statusCode, errorMessage: e.message));
    } catch (e) {
      return ErrorResult(ApiError(errorCode: 0, errorMessage: e.toString()));
    }
  }

  @override
  Future<Result<AppError, ScheduleModel>> startSchedule({required int scheduleId}) async {
    if (!await _networkChecker.hasConnection) return const ErrorResult(NetworkError());
    try {
      final result = await _remoteDataSource.startSchedule(scheduleId: scheduleId);
      return SuccessResult(result);
    } on ApiException catch (e) {
      return ErrorResult(ApiError(errorCode: e.statusCode, errorMessage: e.message));
    } catch (e) {
      return ErrorResult(ApiError(errorCode: 0, errorMessage: e.toString()));
    }
  }

  @override
  Future<Result<AppError, ScheduleModel>> finishSchedule({required int scheduleId}) async {
    if (!await _networkChecker.hasConnection) return const ErrorResult(NetworkError());
    try {
      final result = await _remoteDataSource.finishSchedule(scheduleId: scheduleId);
      return SuccessResult(result);
    } on ApiException catch (e) {
      return ErrorResult(ApiError(errorCode: e.statusCode, errorMessage: e.message));
    } catch (e) {
      return ErrorResult(ApiError(errorCode: 0, errorMessage: e.toString()));
    }
  }

  @override
  Future<Result<AppError, ScheduleModel>> cancelSchedule({
    required int scheduleId,
    required String cancelBy,
    required String? cancelReason,
    required int hour,
    required int minute,
    required String reason,
  }) async {
    if (!await _networkChecker.hasConnection) return const ErrorResult(NetworkError());
    try {
      final result = await _remoteDataSource.cancelSchedule(
        scheduleId: scheduleId,
        cancelBy: cancelBy,
        cancelReason: cancelReason,
        hour: hour,
        minute: minute,
        reason: reason,
      );
      return SuccessResult(result);
    } on ApiException catch (e) {
      return ErrorResult(ApiError(errorCode: e.statusCode, errorMessage: e.message));
    } catch (e) {
      return ErrorResult(ApiError(errorCode: 0, errorMessage: e.toString()));
    }
  }
}

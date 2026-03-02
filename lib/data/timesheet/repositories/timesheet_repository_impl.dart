import 'package:maori_health/core/error/exceptions.dart';
import 'package:maori_health/core/error/failures.dart';
import 'package:maori_health/core/network/network_checker.dart';
import 'package:maori_health/core/result/result.dart';
import 'package:maori_health/core/utils/date_converter.dart';

import 'package:maori_health/data/timesheet/datasources/timesheet_remote_data_source.dart';
import 'package:maori_health/data/timesheet/models/timesheet_response_model.dart';
import 'package:maori_health/domain/timesheet/repositories/timesheet_repository.dart';

class TimeSheetRepositoryImpl implements TimeSheetRepository {
  final TimeSheetRemoteDataSource _remoteDataSource;
  final NetworkChecker _networkChecker;

  TimeSheetRepositoryImpl({required TimeSheetRemoteDataSource remoteDataSource, required NetworkChecker networkChecker})
    : _remoteDataSource = remoteDataSource,
      _networkChecker = networkChecker;

  @override
  Future<Result<AppError, TimesheetResponseModel>> getTimeSheets({
    int? clientUserId,
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
  }) async {
    if (!await _networkChecker.hasConnection) {
      return const ErrorResult(NetworkError());
    }
    try {
      final response = await _remoteDataSource.getTimeSheets(
        clientUserId: clientUserId,
        startDate: startDate != null ? DateConverter.toIsoDate(startDate) : null,
        endDate: endDate != null ? DateConverter.toIsoDate(endDate) : null,
        page: page,
      );
      return SuccessResult(response);
    } on ApiException catch (e) {
      return ErrorResult(ApiError(errorCode: e.statusCode, errorMessage: e.message));
    } catch (e) {
      return ErrorResult(ApiError(errorCode: 0, errorMessage: e.toString()));
    }
  }
}

import 'package:maori_health/core/error/exceptions.dart';
import 'package:maori_health/core/error/failures.dart';
import 'package:maori_health/core/network/network_checker.dart';
import 'package:maori_health/core/result/result.dart';

import 'package:maori_health/data/app_settings/datasources/app_settings_remote_datasource.dart';
import 'package:maori_health/domain/app_settings/entities/app_settings.dart';
import 'package:maori_health/domain/app_settings/repositories/app_settings_repository.dart';

class AppSettingsRepositoryImpl extends AppSettingsRepository {
  final AppSettingsRemoteDataSource _remoteDataSource;
  final NetworkChecker _networkChecker;

  AppSettingsRepositoryImpl({
    required AppSettingsRemoteDataSource remoteDataSource,
    required NetworkChecker networkChecker,
  }) : _remoteDataSource = remoteDataSource,
       _networkChecker = networkChecker;

  @override
  Future<Result<AppError, AppSettings>> getAppSettings() async {
    if (!await _networkChecker.hasConnection) {
      return ErrorResult(NetworkError());
    }
    try {
      final appSettings = await _remoteDataSource.getAppSettings();
      return SuccessResult(appSettings);
    } on ApiException catch (e) {
      return ErrorResult(ApiError(errorCode: e.statusCode, errorMessage: e.message));
    } catch (e) {
      return ErrorResult(ApiError(errorCode: 0, errorMessage: e.toString()));
    }
  }
}

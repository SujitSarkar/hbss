import 'package:maori_health/core/error/exceptions.dart';
import 'package:maori_health/core/error/failures.dart';
import 'package:maori_health/core/network/network_checker.dart';
import 'package:maori_health/core/result/result.dart';
import 'package:maori_health/core/storage/local_cache_service.dart';

import 'package:maori_health/data/app_settings/datasources/app_settings_remote_datasource.dart';
import 'package:maori_health/domain/app_settings/entities/app_settings.dart';
import 'package:maori_health/domain/app_settings/repositories/app_settings_repository.dart';

class AppSettingsRepositoryImpl extends AppSettingsRepository {
  final AppSettingsRemoteDataSource _remoteDataSource;
  final NetworkChecker _networkChecker;
  final LocalCacheService _localCache;

  AppSettingsRepositoryImpl({
    required AppSettingsRemoteDataSource remoteDataSource,
    required NetworkChecker networkChecker,
    required LocalCacheService localCache,
  }) : _remoteDataSource = remoteDataSource,
       _networkChecker = networkChecker,
       _localCache = localCache;

  @override
  Future<Result<AppError, AppSettings>> getAppSettings() async {
    if (!await _networkChecker.hasConnection) {
      final cached = _localCache.getCachedAppSettings();
      if (cached != null) {
        return SuccessResult(cached);
      }
      return const ErrorResult(NetworkError());
    }
    try {
      final appSettings = await _remoteDataSource.getAppSettings();
      await _localCache.setCachedAppSettings(appSettings);
      return SuccessResult(appSettings);
    } on ApiException catch (e) {
      return ErrorResult(ApiError(errorCode: e.statusCode, errorMessage: e.message));
    } catch (e) {
      return ErrorResult(ApiError(errorCode: 0, errorMessage: e.toString()));
    }
  }
}

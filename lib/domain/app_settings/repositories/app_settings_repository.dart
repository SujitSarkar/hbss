import 'package:maori_health/core/error/failures.dart';
import 'package:maori_health/core/result/result.dart';
import 'package:maori_health/domain/app_settings/entities/app_settings.dart';

abstract class AppSettingsRepository {
  Future<Result<AppError, AppSettings>> getAppSettings();
}

import 'package:maori_health/core/error/failures.dart';
import 'package:maori_health/core/result/result.dart';
import 'package:maori_health/domain/app_settings/entities/app_settings.dart';
import 'package:maori_health/domain/app_settings/repositories/app_settings_repository.dart';

class GetAppSettingsUsecase {
  final AppSettingsRepository _repository;

  GetAppSettingsUsecase({required AppSettingsRepository repository}) : _repository = repository;

  Future<Result<AppError, AppSettings>> call() async {
    return _repository.getAppSettings();
  }
}

import 'package:maori_health/domain/app/repositories/theme_preference_repository.dart';

class PersistThemeModeUsecase {
  final ThemePreferenceRepository _repository;

  PersistThemeModeUsecase({required ThemePreferenceRepository repository}) : _repository = repository;

  Future<void> call(String mode) => _repository.saveThemeModeName(mode);
}

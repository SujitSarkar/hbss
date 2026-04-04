import 'package:maori_health/domain/app/repositories/theme_preference_repository.dart';

class GetSavedThemeModeUsecase {
  final ThemePreferenceRepository _repository;

  GetSavedThemeModeUsecase({required ThemePreferenceRepository repository}) : _repository = repository;

  String? call() => _repository.getSavedThemeModeName();
}

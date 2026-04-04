import 'package:maori_health/core/storage/local_cache_service.dart';
import 'package:maori_health/domain/app/repositories/theme_preference_repository.dart';

class ThemePreferenceRepositoryImpl implements ThemePreferenceRepository {
  final LocalCacheService _cache;

  ThemePreferenceRepositoryImpl({required LocalCacheService cache}) : _cache = cache;

  @override
  String? getSavedThemeModeName() => _cache.getThemeMode();

  @override
  Future<void> saveThemeModeName(String mode) => _cache.setThemeMode(mode);
}

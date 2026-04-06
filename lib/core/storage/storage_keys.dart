abstract class StorageKeys {
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String themeMode = 'theme_mode';
  static const String userData = 'user_data';

  /// Cached API payloads (JSON) for offline read — see LocalCacheService.
  static const String cachedClientsList = 'cached_clients_list';
  static const String cachedEmployeesList = 'cached_employees_list';
  static const String cachedLookupEnums = 'cached_lookup_enums';

  /// Server-driven app configuration (API); not compile-time UI strings in app_strings.dart.
  static const String cachedAppSettings = 'cached_app_settings';
}

/// Persists the user's theme mode choice (e.g. `light`, `dark`, `system`).
abstract class ThemePreferenceRepository {
  String? getSavedThemeModeName();

  Future<void> saveThemeModeName(String mode);
}

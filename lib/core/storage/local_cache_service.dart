import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:maori_health/core/storage/storage_keys.dart';
import 'package:maori_health/data/Client/models/Client_model.dart';
import 'package:maori_health/data/app_settings/models/app_settings_model.dart';
import 'package:maori_health/data/auth/models/user_model.dart';
import 'package:maori_health/data/employee/models/employee_model.dart';
import 'package:maori_health/data/lookup_enums/models/lookup_enums_model.dart';

/// Persists JSON snapshots of API models for offline reads (same pattern as [getUserData]/[setUserData]).
///
/// Static UI copy lives in [AppStrings]; server-driven labels/config are cached via [cachedAppSettingsJson].
class LocalCacheService {
  final SharedPreferences _preference;

  LocalCacheService(this._preference);

  static Future<LocalCacheService> init() async {
    final preference = await SharedPreferences.getInstance();
    return LocalCacheService(preference);
  }

  String? getThemeMode() => _preference.getString(StorageKeys.themeMode);
  Future<bool> setThemeMode(String mode) async => await _preference.setString(StorageKeys.themeMode, mode);

  UserModel? getUserData() {
    final raw = _preference.getString(StorageKeys.userData);
    if (raw == null) return null;
    return UserModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<bool> setUserData(UserModel user) async {
    return await _preference.setString(StorageKeys.userData, jsonEncode(user.toJson()));
  }

  Future<bool> removeUserData() async => await _preference.remove(StorageKeys.userData);

  List<ClientModel>? getCachedClients() {
    final raw = _preference.getString(StorageKeys.cachedClientsList);
    if (raw == null || raw.isEmpty) return null;
    final list = jsonDecode(raw) as List<dynamic>;
    return list.map((e) => ClientModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<bool> setCachedClients(List<ClientModel> clients) async {
    final payload = jsonEncode(clients.map((e) => e.toJson()).toList());
    return _preference.setString(StorageKeys.cachedClientsList, payload);
  }

  List<EmployeeModel>? getCachedEmployees() {
    final raw = _preference.getString(StorageKeys.cachedEmployeesList);
    if (raw == null || raw.isEmpty) return null;
    final list = jsonDecode(raw) as List<dynamic>;
    return list.map((e) => EmployeeModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<bool> setCachedEmployees(List<EmployeeModel> employees) async {
    final payload = jsonEncode(employees.map((e) => e.toJson()).toList());
    return _preference.setString(StorageKeys.cachedEmployeesList, payload);
  }

  LookupEnumsModel? getCachedLookupEnums() {
    final raw = _preference.getString(StorageKeys.cachedLookupEnums);
    if (raw == null || raw.isEmpty) return null;
    return LookupEnumsModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<bool> setCachedLookupEnums(LookupEnumsModel enums) async {
    return _preference.setString(StorageKeys.cachedLookupEnums, jsonEncode(enums.toJson()));
  }

  AppSettingsModel? getCachedAppSettings() {
    final raw = _preference.getString(StorageKeys.cachedAppSettings);
    if (raw == null || raw.isEmpty) return null;
    return AppSettingsModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<bool> setCachedAppSettings(AppSettingsModel settings) async {
    return _preference.setString(StorageKeys.cachedAppSettings, jsonEncode(settings.toJson()));
  }

  Future<bool> remove(String key) async => await _preference.remove(key);
  Future<bool> clear() async => await _preference.clear();
}

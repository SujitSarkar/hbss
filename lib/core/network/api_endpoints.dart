import 'package:maori_health/core/config/env_config.dart';

abstract class ApiEndpoints {
  // Auth
  static const String login = 'auth/login';
  static const String logout = 'auth/logout';
  static const String updatePassword = 'auth/update-password';

  // Forgot Password
  static const String forgotPassword = 'auth/forgot-password';
  static const String verifyOtp = 'auth/otp-verification';
  static const String resetPassword = 'auth/reset-password';

  // Assets
  static const String assets = 'assets';
  static String acceptAsset(int id) => 'assets/$id/accept';

  // Notifications
  static const String notifications = 'notifications';
  static String readNotification(String id) => 'notifications/$id';

  // Dashboard
  static const String dashboard = 'dashboard';

  // Lookups
  static const String employees = 'lookups/employees';
  static const String clients = 'lookups/clients';

  // TimeSheets
  static const String timeSheets = 'schedules/timesheet';

  static String fullUrl(String path) => '${EnvConfig.baseUrl}$path';
}

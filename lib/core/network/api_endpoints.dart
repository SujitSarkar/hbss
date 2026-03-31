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

  // Schedule
  static const String schedules = 'schedules';
  static String scheduleById(int scheduleId) => '$schedules/$scheduleId';
  static String acceptSchedule(int scheduleId) => '$schedules/$scheduleId/accept';
  static String startSchedule(int scheduleId) => '$schedules/$scheduleId/start';
  static String finishSchedule(int scheduleId) => '$schedules/$scheduleId/finish';
  static String cancelSchedule(int scheduleId) => '$schedules/$scheduleId/cancel';

  // Lookups
  static const String employees = 'lookups/employees';
  static const String clients = 'lookups/clients';
  static const String enums = 'lookups/enums';

  // App Settings
  static const String settings = 'settings';

  // TimeSheets
  static const String timeSheets = 'schedules/timesheet';

  static String fullUrl(String path) => '${EnvConfig.baseUrl}$path';
  static String imageUrl(String imagePath) => '${EnvConfig.hostUrl}$imagePath';
}

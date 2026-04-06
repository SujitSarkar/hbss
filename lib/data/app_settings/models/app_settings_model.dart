import 'package:maori_health/domain/app_settings/entities/app_settings.dart';

class AppSettingsModel extends AppSettings {
  const AppSettingsModel({
    super.mobileAppName,
    super.appVersion,
    super.mobileLogo,
    super.mobileLoginBgImage,
    super.cancelByKaimahi,
    super.cancelByClient,
    super.officeStartTime,
    super.officeEndTime,
    super.weekDayStart,
    super.slotDuration,
  });

  factory AppSettingsModel.fromJson(Map<String, dynamic> json) => AppSettingsModel(
    mobileAppName: json["mobile_app_name"],
    appVersion: json["app_version"],
    mobileLogo: json["mobile_logo"],
    mobileLoginBgImage: json["mobile_login_bg_image"],
    cancelByKaimahi: json["cancel_by_kaimahi"],
    cancelByClient: json["cancel_by_client"],
    officeStartTime: json["office_start_time"],
    officeEndTime: json["office_end_time"],
    weekDayStart: json["week_day_start"],
    slotDuration: json["slot_duration"],
  );

  Map<String, dynamic> toJson() => {
    'mobile_app_name': mobileAppName,
    'app_version': appVersion,
    'mobile_logo': mobileLogo,
    'mobile_login_bg_image': mobileLoginBgImage,
    'cancel_by_kaimahi': cancelByKaimahi,
    'cancel_by_client': cancelByClient,
    'office_start_time': officeStartTime,
    'office_end_time': officeEndTime,
    'week_day_start': weekDayStart,
    'slot_duration': slotDuration,
  };
}

import 'package:equatable/equatable.dart';

class AppSettings extends Equatable {
  final String? mobileAppName;
  final String? appVersion;
  final dynamic mobileLogo;
  final dynamic mobileLoginBgImage;
  final String? cancelByKaimahi;
  final String? cancelByClient;
  final String? officeStartTime;
  final String? officeEndTime;
  final String? weekDayStart;
  final String? slotDuration;

  const AppSettings({
    this.mobileAppName,
    this.appVersion,
    this.mobileLogo,
    this.mobileLoginBgImage,
    this.cancelByKaimahi,
    this.cancelByClient,
    this.officeStartTime,
    this.officeEndTime,
    this.weekDayStart,
    this.slotDuration,
  });

  @override
  List<Object?> get props => [
    mobileAppName,
    appVersion,
    mobileLogo,
    mobileLoginBgImage,
    cancelByKaimahi,
    cancelByClient,
    officeStartTime,
    officeEndTime,
    weekDayStart,
    slotDuration,
  ];
}

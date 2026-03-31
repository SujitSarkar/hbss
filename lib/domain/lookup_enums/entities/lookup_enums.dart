import 'package:equatable/equatable.dart';

import 'package:maori_health/domain/lookup_enums/entities/asset_status.dart';
import 'package:maori_health/domain/lookup_enums/entities/schedule_status.dart';

class LookupEnums extends Equatable {
  final List<String> gender;
  final ScheduleStatus scheduleStatusValue;
  final ScheduleStatus scheduleStatusKey;
  final AssetStatus assetStatus;
  final AssetStatus assetStatusKey;
  final Map<String, String> jobType;
  final Map<String, String> canceledBy;
  final Map<String, String> cancelReason;

  const LookupEnums({
    required this.gender,
    required this.scheduleStatusValue,
    required this.scheduleStatusKey,
    required this.assetStatus,
    required this.assetStatusKey,
    required this.jobType,
    required this.canceledBy,
    required this.cancelReason,
  });

  @override
  List<Object?> get props => [
    gender,
    scheduleStatusValue,
    scheduleStatusKey,
    assetStatus,
    assetStatusKey,
    jobType,
    canceledBy,
    cancelReason,
  ];
}

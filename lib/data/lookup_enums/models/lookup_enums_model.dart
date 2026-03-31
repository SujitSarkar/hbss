import 'package:maori_health/data/lookup_enums/models/asset_status_model.dart';
import 'package:maori_health/data/lookup_enums/models/schedule_status_model.dart';
import 'package:maori_health/domain/lookup_enums/entities/lookup_enums.dart';

class LookupEnumsModel extends LookupEnums {
  const LookupEnumsModel({
    required super.gender,
    required super.scheduleStatusValue,
    required super.scheduleStatusKey,
    required super.assetStatus,
    required super.assetStatusKey,
    required super.jobType,
    required super.canceledBy,
    required super.cancelReason,
  });

  static List<String> _parseStringList(dynamic value) {
    if (value is List) {
      return value.where((e) => e != null).map((e) => e.toString()).toList();
    }
    return const [];
  }

  static Map<String, String> _parseStringMap(dynamic value) {
    if (value is Map) {
      return value.map((key, value) => MapEntry(key.toString(), value?.toString() ?? ''));
    }
    return const {};
  }

  factory LookupEnumsModel.fromJson(Map<String, dynamic> json) {
    return LookupEnumsModel(
      gender: _parseStringList(json['gender']),
      scheduleStatusValue: ScheduleStatusModel.fromJson(json['schedule_status']),
      scheduleStatusKey: ScheduleStatusModel.fromJson(json['schedule_status_same_key_value']),
      assetStatus: AssetStatusModel.fromJson(json['asset_status']),
      assetStatusKey: AssetStatusModel.fromJson(json['asset_status_same_key_value']),
      jobType: _parseStringMap(json['job_type']),
      canceledBy: _parseStringMap(json['cancel_by']),
      cancelReason: _parseStringMap(json['cancel_reason']),
    );
  }
}

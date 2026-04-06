import 'package:maori_health/domain/lookup_enums/entities/schedule_status.dart';

class ScheduleStatusModel extends ScheduleStatus {
  const ScheduleStatusModel({
    super.active,
    super.cancelled,
    super.completed,
    super.finished,
    super.inprogress,
    super.parked,
  });

  factory ScheduleStatusModel.fromJson(Map<String, dynamic> json) => ScheduleStatusModel(
    active: json["active"],
    cancelled: json["cancelled"],
    completed: json["completed"],
    finished: json["finished"],
    inprogress: json["inprogress"],
    parked: json["parked"],
  );

  Map<String, dynamic> toJson() => {
    'active': active,
    'cancelled': cancelled,
    'completed': completed,
    'finished': finished,
    'inprogress': inprogress,
    'parked': parked,
  };
}

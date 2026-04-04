import 'package:equatable/equatable.dart';

import 'package:maori_health/domain/employee/entities/employee.dart';

/// Single timesheet row from `GET schedules/timesheet` (`data.schedules.data[]`).
class TimeSheet extends Equatable {
  final int id;
  final int? jobListId;
  final int? jobDayId;
  final int? assigneeUserId;
  final int? clientUserId;
  final int? funderId;
  final String? scheduleStartTime;
  final String? scheduleEndTime;
  final String? workStartTime;
  final String? workEndTime;
  final double scheduleTotalTime;
  final double workTotalTime;
  final String? day;
  final String? week;
  final String? jobType;
  final double? payHour;
  final String? travelType;
  final double? travelTime;
  final double? travelDistance;
  final String? visitType;
  final String? batchCreatedAt;
  final int isChecked;
  final String? confirmedAt;
  final String? confirmedBy;
  final String status;
  final int isHoliday;
  final String? cancelDateTime;
  final String? cancelledBy;
  final String? cancelReason;
  final String? cancelNote;
  final int ibtEtApply;
  final int payableCancelled;
  final String? cancelRequestedAt;
  final int? operatorId;
  final String? createdAt;
  final String? updatedAt;
  final String? deletedAt;
  final String? primaryColor;
  final List<String> secondaryColors;
  final Employee? client;
  final Employee? assignee;

  const TimeSheet({
    required this.id,
    this.jobListId,
    this.jobDayId,
    this.assigneeUserId,
    this.clientUserId,
    this.funderId,
    this.scheduleStartTime,
    this.scheduleEndTime,
    this.workStartTime,
    this.workEndTime,
    required this.scheduleTotalTime,
    this.workTotalTime = 0,
    this.day,
    this.week,
    this.jobType,
    this.payHour,
    this.travelType,
    this.travelTime,
    this.travelDistance,
    this.visitType,
    this.batchCreatedAt,
    this.isChecked = 0,
    this.confirmedAt,
    this.confirmedBy,
    required this.status,
    this.isHoliday = 0,
    this.cancelDateTime,
    this.cancelledBy,
    this.cancelReason,
    this.cancelNote,
    this.ibtEtApply = 0,
    this.payableCancelled = 0,
    this.cancelRequestedAt,
    this.operatorId,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.primaryColor,
    this.secondaryColors = const [],
    this.client,
    this.assignee,
  });

  @override
  List<Object?> get props => [
    id,
    scheduleStartTime,
    scheduleEndTime,
    workStartTime,
    workEndTime,
    status,
    primaryColor,
    updatedAt,
  ];
}

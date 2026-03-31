import 'package:equatable/equatable.dart';
import 'package:maori_health/domain/auth/entities/user.dart';
import 'package:maori_health/domain/client/entities/client.dart';

class Schedule extends Equatable {
  final int id;
  final int jobListId;
  final int jobDayId;
  final int assigneeUserId;
  final int clientUserId;
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
  final double payHour;
  final String? travelType;
  final String? travelTime;
  final String? travelDistance;
  final String? visitType;
  final String? batchCreatedAt;
  final int isChecked;
  final String? confirmedAt;
  final String? confirmedBy;
  final String? status;
  final int isHoliday;
  final String? cancelDateTime;
  final String? cancelledBy;
  final String? cancelReason;
  final String? cancelNote;
  final int ibtEtApply;
  final int payableCancelled;
  final String? cancelRequestedAt;
  final int? operatorId;
  final String? primaryColor;
  final List<String> secondaryColors;
  final String? createdAt;
  final String? updatedAt;
  final String? deletedAt;
  final Client? client;
  final User? assignee;

  const Schedule({
    required this.id,
    required this.jobListId,
    required this.jobDayId,
    required this.assigneeUserId,
    required this.clientUserId,
    this.funderId,
    this.scheduleStartTime,
    this.scheduleEndTime,
    this.workStartTime,
    this.workEndTime,
    this.scheduleTotalTime = 0,
    this.workTotalTime = 0,
    this.day,
    this.week,
    this.jobType,
    this.payHour = 0,
    this.travelType,
    this.travelTime,
    this.travelDistance,
    this.visitType,
    this.batchCreatedAt,
    this.isChecked = 0,
    this.confirmedAt,
    this.confirmedBy,
    this.status,
    this.isHoliday = 0,
    this.cancelDateTime,
    this.cancelledBy,
    this.cancelReason,
    this.cancelNote,
    this.ibtEtApply = 0,
    this.payableCancelled = 0,
    this.cancelRequestedAt,
    this.operatorId,
    this.primaryColor,
    this.secondaryColors = const [],
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.client,
    this.assignee,
  });

  @override
  List<Object?> get props => [
    id,
    jobListId,
    jobDayId,
    assigneeUserId,
    clientUserId,
    funderId,
    scheduleStartTime,
    scheduleEndTime,
    workStartTime,
    workEndTime,
    scheduleTotalTime,
    workTotalTime,
    day,
    week,
    jobType,
    payHour,
    travelType,
    travelTime,
    travelDistance,
    visitType,
    batchCreatedAt,
    isChecked,
    confirmedAt,
    confirmedBy,
    status,
    isHoliday,
    cancelDateTime,
    cancelledBy,
    cancelReason,
    cancelNote,
    ibtEtApply,
    payableCancelled,
    cancelRequestedAt,
    operatorId,
    primaryColor,
    secondaryColors,
    createdAt,
    updatedAt,
    deletedAt,
    client,
    assignee,
  ];
}

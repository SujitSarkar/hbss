import 'dart:convert';

import 'package:maori_health/core/utils/data_parse_util.dart';

import 'package:maori_health/data/Client/models/Client_model.dart';
import 'package:maori_health/data/auth/models/user_model.dart';
import 'package:maori_health/domain/dashboard/entities/job.dart';

class JobModel extends Job {
  const JobModel({
    required super.id,
    required super.jobListId,
    required super.jobDayId,
    required super.assigneeUserId,
    required super.clientUserId,
    super.funderId,
    super.scheduleStartTime,
    super.scheduleEndTime,
    super.workStartTime,
    super.workEndTime,
    super.scheduleTotalTime,
    super.workTotalTime,
    super.day,
    super.jobType,
    super.payHour,
    super.travelType,
    super.travelTime,
    super.travelDistance,
    super.visitType,
    super.batchCreatedAt,
    super.isChecked,
    super.confirmedAt,
    super.confirmedBy,
    super.status,
    super.isHoliday,
    super.cancelDateTime,
    super.cancelledBy,
    super.cancelReason,
    super.cancelNote,
    super.ibtEtApply,
    super.payableCancelled,
    super.cancelRequestedAt,
    super.operatorId,
    super.color,
    super.childColors,
    super.createdAt,
    super.updatedAt,
    super.deletedAt,
    super.client,
    super.assignee,
  });

  factory JobModel.fromJson(Map<String, dynamic> json) {
    return JobModel(
      id: DataParseUtil.parseInt(json['id']),
      jobListId: DataParseUtil.parseInt(json['job_list_id']),
      jobDayId: DataParseUtil.parseInt(json['job_day_id']),
      assigneeUserId: DataParseUtil.parseInt(json['assignee_user_id']),
      clientUserId: DataParseUtil.parseInt(json['client_user_id']),
      funderId: DataParseUtil.parseInt(json['funder_id']),
      scheduleStartTime: json['schedule_start_time']?.toString(),
      scheduleEndTime: json['schedule_end_time']?.toString(),
      workStartTime: json['work_start_time']?.toString(),
      workEndTime: json['work_end_time']?.toString(),
      scheduleTotalTime: DataParseUtil.parseDouble(json['schedule_total_time']),
      workTotalTime: DataParseUtil.parseDouble(json['work_total_time']),
      day: json['day']?.toString(),
      jobType: json['job_type']?.toString(),
      payHour: DataParseUtil.parseDouble(json['pay_hour']),
      travelType: json['travel_type']?.toString(),
      travelTime: json['travel_time']?.toString(),
      travelDistance: json['travel_distance']?.toString(),
      visitType: json['visit_type']?.toString(),
      batchCreatedAt: json['batch_created_at']?.toString(),
      isChecked: DataParseUtil.parseInt(json['is_checked']),
      confirmedAt: json['confirmed_at']?.toString(),
      confirmedBy: json['confirmed_by']?.toString(),
      status: json['status']?.toString(),
      isHoliday: DataParseUtil.parseInt(json['is_holiday']),
      cancelDateTime: json['cancel_date_time']?.toString(),
      cancelledBy: json['cancelled_by']?.toString(),
      cancelReason: json['cancel_reason']?.toString(),
      cancelNote: json['cancel_note']?.toString(),
      ibtEtApply: DataParseUtil.parseInt(json['ibt_et_apply']),
      payableCancelled: DataParseUtil.parseInt(json['payable_cancelled']),
      cancelRequestedAt: json['cancel_requested_at']?.toString(),
      operatorId: DataParseUtil.parseInt(json['operator_id']),
      color: json['color']?.toString(),
      childColors: _parseChildColors(json['child_colors']),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      deletedAt: json['deleted_at']?.toString(),
      client: json['client'] != null ? ClientModel.fromJson(json['client'] as Map<String, dynamic>) : null,
      assignee: json['assignee'] != null ? UserModel.fromJson(json['assignee'] as Map<String, dynamic>) : null,
    );
  }

  static List<String> _parseChildColors(dynamic value) {
    if (value == null) return [];
    if (value is List) return value.map((e) => e.toString()).toList();
    if (value is String) {
      try {
        final decoded = jsonDecode(value);
        if (decoded is List) return decoded.map((e) => e.toString()).toList();
      } catch (_) {}
    }
    return [];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'job_list_id': jobListId,
      'job_day_id': jobDayId,
      'assignee_user_id': assigneeUserId,
      'client_user_id': clientUserId,
      'funder_id': funderId,
      'schedule_start_time': scheduleStartTime,
      'schedule_end_time': scheduleEndTime,
      'work_start_time': workStartTime,
      'work_end_time': workEndTime,
      'schedule_total_time': scheduleTotalTime,
      'work_total_time': workTotalTime,
      'day': day,
      'job_type': jobType,
      'pay_hour': payHour,
      'travel_type': travelType,
      'travel_time': travelTime,
      'travel_distance': travelDistance,
      'visit_type': visitType,
      'batch_created_at': batchCreatedAt,
      'is_checked': isChecked,
      'confirmed_at': confirmedAt,
      'confirmed_by': confirmedBy,
      'status': status,
      'is_holiday': isHoliday,
      'cancel_date_time': cancelDateTime,
      'cancelled_by': cancelledBy,
      'cancel_reason': cancelReason,
      'cancel_note': cancelNote,
      'ibt_et_apply': ibtEtApply,
      'payable_cancelled': payableCancelled,
      'cancel_requested_at': cancelRequestedAt,
      'operator_id': operatorId,
      'color': color,
      'child_colors': childColors,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'deleted_at': deletedAt,
      'client': (client as ClientModel?)?.toJson(),
      'assignee': (assignee as UserModel?)?.toJson(),
    };
  }
}

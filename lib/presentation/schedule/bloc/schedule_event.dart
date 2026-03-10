part of 'schedule_bloc.dart';

sealed class ScheduleEvent extends Equatable {
  const ScheduleEvent();

  @override
  List<Object?> get props => [];
}

class SchedulesLoadEvent extends ScheduleEvent {
  final int? clientUserId;
  final String? startDate;
  final String? endDate;

  const SchedulesLoadEvent({this.clientUserId, this.startDate, this.endDate});

  @override
  List<Object?> get props => [clientUserId, startDate, endDate];
}

class SchedulesLoadMoreEvent extends ScheduleEvent {
  final int? clientUserId;
  final String? startDate;
  final String? endDate;

  const SchedulesLoadMoreEvent({this.clientUserId, this.startDate, this.endDate});

  @override
  List<Object?> get props => [clientUserId, startDate, endDate];
}

class ScheduleDetailsLoadEvent extends ScheduleEvent {
  final int scheduleId;

  const ScheduleDetailsLoadEvent({required this.scheduleId});

  @override
  List<Object> get props => [scheduleId];
}

class ScheduleAcceptEvent extends ScheduleEvent {
  final int scheduleId;

  const ScheduleAcceptEvent({required this.scheduleId});

  @override
  List<Object> get props => [scheduleId];
}

class ScheduleStartEvent extends ScheduleEvent {
  final int scheduleId;

  const ScheduleStartEvent({required this.scheduleId});

  @override
  List<Object> get props => [scheduleId];
}

class ScheduleFinishEvent extends ScheduleEvent {
  final int scheduleId;

  const ScheduleFinishEvent({required this.scheduleId});

  @override
  List<Object> get props => [scheduleId];
}

class ScheduleCancelEvent extends ScheduleEvent {
  final int scheduleId;
  final String cancelBy;
  final String? cancelReason;
  final int hour;
  final int minute;
  final String reason;

  const ScheduleCancelEvent({
    required this.scheduleId,
    required this.cancelBy,
    required this.cancelReason,
    required this.hour,
    required this.minute,
    required this.reason,
  });
  @override
  List<Object?> get props => [scheduleId, cancelBy, cancelReason, hour, minute, reason];
}

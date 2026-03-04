part of 'schedule_bloc.dart';

sealed class ScheduleEvent extends Equatable {
  const ScheduleEvent();

  @override
  List<Object> get props => [];
}

class ScheduleDetailsLoadEvent extends ScheduleEvent {
  final int scheduleId;

  const ScheduleDetailsLoadEvent({required this.scheduleId});

  @override
  List<Object> get props => [scheduleId];
}

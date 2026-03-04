part of 'schedule_bloc.dart';

sealed class ScheduleState extends Equatable {
  const ScheduleState();

  @override
  List<Object?> get props => [];
}

class ScheduleInitial extends ScheduleState {}

class ScheduleLoadingState extends ScheduleState {}

class ScheduleDetailsLoadingState extends ScheduleState {}

class ScheduleLoadedState extends ScheduleState {
  final List<JobModel> schedules;
  final JobModel? schedule;

  const ScheduleLoadedState({this.schedules = const [], this.schedule});

  ScheduleLoadedState copyWith({List<JobModel>? schedules, JobModel? schedule}) {
    return ScheduleLoadedState(schedules: schedules ?? this.schedules, schedule: schedule ?? this.schedule);
  }

  @override
  List<Object?> get props => [schedules, schedule];
}

class ScheduleErrorState extends ScheduleState {
  final String errorMessage;

  const ScheduleErrorState(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}

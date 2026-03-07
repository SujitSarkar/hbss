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
  final List<ScheduleModel> schedules;
  final int currentPage;
  final int lastPage;
  final ScheduleModel? scheduleDetails;
  final bool actionLoading;
  final bool isLoadingMore;

  const ScheduleLoadedState({
    this.schedules = const [],
    this.currentPage = 1,
    this.lastPage = 1,
    this.scheduleDetails,
    this.actionLoading = false,
    this.isLoadingMore = false,
  });

  bool get hasMore => currentPage < lastPage;

  ScheduleLoadedState copyWith({
    List<ScheduleModel>? schedules,
    int? currentPage,
    int? lastPage,
    ScheduleModel? scheduleDetails,
    bool? actionLoading,
    bool? isLoadingMore,
  }) {
    return ScheduleLoadedState(
      schedules: schedules ?? this.schedules,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      scheduleDetails: scheduleDetails ?? this.scheduleDetails,
      actionLoading: actionLoading ?? this.actionLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [schedules, scheduleDetails, actionLoading, isLoadingMore];
}

class ScheduleAcceptSuccessState extends ScheduleState {
  final ScheduleModel schedule;

  const ScheduleAcceptSuccessState({required this.schedule});

  @override
  List<Object?> get props => [schedule];
}

class ScheduleStartSuccessState extends ScheduleState {
  final ScheduleModel schedule;

  const ScheduleStartSuccessState({required this.schedule});

  @override
  List<Object?> get props => [schedule];
}

class ScheduleFinishSuccessState extends ScheduleState {
  final ScheduleModel schedule;

  const ScheduleFinishSuccessState({required this.schedule});

  @override
  List<Object?> get props => [schedule];
}

class ScheduleCancelSuccessState extends ScheduleState {
  final ScheduleModel schedule;

  const ScheduleCancelSuccessState({required this.schedule});

  @override
  List<Object?> get props => [schedule];
}

class ScheduleErrorState extends ScheduleState {
  final String errorMessage;

  const ScheduleErrorState(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}

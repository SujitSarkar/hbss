import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:maori_health/core/config/app_strings.dart';

import 'package:maori_health/data/dashboard/models/schedule_model.dart';
import 'package:maori_health/domain/schedule/usecases/get_schedules_usecase.dart';
import 'package:maori_health/domain/schedule/usecases/get_schedule_details_usecase.dart';
import 'package:maori_health/domain/schedule/usecases/accept_schedule_usecase.dart';
import 'package:maori_health/domain/schedule/usecases/start_schedule_usecase.dart';
import 'package:maori_health/domain/schedule/usecases/finish_schedule_usecase.dart';
import 'package:maori_health/domain/schedule/usecases/cancel_schedule_usecase.dart';

part 'schedule_event.dart';
part 'schedule_state.dart';

class ScheduleBloc extends Bloc<ScheduleEvent, ScheduleState> {
  final GetSchedulesUsecase _getSchedulesUsecase;
  final GetScheduleDetailsUsecase _getScheduleDetailsUsecase;
  final AcceptScheduleUsecase _acceptScheduleUsecase;
  final StartScheduleUsecase _startScheduleUsecase;
  final FinishScheduleUsecase _finishScheduleUsecase;
  final CancelScheduleUsecase _cancelScheduleUsecase;
  ScheduleBloc({
    required GetSchedulesUsecase getSchedulesUsecase,
    required GetScheduleDetailsUsecase getScheduleDetailsUsecase,
    required AcceptScheduleUsecase acceptScheduleUsecase,
    required StartScheduleUsecase startScheduleUsecase,
    required FinishScheduleUsecase finishScheduleUsecase,
    required CancelScheduleUsecase cancelScheduleUsecase,
  }) : _getSchedulesUsecase = getSchedulesUsecase,
       _getScheduleDetailsUsecase = getScheduleDetailsUsecase,
       _acceptScheduleUsecase = acceptScheduleUsecase,
       _startScheduleUsecase = startScheduleUsecase,
       _finishScheduleUsecase = finishScheduleUsecase,
       _cancelScheduleUsecase = cancelScheduleUsecase,
       super(ScheduleInitial()) {
    on<SchedulesLoadEvent>(_onSchedulesLoadEvent);
    on<SchedulesLoadMoreEvent>(_onSchedulesLoadMoreEvent);
    on<ScheduleDetailsLoadEvent>(_onScheduleDetailsLoadEvent);
    on<ScheduleAcceptEvent>(_onScheduleAcceptEvent);
    on<ScheduleStartEvent>(_onScheduleStartEvent);
    on<ScheduleFinishEvent>(_onScheduleFinishEvent);
    on<ScheduleCancelEvent>(_onScheduleCancelEvent);
  }

  Future<void> _onSchedulesLoadEvent(SchedulesLoadEvent event, Emitter<ScheduleState> emit) async {
    emit(ScheduleLoadingState());

    final result = await _getSchedulesUsecase.call(
      page: 1,
      clientUserId: event.clientUserId,
      startDate: event.startDate,
      endDate: event.endDate,
    );
    await result.fold(
      onFailure: (error) async {
        emit(ScheduleErrorState(error.errorMessage ?? AppStrings.somethingWentWrong));
      },
      onSuccess: (response) async {
        emit(
          ScheduleLoadedState(
            schedules: response.schedules,
            currentPage: response.currentPage,
            lastPage: response.lastPage,
          ),
        );
      },
    );
  }

  Future<void> _onSchedulesLoadMoreEvent(SchedulesLoadMoreEvent event, Emitter<ScheduleState> emit) async {
    final currentState = state;
    if (currentState is! ScheduleLoadedState || !currentState.hasMore || currentState.isLoadingMore) return;

    emit(currentState.copyWith(isLoadingMore: true));

    final nextPage = currentState.currentPage + 1;
    final result = await _getSchedulesUsecase.call(
      page: nextPage,
      clientUserId: event.clientUserId,
      startDate: event.startDate,
      endDate: event.endDate,
    );

    await result.fold(
      onFailure: (error) async {
        emit(currentState.copyWith(isLoadingMore: false));
      },
      onSuccess: (response) async {
        emit(
          ScheduleLoadedState(
            schedules: [...currentState.schedules, ...response.schedules],
            currentPage: response.currentPage,
            lastPage: response.lastPage,
          ),
        );
      },
    );
  }

  Future<void> _onScheduleDetailsLoadEvent(ScheduleDetailsLoadEvent event, Emitter<ScheduleState> emit) async {
    final currentState = state;
    if (currentState is ScheduleDetailsLoadingState) return;

    if (currentState is ScheduleLoadedState) {
      if (currentState.actionLoading) return;

      emit(ScheduleDetailsLoadingState());
      final result = await _getScheduleDetailsUsecase.call(scheduleId: event.scheduleId);
      await result.fold(
        onFailure: (error) async {
          emit(ScheduleErrorState(error.errorMessage ?? AppStrings.somethingWentWrong));
          emit(currentState);
        },
        onSuccess: (data) async {
          emit(currentState.copyWith(scheduleDetails: data));
        },
      );
    }
  }

  Future<void> _onScheduleAcceptEvent(ScheduleAcceptEvent event, Emitter<ScheduleState> emit) async {
    final currentState = state;

    if (currentState is ScheduleLoadedState) {
      if (currentState.actionLoading) return;

      emit(currentState.copyWith(actionLoading: true));

      final result = await _acceptScheduleUsecase.call(scheduleId: event.scheduleId);
      await result.fold(
        onFailure: (error) async {
          emit(ScheduleErrorState(error.errorMessage ?? AppStrings.somethingWentWrong));
          emit(currentState);
        },
        onSuccess: (updatedSchedule) async {
          emit(ScheduleAcceptSuccessState(schedule: updatedSchedule));

          final int updatedIndex = currentState.schedules.indexWhere((schedule) => schedule.id == event.scheduleId);

          if (updatedIndex != -1) {
            final updatedSchedules = List<ScheduleModel>.from(currentState.schedules);
            updatedSchedules[updatedIndex] = updatedSchedule;
            emit(currentState.copyWith(schedules: updatedSchedules));
          } else {
            emit(currentState);
          }
        },
      );
    }
  }

  Future<void> _onScheduleStartEvent(ScheduleStartEvent event, Emitter<ScheduleState> emit) async {
    final currentState = state;

    if (currentState is ScheduleLoadedState) {
      if (currentState.actionLoading) return;

      emit(currentState.copyWith(actionLoading: true));

      final result = await _startScheduleUsecase.call(scheduleId: event.scheduleId);
      await result.fold(
        onFailure: (error) async {
          emit(ScheduleErrorState(error.errorMessage ?? AppStrings.somethingWentWrong));
          emit(currentState);
        },
        onSuccess: (updatedSchedule) async {
          emit(ScheduleStartSuccessState(schedule: updatedSchedule));

          final int updatedIndex = currentState.schedules.indexWhere((schedule) => schedule.id == event.scheduleId);

          if (updatedIndex != -1) {
            final updatedSchedules = List<ScheduleModel>.from(currentState.schedules);
            updatedSchedules[updatedIndex] = updatedSchedule;
            emit(currentState.copyWith(schedules: updatedSchedules));
          } else {
            emit(currentState);
          }
        },
      );
    }
  }

  Future<void> _onScheduleFinishEvent(ScheduleFinishEvent event, Emitter<ScheduleState> emit) async {
    final currentState = state;

    if (currentState is ScheduleLoadedState) {
      if (currentState.actionLoading) return;

      emit(currentState.copyWith(actionLoading: true));

      final result = await _finishScheduleUsecase.call(scheduleId: event.scheduleId);
      await result.fold(
        onFailure: (error) async {
          emit(ScheduleErrorState(error.errorMessage ?? AppStrings.somethingWentWrong));
          emit(currentState);
        },
        onSuccess: (updatedSchedule) async {
          emit(ScheduleFinishSuccessState(schedule: updatedSchedule));

          final int updatedIndex = currentState.schedules.indexWhere((schedule) => schedule.id == event.scheduleId);

          if (updatedIndex != -1) {
            final updatedSchedules = List<ScheduleModel>.from(currentState.schedules);
            updatedSchedules[updatedIndex] = updatedSchedule;
            emit(currentState.copyWith(schedules: updatedSchedules));
          } else {
            emit(currentState);
          }
        },
      );
    }
  }

  Future<void> _onScheduleCancelEvent(ScheduleCancelEvent event, Emitter<ScheduleState> emit) async {
    final currentState = state;

    if (currentState is ScheduleLoadedState) {
      if (currentState.actionLoading) return;

      emit(currentState.copyWith(actionLoading: true));

      final result = await _cancelScheduleUsecase.call(
        scheduleId: event.scheduleId,
        cancelBy: event.cancelBy,
        cancelReason: event.cancelReason,
        hour: event.hour,
        minute: event.minute,
        reason: event.reason,
      );
      await result.fold(
        onFailure: (error) async {
          emit(ScheduleErrorState(error.errorMessage ?? AppStrings.somethingWentWrong));
          emit(currentState);
        },
        onSuccess: (updatedSchedule) async {
          emit(ScheduleCancelSuccessState(schedule: updatedSchedule));

          final int updatedIndex = currentState.schedules.indexWhere((schedule) => schedule.id == event.scheduleId);

          if (updatedIndex != -1) {
            final updatedSchedules = List<ScheduleModel>.from(currentState.schedules);
            updatedSchedules[updatedIndex] = updatedSchedule;
            emit(currentState.copyWith(schedules: updatedSchedules));
          } else {
            emit(currentState);
          }
        },
      );
    }
  }
}

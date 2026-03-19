import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:maori_health/core/config/app_strings.dart';
import 'package:maori_health/domain/timesheet/repositories/timesheet_repository.dart';

import 'package:maori_health/presentation/timesheet/bloc/timesheet_event.dart';
import 'package:maori_health/presentation/timesheet/bloc/timesheet_state.dart';

class TimeSheetBloc extends Bloc<TimeSheetEvent, TimeSheetState> {
  final TimeSheetRepository _repository;

  TimeSheetBloc({required TimeSheetRepository repository})
    : _repository = repository,
      super(const TimeSheetLoadingState()) {
    on<TimeSheetDateAndClientChanged>(_onDateAndClientChanged);
    on<TimeSheetLoadMore>(_onLoadMore);
  }

  Future<void> _onDateAndClientChanged(TimeSheetDateAndClientChanged event, Emitter<TimeSheetState> emit) async {
    emit(const TimeSheetLoadingState());

    final result = await _repository.getTimeSheets(
      clientUserId: event.client?.id,
      startDate: event.startDate,
      endDate: event.endDate,
      page: 1,
    );

    await result.fold(
      onFailure: (error) async {
        emit(TimeSheetErrorState(error.errorMessage ?? AppStrings.somethingWentWrong));
      },
      onSuccess: (response) async {
        emit(
          TimeSheetLoadedState(
            timeSheets: response.timeSheets,
            currentPage: response.currentPage,
            lastPage: response.lastPage,
            totalSchedules: response.totalSchedules,
            totalTime: response.totalTime,
          ),
        );
      },
    );
  }

  Future<void> _onLoadMore(TimeSheetLoadMore event, Emitter<TimeSheetState> emit) async {
    final currentState = state;
    if (currentState is! TimeSheetLoadedState || !currentState.hasMore || currentState.isLoadingMore) return;

    emit(currentState.copyWith(isLoadingMore: true));

    final nextPage = currentState.currentPage + 1;
    final result = await _repository.getTimeSheets(
      clientUserId: event.client?.id,
      startDate: event.startDate,
      endDate: event.endDate,
      page: nextPage,
    );

    await result.fold(
      onFailure: (error) async {
        emit(currentState.copyWith(isLoadingMore: false));
      },
      onSuccess: (response) async {
        emit(
          TimeSheetLoadedState(
            timeSheets: [...currentState.timeSheets, ...response.timeSheets],
            currentPage: response.currentPage,
            lastPage: response.lastPage,
            totalSchedules: currentState.totalSchedules + response.totalSchedules,
            totalTime: currentState.totalTime + response.totalTime,
          ),
        );
      },
    );
  }
}

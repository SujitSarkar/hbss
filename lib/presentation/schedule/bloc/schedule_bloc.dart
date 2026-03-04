import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:maori_health/core/config/app_strings.dart';
import 'package:maori_health/data/dashboard/models/job_model.dart';
import 'package:maori_health/domain/schedule/usecases/get_schedule_details_usecase.dart';

part 'schedule_event.dart';
part 'schedule_state.dart';

class ScheduleBloc extends Bloc<ScheduleEvent, ScheduleState> {
  final GetScheduleDetailsUsecase _getScheduleDetailsUsecase;
  ScheduleBloc({required GetScheduleDetailsUsecase getScheduleDetailsUsecase})
    : _getScheduleDetailsUsecase = getScheduleDetailsUsecase,
      super(ScheduleInitial()) {
    on<ScheduleDetailsLoadEvent>(_onScheduleDetailsLoadEvent);
  }

  Future<void> _onScheduleDetailsLoadEvent(ScheduleDetailsLoadEvent event, Emitter<ScheduleState> emit) async {
    final currentState = state;

    emit(ScheduleDetailsLoadingState());
    final result = await _getScheduleDetailsUsecase.call(scheduleId: event.scheduleId);
    await result.fold(
      onFailure: (error) async {
        emit(ScheduleErrorState(error.errorMessage ?? AppStrings.somethingWentWrong));
        emit(currentState);
      },
      onSuccess: (data) async {
        if (currentState is ScheduleLoadedState) {
          emit(currentState.copyWith(schedule: data));
        } else {
          emit(ScheduleLoadedState(schedule: data));
        }
      },
    );
  }
}

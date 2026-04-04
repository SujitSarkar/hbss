import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:maori_health/domain/dashboard/usecases/get_dashboard_usecase.dart';
import 'package:maori_health/presentation/dashboard/bloc/dashboard_event.dart';
import 'package:maori_health/presentation/dashboard/bloc/dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetDashboardUsecase _getDashboardUsecase;

  DashboardBloc({required GetDashboardUsecase getDashboardUsecase})
    : _getDashboardUsecase = getDashboardUsecase,
      super(const DashboardInitialState()) {
    on<DashboardLoadEvent>(_onLoadDashboardEvent);
  }

  Future<void> _onLoadDashboardEvent(DashboardLoadEvent event, Emitter<DashboardState> emit) async {
    emit(const DashboardLoadingState());

    final result = await _getDashboardUsecase();

    await result.fold(
      onFailure: (error) async {
        emit(DashboardErrorState(message: error.errorMessage ?? 'Failed to load dashboard'));
      },
      onSuccess: (dashboardData) async {
        emit(DashboardLoadedState(dashboardData: dashboardData));
      },
    );
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:maori_health/core/config/app_strings.dart';
import 'package:maori_health/domain/employee/usecases/get_employees_usecase.dart';

import 'package:maori_health/presentation/employee/bloc/employee_event.dart';
import 'package:maori_health/presentation/employee/bloc/employee_state.dart';

class EmployeeBloc extends Bloc<EmployeeEvent, EmployeeState> {
  final GetEmployeesUsecase _getEmployeesUsecase;

  EmployeeBloc({required GetEmployeesUsecase getEmployeesUsecase})
    : _getEmployeesUsecase = getEmployeesUsecase,
      super(const EmployeeLoadingState()) {
    on<LoadEmployeeEvent>(_onLoadEmployees);
  }

  Future<void> _onLoadEmployees(LoadEmployeeEvent event, Emitter<EmployeeState> emit) async {
    emit(const EmployeeLoadingState());
    final result = await _getEmployeesUsecase();
    await result.fold(
      onFailure: (error) async {
        emit(EmployeeErrorState(error.errorMessage ?? AppStrings.somethingWentWrong));
      },
      onSuccess: (employees) async {
        emit(EmployeeLoadedState(employees));
      },
    );
  }
}

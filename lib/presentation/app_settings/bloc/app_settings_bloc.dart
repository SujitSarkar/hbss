import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:maori_health/core/config/app_strings.dart';
import 'package:maori_health/domain/app_settings/entities/app_settings.dart';
import 'package:maori_health/domain/app_settings/usecases/get_app_settings_usecase.dart';

part 'app_settings_event.dart';
part 'app_settings_state.dart';

class AppSettingsBloc extends Bloc<AppSettingsEvent, AppSettingsState> {
  final GetAppSettingsUsecase _getAppSettingsUsecase;

  AppSettingsBloc({required GetAppSettingsUsecase getAppSettingsUsecase})
    : _getAppSettingsUsecase = getAppSettingsUsecase,
      super(AppSettingsInitial()) {
    on<LoadAppSettingsEvent>(_onLoadAppSettings);
  }

  Future<void> _onLoadAppSettings(LoadAppSettingsEvent event, Emitter<AppSettingsState> emit) async {
    emit(AppSettingsLoadingState());
    final result = await _getAppSettingsUsecase.call();
    await result.fold(
      onFailure: (error) async {
        emit(AppSettingsErrorState(errorMessage: (error.errorMessage ?? AppStrings.somethingWentWrong)));
      },
      onSuccess: (appSettings) async {
        emit(AppSettingsLoadedState(appSettings: appSettings));
      },
    );
  }
}

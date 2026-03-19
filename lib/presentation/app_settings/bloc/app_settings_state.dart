part of 'app_settings_bloc.dart';

sealed class AppSettingsState extends Equatable {
  const AppSettingsState();

  @override
  List<Object> get props => [];
}

final class AppSettingsInitial extends AppSettingsState {}

class AppSettingsLoadingState extends AppSettingsState {}

class AppSettingsLoadedState extends AppSettingsState {
  final AppSettings appSettings;

  const AppSettingsLoadedState({required this.appSettings});

  @override
  List<Object> get props => [appSettings];
}

class AppSettingsErrorState extends AppSettingsState {
  final String errorMessage;

  const AppSettingsErrorState({required this.errorMessage});

  @override
  List<Object> get props => [errorMessage];
}

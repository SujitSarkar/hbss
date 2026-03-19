part of 'app_settings_bloc.dart';

sealed class AppSettingsEvent extends Equatable {
  const AppSettingsEvent();

  @override
  List<Object> get props => [];
}

class LoadAppSettingsEvent extends AppSettingsEvent {
  const LoadAppSettingsEvent();

  @override
  List<Object> get props => [];
}

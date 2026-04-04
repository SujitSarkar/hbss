import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:maori_health/domain/app/usecases/get_saved_theme_mode_usecase.dart';
import 'package:maori_health/domain/app/usecases/persist_theme_mode_usecase.dart';
import 'package:maori_health/presentation/app/bloc/app_event.dart';
import 'package:maori_health/presentation/app/bloc/app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  final GetSavedThemeModeUsecase _getSavedThemeModeUsecase;
  final PersistThemeModeUsecase _persistThemeModeUsecase;

  AppBloc({
    required GetSavedThemeModeUsecase getSavedThemeModeUsecase,
    required PersistThemeModeUsecase persistThemeModeUsecase,
  }) : _getSavedThemeModeUsecase = getSavedThemeModeUsecase,
       _persistThemeModeUsecase = persistThemeModeUsecase,
       super(const AppState()) {
    on<AppStarted>(_onAppStarted);
    on<ThemeModeChanged>(_onThemeModeChanged);
  }

  Future<void> _onAppStarted(AppStarted event, Emitter<AppState> emit) async {
    final savedTheme = _getSavedThemeModeUsecase();
    emit(state.copyWith(themeMode: _parseThemeMode(savedTheme)));
  }

  Future<void> _onThemeModeChanged(ThemeModeChanged event, Emitter<AppState> emit) async {
    await _persistThemeModeUsecase(event.themeMode.name);
    emit(state.copyWith(themeMode: event.themeMode));
  }

  ThemeMode _parseThemeMode(String? value) {
    return ThemeMode.values.firstWhere((mode) => mode.name == value, orElse: () => ThemeMode.light);
  }
}

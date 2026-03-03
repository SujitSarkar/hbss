import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:maori_health/core/config/app_strings.dart';
import 'package:maori_health/domain/auth/repositories/auth_repository.dart';

import 'package:maori_health/presentation/auth/bloc/auth_event.dart';
import 'package:maori_health/presentation/auth/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc({required AuthRepository authRepository})
    : _authRepository = authRepository,
      super(const AuthLoadingState()) {
    on<AuthLocalLoginEvent>(_onLocalLoginEvent);
    on<AuthLoginEvent>(_onLoginEvent);
    on<AuthChangePasswordEvent>(_onChangePasswordEvent);
    on<AuthForgotPasswordEvent>(_onForgotPasswordEvent);
    on<AuthVerifyOtpEvent>(_onVerifyOtpEvent);
    on<AuthResetPasswordEvent>(_onResetPasswordEvent);
    on<AuthLogoutEvent>(_onLogoutEvent);
  }

  Future<void> _onLocalLoginEvent(AuthLocalLoginEvent event, Emitter<AuthState> emit) async {
    final result = await _authRepository.getLocalLogin();
    await result.fold(
      onFailure: (_) async => emit(const UnAuthenticatedState()),
      onSuccess: (user) async => emit(AuthenticatedState(user: user)),
    );
  }

  Future<void> _onLoginEvent(AuthLoginEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoadingState());

    final result = await _authRepository.login(email: event.email, password: event.password);
    await result.fold(
      onFailure: (error) async {
        emit(AuthErrorState(error.errorMessage ?? AppStrings.somethingWentWrong));
      },
      onSuccess: (response) async {
        emit(AuthenticatedState(user: response.user));
      },
    );
  }

  Future<void> _onChangePasswordEvent(AuthChangePasswordEvent event, Emitter<AuthState> emit) async {
    final currentUser = state.user;
    if (currentUser == null) return;

    emit(UpdatePassLoadingState());

    final result = await _authRepository.updatePassword(
      oldPassword: event.oldPassword,
      newPassword: event.newPassword,
      confirmPassword: event.confirmPassword,
    );

    await result.fold(
      onFailure: (error) async {
        emit(AuthErrorState(error.errorMessage ?? AppStrings.somethingWentWrong, user: currentUser));
      },
      onSuccess: (message) async {
        emit(ChangePassSuccessState(user: currentUser, message: message));
        await Future.delayed(const Duration(milliseconds: 100));
        emit(AuthenticatedState(user: currentUser));
      },
    );
  }

  Future<void> _onForgotPasswordEvent(AuthForgotPasswordEvent event, Emitter<AuthState> emit) async {
    final currentState = state;
    if (currentState is AuthForgotPasswordLoadingState) return;

    emit(const AuthForgotPasswordLoadingState());
    final result = await _authRepository.forgotPassword(email: event.email);

    await result.fold(
      onFailure: (error) async {
        emit(AuthErrorState(error.errorMessage ?? AppStrings.somethingWentWrong));
      },
      onSuccess: (response) async {
        emit(AuthOtpSentSuccessState(email: event.email, message: response.message));
      },
    );
  }

  Future<void> _onVerifyOtpEvent(AuthVerifyOtpEvent event, Emitter<AuthState> emit) async {
    final currentState = state;
    if (currentState is AuthForgotPasswordLoadingState) return;

    emit(const AuthForgotPasswordLoadingState());
    final result = await _authRepository.verifyOtp(email: event.email, otp: event.otp);

    await result.fold(
      onFailure: (error) async {
        emit(AuthErrorState(error.errorMessage ?? AppStrings.somethingWentWrong));
      },
      onSuccess: (response) async {
        emit(AuthOtpVerifiedState(email: event.email, message: response.message));
      },
    );
  }

  Future<void> _onResetPasswordEvent(AuthResetPasswordEvent event, Emitter<AuthState> emit) async {
    final currentState = state;
    if (currentState is AuthForgotPasswordLoadingState) return;

    emit(const AuthForgotPasswordLoadingState());
    final result = await _authRepository.resetPassword(
      email: event.email,
      newPassword: event.newPassword,
      confirmPassword: event.confirmPassword,
    );

    await result.fold(
      onFailure: (error) async {
        emit(AuthErrorState(error.errorMessage ?? AppStrings.somethingWentWrong));
      },
      onSuccess: (response) async {
        emit(AuthResetPasswordSuccessState(message: response.message));
      },
    );
  }

  Future<void> _onLogoutEvent(AuthLogoutEvent event, Emitter<AuthState> emit) async {
    final currentUser = state.user;
    emit(const AuthLoadingState());

    final success = await _authRepository.logout();
    if (success) {
      emit(const UnAuthenticatedState());
    } else if (currentUser != null) {
      emit(AuthenticatedState(user: currentUser));
    } else {
      emit(const UnAuthenticatedState());
    }
  }
}

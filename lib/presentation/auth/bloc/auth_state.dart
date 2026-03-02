import 'package:equatable/equatable.dart';

import 'package:maori_health/domain/auth/entities/user.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  User? get user => null;

  @override
  List<Object?> get props => [];
}

class AuthLoadingState extends AuthState {
  const AuthLoadingState();
}

class AuthenticatedState extends AuthState {
  @override
  final User user;

  const AuthenticatedState({required this.user});

  @override
  List<Object?> get props => [user];
}

class UnAuthenticatedState extends AuthState {
  const UnAuthenticatedState();
}

class AuthErrorState extends AuthState {
  final String errorMessage;
  @override
  final User? user;

  const AuthErrorState(this.errorMessage, {this.user});

  @override
  List<Object?> get props => [errorMessage, user];
}

class UpdatePassLoadingState extends AuthState {
  const UpdatePassLoadingState();

  @override
  List<Object?> get props => [user];
}

class ChangePassSuccessState extends AuthState {
  @override
  final User user;
  final String message;

  const ChangePassSuccessState({required this.user, required this.message});

  @override
  List<Object?> get props => [user, message];
}

class AuthForgotPasswordLoadingState extends AuthState {
  const AuthForgotPasswordLoadingState();
}

class AuthOtpSentSuccessState extends AuthState {
  final String email;
  final String message;
  const AuthOtpSentSuccessState({required this.email, required this.message});

  @override
  List<Object?> get props => [email, message];
}

class AuthOtpVerifiedState extends AuthState {
  final String email;
  final String message;
  const AuthOtpVerifiedState({required this.email, required this.message});

  @override
  List<Object?> get props => [email, message];
}

class AuthResetPasswordSuccessState extends AuthState {
  final String message;
  const AuthResetPasswordSuccessState({required this.message});

  @override
  List<Object?> get props => [message];
}

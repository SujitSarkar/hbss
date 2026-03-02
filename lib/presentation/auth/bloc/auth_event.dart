import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthLocalLoginEvent extends AuthEvent {
  const AuthLocalLoginEvent();
}

class AuthLoginEvent extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginEvent({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class AuthLogoutEvent extends AuthEvent {
  const AuthLogoutEvent();
}

class AuthChangePasswordEvent extends AuthEvent {
  final String oldPassword;
  final String newPassword;
  final String confirmPassword;

  const AuthChangePasswordEvent({required this.oldPassword, required this.newPassword, required this.confirmPassword});

  @override
  List<Object?> get props => [oldPassword, newPassword, confirmPassword];
}

class AuthForgotPasswordEvent extends AuthEvent {
  final String email;

  const AuthForgotPasswordEvent({required this.email});

  @override
  List<Object?> get props => [email];
}

class AuthVerifyOtpEvent extends AuthEvent {
  final String email;
  final String otp;

  const AuthVerifyOtpEvent({required this.email, required this.otp});

  @override
  List<Object?> get props => [email, otp];
}

class AuthResetPasswordEvent extends AuthEvent {
  final String email;
  final String newPassword;
  final String confirmPassword;

  const AuthResetPasswordEvent({required this.email, required this.newPassword, required this.confirmPassword});

  @override
  List<Object?> get props => [email, newPassword, confirmPassword];
}

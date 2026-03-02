import 'package:maori_health/core/error/failures.dart';
import 'package:maori_health/core/result/result.dart';
import 'package:maori_health/domain/auth/entities/forgot_pass_response.dart';

import 'package:maori_health/domain/auth/entities/login_response.dart';
import 'package:maori_health/domain/auth/entities/user.dart';

abstract class AuthRepository {
  Future<Result<AppError, LoginResponse>> login({required String email, required String password});
  Future<Result<AppError, User>> getLocalLogin();
  Future<Result<AppError, String>> updatePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  });

  Future<Result<AppError, ForgotPasswordResponse>> forgotPassword({required String email});
  Future<Result<AppError, ForgotPasswordResponse>> verifyOtp({required String email, required String otp});
  Future<Result<AppError, ForgotPasswordResponse>> resetPassword({
    required String email,
    required String newPassword,
    required String confirmPassword,
  });
  Future<bool> logout();
}

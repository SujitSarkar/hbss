import 'package:maori_health/core/error/failures.dart';
import 'package:maori_health/core/result/result.dart';
import 'package:maori_health/domain/auth/entities/forgot_pass_response.dart';
import 'package:maori_health/domain/auth/repositories/auth_repository.dart';

class ResetPasswordUsecase {
  final AuthRepository _repository;

  ResetPasswordUsecase({required AuthRepository repository}) : _repository = repository;

  Future<Result<AppError, ForgotPasswordResponse>> call({
    required String email,
    required String newPassword,
    required String confirmPassword,
  }) {
    return _repository.resetPassword(email: email, newPassword: newPassword, confirmPassword: confirmPassword);
  }
}

import 'package:maori_health/core/error/failures.dart';
import 'package:maori_health/core/result/result.dart';
import 'package:maori_health/domain/auth/entities/forgot_pass_response.dart';
import 'package:maori_health/domain/auth/repositories/auth_repository.dart';

class VerifyOtpUsecase {
  final AuthRepository _repository;

  VerifyOtpUsecase({required AuthRepository repository}) : _repository = repository;

  Future<Result<AppError, ForgotPasswordResponse>> call({required String email, required String otp}) {
    return _repository.verifyOtp(email: email, otp: otp);
  }
}

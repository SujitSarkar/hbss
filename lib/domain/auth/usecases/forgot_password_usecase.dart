import 'package:maori_health/core/error/failures.dart';
import 'package:maori_health/core/result/result.dart';
import 'package:maori_health/domain/auth/entities/forgot_pass_response.dart';
import 'package:maori_health/domain/auth/repositories/auth_repository.dart';

class ForgotPasswordUsecase {
  final AuthRepository _repository;

  ForgotPasswordUsecase({required AuthRepository repository}) : _repository = repository;

  Future<Result<AppError, ForgotPasswordResponse>> call({required String email}) {
    return _repository.forgotPassword(email: email);
  }
}

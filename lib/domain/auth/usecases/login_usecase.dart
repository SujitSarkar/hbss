import 'package:maori_health/core/error/failures.dart';
import 'package:maori_health/core/result/result.dart';
import 'package:maori_health/domain/auth/entities/login_response.dart';
import 'package:maori_health/domain/auth/repositories/auth_repository.dart';

class LoginUsecase {
  final AuthRepository _repository;

  LoginUsecase({required AuthRepository repository}) : _repository = repository;

  Future<Result<AppError, LoginResponse>> call({required String email, required String password}) {
    return _repository.login(email: email, password: password);
  }
}

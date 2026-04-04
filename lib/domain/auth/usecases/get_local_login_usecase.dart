import 'package:maori_health/core/error/failures.dart';
import 'package:maori_health/core/result/result.dart';
import 'package:maori_health/domain/auth/entities/user.dart';
import 'package:maori_health/domain/auth/repositories/auth_repository.dart';

class GetLocalLoginUsecase {
  final AuthRepository _repository;

  GetLocalLoginUsecase({required AuthRepository repository}) : _repository = repository;

  Future<Result<AppError, User>> call() {
    return _repository.getLocalLogin();
  }
}

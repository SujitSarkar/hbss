import 'package:maori_health/domain/auth/repositories/auth_repository.dart';

class LogoutUsecase {
  final AuthRepository _repository;

  LogoutUsecase({required AuthRepository repository}) : _repository = repository;

  Future<bool> call() {
    return _repository.logout();
  }
}

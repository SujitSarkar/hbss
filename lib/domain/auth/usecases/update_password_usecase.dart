import 'package:maori_health/core/error/failures.dart';
import 'package:maori_health/core/result/result.dart';
import 'package:maori_health/domain/auth/repositories/auth_repository.dart';

class UpdatePasswordUsecase {
  final AuthRepository _repository;

  UpdatePasswordUsecase({required AuthRepository repository}) : _repository = repository;

  Future<Result<AppError, String>> call({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) {
    return _repository.updatePassword(
      oldPassword: oldPassword,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );
  }
}

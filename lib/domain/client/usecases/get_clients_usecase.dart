import 'package:maori_health/core/error/failures.dart';
import 'package:maori_health/core/result/result.dart';
import 'package:maori_health/domain/client/entities/client.dart';
import 'package:maori_health/domain/client/repositories/client_repository.dart';

class GetClientsUsecase {
  final ClientRepository _repository;

  GetClientsUsecase({required ClientRepository repository}) : _repository = repository;

  Future<Result<AppError, List<Client>>> call({int page = 1}) {
    return _repository.getClients(page: page);
  }
}

import 'package:maori_health/domain/offline_sync/repositories/offline_sync_repository.dart';

class HasPendingOfflineSyncUsecase {
  HasPendingOfflineSyncUsecase({required OfflineSyncRepository repository}) : _repository = repository;

  final OfflineSyncRepository _repository;

  Future<bool> call() => _repository.hasPendingOfflineSchedules();
}

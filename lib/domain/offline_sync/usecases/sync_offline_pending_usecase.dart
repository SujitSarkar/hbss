import 'package:maori_health/core/error/failures.dart';
import 'package:maori_health/core/result/result.dart';
import 'package:maori_health/domain/offline_sync/repositories/offline_sync_repository.dart';

class SyncOfflinePendingUsecase {
  SyncOfflinePendingUsecase({required OfflineSyncRepository repository}) : _repository = repository;

  final OfflineSyncRepository _repository;

  Future<Result<AppError, bool>> call() => _repository.syncPendingSchedules();
}

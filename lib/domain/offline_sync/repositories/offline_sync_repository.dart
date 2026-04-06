import 'package:maori_health/core/error/failures.dart';
import 'package:maori_health/core/result/result.dart';

/// Drains the offline schedule queue to the API and persists results to local ObjectBox storage.
abstract class OfflineSyncRepository {
  Future<bool> hasPendingOfflineSchedules();

  Future<Result<AppError, bool>> syncPendingSchedules();
}

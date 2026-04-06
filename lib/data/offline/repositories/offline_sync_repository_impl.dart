import 'dart:async';
import 'dart:convert';

import 'package:maori_health/core/config/app_constants.dart';
import 'package:maori_health/core/error/exceptions.dart';
import 'package:maori_health/core/error/failures.dart';
import 'package:maori_health/core/network/network_checker.dart';
import 'package:maori_health/core/result/result.dart';
import 'package:maori_health/data/dashboard/models/schedule_model.dart';
import 'package:maori_health/data/local_storage/local_storage_data_source.dart';
import 'package:maori_health/data/objectbox/entities.dart';
import 'package:maori_health/data/offline/offline_schedule_queue_data_source.dart';
import 'package:maori_health/data/schedule/datasources/schedule_remote_datasource.dart';
import 'package:maori_health/domain/offline_sync/repositories/offline_sync_repository.dart';

class OfflineSyncRepositoryImpl implements OfflineSyncRepository {
  OfflineSyncRepositoryImpl({
    required NetworkChecker networkChecker,
    required OfflineScheduleQueueDataSource queue,
    required ScheduleRemoteDataSource remote,
    required LocalStorageDataSource localStorage,
  }) : _networkChecker = networkChecker,
       _queue = queue,
       _remote = remote,
       _localStorage = localStorage;

  final NetworkChecker _networkChecker;
  final OfflineScheduleQueueDataSource _queue;
  final ScheduleRemoteDataSource _remote;
  final LocalStorageDataSource _localStorage;

  @override
  Future<bool> hasPendingOfflineSchedules() => _queue.hasPending;

  @override
  Future<Result<AppError, bool>> syncPendingSchedules() async {
    if (!await _networkChecker.hasConnection) {
      return const ErrorResult(NetworkError());
    }
    if (!await _queue.hasPending) {
      return const SuccessResult(false);
    }

    try {
      final pending = await _queue.getPendingSorted();
      for (final PendingScheduleSyncEntity p in pending) {
        try {
          final updated = await _execute(p).timeout(AppConstants.connectTimeout + AppConstants.receiveTimeout);
          await _localStorage.upsertSchedule(updated);
          await _queue.remove(p.id);
        } on TimeoutException {
          break;
        } on ApiException {
          break;
        } catch (_) {
          break;
        }
      }
      return const SuccessResult(true);
    } catch (e) {
      return ErrorResult(ApiError(errorCode: 0, errorMessage: e.toString()));
    }
  }

  Future<ScheduleModel> _execute(PendingScheduleSyncEntity p) async {
    switch (p.actionType) {
      case 0:
        return _remote.startSchedule(scheduleId: p.scheduleId);
      case 1:
        return _remote.finishSchedule(scheduleId: p.scheduleId);
      case 2:
        final raw = p.cancelPayloadJson;
        if (raw == null || raw.isEmpty) {
          throw ApiException(message: 'Missing cancel payload');
        }
        final m = jsonDecode(raw) as Map<String, dynamic>;
        return _remote.cancelSchedule(
          scheduleId: p.scheduleId,
          cancelBy: m['cancelBy'] as String,
          cancelReason: m['cancelReason'] as String?,
          hour: m['hour'] as int?,
          minute: m['minute'] as int?,
          reason: m['reason'] as String,
        );
      default:
        throw ApiException(message: 'Unknown action type');
    }
  }
}

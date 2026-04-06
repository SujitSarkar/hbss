import 'dart:convert';

import 'package:maori_health/core/error/exceptions.dart';
import 'package:maori_health/core/error/failures.dart';
import 'package:maori_health/core/network/network_checker.dart';
import 'package:maori_health/core/result/result.dart';

import 'package:maori_health/data/auth/models/user_model.dart';
import 'package:maori_health/data/local_storage/local_storage_data_source.dart';
import 'package:maori_health/data/dashboard/models/schedule_model.dart';
import 'package:maori_health/data/offline/offline_schedule_queue_data_source.dart';
import 'package:maori_health/data/schedule/datasources/schedule_remote_datasource.dart';
import 'package:maori_health/data/schedule/models/paginated_schedule_response.dart';
import 'package:maori_health/data/schedule/schedule_offline_patch.dart';
import 'package:maori_health/domain/auth/repositories/auth_repository.dart';
import 'package:maori_health/domain/schedule/repositories/schedule_repository.dart';

class ScheduleRepositoryImpl implements ScheduleRepository {
  ScheduleRepositoryImpl({
    required ScheduleRemoteDataSource remoteDataSource,
    required NetworkChecker networkChecker,
    required LocalStorageDataSource localStorage,
    required OfflineScheduleQueueDataSource offlineQueue,
    required AuthRepository authRepository,
  }) : _remoteDataSource = remoteDataSource,
       _networkChecker = networkChecker,
       _localStorage = localStorage,
       _offlineQueue = offlineQueue,
       _authRepository = authRepository;

  final ScheduleRemoteDataSource _remoteDataSource;
  final NetworkChecker _networkChecker;
  final LocalStorageDataSource _localStorage;
  final OfflineScheduleQueueDataSource _offlineQueue;
  final AuthRepository _authRepository;

  static const int _queueStart = 0;
  static const int _queueFinish = 1;
  static const int _queueCancel = 2;

  String _scheduleListCacheKey({int? clientUserId, String? startDate, String? endDate}) =>
      '${clientUserId ?? 'null'}_${startDate ?? 'null'}_${endDate ?? 'null'}';

  String _nowIso() => DateTime.now().toIso8601String();

  double _workTotalHours(ScheduleModel schedule) {
    final start = DateTime.tryParse(schedule.workStartTime ?? '');
    if (start == null) return schedule.workTotalTime;
    final hours = DateTime.now().difference(start).inMinutes / 60.0;
    return hours < 0 ? 0 : hours;
  }

  @override
  Future<Result<AppError, PaginatedScheduleResponse>> getSchedules({
    required int page,
    int? clientUserId,
    String? startDate,
    String? endDate,
  }) async {
    final localStorageKey = _scheduleListCacheKey(clientUserId: clientUserId, startDate: startDate, endDate: endDate);

    if (await _networkChecker.hasConnection) {
      try {
        final result = await _remoteDataSource.getSchedules(
          page: page,
          clientUserId: clientUserId,
          startDate: startDate,
          endDate: endDate,
        );
        await _localStorage.persistScheduleList(localStorageKey: localStorageKey, page: result, append: page > 1);
        return SuccessResult(result);
      } on ApiException catch (e) {
        return ErrorResult(ApiError(errorCode: e.statusCode, errorMessage: e.message));
      } catch (e) {
        return ErrorResult(ApiError(errorCode: 0, errorMessage: e.toString()));
      }
    }

    final cached = await _localStorage.readScheduleList(localStorageKey);
    if (cached == null) {
      return const ErrorResult(NetworkError());
    }
    if (page == 1) {
      return SuccessResult(cached);
    }
    return SuccessResult(PaginatedScheduleResponse(schedules: const [], currentPage: page, lastPage: cached.lastPage));
  }

  @override
  Future<Result<AppError, ScheduleModel>> getScheduleById({required int scheduleId}) async {
    if (await _networkChecker.hasConnection) {
      try {
        final result = await _remoteDataSource.getScheduleById(scheduleId: scheduleId);
        await _localStorage.upsertSchedule(result);
        return SuccessResult(result);
      } on ApiException catch (e) {
        return ErrorResult(ApiError(errorCode: e.statusCode, errorMessage: e.message));
      } catch (e) {
        return ErrorResult(ApiError(errorCode: 0, errorMessage: e.toString()));
      }
    }

    final cached = await _localStorage.getScheduleById(scheduleId);
    if (cached != null) {
      return SuccessResult(cached);
    }
    return const ErrorResult(NetworkError());
  }

  @override
  Future<Result<AppError, ScheduleModel>> acceptSchedule({required int scheduleId}) async {
    if (!await _networkChecker.hasConnection) {
      return const ErrorResult(ApiError(errorMessage: 'Accept is not available while offline.'));
    }
    try {
      final result = await _remoteDataSource.acceptSchedule(scheduleId: scheduleId);
      await _localStorage.upsertSchedule(result);
      return SuccessResult(result);
    } on ApiException catch (e) {
      return ErrorResult(ApiError(errorCode: e.statusCode, errorMessage: e.message));
    } catch (e) {
      return ErrorResult(ApiError(errorCode: 0, errorMessage: e.toString()));
    }
  }

  @override
  Future<Result<AppError, ScheduleModel>> startSchedule({required int scheduleId}) async {
    if (await _networkChecker.hasConnection) {
      try {
        final result = await _remoteDataSource.startSchedule(scheduleId: scheduleId);
        await _localStorage.upsertSchedule(result);
        return SuccessResult(result);
      } on ApiException catch (e) {
        return ErrorResult(ApiError(errorCode: e.statusCode, errorMessage: e.message));
      } catch (e) {
        return ErrorResult(ApiError(errorCode: 0, errorMessage: e.toString()));
      }
    }

    final base = await _localStorage.getScheduleById(scheduleId);
    if (base == null) {
      return const ErrorResult(ApiError(errorMessage: 'Schedule not available offline.'));
    }

    final userResult = await _authRepository.getLocalLogin();
    return userResult.fold(
      onFailure: (e) async => ErrorResult(ApiError(errorMessage: e.errorMessage ?? 'User not available')),
      onSuccess: (user) async {
        if (user is! UserModel) {
          return const ErrorResult(ApiError(errorMessage: 'Offline start requires cached user profile.'));
        }
        final updated = base.applyOfflineStart(
          assignee: user,
          workStartIso: _nowIso(),
          statusKey: OfflineScheduleStatusKeys.inprogress,
          updatedAtIso: _nowIso(),
        );
        await Future.wait([
          _localStorage.upsertSchedule(updated),
          _offlineQueue.enqueue(scheduleId: scheduleId, actionType: _queueStart),
        ]);
        return SuccessResult(updated);
      },
    );
  }

  @override
  Future<Result<AppError, ScheduleModel>> finishSchedule({required int scheduleId}) async {
    if (await _networkChecker.hasConnection) {
      try {
        final result = await _remoteDataSource.finishSchedule(scheduleId: scheduleId);
        await _localStorage.upsertSchedule(result);
        return SuccessResult(result);
      } on ApiException catch (e) {
        return ErrorResult(ApiError(errorCode: e.statusCode, errorMessage: e.message));
      } catch (e) {
        return ErrorResult(ApiError(errorCode: 0, errorMessage: e.toString()));
      }
    }

    final base = await _localStorage.getScheduleById(scheduleId);
    if (base == null) {
      return const ErrorResult(ApiError(errorMessage: 'Schedule not available offline.'));
    }

    final updated = base.applyOfflineFinish(
      workEndIso: _nowIso(),
      workTotalHours: _workTotalHours(base),
      statusKey: OfflineScheduleStatusKeys.finished,
      updatedAtIso: _nowIso(),
    );
    await Future.wait([
      _localStorage.upsertSchedule(updated),
      _offlineQueue.enqueue(scheduleId: scheduleId, actionType: _queueFinish),
    ]);
    return SuccessResult(updated);
  }

  @override
  Future<Result<AppError, ScheduleModel>> cancelSchedule({
    required int scheduleId,
    required String cancelBy,
    required String? cancelReason,
    required int? hour,
    required int? minute,
    required String reason,
  }) async {
    if (await _networkChecker.hasConnection) {
      try {
        final result = await _remoteDataSource.cancelSchedule(
          scheduleId: scheduleId,
          cancelBy: cancelBy,
          cancelReason: cancelReason,
          hour: hour,
          minute: minute,
          reason: reason,
        );
        await _localStorage.upsertSchedule(result);
        return SuccessResult(result);
      } on ApiException catch (e) {
        return ErrorResult(ApiError(errorCode: e.statusCode, errorMessage: e.message));
      } catch (e) {
        return ErrorResult(ApiError(errorCode: 0, errorMessage: e.toString()));
      }
    }

    final base = await _localStorage.getScheduleById(scheduleId);
    if (base == null) {
      return const ErrorResult(ApiError(errorMessage: 'Schedule not available offline.'));
    }

    final payload = jsonEncode({
      'cancelBy': cancelBy,
      'cancelReason': cancelReason,
      'hour': hour,
      'minute': minute,
      'reason': reason,
    });

    final updated = base.applyOfflineCancel(
      cancelDateIso: _nowIso(),
      statusKey: OfflineScheduleStatusKeys.cancelled,
      updatedAtIso: _nowIso(),
      cancelledByValue: cancelBy.toLowerCase(),
      cancelReasonValue: cancelReason,
      cancelNoteValue: reason,
    );
    await Future.wait([
      _localStorage.upsertSchedule(updated),
      _offlineQueue.enqueue(scheduleId: scheduleId, actionType: _queueCancel, cancelPayloadJson: payload),
    ]);
    return SuccessResult(updated);
  }
}

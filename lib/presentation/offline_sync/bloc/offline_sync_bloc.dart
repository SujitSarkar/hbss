import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:maori_health/core/network/network_checker.dart';
import 'package:maori_health/domain/offline_sync/usecases/has_pending_offline_sync_usecase.dart';
import 'package:maori_health/domain/offline_sync/usecases/sync_offline_pending_usecase.dart';

import 'package:maori_health/presentation/offline_sync/bloc/offline_sync_event.dart';
import 'package:maori_health/presentation/offline_sync/bloc/offline_sync_state.dart';

class OfflineSyncBloc extends Bloc<OfflineSyncEvent, OfflineSyncState> {
  OfflineSyncBloc({
    required NetworkChecker networkChecker,
    required HasPendingOfflineSyncUsecase hasPendingOfflineSyncUsecase,
    required SyncOfflinePendingUsecase syncOfflinePendingUsecase,
  }) : _networkChecker = networkChecker,
       _hasPendingOfflineSyncUsecase = hasPendingOfflineSyncUsecase,
       _syncOfflinePendingUsecase = syncOfflinePendingUsecase,
       super(OfflineSyncState.initial) {
    on<OfflineSyncStarted>(_onStarted);
    on<OfflineSyncRunRequested>(_onRunRequested);
  }

  final NetworkChecker _networkChecker;
  final HasPendingOfflineSyncUsecase _hasPendingOfflineSyncUsecase;
  final SyncOfflinePendingUsecase _syncOfflinePendingUsecase;

  StreamSubscription<bool>? _connectionSubscription;
  bool _wasOnline = false;
  bool _running = false;

  Future<void> _onStarted(OfflineSyncStarted event, Emitter<OfflineSyncState> emit) async {
    await _connectionSubscription?.cancel();

    // Baseline connectivity *before* listening. If we subscribe first, the first probe emission
    // looks like offline→online (because _wasOnline was false) and spuriously schedules sync on every cold start.
    _wasOnline = await _networkChecker.checkConnection();

    _connectionSubscription = _networkChecker.connectionStream.listen((online) {
      final cameOnline = online && !_wasOnline;
      _wasOnline = online;
      // Only drain when there is queued work; avoids a sync pass on every reconnect with an empty queue.
      if (cameOnline) {
        Future(() async {
          if (await _hasPendingOfflineSyncUsecase()) {
            add(const OfflineSyncRunRequested());
          }
        });
      }
    });

    // App opened while online with a pending queue (no false→true transition on the stream).
    if (_wasOnline && await _hasPendingOfflineSyncUsecase()) {
      add(const OfflineSyncRunRequested());
    }
  }

  Future<void> _onRunRequested(OfflineSyncRunRequested event, Emitter<OfflineSyncState> emit) async {
    if (_running) return;
    if (!await _networkChecker.hasConnection) return;
    if (!await _hasPendingOfflineSyncUsecase()) return;

    _running = true;
    emit(const OfflineSyncState(status: OfflineSyncStatus.syncing));
    await Future<void>.delayed(const Duration(milliseconds: 50));

    final result = await _syncOfflinePendingUsecase();
    await result.fold(
      onFailure: (error) async {
        emit(OfflineSyncState(status: OfflineSyncStatus.failure, message: error.errorMessage));
      },
      onSuccess: (_) async {
        emit(OfflineSyncState.initial);
      },
    );
    _running = false;
  }

  @override
  Future<void> close() async {
    await _connectionSubscription?.cancel();
    return super.close();
  }
}

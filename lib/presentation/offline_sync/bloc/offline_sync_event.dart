import 'package:equatable/equatable.dart';

sealed class OfflineSyncEvent extends Equatable {
  const OfflineSyncEvent();

  @override
  List<Object?> get props => [];
}

/// Subscribe to connectivity and run sync when appropriate (call once at app start).
class OfflineSyncStarted extends OfflineSyncEvent {
  const OfflineSyncStarted();
}

/// Internal: connectivity restored or initial online with pending work.
class OfflineSyncRunRequested extends OfflineSyncEvent {
  const OfflineSyncRunRequested();
}

import 'package:equatable/equatable.dart';

enum OfflineSyncStatus { idle, syncing, failure }

class OfflineSyncState extends Equatable {
  const OfflineSyncState({required this.status, this.message});

  final OfflineSyncStatus status;
  final String? message;

  static const initial = OfflineSyncState(status: OfflineSyncStatus.idle);

  @override
  List<Object?> get props => [status, message];
}

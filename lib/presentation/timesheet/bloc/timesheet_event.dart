import 'package:equatable/equatable.dart';
import 'package:maori_health/domain/client/entities/client.dart';

abstract class TimeSheetEvent extends Equatable {
  const TimeSheetEvent();

  @override
  List<Object?> get props => [];
}

class TimeSheetDateAndClientChanged extends TimeSheetEvent {
  final DateTime? startDate;
  final DateTime? endDate;
  final Client? client;

  const TimeSheetDateAndClientChanged({this.startDate, this.endDate, this.client});

  @override
  List<Object?> get props => [startDate, endDate, client];
}

class TimeSheetLoadMore extends TimeSheetEvent {
  final DateTime? startDate;
  final DateTime? endDate;
  final Client? client;
  const TimeSheetLoadMore({this.startDate, this.endDate, this.client});

  @override
  List<Object?> get props => [startDate, endDate, client];
}

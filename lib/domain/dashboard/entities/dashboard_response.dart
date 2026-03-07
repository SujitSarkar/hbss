import 'package:equatable/equatable.dart';

import 'package:maori_health/domain/schedule/entities/schedule.dart';
import 'package:maori_health/domain/dashboard/entities/stats.dart';

class DashboardResponse extends Equatable {
  final List<Schedule> availableJobs;
  final List<Schedule> todaysSchedules;
  final List<Schedule> upcomingSchedules;
  final Schedule? nextSchedule;
  final Schedule? currentSchedule;
  final Stats stats;

  const DashboardResponse({
    this.availableJobs = const [],
    this.todaysSchedules = const [],
    this.upcomingSchedules = const [],
    this.nextSchedule,
    this.currentSchedule,
    this.stats = const Stats(),
  });

  @override
  List<Object?> get props => [availableJobs, todaysSchedules, upcomingSchedules, nextSchedule, currentSchedule, stats];
}

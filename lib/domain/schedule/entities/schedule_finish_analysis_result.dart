enum ScheduleFinishCategory { onTime, early, overtime }

class ScheduleFinishAnalysis {
  final ScheduleFinishCategory category;
  final Duration scheduledDuration;
  final Duration actualDuration;
  final Duration durationDifference;
  final DateTime? scheduleEnd;

  const ScheduleFinishAnalysis({
    required this.category,
    required this.scheduledDuration,
    required this.actualDuration,
    required this.durationDifference,
    required this.scheduleEnd,
  });
}

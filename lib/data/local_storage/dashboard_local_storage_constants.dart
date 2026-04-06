/// Section indices for [DashboardSectionLinkEntity.section].
abstract final class DashboardLocalStorageSection {
  static const int availableJobs = 0;
  static const int todaysSchedules = 1;
  static const int upcomingSchedules = 2;
}

/// [DashboardPointerEntity.pointerKind] values.
abstract final class DashboardPointerKind {
  static const int nextSchedule = 0;
  static const int currentSchedule = 1;
}

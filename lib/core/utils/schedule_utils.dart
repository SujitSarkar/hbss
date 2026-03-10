import 'package:flutter/material.dart';

import 'package:maori_health/core/config/app_strings.dart';
import 'package:maori_health/core/theme/app_colors.dart';
import 'package:maori_health/core/utils/extensions.dart';
import 'package:maori_health/domain/lookup_enums/entities/schedule_status.dart';

import 'package:maori_health/domain/schedule/entities/schedule.dart';
import 'package:maori_health/domain/schedule/entities/schedule_finish_analysis_result.dart';

import 'package:maori_health/presentation/shared/widgets/horizontal_week_calender.dart';

class ScheduleUtils {
  static String getScheduleStatus({
    required String? status,
    required ScheduleStatus scheduleStatusKey,
    required ScheduleStatus scheduleStatusValue,
  }) {
    if (status == scheduleStatusKey.active) {
      return scheduleStatusValue.active ?? '';
    } else if (status == scheduleStatusKey.cancelled) {
      return scheduleStatusValue.cancelled ?? '';
    } else if (status == scheduleStatusKey.completed) {
      return scheduleStatusValue.completed ?? '';
    } else if (status == scheduleStatusKey.finished) {
      return scheduleStatusValue.finished ?? '';
    } else if (status == scheduleStatusKey.inprogress) {
      return scheduleStatusValue.inprogress ?? '';
    } else if (status == scheduleStatusKey.parked) {
      return scheduleStatusValue.parked ?? '';
    } else {
      return status?.capitalize() ?? '';
    }
  }

  static List<DateTime> getWeekDates({required WeekStartFrom weekStartFrom, DateTime? currentDate}) {
    final DateTime now = currentDate ?? DateTime.now();
    final DateTime dateOnly = DateTime(now.year, now.month, now.day);

    // 2. Determine the offset based on the starting day
    // If Monday: Mon(1) -> 0, Tue(2) -> 1 ... Sun(7) -> 6
    // If Sunday: Sun(7) -> 0, Mon(1) -> 1 ... Sat(6) -> 5
    int offset = (weekStartFrom == WeekStartFrom.monday) ? dateOnly.weekday - 1 : dateOnly.weekday % 7;

    final DateTime firstDayOfWeek = dateOnly.subtract(Duration(days: offset));

    // 3. Generate the 7-day list
    return List.generate(7, (index) => firstDayOfWeek.add(Duration(days: index)));
  }

  static ScheduleFinishAnalysis analyzeFinishState(
    Schedule schedule, {
    DateTime? currentDateTime,
    Duration tolerance = const Duration(minutes: 1),
  }) {
    final now = currentDateTime ?? DateTime.now();
    final scheduleStart = DateTime.tryParse(schedule.scheduleStartTime ?? '');
    final scheduleEnd = DateTime.tryParse(schedule.scheduleEndTime ?? '');
    final workStart = DateTime.tryParse(schedule.workStartTime ?? '');

    final fallbackScheduled = Duration(minutes: (schedule.scheduleTotalTime * 60).round());
    final scheduledDuration = (scheduleStart != null && scheduleEnd != null)
        ? scheduleEnd.difference(scheduleStart)
        : fallbackScheduled;
    final normalizedScheduled = scheduledDuration.isNegative ? Duration.zero : scheduledDuration;

    final actualDuration = workStart != null ? now.difference(workStart) : normalizedScheduled;
    final normalizedActual = actualDuration.isNegative ? Duration.zero : actualDuration;

    final difference = normalizedActual - normalizedScheduled;
    final category = difference.abs() <= tolerance
        ? ScheduleFinishCategory.onTime
        : difference.isNegative
        ? ScheduleFinishCategory.early
        : ScheduleFinishCategory.overtime;

    return ScheduleFinishAnalysis(
      category: category,
      scheduledDuration: normalizedScheduled,
      actualDuration: normalizedActual,
      durationDifference: difference.abs(),
      scheduleEnd: scheduleEnd,
    );
  }

  static Color finishStatusColor(ScheduleFinishCategory category) {
    switch (category) {
      case ScheduleFinishCategory.onTime:
        return AppColors.success;
      case ScheduleFinishCategory.early:
        return AppColors.warning;
      case ScheduleFinishCategory.overtime:
        return AppColors.error;
    }
  }

  static IconData finishStatusIcon(ScheduleFinishCategory category) {
    switch (category) {
      case ScheduleFinishCategory.onTime:
        return Icons.check_circle_outline_rounded;
      case ScheduleFinishCategory.early:
        return Icons.warning_amber_rounded;
      case ScheduleFinishCategory.overtime:
        return Icons.watch_later_outlined;
    }
  }

  static String finishSummaryTitle(ScheduleFinishCategory category) {
    return category == ScheduleFinishCategory.early ? AppStrings.appointmentSummary : AppStrings.jobSummary;
  }

  static String finishStatusTitle(ScheduleFinishCategory category) {
    switch (category) {
      case ScheduleFinishCategory.onTime:
        return AppStrings.finishingOnTime;
      case ScheduleFinishCategory.early:
        return AppStrings.finishingEarly;
      case ScheduleFinishCategory.overtime:
        return AppStrings.overHours;
    }
  }

  static String finishStatusMessage(
    ScheduleFinishCategory category, {
    required Duration durationDifference,
    required String scheduledEndTimeLabel,
  }) {
    switch (category) {
      case ScheduleFinishCategory.onTime:
        return '';
      case ScheduleFinishCategory.early:
        return '${AppStrings.finishEarlyMessagePrefix} $scheduledEndTimeLabel. ${AppStrings.finishEarlyMessageSuffix}';
      case ScheduleFinishCategory.overtime:
        return '${AppStrings.overHoursMessagePrefix} ${durationDifference.inMinutes} ${AppStrings.overHoursMessageMiddle} '
            '${AppStrings.overHoursMessageSuffix} $scheduledEndTimeLabel.';
    }
  }

  static String formatDurationInHours(Duration duration) {
    final totalMinutes = duration.inMinutes;
    final hours = totalMinutes / 60;
    final hoursLabel = hours == hours.toInt() ? hours.toInt().toString() : hours.toStringAsFixed(1);
    return '$hoursLabel ${AppStrings.hours}';
  }
}

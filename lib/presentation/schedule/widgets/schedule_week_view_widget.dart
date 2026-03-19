import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:maori_health/core/theme/app_colors.dart';
import 'package:maori_health/core/utils/color_utils.dart';
import 'package:maori_health/domain/schedule/entities/schedule.dart';
import 'package:maori_health/presentation/app_settings/bloc/app_settings_bloc.dart';

class ScheduleWeekViewWidget extends StatelessWidget {
  final List<DateTime> weekDates;
  final List<Schedule> schedules;
  final ValueChanged<Schedule>? onScheduleTap;

  const ScheduleWeekViewWidget({super.key, required this.weekDates, required this.schedules, this.onScheduleTap});

  static const int _defaultStartHour = 7;
  static const int _defaultEndHour = 19;
  static const int _defaultSlotMinutes = 60;
  static const double _pixelsPerHour = 64;
  static const double _timeColumnWidth = 46;
  static const double _cardMinHeight = 44;

  @override
  Widget build(BuildContext context) {
    final viewConfig = _resolveViewConfig(context);
    final normalizedWeekDates = weekDates.map(_dateOnly).toList()..sort();
    final grouped = _groupSchedulesByWeekDate(normalizedWeekDates);
    final totalGridHeight = viewConfig.totalHeight;
    final theme = Theme.of(context);

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const .fromLTRB(12, 12, 12, 24),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          _buildHeader(theme, normalizedWeekDates),
          const SizedBox(height: 8),
          SizedBox(
            height: totalGridHeight + 1,
            child: Row(
              crossAxisAlignment: .start,
              children: [
                SizedBox(
                  width: _timeColumnWidth,
                  child: _TimeScaleColumn(
                    startMinutes: viewConfig.startMinutes,
                    endMinutes: viewConfig.endMinutes,
                    slotMinutes: viewConfig.slotMinutes,
                    pixelsPerHour: _pixelsPerHour,
                    textStyle: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: .w500,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(width: 2),
                Expanded(
                  child: Row(
                    children: [
                      for (final weekDate in normalizedWeekDates)
                        Expanded(
                          child: _WeekDayColumn(
                            schedules: grouped[weekDate] ?? const [],
                            startMinutes: viewConfig.startMinutes,
                            endMinutes: viewConfig.endMinutes,
                            slotMinutes: viewConfig.slotMinutes,
                            pixelsPerHour: _pixelsPerHour,
                            onScheduleTap: onScheduleTap,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, List<DateTime> normalizedWeekDates) {
    return Row(
      children: [
        const SizedBox(width: _timeColumnWidth + 2),
        Expanded(
          child: Row(
            children: [
              for (final date in normalizedWeekDates)
                Expanded(
                  child: Column(
                    mainAxisSize: .min,
                    children: [
                      Text('${date.day}', style: theme.textTheme.titleMedium?.copyWith(fontWeight: .w700)),
                      const SizedBox(height: 2),
                      Text(
                        DateFormat('EEE').format(date),
                        style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Map<DateTime, List<Schedule>> _groupSchedulesByWeekDate(List<DateTime> normalizedWeekDates) {
    final grouped = <DateTime, List<Schedule>>{for (final date in normalizedWeekDates) date: []};

    for (final schedule in schedules) {
      final start = _parseIso(schedule.scheduleStartTime);
      if (start == null) continue;
      final scheduleDate = _dateOnly(start.toLocal());
      DateTime? weekDateKey;
      for (final date in normalizedWeekDates) {
        if (_isSameDate(date, scheduleDate)) {
          weekDateKey = date;
          break;
        }
      }
      if (weekDateKey != null) {
        grouped[weekDateKey]!.add(schedule);
      }
    }

    return grouped;
  }

  DateTime? _parseIso(String? value) => value == null || value.isEmpty ? null : DateTime.tryParse(value);

  DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

  bool _isSameDate(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  _WeekViewConfig _resolveViewConfig(BuildContext context) {
    final settingsState = context.watch<AppSettingsBloc>().state;
    if (settingsState is! AppSettingsLoadedState) {
      return _WeekViewConfig(
        startMinutes: _defaultStartHour * 60,
        endMinutes: _defaultEndHour * 60,
        slotMinutes: _defaultSlotMinutes,
        pixelsPerHour: _pixelsPerHour,
      );
    }

    final startMinutes = _parseTimeToMinutes(settingsState.appSettings.officeStartTime) ?? (_defaultStartHour * 60);
    var endMinutes = _parseTimeToMinutes(settingsState.appSettings.officeEndTime) ?? (_defaultEndHour * 60);
    final slotMinutes = _parseDurationToMinutes(settingsState.appSettings.slotDuration) ?? _defaultSlotMinutes;

    if (endMinutes <= startMinutes) {
      endMinutes = startMinutes + _defaultSlotMinutes;
    }

    return _WeekViewConfig(
      startMinutes: startMinutes,
      endMinutes: endMinutes,
      slotMinutes: math.max(1, slotMinutes),
      pixelsPerHour: _pixelsPerHour,
    );
  }

  int? _parseTimeToMinutes(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final parts = value.split(':');
    if (parts.length < 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    return (hour * 60) + minute;
  }

  int? _parseDurationToMinutes(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final parts = value.split(':');
    if (parts.length < 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    return (hour * 60) + minute;
  }
}

class _TimeScaleColumn extends StatelessWidget {
  final int startMinutes;
  final int endMinutes;
  final int slotMinutes;
  final double pixelsPerHour;
  final TextStyle? textStyle;

  const _TimeScaleColumn({
    required this.startMinutes,
    required this.endMinutes,
    required this.slotMinutes,
    required this.pixelsPerHour,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final totalHeight = ((endMinutes - startMinutes) / 60) * pixelsPerHour;
    return SizedBox(
      height: totalHeight + 1,
      child: Stack(
        clipBehavior: .none,
        children: [
          for (int minute = startMinutes; minute <= endMinutes; minute += slotMinutes)
            Positioned(
              top: ((minute - startMinutes) / 60) * pixelsPerHour - 10,
              left: 0,
              right: 0,
              child: Text(_formatHourLabel(minute), style: textStyle),
            ),
        ],
      ),
    );
  }

  String _formatHourLabel(int totalMinutes) {
    final hour24 = (totalMinutes ~/ 60) % 24;
    final minute = totalMinutes % 60;
    final hour12 = hour24 == 0 ? 12 : (hour24 > 12 ? hour24 - 12 : hour24);
    return '$hour12.${minute.toString().padLeft(2, '0')}';
  }
}

class _WeekDayColumn extends StatelessWidget {
  final List<Schedule> schedules;
  final int startMinutes;
  final int endMinutes;
  final int slotMinutes;
  final double pixelsPerHour;
  final ValueChanged<Schedule>? onScheduleTap;

  const _WeekDayColumn({
    required this.schedules,
    required this.startMinutes,
    required this.endMinutes,
    required this.slotMinutes,
    required this.pixelsPerHour,
    this.onScheduleTap,
  });

  @override
  Widget build(BuildContext context) {
    final totalHeight = ((endMinutes - startMinutes) / 60) * pixelsPerHour;
    final theme = Theme.of(context);
    final items = _buildItems(totalHeight);
    final slotCount = ((endMinutes - startMinutes) / slotMinutes).ceil();

    return Container(
      height: totalHeight + 1,
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: theme.dividerColor)),
      ),
      child: Stack(
        children: [
          Column(
            children: List.generate(
              slotCount,
              (_) => Container(
                height: (slotMinutes / 60) * pixelsPerHour,
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: theme.dividerColor)),
                ),
              ),
            ),
          ),
          for (final item in items)
            Positioned(
              top: item.top,
              left: 0,
              right: 0,
              height: item.height,
              child: InkWell(
                onTap: onScheduleTap == null ? null : () => onScheduleTap!(item.schedule),
                borderRadius: .circular(10),
                child: Container(
                  height: .infinity,
                  width: .infinity,
                  padding: const .symmetric(horizontal: 2, vertical: 2),
                  alignment: .center,
                  decoration: BoxDecoration(borderRadius: .circular(8), color: item.backgroundColor),
                  child: FittedBox(
                    alignment: .center,
                    fit: .scaleDown,
                    child: Column(
                      crossAxisAlignment: .center,
                      mainAxisAlignment: .center,
                      children: [
                        Text(
                          _title(item.schedule),
                          maxLines: 1,
                          overflow: .ellipsis,
                          style: theme.textTheme.labelSmall?.copyWith(fontWeight: .w600),
                        ),
                        Text(
                          _formatTime(item.start),
                          maxLines: 1,
                          overflow: .ellipsis,
                          style: theme.textTheme.labelMedium?.copyWith(fontWeight: .w500),
                        ),
                        Text('-', maxLines: 1, style: theme.textTheme.labelMedium?.copyWith(fontWeight: .w500)),
                        Text(
                          _formatTime(item.end),
                          maxLines: 1,
                          overflow: .ellipsis,
                          style: theme.textTheme.labelMedium?.copyWith(fontWeight: .w500),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  List<_PositionedScheduleItem> _buildItems(double totalHeight) {
    final items = <_PositionedScheduleItem>[];
    final windowStartMinutes = startMinutes;
    final windowEndMinutes = endMinutes;

    for (final schedule in schedules) {
      final start = _parseIso(schedule.scheduleStartTime)?.toLocal();
      if (start == null) continue;
      final fallbackDuration = math.max(30, (schedule.scheduleTotalTime * 60).round());
      final end = _parseIso(schedule.scheduleEndTime)?.toLocal() ?? start.add(Duration(minutes: fallbackDuration));

      final startMinutes = (start.hour * 60) + start.minute;
      final endMinutes = (end.hour * 60) + end.minute;

      final visibleStart = math.max(startMinutes, windowStartMinutes);
      final visibleEnd = math.min(endMinutes, windowEndMinutes);
      if (visibleEnd <= visibleStart) continue;

      final top = ((visibleStart - windowStartMinutes) / 60) * pixelsPerHour;
      final height = math.max(
        ScheduleWeekViewWidget._cardMinHeight,
        ((visibleEnd - visibleStart) / 60) * pixelsPerHour,
      );

      final baseColor = ColorUtils.hexToColor(schedule.color) ?? AppColors.primary;
      items.add(
        _PositionedScheduleItem(
          schedule: schedule,
          start: start,
          end: end,
          top: top.clamp(0, totalHeight - ScheduleWeekViewWidget._cardMinHeight),
          height: height.clamp(ScheduleWeekViewWidget._cardMinHeight, totalHeight - top),
          backgroundColor: baseColor.withAlpha(150),
        ),
      );
    }

    items.sort((a, b) => a.top.compareTo(b.top));
    return items;
  }

  DateTime? _parseIso(String? value) => value == null || value.isEmpty ? null : DateTime.tryParse(value);

  String _title(Schedule schedule) =>
      (schedule.jobType != null && schedule.jobType!.trim().isNotEmpty) ? schedule.jobType!.toUpperCase() : '';

  String _formatTime(DateTime dateTime) => DateFormat('h.mm').format(dateTime);
}

class _PositionedScheduleItem {
  final Schedule schedule;
  final DateTime start;
  final DateTime end;
  final double top;
  final double height;
  final Color backgroundColor;

  const _PositionedScheduleItem({
    required this.schedule,
    required this.start,
    required this.end,
    required this.top,
    required this.height,
    required this.backgroundColor,
  });
}

class _WeekViewConfig {
  final int startMinutes;
  final int endMinutes;
  final int slotMinutes;
  final double pixelsPerHour;

  const _WeekViewConfig({
    required this.startMinutes,
    required this.endMinutes,
    required this.slotMinutes,
    required this.pixelsPerHour,
  });

  double get totalHeight => ((endMinutes - startMinutes) / 60) * pixelsPerHour;
}

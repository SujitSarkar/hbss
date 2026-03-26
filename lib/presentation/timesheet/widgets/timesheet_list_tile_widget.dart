import 'package:flutter/material.dart';

import 'package:maori_health/core/utils/color_utils.dart';
import 'package:maori_health/core/utils/date_converter.dart';
import 'package:maori_health/core/utils/extensions.dart';
import 'package:maori_health/domain/timesheet/entities/timesheet.dart';

class TimeSheetListTileWidget extends StatelessWidget {
  final TimeSheet timeSheet;

  const TimeSheetListTileWidget({super.key, required this.timeSheet});

  @override
  Widget build(BuildContext context) {
    final startDt = DateTime.tryParse(timeSheet.scheduleStartTime ?? '');
    final endDt = DateTime.tryParse(timeSheet.scheduleEndTime ?? '');

    final dayDate = startDt != null ? DateConverter.toWeekMonthDay(startDt) : '-';
    final startTime = startDt != null ? DateConverter.toDisplayTime(startDt) : '-';
    final endTime = endDt != null ? DateConverter.toDisplayTime(endDt) : '-';

    final totalHours = timeSheet.scheduleTotalTime;
    final hoursLabel = totalHours == totalHours.toInt() ? '${totalHours.toInt()}H' : '${totalHours}H';

    final jobType = (timeSheet.jobType ?? '').toUpperCase();

    return Container(
      padding: const .all(12),
      decoration: BoxDecoration(
        color: context.theme.cardColor,
        borderRadius: .circular(12),
        border: .all(color: context.theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: .start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(dayDate, style: context.textTheme.titleSmall?.copyWith(fontWeight: .w700)),
              ),
              const SizedBox(width: 8),
              _StatusBadge(status: timeSheet.status, color: timeSheet.color ?? ''),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '$startTime - $endTime',
            style: context.textTheme.bodySmall?.copyWith(color: context.colorScheme.onSurfaceVariant),
          ),
          Row(
            mainAxisAlignment: .spaceBetween,
            children: [
              Expanded(
                child: Text(jobType, style: context.textTheme.bodyMedium?.copyWith(fontWeight: .w700)),
              ),
              Text(hoursLabel, style: context.textTheme.titleLarge?.copyWith(fontWeight: .w700)),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  final String color;

  const _StatusBadge({required this.status, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const .symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(borderRadius: .circular(4), color: ColorUtils.hexToColor(color)),
      child: Text(
        status.capitalize(),
        style: context.textTheme.labelSmall?.copyWith(color: context.colorScheme.onPrimary, fontSize: 10),
      ),
    );
  }
}

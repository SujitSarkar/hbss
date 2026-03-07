import 'package:flutter/material.dart';

import 'package:maori_health/core/config/app_strings.dart';
import 'package:maori_health/core/enums/job_status.enum.dart';
import 'package:maori_health/core/theme/app_colors.dart';
import 'package:maori_health/core/utils/color_utils.dart';
import 'package:maori_health/core/utils/date_converter.dart';
import 'package:maori_health/core/utils/extensions.dart';
import 'package:maori_health/domain/schedule/entities/schedule.dart';

class ScheduleListTileWidget extends StatelessWidget {
  final Schedule schedule;
  final VoidCallback? onTap;
  const ScheduleListTileWidget({super.key, required this.schedule, this.onTap});

  String get _date => DateConverter.formatIsoDateTime(schedule.scheduleStartTime, pattern: 'EEEE, MMMM d, yyyy');
  String get _startTime => DateConverter.formatIsoDateTime(schedule.scheduleStartTime, pattern: 'h:mm a');
  String get _endTime => DateConverter.formatIsoDateTime(schedule.scheduleEndTime, pattern: 'h:mm a');
  String get _totalHours => schedule.scheduleTotalTime.toStringAsFixed(2);
  String get _title => (schedule.jobType ?? '-').toUpperCase();
  String get _subtitle => 'Job #${schedule.id}';
  String? get _workStartedAt => schedule.workStartTime != null
      ? DateConverter.formatIsoDateTime(schedule.workStartTime, pattern: 'h:mm a')
      : null;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final textTheme = context.textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const .all(12),
        decoration: BoxDecoration(
          color: AppColors.primary.withAlpha(30),
          borderRadius: .circular(14),
          border: .all(color: AppColors.primary.withAlpha(100)),
        ),
        child: Column(
          crossAxisAlignment: .start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: .start,
              children: [
                Expanded(
                  child: Text(_date, style: textTheme.bodySmall?.copyWith(fontWeight: .w500)),
                ),
                if (schedule.status == JobStatusEnum.inProgress.value)
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: ColorUtils.hexToColor(schedule.color)),
                  ),
                schedule.status != null
                    ? Container(
                        padding: const .symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: ColorUtils.hexToColor(schedule.color),
                          borderRadius: .circular(4),
                        ),
                        child: Text(
                          schedule.status!.capitalize(),
                          style: textTheme.bodySmall?.copyWith(color: theme.colorScheme.onPrimary, fontWeight: .w500),
                        ),
                      )
                    : SizedBox.shrink(),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              _title,
              style: textTheme.titleMedium?.copyWith(fontWeight: .bold),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Text(_subtitle, style: textTheme.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
                if (_workStartedAt != null)
                  Text(
                    '${AppStrings.startedAt} : $_workStartedAt',
                    style: textTheme.bodySmall?.copyWith(fontWeight: .w600),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _TimeColumn(label: AppStrings.startTime, value: _startTime),
                const SizedBox(width: 24),
                _TimeColumn(label: AppStrings.endTime, value: _endTime),
                const Spacer(),
                _TimeColumn(label: AppStrings.totalHours, value: _totalHours),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeColumn extends StatelessWidget {
  final String label;
  final String value;

  const _TimeColumn({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;

    return Column(
      crossAxisAlignment: .start,
      children: [
        Text(label, style: textTheme.bodySmall?.copyWith(fontWeight: .w500)),
        const SizedBox(height: 2),
        Text(value, style: textTheme.titleSmall?.copyWith(fontWeight: .bold)),
      ],
    );
  }
}

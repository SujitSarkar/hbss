import 'package:flutter/material.dart';

import 'package:maori_health/core/config/app_strings.dart';
import 'package:maori_health/core/theme/app_colors.dart';
import 'package:maori_health/core/utils/extensions.dart';
import 'package:maori_health/core/utils/schedule_utils.dart';
import 'package:maori_health/presentation/lookup_enums/bloc/bloc.dart';

class ScheduleDetailsInfoCard extends StatelessWidget {
  final LookupEnumsLoadedState? lookupEnumState;
  final String? status;
  final String date;
  final String jobType;
  final String clientName;
  final String clientAddress;
  final String duration;
  final String startTime;
  final String endTime;
  final String? jobStartedTime;

  const ScheduleDetailsInfoCard({
    super.key,
    required this.lookupEnumState,
    required this.status,
    required this.date,
    required this.jobType,
    required this.clientName,
    required this.clientAddress,
    required this.duration,
    required this.startTime,
    required this.endTime,
    this.jobStartedTime,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;
    final labelStyle = textTheme.bodySmall?.copyWith(color: context.colorScheme.onSurfaceVariant);

    return Container(
      width: double.infinity,
      padding: const .all(16),
      decoration: BoxDecoration(
        borderRadius: .circular(14),
        border: .all(color: context.theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Row(
            crossAxisAlignment: .start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    Text(AppStrings.date, style: labelStyle),
                    Text(date, style: textTheme.titleMedium?.copyWith(fontWeight: .bold)),
                  ],
                ),
              ),
              // Status Badge Row
              lookupEnumState is LookupEnumsLoadedState
                  ? Row(
                      crossAxisAlignment: .center,
                      children: [
                        if (lookupEnumState != null &&
                            status == lookupEnumState!.lookupEnums.scheduleStatusKey.inprogress)
                          Container(
                            width: 14,
                            height: 14,
                            margin: const .only(right: 4),
                            decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.success),
                          ),
                        status != null
                            ? Container(
                                padding: const .symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  border: Border.all(color: colorScheme.primary),
                                  borderRadius: .circular(4),
                                ),
                                child: Text(
                                  ScheduleUtils.getScheduleStatus(
                                    status: status,
                                    scheduleStatusKey: lookupEnumState!.lookupEnums.scheduleStatusKey,
                                    scheduleStatusValue: lookupEnumState!.lookupEnums.scheduleStatusValue,
                                  ),
                                  style: textTheme.bodySmall?.copyWith(fontWeight: .w500),
                                ),
                              )
                            : SizedBox.shrink(),
                      ],
                    )
                  : SizedBox.shrink(),
            ],
          ),
          const SizedBox(height: 8),
          Text(AppStrings.jobType, style: labelStyle),
          Text(jobType, style: textTheme.titleMedium?.copyWith(fontWeight: .bold)),
          const SizedBox(height: 8),
          Text(AppStrings.clientName, style: labelStyle),
          Text(clientName, style: textTheme.titleMedium?.copyWith(fontWeight: .bold)),
          const SizedBox(height: 8),
          Text(AppStrings.clientAddress, style: labelStyle),
          Text(clientAddress, style: textTheme.titleMedium?.copyWith(fontWeight: .bold)),
          const SizedBox(height: 8),
          Text(AppStrings.duration, style: labelStyle),
          Row(
            crossAxisAlignment: .baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(duration, style: textTheme.titleMedium?.copyWith(fontWeight: .bold)),
              const SizedBox(width: 6),
              Text(AppStrings.hours, style: textTheme.bodyMedium),
            ],
          ),
          const SizedBox(height: 12),
          Text(AppStrings.scheduledTime, style: textTheme.titleSmall?.copyWith(fontWeight: .bold)),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    Text(jobStartedTime != null ? AppStrings.start : AppStrings.startTime, style: labelStyle),
                    _buildTimeValue(context, startTime),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    Text(jobStartedTime != null ? AppStrings.end : AppStrings.endTime, style: labelStyle),
                    _buildTimeValue(context, endTime),
                  ],
                ),
              ),
            ],
          ),
          if (jobStartedTime != null) ...[
            const SizedBox(height: 12),
            Text(AppStrings.jobStartedTime, style: textTheme.titleSmall?.copyWith(fontWeight: .bold)),
            const SizedBox(height: 2),
            Text(jobStartedTime!, style: textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }

  Widget _buildTimeValue(BuildContext context, String time) {
    final parts = _splitTime(time);
    return Row(
      crossAxisAlignment: .baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(parts.$1, style: context.textTheme.titleMedium?.copyWith(fontWeight: .bold)),
        const SizedBox(width: 4),
        Text(parts.$2, style: context.textTheme.bodyMedium),
      ],
    );
  }

  (String, String) _splitTime(String time) {
    final match = RegExp(r'^(\d{1,2}:\d{2})\s*(.*)$').firstMatch(time);
    if (match != null) return (match.group(1)!, match.group(2) ?? '');
    return (time, '');
  }
}

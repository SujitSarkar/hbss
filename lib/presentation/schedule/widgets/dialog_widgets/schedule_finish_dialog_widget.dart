import 'package:flutter/material.dart';

import 'package:maori_health/core/config/app_strings.dart';
import 'package:maori_health/core/utils/date_converter.dart';
import 'package:maori_health/core/utils/extensions.dart';
import 'package:maori_health/core/utils/schedule_utils.dart';
import 'package:maori_health/domain/schedule/entities/schedule_finish_analysis_result.dart';

import 'package:maori_health/presentation/shared/widgets/app_dialog.dart';
import 'package:maori_health/presentation/shared/widgets/solid_button.dart';

class ScheduleFinishDialogWidget extends StatelessWidget {
  final ScheduleFinishAnalysis data;
  final VoidCallback onSave;
  final VoidCallback onClose;

  const ScheduleFinishDialogWidget({super.key, required this.data, required this.onSave, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final statusColor = ScheduleUtils.finishStatusColor(data.category);
    final statusIcon = ScheduleUtils.finishStatusIcon(data.category);
    final summaryTitle = ScheduleUtils.finishSummaryTitle(data.category);

    return AppDialog(
      title: AppStrings.finishJob,
      content: Column(
        crossAxisAlignment: .start,
        children: [
          Text(summaryTitle, style: context.textTheme.titleMedium?.copyWith(fontWeight: .w700)),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: .start,
            children: [
              Icon(statusIcon, color: statusColor, size: 30),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    Text(
                      ScheduleUtils.finishStatusTitle(data.category),
                      style: context.textTheme.titleMedium?.copyWith(fontWeight: .w700, color: statusColor),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      ScheduleUtils.finishStatusMessage(
                        data.category,
                        durationDifference: data.durationDifference,
                        scheduledEndTimeLabel: DateConverter.formatIsoDateTime(
                          data.scheduleEnd?.toIso8601String() ?? '',
                          pattern: 'h:mm a',
                        ),
                      ),
                      style: context.textTheme.bodyMedium?.copyWith(color: statusColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _DurationColumn(
                  label: AppStrings.scheduledDuration,
                  value: ScheduleUtils.formatDurationInHours(data.scheduledDuration),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: _DurationColumn(
                  label: AppStrings.actualDuration,
                  value: ScheduleUtils.formatDurationInHours(data.actualDuration),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: SolidButton(
                  onPressed: () {
                    Navigator.of(context).maybePop();
                    onSave();
                  },
                  child: const Text(AppStrings.save),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SolidButton(
                  backgroundColor: context.theme.disabledColor,
                  foregroundColor: Colors.white,
                  onPressed: onClose,
                  child: const Text(AppStrings.close),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _DurationColumn extends StatelessWidget {
  final String label;
  final String value;

  const _DurationColumn({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .center,
      children: [
        Text(
          label,
          textAlign: TextAlign.center,
          style: context.textTheme.labelMedium?.copyWith(fontWeight: .w600),
        ),
        const SizedBox(height: 4),
        Text(value, style: context.textTheme.titleMedium?.copyWith(fontWeight: .bold)),
      ],
    );
  }
}

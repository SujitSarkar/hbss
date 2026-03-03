import 'package:flutter/material.dart';

import 'package:maori_health/core/config/app_strings.dart';
import 'package:maori_health/core/theme/app_colors.dart';
import 'package:maori_health/core/utils/date_converter.dart';
import 'package:maori_health/core/utils/extensions.dart';
import 'package:maori_health/core/utils/dashboard_utils.dart';
import 'package:maori_health/domain/dashboard/entities/job.dart';

import 'package:maori_health/presentation/dashboard/pages/job_details_page.dart';

class JobCard extends StatelessWidget {
  final Job job;
  final VoidCallback? onTap;

  const JobCard({super.key, required this.job, this.onTap});

  JobStatus get _status => DashboardUtils.mapJobStatus(job.status);

  String get _date => DateConverter.formatIsoDateTime(job.scheduleStartTime, pattern: 'EEEE, MMMM d, yyyy');
  String get _startTime => DateConverter.formatIsoDateTime(job.scheduleStartTime, pattern: 'h:mm a');
  String get _endTime => DateConverter.formatIsoDateTime(job.scheduleEndTime, pattern: 'h:mm a');
  String get _totalHours => job.scheduleTotalTime.toStringAsFixed(2);
  String get _title => DashboardUtils.formatJobType(job.jobType);
  String get _subtitle => 'Job #${job.id}';
  String? get _workStartedAt =>
      job.workStartTime != null ? DateConverter.formatIsoDateTime(job.workStartTime, pattern: 'h:mm a') : null;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const .all(14),
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
              children: [
                Expanded(
                  child: Text(_date, style: textTheme.bodySmall?.copyWith(fontWeight: .w500)),
                ),
                if (_status == JobStatus.started)
                  Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.success),
                  ),
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

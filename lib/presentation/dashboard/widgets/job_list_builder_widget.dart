import 'package:flutter/material.dart';

import 'package:maori_health/core/utils/extensions.dart';
import 'package:maori_health/domain/schedule/entities/schedule.dart';
import 'package:maori_health/presentation/schedule/widgets/schedule_list_tile_widget.dart';

class JobListBuilderWidget extends StatelessWidget {
  final String title;
  final List<Schedule> jobs;
  final void Function(Schedule job) onJobTap;
  const JobListBuilderWidget({super.key, required this.title, required this.jobs, required this.onJobTap});

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    return Column(
      crossAxisAlignment: .start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title, style: textTheme.titleMedium?.copyWith(fontWeight: .bold)),
        const SizedBox(height: 8),
        ListView.separated(
          padding: .zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: jobs.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            return ScheduleListTileWidget(schedule: jobs[index], onTap: () => onJobTap(jobs[index]));
          },
        ),
      ],
    );
  }
}

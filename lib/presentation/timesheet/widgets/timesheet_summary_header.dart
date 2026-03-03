import 'package:flutter/material.dart';
import 'package:maori_health/core/config/app_strings.dart';

import 'package:maori_health/core/utils/extensions.dart';

class TimeSheetSummaryHeader extends StatelessWidget {
  final double totalHours;
  final int totalAppointments;

  const TimeSheetSummaryHeader({super.key, required this.totalHours, required this.totalAppointments});

  @override
  Widget build(BuildContext context) {
    final hoursLabel = totalHours == totalHours.toInt() ? '${totalHours.toInt()}H' : '${totalHours}H';

    return Row(
      children: [
        Icon(Icons.schedule_outlined, size: 18, color: context.colorScheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            '$totalAppointments ${AppStrings.appointments}',
            style: context.textTheme.bodyMedium?.copyWith(fontWeight: .w600),
          ),
        ),
        Text(hoursLabel, style: context.textTheme.titleLarge?.copyWith(fontWeight: .w700)),
      ],
    );
  }
}

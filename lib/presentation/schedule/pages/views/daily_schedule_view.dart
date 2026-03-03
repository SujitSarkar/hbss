import 'package:flutter/material.dart';

import 'package:maori_health/presentation/shared/widgets/horizontal_date_picker.dart';

class DailyScheduleView extends StatelessWidget {
  final DateTime? selectedDate;
  final void Function(DateTime? date) onSelected;

  const DailyScheduleView({super.key, required this.selectedDate, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final focusedDate = selectedDate ?? DateTime.now();
    final now = DateTime.now();
    final firstDayOfFocusedMonth = DateTime(focusedDate.year, focusedDate.month, 1);
    final lastDayOfFocusedMonth = DateTime(focusedDate.year, focusedDate.month + 1, 0);
    final calendarFirstDate = DateTime(1026, 1, 1);
    final calendarLastDate = DateTime(now.year + 1, now.month, now.day);
    return Column(
      crossAxisAlignment: .start,
      children: [
        HorizontalDatePicker(
          focusedDate: focusedDate,
          firstDate: firstDayOfFocusedMonth,
          lastDate: lastDayOfFocusedMonth,
          calendarFirstDate: calendarFirstDate,
          calendarLastDate: calendarLastDate,
          onDateChange: onSelected,
        ),
      ],
    );
  }
}

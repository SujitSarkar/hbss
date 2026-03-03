import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:maori_health/core/utils/extensions.dart';
import 'package:maori_health/presentation/shared/widgets/app_date_picker.dart';

class HorizontalDatePicker extends StatefulWidget {
  final DateTime focusedDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final DateTime? calendarFirstDate;
  final DateTime? calendarLastDate;
  final ValueChanged<DateTime> onDateChange;

  const HorizontalDatePicker({
    super.key,
    required this.focusedDate,
    required this.firstDate,
    required this.lastDate,
    this.calendarFirstDate,
    this.calendarLastDate,
    required this.onDateChange,
  });

  @override
  State<HorizontalDatePicker> createState() => _HorizontalDatePickerState();
}

class _HorizontalDatePickerState extends State<HorizontalDatePicker> {
  late final ScrollController _scrollController;

  static const double _itemWidth = 50.0;
  static const double _itemSpacing = 6.0;

  int get _totalDays => widget.lastDate.difference(widget.firstDate).inDays + 1;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _animateToDate(widget.focusedDate));
  }

  @override
  void didUpdateWidget(covariant HorizontalDatePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusedDate != widget.focusedDate ||
        oldWidget.firstDate != widget.firstDate ||
        oldWidget.lastDate != widget.lastDate) {
      _animateToDate(widget.focusedDate);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  double _offsetForDate(DateTime date, {double viewportWidth = 0}) {
    final index = date.difference(widget.firstDate).inDays;
    final itemOffset = index * (_itemWidth + _itemSpacing);
    final centerOffset = itemOffset - (viewportWidth / 2) + (_itemWidth / 2) + 20;
    return centerOffset.clamp(
      0.0,
      _scrollController.hasClients ? _scrollController.position.maxScrollExtent : double.infinity,
    );
  }

  void _animateToDate(DateTime date) {
    if (!_scrollController.hasClients) return;
    final viewportWidth = _scrollController.position.viewportDimension;
    final offset = _offsetForDate(date, viewportWidth: viewportWidth);
    _scrollController.animateTo(offset, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Container(
      padding: const .all(8),
      color: theme.cardColor,
      child: SizedBox(
        height: 60,
        child: Row(
          children: [
            Expanded(
              child: ListView.separated(
                padding: .zero,
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                itemCount: _totalDays,
                separatorBuilder: (_, _) => const SizedBox(width: _itemSpacing),
                itemBuilder: (context, index) {
                  final date = widget.firstDate.add(Duration(days: index));
                  final isSelected =
                      date.year == widget.focusedDate.year &&
                      date.month == widget.focusedDate.month &&
                      date.day == widget.focusedDate.day;

                  return _DateCell(
                    date: date,
                    isSelected: isSelected,
                    onTap: () => widget.onDateChange(date),
                    theme: theme,
                  );
                },
              ),
            ),
            Container(
              margin: const .only(left: 8),
              height: 50,
              child: VerticalDivider(color: theme.dividerColor, width: 1, thickness: 1),
            ),
            IconButton(
              onPressed: () => _showCalendarModal(context),
              icon: Icon(Icons.calendar_month_outlined, color: theme.colorScheme.primary, size: 26),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showCalendarModal(BuildContext context) async {
    final picked = await AppDatePicker.show(
      context: context,
      initialDate: widget.focusedDate,
      firstDate: widget.calendarFirstDate ?? widget.firstDate,
      lastDate: widget.calendarLastDate ?? widget.lastDate,
    );

    if (picked != null) {
      widget.onDateChange(picked);
      _animateToDate(picked);
    }
  }
}

class _DateCell extends StatelessWidget {
  final DateTime date;
  final bool isSelected;
  final VoidCallback onTap;
  final ThemeData theme;

  const _DateCell({required this.date, required this.isSelected, required this.onTap, required this.theme});

  @override
  Widget build(BuildContext context) {
    final primary = theme.colorScheme.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: const .all(Radius.circular(8)),
      child: Container(
        width: 50,
        height: 60,
        decoration: BoxDecoration(
          color: theme.dividerColor.withAlpha(80),
          borderRadius: const .all(Radius.circular(8)),
        ),
        child: Container(
          padding: const .symmetric(vertical: 4, horizontal: 10),
          decoration: BoxDecoration(
            border: isSelected ? .all(color: primary) : null,
            borderRadius: const .all(Radius.circular(8)),
          ),
          child: Column(
            mainAxisSize: .min,
            mainAxisAlignment: .center,
            crossAxisAlignment: .start,
            children: [
              Text(
                DateFormat('MMM').format(date),
                maxLines: 1,
                overflow: .ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(fontSize: 8, color: isSelected ? primary : theme.hintColor),
              ),
              Text(
                date.day.toString().padLeft(2, '0'),
                maxLines: 1,
                overflow: .ellipsis,
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: .bold, color: isSelected ? primary : null),
              ),
              Text(
                DateFormat('EEE').format(date),
                maxLines: 1,
                overflow: .ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(fontSize: 8, color: isSelected ? primary : theme.hintColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

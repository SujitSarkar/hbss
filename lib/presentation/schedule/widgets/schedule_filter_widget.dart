import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:maori_health/core/config/app_strings.dart';
import 'package:maori_health/core/enums/schedule.enum.dart';
import 'package:maori_health/core/utils/extensions.dart';
import 'package:maori_health/domain/client/entities/client.dart';

import 'package:maori_health/presentation/client/bloc/client_bloc.dart';
import 'package:maori_health/presentation/client/widgets/client_tile_widget.dart';
import 'package:maori_health/presentation/shared/widgets/auto_complete_search_field.dart';
import 'package:maori_health/presentation/shared/widgets/horizontal_date_picker.dart';
import 'package:maori_health/presentation/shared/widgets/horizontal_week_calender.dart';
import 'package:maori_health/presentation/shared/widgets/loading_widget.dart';

class ScheduleFilterWidget extends StatefulWidget {
  final ScheduleFilter selectedFilter;
  final DateTime? initialDate;
  final List<DateTime> initialWeek;
  final WeekStartFrom weekStartFrom;
  final Client? initialClient;
  final void Function(DateTime? date, List<DateTime> week, Client? client) onFilterChanged;
  const ScheduleFilterWidget({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
    this.weekStartFrom = WeekStartFrom.monday,
    this.initialClient,
    this.initialDate,
    this.initialWeek = const [],
  });

  @override
  State<ScheduleFilterWidget> createState() => _ScheduleFilterWidgetState();
}

class _ScheduleFilterWidgetState extends State<ScheduleFilterWidget> {
  // Client? selectedClient;
  // DateTime? selectedDate = DateTime.now();
  // List<DateTime> selectedWeek = [];

  final ValueNotifier<Client?> selectedClient = ValueNotifier(null);
  final ValueNotifier<DateTime?> selectedDate = ValueNotifier(DateTime.now());
  final ValueNotifier<List<DateTime>> selectedWeek = ValueNotifier([]);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      selectedClient.value = widget.initialClient;
      selectedDate.value = widget.initialDate;
      selectedWeek.value = widget.initialWeek;
    });
  }

  void onChangeFilter({Client? client, DateTime? date, List<DateTime> week = const []}) {
    selectedClient.value = client;
    selectedDate.value = date;
    selectedWeek.value = week;
    widget.onFilterChanged(selectedDate.value, selectedWeek.value, selectedClient.value);
  }

  @override
  Widget build(BuildContext context) {
    return switch (widget.selectedFilter) {
      ScheduleFilter.daily => ValueListenableBuilder(
        valueListenable: selectedDate,
        builder: (context, value, child) => DailyFilterWidget(
          selectedDate: value,
          onSelected: (date) {
            onChangeFilter(date: date);
          },
        ),
      ),
      ScheduleFilter.weekly => ValueListenableBuilder(
        valueListenable: selectedWeek,
        builder: (context, value, child) => WeekFilterWidget(
          selectedDate: selectedDate.value,
          weekStartFrom: widget.weekStartFrom,
          onDateChange: (date) {},
          onWeekChange: (week) {
            onChangeFilter(week: week);
          },
        ),
      ),
      ScheduleFilter.client => ValueListenableBuilder(
        valueListenable: selectedClient,
        builder: (context, value, child) => ClientFilterWidget(
          selectedClient: value,
          onSelected: (client) {
            onChangeFilter(client: client);
          },
        ),
      ),
    };
  }
}

class DailyFilterWidget extends StatelessWidget {
  final DateTime? selectedDate;
  final void Function(DateTime? date) onSelected;

  const DailyFilterWidget({super.key, required this.selectedDate, required this.onSelected});

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

class WeekFilterWidget extends StatelessWidget {
  final DateTime? selectedDate;
  final WeekStartFrom? weekStartFrom;
  final Function(DateTime? date) onDateChange;
  final Function(List<DateTime> week) onWeekChange;

  const WeekFilterWidget({
    super.key,
    this.selectedDate,
    this.weekStartFrom = WeekStartFrom.monday,
    required this.onDateChange,
    required this.onWeekChange,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        HorizontalWeekCalendar(
          minDate: DateTime(2026, 1, 1),
          maxDate: DateTime.now().add(const Duration(days: 365)),
          initialDate: selectedDate ?? DateTime.now(),
          weekStartFrom: weekStartFrom,
          onDateChange: onDateChange,
          onWeekChange: onWeekChange,
          disableDayPicker: true,
        ),
      ],
    );
  }
}

class ClientFilterWidget extends StatelessWidget {
  final Client? selectedClient;
  final void Function(Client? client) onSelected;
  const ClientFilterWidget({super.key, this.selectedClient, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ClientBloc, ClientState>(
      builder: (context, state) {
        final clients = state is ClientLoadedState ? state.clients : <Client>[];
        final isLoading = state is ClientLoadingState;
        return Padding(
          padding: const .fromLTRB(12, 0, 12, 0),
          child: Column(
            crossAxisAlignment: .start,
            children: [
              Row(
                children: [
                  Text(AppStrings.client, style: context.textTheme.bodyMedium?.copyWith(fontWeight: .w600)),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: AutoCompleteSearchField<Client>(
                      items: clients,
                      title: AppStrings.selectClient,
                      searchHint: AppStrings.searchClient,
                      initialQuery: selectedClient?.fullName,
                      itemFilter: (client, query) =>
                          client.fullName?.toLowerCase().contains(query.toLowerCase()) ?? false,
                      itemSorter: (a, b) => a.fullName?.compareTo(b.fullName ?? '') ?? 0,
                      itemBuilder: (client) => ClientTileWidget(client: client),
                      onSelected: onSelected,
                      onClear: () => onSelected(null),
                      builder: (onTap) {
                        return InkWell(
                          onTap: onTap,
                          borderRadius: .circular(8),
                          child: Container(
                            padding: const .symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              borderRadius: .circular(8),
                              border: .all(color: context.theme.dividerColor),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: isLoading
                                      ? const Center(child: SizedBox(height: 16, width: 16, child: LoadingWidget()))
                                      : Text(
                                          selectedClient?.fullName ?? AppStrings.select,
                                          style: context.textTheme.bodySmall?.copyWith(
                                            fontWeight: .w600,
                                            color: context.colorScheme.onSurface,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                ),
                                Icon(Icons.keyboard_arrow_down, size: 20, color: context.colorScheme.onSurfaceVariant),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

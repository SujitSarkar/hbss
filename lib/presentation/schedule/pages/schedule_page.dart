import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:maori_health/core/enums/schedule.enum.dart';
import 'package:maori_health/core/router/route_names.dart';
import 'package:maori_health/core/utils/date_converter.dart';
import 'package:maori_health/core/utils/schedule_utils.dart';
import 'package:maori_health/domain/client/entities/client.dart';

import 'package:maori_health/presentation/client/bloc/client_bloc.dart';
import 'package:maori_health/presentation/lookup_enums/bloc/bloc.dart';
import 'package:maori_health/presentation/schedule/widgets/schedule_list_tile_widget.dart';
import 'package:maori_health/presentation/schedule/bloc/schedule_bloc.dart';
import 'package:maori_health/presentation/schedule/widgets/schedule_filter_widget.dart';
import 'package:maori_health/presentation/schedule/widgets/schedule_header_widget.dart';
import 'package:maori_health/presentation/schedule/widgets/schedule_shimmer.dart';
import 'package:maori_health/presentation/shared/widgets/error_view_widget.dart';
import 'package:maori_health/presentation/shared/widgets/horizontal_week_calender.dart';
import 'package:maori_health/presentation/shared/widgets/pagination_wrapper.dart';
import 'package:maori_health/presentation/shared/widgets/swipe_refresh_wrapper.dart';

const List<ScheduleFilter> scheduleFilters = [ScheduleFilter.daily, ScheduleFilter.weekly, ScheduleFilter.client];

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => SchedulePageState();
}

class SchedulePageState extends State<SchedulePage> {
  final ValueNotifier<ScheduleFilter> _selectedFilter = ValueNotifier(scheduleFilters.first);
  final ValueNotifier<Client?> _selectedClient = ValueNotifier(null);
  final ValueNotifier<DateTime?> _selectedDate = ValueNotifier(DateTime.now());
  final ValueNotifier<List<DateTime>> _selectedWeek = ValueNotifier([]);

  @override
  void initState() {
    super.initState();
    _selectedWeek.value = ScheduleUtils.getWeekDates(weekStartFrom: WeekStartFrom.monday);
    // Load initial schedules by Daily filter
    context.read<ScheduleBloc>().add(
      SchedulesLoadEvent(
        startDate: DateConverter.toIsoDate(_selectedDate.value ?? DateTime.now()),
        endDate: DateConverter.toIsoDate(_selectedDate.value ?? DateTime.now()),
      ),
    );

    // Load LookupEnums if not loaded
    if (context.read<LookupEnumsBloc>().state is! LookupEnumsLoadedState) {
      context.read<LookupEnumsBloc>().add(const LoadLookupEnumsEvent());
    }

    // Load clients if not loaded
    if (context.read<ClientBloc>().state is! ClientLoadedState) {
      context.read<ClientBloc>().add(const LoadClientsEvent());
    }
  }

  Future<void> _onRefresh(BuildContext context) async {
    if (_selectedFilter.value == ScheduleFilter.daily) {
      context.read<ScheduleBloc>().add(
        SchedulesLoadEvent(
          startDate: DateConverter.toIsoDate(_selectedDate.value ?? DateTime.now()),
          endDate: DateConverter.toIsoDate(_selectedDate.value ?? DateTime.now()),
        ),
      );
    } else if (_selectedFilter.value == ScheduleFilter.weekly) {
      context.read<ScheduleBloc>().add(
        SchedulesLoadEvent(
          startDate: DateConverter.toIsoDate(_selectedWeek.value.first),
          endDate: DateConverter.toIsoDate(_selectedWeek.value.last),
        ),
      );
    } else if (_selectedFilter.value == ScheduleFilter.client) {
      context.read<ScheduleBloc>().add(SchedulesLoadEvent(clientUserId: _selectedClient.value?.id));
    }
    // Load LookupEnums if not loaded
    if (context.read<LookupEnumsBloc>().state is! LookupEnumsLoadedState) {
      context.read<LookupEnumsBloc>().add(const LoadLookupEnumsEvent());
    }

    // Load clients if not loaded
    if (context.read<ClientBloc>().state is! ClientLoadedState) {
      context.read<ClientBloc>().add(const LoadClientsEvent());
    }
  }

  void _onFilterTypeChanged(ScheduleFilter filter) {
    _selectedFilter.value = filter;
    // Set default values
    _selectedDate.value = DateTime.now();
    _selectedClient.value = null;
    _selectedWeek.value = ScheduleUtils.getWeekDates(weekStartFrom: WeekStartFrom.monday);
    _onFilterChanged(_selectedDate.value, _selectedWeek.value, _selectedClient.value);
  }

  void _onFilterChanged(DateTime? date, List<DateTime> week, Client? client) {
    _selectedDate.value = date;
    _selectedWeek.value = week;
    _selectedClient.value = client;

    if (_selectedFilter.value == ScheduleFilter.daily) {
      context.read<ScheduleBloc>().add(
        SchedulesLoadEvent(
          startDate: DateConverter.toIsoDate(_selectedDate.value ?? DateTime.now()),
          endDate: DateConverter.toIsoDate(_selectedDate.value ?? DateTime.now()),
        ),
      );
    } else if (_selectedFilter.value == ScheduleFilter.weekly) {
      context.read<ScheduleBloc>().add(
        SchedulesLoadEvent(
          startDate: DateConverter.toIsoDate(_selectedWeek.value.first),
          endDate: DateConverter.toIsoDate(_selectedWeek.value.last),
        ),
      );
    } else if (_selectedFilter.value == ScheduleFilter.client) {
      context.read<ScheduleBloc>().add(SchedulesLoadEvent(clientUserId: _selectedClient.value?.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Schedule AppBar
            ValueListenableBuilder(
              valueListenable: _selectedFilter,
              builder: (context, value, child) {
                return ScheduleHeaderWidget(selectedFilter: value, onFilterChanged: _onFilterTypeChanged);
              },
            ),
            const SizedBox(height: 12),
            ValueListenableBuilder(
              valueListenable: _selectedFilter,
              builder: (context, value, child) {
                return ScheduleFilterWidget(
                  selectedFilter: value,
                  initialDate: _selectedDate.value,
                  initialWeek: _selectedWeek.value,
                  initialClient: _selectedClient.value,
                  onFilterChanged: _onFilterChanged,
                );
              },
            ),
            Expanded(
              child: BlocBuilder<ScheduleBloc, ScheduleState>(
                builder: (context, state) {
                  return switch (state) {
                    ScheduleLoadingState() => const ScheduleShimmer(),
                    ScheduleErrorState(:final errorMessage) => ErrorViewWidget(
                      message: errorMessage,
                      onRetry: () => _onRefresh(context),
                    ),
                    ScheduleLoadedState() => PaginationWrapper(
                      hasMore: state.hasMore,
                      isLoadingMore: state.isLoadingMore,
                      onLoadMore: () => context.read<ScheduleBloc>().add(const SchedulesLoadMoreEvent()),
                      child: SwipeRefreshWrapper(
                        onRefresh: () => _onRefresh(context),
                        child: ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const .fromLTRB(12, 12, 12, 24),
                          itemBuilder: (context, index) => ScheduleListTileWidget(
                            schedule: state.schedules[index],
                            onTap: () {
                              context.pushNamed(
                                RouteNames.scheduleDetails,
                                extra: {'fromScreenName': 'schedule', 'schedule': state.schedules[index]},
                              );
                            },
                          ),
                          itemCount: state.schedules.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 12),
                        ),
                      ),
                    ),
                    _ => const SizedBox.shrink(),
                  };
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

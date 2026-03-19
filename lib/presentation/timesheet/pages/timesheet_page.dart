import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:maori_health/core/config/app_strings.dart';
import 'package:maori_health/core/di/injection.dart';

import 'package:maori_health/domain/client/entities/client.dart';

import 'package:maori_health/presentation/client/bloc/client_bloc.dart';
import 'package:maori_health/presentation/shared/widgets/common_app_bar.dart';
import 'package:maori_health/presentation/shared/widgets/error_view_widget.dart';
import 'package:maori_health/presentation/shared/widgets/no_data_found_widget.dart';
import 'package:maori_health/presentation/shared/widgets/pagination_wrapper.dart';
import 'package:maori_health/presentation/shared/widgets/swipe_refresh_wrapper.dart';
import 'package:maori_health/presentation/timesheet/bloc/bloc.dart';
import 'package:maori_health/presentation/timesheet/widgets/timesheet_filter_widget.dart';
import 'package:maori_health/presentation/timesheet/widgets/timesheet_list_tile_widget.dart';
import 'package:maori_health/presentation/timesheet/widgets/timesheet_shimmer.dart';
import 'package:maori_health/presentation/timesheet/widgets/timesheet_summary_header.dart';

class TimeSheetPage extends StatelessWidget {
  const TimeSheetPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<TimeSheetBloc>()..add(const TimeSheetDateAndClientChanged()),
      child: const _TimeSheetView(),
    );
  }
}

class _TimeSheetView extends StatefulWidget {
  const _TimeSheetView();

  @override
  State<_TimeSheetView> createState() => _TimeSheetViewState();
}

class _TimeSheetViewState extends State<_TimeSheetView> {
  DateTime? _startDate;
  DateTime? _endDate;
  Client? _selectedClient;

  TimeSheetBloc get _timeSheetBloc => context.read<TimeSheetBloc>();

  @override
  void initState() {
    super.initState();
    // Load Clients if not loaded
    if (context.read<ClientBloc>().state is! ClientLoadedState) {
      context.read<ClientBloc>().add(const LoadClientsEvent());
    }
  }

  Future<void> _onRefresh(BuildContext context) async {
    _timeSheetBloc.add(
      TimeSheetDateAndClientChanged(startDate: _startDate, endDate: _endDate, client: _selectedClient),
    );

    // Load employees if not loaded
    if (context.read<ClientBloc>().state is! ClientLoadedState) {
      context.read<ClientBloc>().add(const LoadClientsEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(context: context, title: Text(AppStrings.timeSheets)),
      body: SafeArea(
        child: Padding(
          padding: const .fromLTRB(16, 8, 16, 0),
          child: Column(
            children: [
              TimesheetFilterWidget(
                startDate: _startDate,
                endDate: _endDate,
                selectedClient: _selectedClient,
                onDateRangeChanged: (start, end) {
                  setState(() {
                    _startDate = start;
                    _endDate = end;
                  });
                  _timeSheetBloc.add(
                    TimeSheetDateAndClientChanged(startDate: start, endDate: end, client: _selectedClient),
                  );
                },
                onDateRangeCleared: () {
                  setState(() {
                    _startDate = null;
                    _endDate = null;
                  });
                  _timeSheetBloc.add(TimeSheetDateAndClientChanged(client: _selectedClient));
                },
                onClientChanged: (client) {
                  setState(() => _selectedClient = client);
                  _timeSheetBloc.add(
                    TimeSheetDateAndClientChanged(startDate: _startDate, endDate: _endDate, client: client),
                  );
                },
              ),
              const SizedBox(height: 16),
              Expanded(
                child: BlocBuilder<TimeSheetBloc, TimeSheetState>(
                  builder: (context, state) {
                    return switch (state) {
                      TimeSheetLoadingState() => const TimeSheetShimmer(),
                      TimeSheetErrorState(:final errorMessage) => ErrorViewWidget(
                        message: errorMessage,
                        onRetry: () => _timeSheetBloc.add(const TimeSheetDateAndClientChanged()),
                      ),
                      TimeSheetLoadedState() => _buildContent(context, state),
                      _ => const SizedBox.shrink(),
                    };
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, TimeSheetLoadedState state) {
    return Column(
      children: [
        TimeSheetSummaryHeader(totalHours: state.totalTime, totalAppointments: state.totalSchedules),
        const SizedBox(height: 16),
        Expanded(
          child: state.timeSheets.isEmpty
              ? SwipeRefreshWrapper(
                  onRefresh: () => _onRefresh(context),
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [SliverFillRemaining(child: NoDataFoundWidget(message: AppStrings.noDataFound))],
                  ),
                )
              : PaginationWrapper(
                  hasMore: state.hasMore,
                  isLoadingMore: state.isLoadingMore,
                  onLoadMore: () => _timeSheetBloc.add(
                    TimeSheetLoadMore(startDate: _startDate, endDate: _endDate, client: _selectedClient),
                  ),
                  child: SwipeRefreshWrapper(
                    onRefresh: () => _onRefresh(context),
                    child: ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const .only(bottom: 16),
                      itemCount: state.timeSheets.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (_, index) => TimeSheetListTileWidget(timeSheet: state.timeSheets[index]),
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}

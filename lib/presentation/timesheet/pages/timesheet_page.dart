import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:maori_health/core/config/app_strings.dart';
import 'package:maori_health/core/di/injection.dart';
import 'package:maori_health/domain/employee/entities/employee.dart';

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
      create: (_) => getIt<TimeSheetBloc>()..add(const TimeSheetDateAndEmployeeChanged()),
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
  Employee? _selectedEmployee;

  TimeSheetBloc get _timeSheetBloc => context.read<TimeSheetBloc>();

  Future<void> _onRefresh(BuildContext context) async {
    _timeSheetBloc.add(
      TimeSheetDateAndEmployeeChanged(startDate: _startDate, endDate: _endDate, employee: _selectedEmployee),
    );
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
                selectedEmployee: _selectedEmployee,
                onDateRangeChanged: (start, end) {
                  setState(() {
                    _startDate = start;
                    _endDate = end;
                  });
                  _timeSheetBloc.add(
                    TimeSheetDateAndEmployeeChanged(startDate: start, endDate: end, employee: _selectedEmployee),
                  );
                },
                onDateRangeCleared: () {
                  setState(() {
                    _startDate = null;
                    _endDate = null;
                  });
                  _timeSheetBloc.add(TimeSheetDateAndEmployeeChanged(employee: _selectedEmployee));
                },
                onEmployeeChanged: (employee) {
                  setState(() => _selectedEmployee = employee);
                  _timeSheetBloc.add(
                    TimeSheetDateAndEmployeeChanged(startDate: _startDate, endDate: _endDate, employee: employee),
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
                        onRetry: () => _timeSheetBloc.add(const TimeSheetDateAndEmployeeChanged()),
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
                    TimeSheetLoadMore(startDate: _startDate, endDate: _endDate, employee: _selectedEmployee),
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

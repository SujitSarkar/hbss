import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maori_health/core/config/app_list.dart';
import 'package:maori_health/core/di/injection.dart';

import 'package:maori_health/domain/client/entities/client.dart';
import 'package:maori_health/presentation/schedule/bloc/schedule_bloc.dart';
import 'package:maori_health/presentation/schedule/pages/views/client_schedule_view.dart';
import 'package:maori_health/presentation/schedule/pages/views/daily_schedule_view.dart';
import 'package:maori_health/presentation/schedule/widgets/shedule_header_widget.dart';

class SchedulePage extends StatelessWidget {
  const SchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (_) => getIt<ScheduleBloc>(), child: _ScheduleView());
  }
}

class _ScheduleView extends StatelessWidget {
  _ScheduleView();

  final ValueNotifier<String> selectedFilter = ValueNotifier(AppList.scheduleFilters.first);
  final ValueNotifier<Client?> selectedClient = ValueNotifier(null);
  final ValueNotifier<DateTime?> selectedDate = ValueNotifier(DateTime.now());

  @override
  Widget build(BuildContext context) {
    // final theme = context.theme;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            ValueListenableBuilder(
              valueListenable: selectedFilter,
              builder: (context, value, child) {
                return ScheduleHeaderWidget(
                  onFilterChanged: (value) {
                    selectedDate.value = null;
                    selectedClient.value = null;
                    selectedFilter.value = value;
                  },
                  selectedFilter: value,
                );
              },
            ),
            const SizedBox(height: 12),
            Expanded(
              child: BlocBuilder<ScheduleBloc, ScheduleState>(
                builder: (context, state) {
                  // return const SizedBox.shrink();
                  // return switch (state) {
                  //   ScheduleLoadingState() => const ScheduleShimmer(),
                  //   ScheduleErrorState() => const ScheduleError(),
                  //   ScheduleLoadedState() => const ScheduleLoaded(),
                  // };

                  return ValueListenableBuilder(
                    valueListenable: selectedFilter,
                    builder: (context, value, child) {
                      return switch (value) {
                        'Client' => ValueListenableBuilder(
                          valueListenable: selectedClient,
                          builder: (context, value, child) {
                            return ClientScheduleView(
                              selectedClient: value,
                              onSelected: (client) {
                                selectedClient.value = client;
                              },
                            );
                          },
                        ),
                        'Daily' => ValueListenableBuilder(
                          valueListenable: selectedDate,
                          builder: (context, value, child) {
                            return DailyScheduleView(
                              selectedDate: value,
                              onSelected: (date) {
                                selectedDate.value = date;
                              },
                            );
                          },
                        ),
                        _ => const SizedBox.shrink(),
                      };
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

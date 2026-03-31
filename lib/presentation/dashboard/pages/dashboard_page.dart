import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:maori_health/core/config/assets.dart';
import 'package:maori_health/core/config/app_strings.dart';
import 'package:maori_health/core/di/injection.dart';
import 'package:maori_health/core/network/api_endpoints.dart';
import 'package:maori_health/core/router/route_names.dart';
import 'package:maori_health/core/utils/extensions.dart';

import 'package:maori_health/domain/dashboard/entities/dashboard_response.dart';
import 'package:maori_health/domain/schedule/entities/schedule.dart';
import 'package:maori_health/domain/dashboard/entities/stats.dart';

import 'package:maori_health/presentation/auth/bloc/bloc.dart';
import 'package:maori_health/presentation/dashboard/bloc/bloc.dart';
import 'package:maori_health/presentation/dashboard/widgets/dashboard_shimmer.dart';
import 'package:maori_health/presentation/dashboard/widgets/job_list_builder_widget.dart';
import 'package:maori_health/presentation/lookup_enums/bloc/bloc.dart';
import 'package:maori_health/presentation/dashboard/widgets/schedule_slider.dart';
import 'package:maori_health/presentation/dashboard/widgets/stat_card.dart';
import 'package:maori_health/presentation/shared/widgets/error_view_widget.dart';
import 'package:maori_health/presentation/shared/widgets/swipe_refresh_wrapper.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<DashboardBloc>()..add(const DashboardLoadEvent()),
      child: const _DashboardView(),
    );
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<DashboardBloc, DashboardState>(
          builder: (context, state) => switch (state) {
            DashboardInitialState() || DashboardLoadingState() => const DashboardShimmer(),
            DashboardErrorState(:final message) => ErrorViewWidget(
              message: message,
              onRetry: () => _onRefresh(context),
            ),
            DashboardLoadedState(:final dashboardData) => _buildLoaded(context, dashboardData),
          },
        ),
      ),
    );
  }

  Future<void> _onRefresh(BuildContext context) async {
    context.read<DashboardBloc>().add(const DashboardLoadEvent());

    // Load LookupEnums if not loaded
    if (context.read<LookupEnumsBloc>().state is! LookupEnumsLoadedState) {
      context.read<LookupEnumsBloc>().add(const LoadLookupEnumsEvent());
    }
  }

  void _onScheduleTap(BuildContext context, Schedule schedule) async {
    final shouldRefresh = await context.pushNamed<bool>(
      RouteNames.scheduleDetails,
      extra: {'fromScreenName': RouteNames.dashboard, 'schedule': schedule},
    );
    if (shouldRefresh == true && context.mounted) {
      _onRefresh(context);
    }
  }

  Widget _buildLoaded(BuildContext context, DashboardResponse dashboardData) {
    final statsItems = _buildStatsItems(dashboardData.stats);

    return SwipeRefreshWrapper(
      onRefresh: () => _onRefresh(context),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const .fromLTRB(16, 16, 16, 24),
        child: Column(
          crossAxisAlignment: .start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 20),

            // Available Jobs Slider
            if (dashboardData.availableJobs.isNotEmpty) ...[
              Text(AppStrings.availableJobs, style: context.textTheme.titleMedium?.copyWith(fontWeight: .bold)),
              const SizedBox(height: 12),
              ScheduleSlider(
                schedules: dashboardData.availableJobs,
                onScheduleTap: (schedule) => _onScheduleTap(context, schedule),
              ),
              const SizedBox(height: 24),
            ],

            // Stats Grid
            GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.3,
              ),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: statsItems.length,
              itemBuilder: (context, index) => StatCard(value: statsItems[index].value, label: statsItems[index].label),
            ),
            const SizedBox(height: 24),

            // Current Scheduled Job
            if (dashboardData.currentSchedule != null) ...[
              JobListBuilderWidget(
                title: AppStrings.currentScheduled,
                jobs: [dashboardData.currentSchedule!],
                onJobTap: (job) => _onScheduleTap(context, job),
              ),
              const SizedBox(height: 16),
            ],

            // Next Scheduled Job
            if (dashboardData.nextSchedule != null) ...[
              JobListBuilderWidget(
                title: AppStrings.nextSchedule,
                jobs: [dashboardData.nextSchedule!],
                onJobTap: (job) => _onScheduleTap(context, job),
              ),
              const SizedBox(height: 16),
            ],

            // Today Scheduled Jobs
            if (dashboardData.todaysSchedules.isNotEmpty) ...[
              JobListBuilderWidget(
                title: AppStrings.todaySchedule,
                jobs: dashboardData.todaysSchedules,
                onJobTap: (job) => _onScheduleTap(context, job),
              ),
              const SizedBox(height: 16),
            ],

            // Upcoming Scheduled Jobs
            if (dashboardData.upcomingSchedules.isNotEmpty) ...[
              JobListBuilderWidget(
                title: AppStrings.upcomingSchedule,
                jobs: dashboardData.upcomingSchedules,
                onJobTap: (job) => _onScheduleTap(context, job),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final textTheme = context.textTheme;

    return BlocBuilder<AuthBloc, AuthState>(
      buildWhen: (prev, curr) => prev.user != curr.user,
      builder: (context, state) {
        final name = state.user?.firstName ?? '';
        return Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: .start,
                children: [
                  Text('Hi, $name', style: textTheme.headlineSmall?.copyWith(fontWeight: .bold)),
                  const SizedBox(height: 2),
                  Text(
                    AppStrings.welcomeTo,
                    style: textTheme.bodySmall?.copyWith(color: context.colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            CachedNetworkImage(
              imageUrl: ApiEndpoints.imageUrl(state.user?.avatar ?? ''),
              height: 48,
              placeholder: (_, _) => Image.asset(Assets.assetsImagesBannerLogo, height: 48),
              errorWidget: (_, _, _) => Image.asset(Assets.assetsImagesBannerLogo, height: 48),
            ),
          ],
        );
      },
    );
  }

  List<StatsGridItem> _buildStatsItems(Stats stats) {
    return [
      StatsGridItem(value: '${stats.totalJobs}', label: AppStrings.totalJob),
      StatsGridItem(value: '${stats.activeJobs}', label: AppStrings.activeJob),
      StatsGridItem(value: '${stats.cancelledJobs}', label: AppStrings.cancelJob),
      StatsGridItem(value: '${stats.completedJobs}', label: AppStrings.completeJob),
      StatsGridItem(value: '${stats.totalClients}', label: AppStrings.totalClient),
      StatsGridItem(value: '${stats.missedTimesheets}', label: AppStrings.missedTimeSheets),
    ];
  }
}

class StatsGridItem {
  final String value;
  final String label;

  const StatsGridItem({required this.value, required this.label});
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:maori_health/core/config/assets.dart';
import 'package:maori_health/core/config/app_strings.dart';
import 'package:maori_health/core/di/injection.dart';
import 'package:maori_health/core/router/route_names.dart';
import 'package:maori_health/core/utils/extensions.dart';

import 'package:maori_health/domain/dashboard/entities/dashboard_response.dart';
import 'package:maori_health/domain/dashboard/entities/job.dart';
import 'package:maori_health/domain/dashboard/entities/stats.dart';

import 'package:maori_health/presentation/auth/bloc/bloc.dart';
import 'package:maori_health/presentation/dashboard/bloc/bloc.dart';
import 'package:maori_health/presentation/dashboard/widgets/dashboard_shimmer.dart';
import 'package:maori_health/presentation/dashboard/widgets/job_card.dart';
import 'package:maori_health/presentation/dashboard/widgets/job_carousel.dart';
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
            DashboardErrorState(:final message) => _buildError(context, message),
            DashboardLoadedState(:final dashboardData) => _buildLoaded(context, dashboardData),
          },
        ),
      ),
    );
  }

  Future<void> _onRefresh(BuildContext context) async {
    context.read<DashboardBloc>().add(const DashboardLoadEvent());
  }

  void _onJobTap(BuildContext context, Job job) {
    context.pushNamed(RouteNames.jobDetails, extra: job);
  }

  Widget _buildError(BuildContext context, String message) {
    return SwipeRefreshWrapper(
      onRefresh: () => _onRefresh(context),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: context.screenSize.height * 0.3),
          ErrorViewWidget(message: message, onRetry: () => _onRefresh(context)),
        ],
      ),
    );
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

            if (dashboardData.availableJobs.isNotEmpty) ...[
              _buildSectionTitle(context, AppStrings.availableJobs),
              const SizedBox(height: 12),
              JobCarousel(jobs: dashboardData.availableJobs, onJobTap: (job) => _onJobTap(context, job)),
              const SizedBox(height: 24),
            ],

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

            if (dashboardData.currentSchedule != null) ...[
              _buildSectionTitle(context, AppStrings.currentScheduled),
              const SizedBox(height: 12),
              _buildJobCard(context, dashboardData.currentSchedule!),
              const SizedBox(height: 16),
            ],

            if (dashboardData.nextSchedule != null) ...[
              _buildSectionTitle(context, AppStrings.nextSchedule),
              const SizedBox(height: 12),
              _buildJobCard(context, dashboardData.nextSchedule!),
              const SizedBox(height: 16),
            ],

            if (dashboardData.todaysSchedules.isNotEmpty) ...[
              _buildSectionTitle(context, AppStrings.todaySchedule),
              const SizedBox(height: 12),
              ...dashboardData.todaysSchedules.map((j) => _buildJobCard(context, j)),
              const SizedBox(height: 16),
            ],

            if (dashboardData.upcomingSchedules.isNotEmpty) ...[
              _buildSectionTitle(context, AppStrings.upcomingSchedule),
              const SizedBox(height: 12),
              ...dashboardData.upcomingSchedules.map((j) => _buildJobCard(context, j)),
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
            Image.asset(Assets.assetsImagesBannerLogo, height: 48),
          ],
        );
      },
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(title, style: context.textTheme.titleLarge?.copyWith(fontWeight: .bold));
  }

  Widget _buildJobCard(BuildContext context, Job job) {
    return Padding(
      padding: const .only(bottom: 12),
      child: JobCard(job: job, onTap: () => _onJobTap(context, job)),
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

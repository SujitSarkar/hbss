import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:maori_health/core/config/app_strings.dart';
import 'package:maori_health/core/enums/job.status.enum.dart';
import 'package:maori_health/core/theme/app_colors.dart';
import 'package:maori_health/core/utils/date_converter.dart';
import 'package:maori_health/core/utils/extensions.dart';
import 'package:maori_health/core/utils/dashboard_utils.dart';
import 'package:maori_health/domain/dashboard/entities/job.dart';

import 'package:maori_health/presentation/dashboard/widgets/job_details_info_card.dart';
import 'package:maori_health/presentation/schedule/bloc/schedule_bloc.dart';
import 'package:maori_health/presentation/schedule/widgets/job_details_shimmer.dart';
import 'package:maori_health/presentation/shared/widgets/common_app_bar.dart';
import 'package:maori_health/presentation/shared/widgets/solid_button.dart';

class JobDetailsPage extends StatefulWidget {
  final Job? job;
  final int? jobScheduleId;
  const JobDetailsPage({super.key, this.job, this.jobScheduleId});

  @override
  State<JobDetailsPage> createState() => _JobDetailsPageState();
}

class _JobDetailsPageState extends State<JobDetailsPage> {
  final ValueNotifier<Job?> _jobNotifier = ValueNotifier(null);

  @override
  void initState() {
    super.initState();
    _jobNotifier.value = widget.job;
    if (widget.job == null && widget.jobScheduleId != null) {
      context.read<ScheduleBloc>().add(ScheduleDetailsLoadEvent(scheduleId: widget.jobScheduleId!));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ScheduleBloc, ScheduleState>(
      listener: (context, state) {
        if (state is ScheduleLoadedState) {
          _jobNotifier.value = state.schedule;
        } else if (state is ScheduleErrorState) {
          context.showSnackBar(state.errorMessage);
        }
      },
      child: BlocBuilder<ScheduleBloc, ScheduleState>(
        builder: (context, state) {
          return Scaffold(
            appBar: CommonAppBar(context: context, title: Text(AppStrings.jobDetails)),
            body: state is ScheduleDetailsLoadingState
                ? JobDetailsShimmer()
                : SafeArea(
                    child: SingleChildScrollView(
                      padding: const .fromLTRB(12, 0, 12, 24),
                      child: ValueListenableBuilder(
                        valueListenable: _jobNotifier,
                        builder: (context, job, child) {
                          return Column(
                            crossAxisAlignment: .start,
                            children: [
                              JobDetailsInfoCard(
                                date: DateConverter.formatIsoDateTime(job?.scheduleStartTime),
                                jobType: DashboardUtils.formatJobType(job?.jobType),
                                clientName: job?.client?.fullName ?? '-',
                                clientAddress: job?.client?.address?.fullAddress ?? '-',
                                duration: job?.scheduleTotalTime.toStringAsFixed(2) ?? '-',
                                startTime: DateConverter.formatIsoDateTime(job?.scheduleStartTime, pattern: 'h:mm a'),
                                endTime: DateConverter.formatIsoDateTime(job?.scheduleEndTime, pattern: 'h:mm a'),
                                status: job?.status,
                                jobStartedTime: job?.workStartTime != null
                                    ? DateConverter.formatIsoDateTime(job!.workStartTime, pattern: 'h:mm a')
                                    : null,
                              ),
                              const SizedBox(height: 24),
                              if (job != null) _buildActions(job.status),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
          );
        },
      ),
    );
  }

  Widget _buildActions(String? jobStatus) {
    if (jobStatus == JobStatusEnum.pending.value) {
      return _buildPendingActions();
    } else if (jobStatus == JobStatusEnum.active.value) {
      return _buildAcceptedActions();
    } else if (jobStatus == JobStatusEnum.inProgress.value) {
      return _buildStartedActions();
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget _buildPendingActions() {
    return Column(
      crossAxisAlignment: .stretch,
      children: [
        SolidButton(onPressed: () {}, child: const Text(AppStrings.acceptJob)),
        const SizedBox(height: 24),
        SolidButton(
          onPressed: () => Navigator.maybePop(context),
          backgroundColor: AppColors.primary.withAlpha(250),
          child: const Text(AppStrings.backToDashboard),
        ),
      ],
    );
  }

  Widget _buildAcceptedActions() {
    return Column(
      crossAxisAlignment: .stretch,
      children: [
        SolidButton(onPressed: () {}, child: const Text(AppStrings.startJob)),
        const SizedBox(height: 12),
        SolidButton(
          onPressed: () {
            // TODO: Dispatch cancel job
          },
          backgroundColor: AppColors.amber,
          foregroundColor: Colors.black87,
          child: const Text(AppStrings.cancelJob),
        ),
        const SizedBox(height: 12),
        SolidButton(
          onPressed: () => Navigator.maybePop(context),
          backgroundColor: AppColors.primary.withAlpha(150),
          child: const Text(AppStrings.backToDashboard),
        ),
      ],
    );
  }

  Widget _buildStartedActions() {
    return Column(
      crossAxisAlignment: .stretch,
      children: [
        SolidButton(
          onPressed: () {
            // TODO: Dispatch finish job
          },
          child: const Text(AppStrings.finishJob),
        ),
        const SizedBox(height: 12),
        SolidButton(
          onPressed: () {
            // TODO: Dispatch cancel job
          },
          backgroundColor: AppColors.amber,
          foregroundColor: Colors.black87,
          child: const Text(AppStrings.cancelJob),
        ),
        const SizedBox(height: 12),
        SolidButton(
          onPressed: () => Navigator.maybePop(context),
          backgroundColor: AppColors.primary,
          child: const Text(AppStrings.backToDashboard),
        ),
      ],
    );
  }
}

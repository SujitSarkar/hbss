import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:maori_health/core/config/app_strings.dart';
import 'package:maori_health/core/enums/job_status.enum.dart';
import 'package:maori_health/core/theme/app_colors.dart';
import 'package:maori_health/core/utils/date_converter.dart';
import 'package:maori_health/core/utils/extensions.dart';
import 'package:maori_health/domain/schedule/entities/schedule.dart';

import 'package:maori_health/presentation/schedule/widgets/schedule_details_info_card.dart';
import 'package:maori_health/presentation/schedule/bloc/schedule_bloc.dart';
import 'package:maori_health/presentation/schedule/widgets/schedule_details_shimmer.dart';
import 'package:maori_health/presentation/shared/widgets/common_app_bar.dart';
import 'package:maori_health/presentation/shared/widgets/solid_button.dart';

class ScheduleDetailsPage extends StatefulWidget {
  final Schedule? schedule;
  final int? scheduleId;
  const ScheduleDetailsPage({super.key, this.schedule, this.scheduleId});

  @override
  State<ScheduleDetailsPage> createState() => _ScheduleDetailsPageState();
}

class _ScheduleDetailsPageState extends State<ScheduleDetailsPage> {
  final ValueNotifier<Schedule?> _scheduleNotifier = ValueNotifier(null);

  @override
  void initState() {
    super.initState();
    _scheduleNotifier.value = widget.schedule;
    if (widget.schedule == null && widget.scheduleId != null) {
      context.read<ScheduleBloc>().add(ScheduleDetailsLoadEvent(scheduleId: widget.scheduleId!));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ScheduleBloc, ScheduleState>(
      listener: (context, state) {
        if (state is ScheduleLoadedState) {
          _scheduleNotifier.value = state.scheduleDetails;
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
                        valueListenable: _scheduleNotifier,
                        builder: (context, job, child) {
                          return Column(
                            crossAxisAlignment: .start,
                            children: [
                              ScheduleDetailsInfoCard(
                                date: DateConverter.formatIsoDateTime(job?.scheduleStartTime),
                                jobType: (job?.jobType ?? '-').toUpperCase(),
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

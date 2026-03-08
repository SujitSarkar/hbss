import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:maori_health/core/config/app_strings.dart';
import 'package:maori_health/core/enums/job_status.enum.dart';
import 'package:maori_health/core/theme/app_colors.dart';
import 'package:maori_health/core/utils/date_converter.dart';
import 'package:maori_health/core/utils/extensions.dart';
import 'package:maori_health/core/utils/schedule_utils.dart';

import 'package:maori_health/domain/schedule/entities/schedule.dart';

import 'package:maori_health/presentation/schedule/widgets/schedule_details_info_card.dart';
import 'package:maori_health/presentation/schedule/bloc/schedule_bloc.dart';
import 'package:maori_health/presentation/schedule/widgets/schedule_details_shimmer.dart';
import 'package:maori_health/presentation/schedule/widgets/schedule_finish_dialog_widget.dart';
import 'package:maori_health/presentation/shared/widgets/common_app_bar.dart';
import 'package:maori_health/presentation/shared/widgets/confirmation_dialog.dart';
import 'package:maori_health/presentation/shared/widgets/loading_overlay.dart';
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
        if (state is ScheduleLoadedState && state.scheduleDetails != null) {
          _scheduleNotifier.value = state.scheduleDetails;
        } else if (state is ScheduleStartSuccessState) {
          _scheduleNotifier.value = state.schedule;
        } else if (state is ScheduleFinishSuccessState) {
          _scheduleNotifier.value = state.schedule;
        } else if (state is ScheduleCancelSuccessState) {
          _scheduleNotifier.value = state.schedule;
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
                : LoadingOverlay(
                    isLoading: state is ScheduleLoadedState && state.actionLoading,
                    child: SafeArea(
                      child: SingleChildScrollView(
                        padding: const .fromLTRB(12, 0, 12, 24),
                        child: ValueListenableBuilder(
                          valueListenable: _scheduleNotifier,
                          builder: (_, job, _) {
                            return Column(
                              crossAxisAlignment: .start,
                              mainAxisSize: MainAxisSize.max,
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
                                if (job != null) _buildActions(job),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
          );
        },
      ),
    );
  }

  Widget _buildActions(Schedule? job) {
    if (job?.status == JobStatusEnum.pending.value) {
      return _buildPendingActions(job);
    } else if (job?.status == JobStatusEnum.active.value) {
      return _buildAcceptedActions(job);
    } else if (job?.status == JobStatusEnum.inProgress.value) {
      return _buildStartedActions(job);
    } else if (job?.status == JobStatusEnum.finished.value) {
      return _buildFinishedActions(job);
    } else {
      return const SizedBox.shrink();
    }
  }

  ScheduleFinishDialogData _buildFinishDialogData(Schedule job) {
    final analysis = ScheduleUtils.analyzeFinishState(job);

    return ScheduleFinishDialogData(
      category: analysis.category,
      scheduledDuration: analysis.scheduledDuration,
      actualDuration: analysis.actualDuration,
      durationDifference: analysis.durationDifference,
      scheduledEndTimeLabel: DateConverter.formatIsoDateTime(
        analysis.scheduleEnd?.toIso8601String() ?? job.scheduleEndTime,
        pattern: 'h:mm a',
      ),
    );
  }

  Widget _buildPendingActions(Schedule? job) {
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

  Widget _buildAcceptedActions(Schedule? job) {
    return Column(
      crossAxisAlignment: .stretch,
      children: [
        SolidButton(
          onPressed: () async {
            if (job == null) return;
            final confirmed = await showConfirmationDialog(
              context,
              title: AppStrings.startJob,
              message: AppStrings.areYouSureYouWantToStartJob,
              confirmText: AppStrings.yes,
              cancelText: AppStrings.no,
              cancelColor: context.theme.colorScheme.error,
            );
            if (confirmed && mounted) {
              context.read<ScheduleBloc>().add(ScheduleStartEvent(scheduleId: job.id));
            }
          },
          child: const Text(AppStrings.startJob),
        ),
        const SizedBox(height: 12),
        SolidButton(
          onPressed: () async {
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

  Widget _buildStartedActions(Schedule? job) {
    return Column(
      crossAxisAlignment: .stretch,
      children: [
        SolidButton(
          onPressed: () async {
            if (job == null) return;
            final confirmed = await showScheduleFinishDialog(context, data: _buildFinishDialogData(job));
            if (!mounted) return;
            if (confirmed) {
              context.read<ScheduleBloc>().add(ScheduleFinishEvent(scheduleId: job.id));
            }
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

  Widget _buildFinishedActions(Schedule? job) {
    return Column(
      crossAxisAlignment: .stretch,
      children: [
        SolidButton(onPressed: () => Navigator.maybePop(context), child: const Text(AppStrings.backToDashboard)),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:maori_health/core/config/app_strings.dart';
import 'package:maori_health/core/router/route_names.dart';
import 'package:maori_health/core/theme/app_colors.dart';
import 'package:maori_health/core/utils/date_converter.dart';
import 'package:maori_health/core/utils/extensions.dart';
import 'package:maori_health/core/utils/schedule_utils.dart';
import 'package:maori_health/domain/schedule/entities/schedule.dart';

import 'package:maori_health/presentation/lookup_enums/bloc/bloc.dart';
import 'package:maori_health/presentation/schedule/widgets/dialog_widgets/schedule_cancel_dialog_widget.dart';
import 'package:maori_health/presentation/schedule/widgets/schedule_details_info_card.dart';
import 'package:maori_health/presentation/schedule/bloc/schedule_bloc.dart';
import 'package:maori_health/presentation/schedule/widgets/shimmer_widgets/schedule_details_shimmer.dart';
import 'package:maori_health/presentation/schedule/widgets/dialog_widgets/schedule_finish_dialog_widget.dart';
import 'package:maori_health/presentation/shared/widgets/common_app_bar.dart';
import 'package:maori_health/presentation/shared/widgets/confirmation_dialog.dart';
import 'package:maori_health/presentation/shared/widgets/loading_overlay.dart';
import 'package:maori_health/presentation/shared/widgets/solid_button.dart';

class ScheduleDetailsPage extends StatefulWidget {
  final String fromScreenName;
  final Schedule? schedule;
  final int? scheduleId;
  const ScheduleDetailsPage({super.key, required this.fromScreenName, this.schedule, this.scheduleId});

  @override
  State<ScheduleDetailsPage> createState() => _ScheduleDetailsPageState();
}

class _ScheduleDetailsPageState extends State<ScheduleDetailsPage> {
  final ValueNotifier<Schedule?> _scheduleNotifier = ValueNotifier(null);
  bool _shouldRefreshDashboard = false;

  @override
  void initState() {
    super.initState();
    _scheduleNotifier.value = widget.schedule;
    if (widget.schedule == null && widget.scheduleId != null) {
      context.read<ScheduleBloc>().add(ScheduleDetailsLoadEvent(scheduleId: widget.scheduleId!));
    }

    // Load LookupEnums if not loaded
    if (context.read<LookupEnumsBloc>().state is! LookupEnumsLoadedState) {
      context.read<LookupEnumsBloc>().add(const LoadLookupEnumsEvent());
    }
  }

  void _onJobCanceled(String canceledBy, String? cancelReason, int? hour, int minute, String reason) {
    context.read<ScheduleBloc>().add(
      ScheduleCancelEvent(
        scheduleId: _scheduleNotifier.value?.id ?? 0,
        cancelBy: canceledBy,
        cancelReason: cancelReason,
        hour: hour,
        minute: minute,
        reason: reason,
      ),
    );
  }

  void _markDashboardRefreshNeeded() {
    if (widget.fromScreenName == RouteNames.dashboard) {
      _shouldRefreshDashboard = true;
    }
  }

  void _popWithResult() {
    if (!mounted) return;
    Navigator.pop(context, _shouldRefreshDashboard);
  }

  @override
  Widget build(BuildContext context) {
    final lookupEnumState = context.watch<LookupEnumsBloc>().state;
    final LookupEnumsLoadedState? lookupEnumsLoadedState = lookupEnumState is LookupEnumsLoadedState
        ? lookupEnumState
        : null;

    return BlocListener<ScheduleBloc, ScheduleState>(
      listener: (context, state) {
        if (state is ScheduleLoadedState && state.scheduleDetails != null) {
          _scheduleNotifier.value = state.scheduleDetails;
        } else if (state is ScheduleAcceptSuccessState) {
          _scheduleNotifier.value = state.schedule;
          _markDashboardRefreshNeeded();
        } else if (state is ScheduleStartSuccessState) {
          _scheduleNotifier.value = state.schedule;
          _markDashboardRefreshNeeded();
        } else if (state is ScheduleFinishSuccessState) {
          _scheduleNotifier.value = state.schedule;
          _markDashboardRefreshNeeded();
        } else if (state is ScheduleCancelSuccessState) {
          _scheduleNotifier.value = state.schedule;
          _markDashboardRefreshNeeded();
        } else if (state is ScheduleErrorState) {
          context.showSnackBar(state.errorMessage, isError: true);
        }
      },
      child: BlocBuilder<ScheduleBloc, ScheduleState>(
        builder: (context, state) {
          return PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, result) {
              if (!didPop) _popWithResult();
            },
            child: Scaffold(
              appBar: CommonAppBar(
                context: context,
                title: Text(AppStrings.jobDetails),
                leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: _popWithResult),
              ),
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
                                    lookupEnumState: lookupEnumsLoadedState,
                                    date: DateConverter.formatIsoDateTime(job?.scheduleStartTime),
                                    jobType: (job?.jobType ?? '-').toUpperCase(),
                                    clientName: job?.client?.fullName ?? '-',
                                    clientAddress: job?.client?.address?.fullAddress ?? '-',
                                    duration: job?.scheduleTotalTime.toStringAsFixed(2) ?? '-',
                                    startTime: DateConverter.formatIsoDateTime(
                                      job?.scheduleStartTime,
                                      pattern: 'h:mm a',
                                    ),
                                    endTime: DateConverter.formatIsoDateTime(job?.scheduleEndTime, pattern: 'h:mm a'),
                                    status: job?.status,
                                    jobStartedTime: job?.workStartTime != null
                                        ? DateConverter.formatIsoDateTime(job!.workStartTime, pattern: 'h:mm a')
                                        : null,
                                  ),
                                  const SizedBox(height: 24),
                                  if (job != null && lookupEnumsLoadedState != null)
                                    _buildActions(job, lookupEnumsLoadedState),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActions(Schedule? job, LookupEnumsLoadedState? lookupEnumsLoadedState) {
    if (job?.assignee == null) {
      return _buildPendingActions(job);
    } else if (job?.assignee != null && job?.status == lookupEnumsLoadedState?.lookupEnums.scheduleStatusKey.active) {
      return _buildAcceptedActions(job);
    } else if (job?.assignee != null &&
        job?.status == lookupEnumsLoadedState?.lookupEnums.scheduleStatusKey.inprogress) {
      return _buildStartedActions(job);
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget _buildPendingActions(Schedule? job) {
    return Column(
      crossAxisAlignment: .stretch,
      children: [
        SolidButton(
          onPressed: () async {
            if (job == null) return;
            final confirmed = await showConfirmationDialog(
              context,
              title: AppStrings.acceptJob,
              message: AppStrings.areYouSureYouWantToAcceptJob,
              confirmText: AppStrings.yes,
              cancelText: AppStrings.no,
              cancelColor: context.theme.colorScheme.error,
            );
            if (confirmed && mounted) {
              context.read<ScheduleBloc>().add(ScheduleAcceptEvent(scheduleId: job.id));
            }
          },
          child: const Text(AppStrings.acceptJob),
        ),
        const SizedBox(height: 24),
        SolidButton(
          onPressed: _popWithResult,
          backgroundColor: AppColors.primary.withAlpha(250),
          child: Text('${AppStrings.backTo} ${widget.fromScreenName.capitalize()}'),
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
            if (job == null) return;
            await showDialog(
              context: context,
              barrierDismissible: false,
              builder: (dialogContext) => ScheduleCancelDialogWidget(
                schedule: job,
                onSave: _onJobCanceled,
                onClose: () => Navigator.maybePop(dialogContext),
              ),
            );
          },
          backgroundColor: AppColors.amber,
          foregroundColor: Colors.black87,
          child: const Text(AppStrings.cancelJob),
        ),
        const SizedBox(height: 12),
        SolidButton(
          onPressed: _popWithResult,
          backgroundColor: AppColors.primary.withAlpha(150),
          child: Text('${AppStrings.backTo} ${widget.fromScreenName.capitalize()}'),
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
            await showDialog(
              context: context,
              barrierDismissible: false,
              builder: (dialogContext) => ScheduleFinishDialogWidget(
                data: ScheduleUtils.analyzeFinishState(job),
                onSave: () => context.read<ScheduleBloc>().add(ScheduleFinishEvent(scheduleId: job.id)),
                onClose: () => Navigator.maybePop(dialogContext),
              ),
            );
          },
          child: const Text(AppStrings.finishJob),
        ),
        const SizedBox(height: 12),
        SolidButton(
          onPressed: () async {
            if (job == null) return;
            await showDialog(
              context: context,
              barrierDismissible: false,
              builder: (dialogContext) => ScheduleCancelDialogWidget(
                schedule: job,
                onSave: _onJobCanceled,
                onClose: () => Navigator.maybePop(dialogContext),
              ),
            );
          },
          backgroundColor: AppColors.amber,
          foregroundColor: Colors.black87,
          child: const Text(AppStrings.cancelJob),
        ),
        const SizedBox(height: 12),
        SolidButton(
          onPressed: _popWithResult,
          backgroundColor: AppColors.primary,
          child: Text('${AppStrings.backTo} ${widget.fromScreenName.capitalize()}'),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:maori_health/core/config/app_strings.dart';
import 'package:maori_health/core/theme/app_colors.dart';
import 'package:maori_health/core/utils/color_utils.dart';
import 'package:maori_health/core/utils/date_converter.dart';
import 'package:maori_health/core/utils/extensions.dart';
import 'package:maori_health/core/utils/schedule_utils.dart';
import 'package:maori_health/domain/schedule/entities/schedule.dart';

import 'package:maori_health/presentation/lookup_enums/bloc/bloc.dart';
import 'package:maori_health/presentation/shared/widgets/loading_widget.dart';

class ScheduleListTileWidget extends StatelessWidget {
  final Schedule schedule;
  final VoidCallback? onTap;
  const ScheduleListTileWidget({super.key, required this.schedule, this.onTap});

  String get _date => DateConverter.formatIsoDateTime(schedule.scheduleStartTime, pattern: 'EEEE, MMMM d, yyyy');
  String get _startTime => DateConverter.formatIsoDateTime(schedule.scheduleStartTime, pattern: 'h:mm a');
  String get _endTime => DateConverter.formatIsoDateTime(schedule.scheduleEndTime, pattern: 'h:mm a');
  String get _totalHours => schedule.scheduleTotalTime.toStringAsFixed(2);
  String get _title => (schedule.jobType ?? '-').toUpperCase();
  String get _subtitle => 'Job #${schedule.id}';
  String? get _workStartedAt => schedule.workStartTime != null
      ? DateConverter.formatIsoDateTime(schedule.workStartTime, pattern: 'h:mm a')
      : null;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;

    return BlocBuilder<LookupEnumsBloc, LookupEnumsState>(
      builder: (context, lookupEnumState) {
        return GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const .all(12),
            decoration: BoxDecoration(
              color: schedule.color != null ? ColorUtils.hexToColor(schedule.color) : AppColors.primary.withAlpha(30),
              borderRadius: .circular(14),
              border: .all(color: AppColors.primary.withAlpha(150)),
            ),
            child: Column(
              crossAxisAlignment: .start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: .start,
                  children: [
                    Expanded(
                      child: Text(
                        _date,
                        style: textTheme.bodySmall?.copyWith(fontWeight: .w500, color: Colors.white),
                      ),
                    ),
                    // Status Badge Row
                    lookupEnumState is LookupEnumsLoadedState
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: .center,
                            children: [
                              if (schedule.status == lookupEnumState.lookupEnums.scheduleStatusKey.inprogress)
                                Padding(
                                  padding: const .only(right: 4),
                                  child: CircleAvatar(radius: 5, backgroundColor: AppColors.primary),
                                ),
                              schedule.status != null
                                  ? Container(
                                      padding: const .symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.white),
                                        borderRadius: .circular(4),
                                      ),
                                      child: Text(
                                        ScheduleUtils.getScheduleStatus(
                                          status: schedule.status,
                                          scheduleStatusKey: lookupEnumState.lookupEnums.scheduleStatusKey,
                                          scheduleStatusValue: lookupEnumState.lookupEnums.scheduleStatusValue,
                                        ),
                                        style: textTheme.bodySmall?.copyWith(color: Colors.white, fontWeight: .w500),
                                      ),
                                    )
                                  : SizedBox.shrink(),
                            ],
                          )
                        : SizedBox(height: 16, width: 16, child: LoadingWidget()),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  _title,
                  style: textTheme.titleMedium?.copyWith(fontWeight: .bold, color: Colors.white),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _subtitle,
                        style: textTheme.bodySmall?.copyWith(color: Colors.white),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (_workStartedAt != null)
                      Text(
                        '${AppStrings.startedAt} : $_workStartedAt',
                        style: textTheme.bodySmall?.copyWith(fontWeight: .w600, color: Colors.white),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _TimeColumn(label: AppStrings.startTime, value: _startTime),
                    const SizedBox(width: 24),
                    _TimeColumn(label: AppStrings.endTime, value: _endTime),
                    const Spacer(),
                    _TimeColumn(label: AppStrings.totalHours, value: _totalHours),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TimeColumn extends StatelessWidget {
  final String label;
  final String value;

  const _TimeColumn({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;

    return Column(
      crossAxisAlignment: .start,
      children: [
        Text(
          label,
          style: textTheme.bodySmall?.copyWith(fontWeight: .w500, color: Colors.white),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: textTheme.titleSmall?.copyWith(fontWeight: .bold, color: Colors.white),
        ),
      ],
    );
  }
}

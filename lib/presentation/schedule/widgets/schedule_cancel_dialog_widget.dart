import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:maori_health/core/config/app_strings.dart';
import 'package:maori_health/core/utils/extensions.dart';
import 'package:maori_health/core/utils/form_validators.dart';

import 'package:maori_health/domain/schedule/entities/schedule.dart';

import 'package:maori_health/presentation/lookup_enums/bloc/bloc.dart';
import 'package:maori_health/presentation/shared/decorations/outline_input_decoration.dart';
import 'package:maori_health/presentation/shared/widgets/app_dialog.dart';
import 'package:maori_health/presentation/shared/widgets/loading_widget.dart';
import 'package:maori_health/presentation/shared/widgets/solid_button.dart';

class ScheduleCancelDialogWidget extends StatelessWidget {
  final Schedule schedule;
  final VoidCallback onClose;
  final Function(String canceledBy, String? cancelReason, int hour, int minute, String reason) onSave;

  const ScheduleCancelDialogWidget({super.key, required this.schedule, required this.onSave, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final ValueNotifier<String?> canceledBy = ValueNotifier(null);
    final ValueNotifier<String?> cancelReason = ValueNotifier(null);
    final TextEditingController hourController = TextEditingController();
    final TextEditingController minuteController = TextEditingController();
    final TextEditingController reasonController = TextEditingController();

    return AppDialog(
      title: AppStrings.cancelJob,
      content: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: .start,
          children: [
            // Canceled by filter
            ValueListenableBuilder(
              valueListenable: canceledBy,
              builder: (context, value, child) => CanceledByFilterWidget(
                selectedCanceledBy: value,
                onSelected: (newCanceledBy) {
                  canceledBy.value = newCanceledBy;
                },
              ),
            ),
            const SizedBox(height: 18),

            // Cancel reason filter
            ValueListenableBuilder(
              valueListenable: canceledBy,
              builder: (context, value, child) {
                if (value?.toLowerCase() == AppStrings.client.toLowerCase()) {
                  return Column(
                    crossAxisAlignment: .start,
                    children: [
                      ValueListenableBuilder(
                        valueListenable: cancelReason,
                        builder: (context, value, child) => CancelReasonFilterWidget(
                          selectedCancelReason: value,
                          onSelected: (newReason) {
                            cancelReason.value = newReason;
                          },
                        ),
                      ),
                      const SizedBox(height: 18),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),

            // Hours and minutes input
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: hourController,
                    decoration: OutlineInputDecoration(context: context, labelText: AppStrings.hours),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: FormValidators.validateHours,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    keyboardType: .number,
                    errorBuilder: (context, error) => Text(
                      error,
                      maxLines: 2,
                      style: context.textTheme.labelSmall?.copyWith(
                        fontSize: 9,
                        color: context.theme.colorScheme.error,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: TextFormField(
                    controller: minuteController,
                    decoration: OutlineInputDecoration(context: context, labelText: AppStrings.minutes),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: FormValidators.validateMinutes,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    keyboardType: .number,
                    errorBuilder: (context, error) => Text(
                      error,
                      maxLines: 2,
                      style: context.textTheme.labelSmall?.copyWith(
                        fontSize: 9,
                        color: context.theme.colorScheme.error,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Cancel reason input
            TextFormField(
              controller: reasonController,
              decoration: OutlineInputDecoration(context: context, labelText: AppStrings.reason),
              validator: FormValidators.required(),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              keyboardType: .text,
              textCapitalization: .sentences,
              minLines: 3,
              maxLines: 5,
            ),
            const SizedBox(height: 18),

            // Save and close buttons
            Row(
              children: [
                Expanded(
                  child: SolidButton(
                    onPressed: () {
                      if (formKey.currentState?.validate() ?? false) {
                        Navigator.maybePop(context);
                        onSave(
                          canceledBy.value!,
                          cancelReason.value,
                          int.parse(hourController.text),
                          int.parse(minuteController.text),
                          reasonController.text,
                        );
                      }
                    },
                    child: const Text(AppStrings.save),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SolidButton(onPressed: onClose, child: const Text(AppStrings.close)),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class CanceledByFilterWidget extends StatelessWidget {
  final String? selectedCanceledBy;
  final void Function(String? canceledBy) onSelected;
  const CanceledByFilterWidget({super.key, this.selectedCanceledBy, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LookupEnumsBloc, LookupEnumsState>(
      builder: (context, state) {
        final List<String> canceledByList = state is LookupEnumsLoadedState
            ? state.lookupEnums.canceledBy.values.toList()
            : [];
        final isLoading = state is LookupEnumsLoadingState;
        return Column(
          crossAxisAlignment: .start,
          children: [
            Text(AppStrings.canceledBy, style: context.textTheme.bodyMedium?.copyWith(fontWeight: .w600)),
            const SizedBox(height: 8),
            isLoading
                ? Container(
                    height: 44,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: .circular(10),
                      border: .all(color: context.theme.hintColor),
                    ),
                    child: Center(child: SizedBox(height: 16, width: 16, child: LoadingWidget())),
                  )
                : DropdownButtonHideUnderline(
                    child: DropdownButtonFormField<String>(
                      initialValue: selectedCanceledBy,
                      items: canceledByList.map((e) => DropdownMenuItem<String>(value: e, child: Text(e))).toList(),
                      onChanged: (String? value) => onSelected(value),
                      validator: FormValidators.required(),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: OutlineInputDecoration(
                        context: context,
                        hintText: AppStrings.select,
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                      ),
                    ),
                  ),
          ],
        );
      },
    );
  }
}

class CancelReasonFilterWidget extends StatelessWidget {
  final String? selectedCancelReason;
  final void Function(String? cancelReason) onSelected;
  const CancelReasonFilterWidget({super.key, this.selectedCancelReason, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LookupEnumsBloc, LookupEnumsState>(
      builder: (context, state) {
        final List<String> cancelReasons = state is LookupEnumsLoadedState
            ? state.lookupEnums.cancelReason.values.toList()
            : [];
        final isLoading = state is LookupEnumsLoadingState;
        return Column(
          crossAxisAlignment: .start,
          children: [
            Text(AppStrings.cancelReason, style: context.textTheme.bodyMedium?.copyWith(fontWeight: .w600)),
            const SizedBox(height: 8),
            isLoading
                ? Container(
                    height: 44,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: .circular(10),
                      border: .all(color: context.theme.hintColor),
                    ),
                    child: Center(child: SizedBox(height: 16, width: 16, child: LoadingWidget())),
                  )
                : DropdownButtonHideUnderline(
                    child: DropdownButtonFormField<String>(
                      initialValue: selectedCancelReason,
                      items: cancelReasons.map((e) => DropdownMenuItem<String>(value: e, child: Text(e))).toList(),
                      onChanged: (String? value) => onSelected(value),
                      validator: FormValidators.required(),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: OutlineInputDecoration(
                        context: context,
                        hintText: AppStrings.select,
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                      ),
                    ),
                  ),
          ],
        );
      },
    );
  }
}

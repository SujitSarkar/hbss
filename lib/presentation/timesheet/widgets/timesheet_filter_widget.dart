import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:maori_health/core/config/app_strings.dart';
import 'package:maori_health/core/utils/date_converter.dart';
import 'package:maori_health/core/utils/extensions.dart';
import 'package:maori_health/domain/employee/entities/employee.dart';

import 'package:maori_health/presentation/employee/bloc/employee_bloc.dart';
import 'package:maori_health/presentation/employee/bloc/employee_state.dart';
import 'package:maori_health/presentation/employee/widgets/employee_tile_widget.dart';
import 'package:maori_health/presentation/shared/widgets/auto_complete_search_field.dart';
import 'package:maori_health/presentation/shared/widgets/loading_widget.dart';

class TimesheetFilterWidget extends StatelessWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final Employee? selectedEmployee;
  final void Function(DateTime start, DateTime end) onDateRangeChanged;
  final VoidCallback onDateRangeCleared;
  final void Function(Employee? employee) onEmployeeChanged;

  const TimesheetFilterWidget({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.selectedEmployee,
    required this.onDateRangeChanged,
    required this.onDateRangeCleared,
    required this.onEmployeeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final hasDateRange = startDate != null && endDate != null;
    final dateRangeText = hasDateRange
        ? '${DateConverter.formatDate(startDate!)} - ${DateConverter.formatDate(endDate!)}'
        : AppStrings.selectDateRange;

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: _EmployeeAutoComplete(selectedEmployee: selectedEmployee, onSelected: onEmployeeChanged),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 3,
          child: InkWell(
            onTap: () => _pickDateRange(context),
            borderRadius: .circular(8),
            child: Container(
              padding: const .symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: .circular(8),
                border: .all(color: context.theme.dividerColor),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(dateRangeText, style: context.textTheme.bodySmall, overflow: TextOverflow.ellipsis),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.calendar_today_outlined, size: 18, color: context.colorScheme.onSurfaceVariant),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickDateRange(BuildContext context) async {
    final now = DateTime.now();
    bool cleared = false;

    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: now.add(const Duration(days: 365)),
      initialDateRange: (startDate != null && endDate != null) ? DateTimeRange(start: startDate!, end: endDate!) : null,
      saveText: AppStrings.apply,
      cancelText: AppStrings.clear,
      builder: (dialogContext, child) {
        return Theme(
          data: dialogContext.theme.copyWith(
            colorScheme: dialogContext.colorScheme.copyWith(primary: dialogContext.colorScheme.primary),
          ),
          child: Column(
            children: [
              Expanded(child: child!),
              if (startDate != null && endDate != null)
                SafeArea(
                  top: false,
                  child: Container(
                    width: double.infinity,
                    alignment: .center,
                    padding: const .only(bottom: 8),
                    color: context.colorScheme.surface,
                    child: Center(
                      child: TextButton.icon(
                        style: TextButton.styleFrom(
                          backgroundColor: context.colorScheme.error,
                          foregroundColor: context.colorScheme.onError,
                          shape: RoundedRectangleBorder(borderRadius: .circular(8)),
                        ),
                        onPressed: () {
                          cleared = true;
                          Navigator.of(dialogContext).pop();
                        },
                        icon: Icon(Icons.clear, size: 20),
                        label: Text(
                          AppStrings.clear,
                          style: context.textTheme.bodyMedium?.copyWith(color: context.colorScheme.onError),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );

    if (cleared) {
      onDateRangeCleared();
    } else if (picked != null) {
      onDateRangeChanged(picked.start, picked.end);
    }
  }
}

class _EmployeeAutoComplete extends StatelessWidget {
  final Employee? selectedEmployee;
  final void Function(Employee? employee) onSelected;

  const _EmployeeAutoComplete({this.selectedEmployee, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EmployeeBloc, EmployeeState>(
      builder: (context, employeeState) {
        final employees = employeeState is EmployeeLoadedState ? employeeState.employees : <Employee>[];
        final isLoading = employeeState is EmployeeLoadingState;

        return AutoCompleteSearchField<Employee>(
          items: employees,
          title: AppStrings.selectEmployee,
          searchHint: AppStrings.searchEmployee,
          initialQuery: selectedEmployee?.fullName,
          itemFilter: (employee, query) => employee.fullName.toLowerCase().contains(query.toLowerCase()),
          itemSorter: (a, b) => a.fullName.compareTo(b.fullName),
          itemBuilder: (employee) => EmployeeTileWidget(employee: employee),
          onSelected: onSelected,
          onClear: () {
            onSelected(null);
          },
          builder: (onTap) {
            return InkWell(
              onTap: onTap,
              borderRadius: .circular(8),
              child: Container(
                padding: const .symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: .circular(8),
                  border: .all(color: context.theme.dividerColor),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: isLoading
                          ? const Center(child: SizedBox(height: 16, width: 16, child: LoadingWidget()))
                          : Text(
                              selectedEmployee?.fullName ?? AppStrings.employee,
                              style: context.textTheme.bodySmall?.copyWith(
                                fontWeight: .w600,
                                color: context.colorScheme.onSurface,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                    ),
                    Icon(Icons.keyboard_arrow_down, size: 20, color: context.colorScheme.onSurfaceVariant),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

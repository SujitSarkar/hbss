import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:maori_health/core/config/app_strings.dart';
import 'package:maori_health/core/utils/date_converter.dart';
import 'package:maori_health/core/utils/extensions.dart';
import 'package:maori_health/domain/client/entities/client.dart';

import 'package:maori_health/presentation/client/bloc/client_bloc.dart';
import 'package:maori_health/presentation/client/widgets/client_tile_widget.dart';
import 'package:maori_health/presentation/shared/widgets/auto_complete_search_field.dart';
import 'package:maori_health/presentation/shared/widgets/loading_widget.dart';

class TimesheetFilterWidget extends StatelessWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final Client? selectedClient;
  final void Function(DateTime start, DateTime end) onDateRangeChanged;
  final VoidCallback onDateRangeCleared;
  final void Function(Client? client) onClientChanged;

  const TimesheetFilterWidget({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.selectedClient,
    required this.onDateRangeChanged,
    required this.onDateRangeCleared,
    required this.onClientChanged,
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
          child: _ClientAutoComplete(selectedClient: selectedClient, onSelected: onClientChanged),
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

class _ClientAutoComplete extends StatelessWidget {
  final Client? selectedClient;
  final void Function(Client? client) onSelected;

  const _ClientAutoComplete({this.selectedClient, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ClientBloc, ClientState>(
      builder: (context, clientState) {
        final clients = clientState is ClientLoadedState ? clientState.clients : <Client>[];
        final isLoading = clientState is ClientLoadingState;

        return AutoCompleteSearchField<Client>(
          items: clients,
          title: AppStrings.selectClient,
          searchHint: AppStrings.searchClient,
          initialQuery: selectedClient?.fullName,
          itemFilter: (client, query) => client.fullName?.toLowerCase().contains(query.toLowerCase()) ?? false,
          itemSorter: (a, b) => a.fullName?.compareTo(b.fullName ?? '') ?? 0,
          itemBuilder: (client) => ClientTileWidget(client: client),
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
                              selectedClient?.fullName ?? AppStrings.client,
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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:maori_health/core/config/app_strings.dart';
import 'package:maori_health/core/utils/extensions.dart';

import 'package:maori_health/domain/client/entities/client.dart';

import 'package:maori_health/presentation/client/bloc/client_bloc.dart';
import 'package:maori_health/presentation/schedule/widgets/client_tile_widget.dart';
import 'package:maori_health/presentation/shared/widgets/auto_complete_search_field.dart';
import 'package:maori_health/presentation/shared/widgets/loading_widget.dart';

class ClientScheduleView extends StatelessWidget {
  final Client? selectedClient;
  final void Function(Client? client) onSelected;

  const ClientScheduleView({super.key, this.selectedClient, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const .fromLTRB(12, 0, 12, 0),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Row(
            children: [
              Text(AppStrings.client, style: context.textTheme.bodyMedium?.copyWith(fontWeight: .w600)),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: _ClientAutoComplete(selectedClient: selectedClient, onSelected: onSelected),
              ),
            ],
          ),
        ],
      ),
    );
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
                              selectedClient?.fullName ?? AppStrings.select,
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

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:maori_health/core/config/app_strings.dart';
import 'package:maori_health/domain/client/entities/client.dart';
import 'package:maori_health/domain/client/repositories/client_repository.dart';

part 'client_event.dart';
part 'client_state.dart';

class ClientBloc extends Bloc<ClientEvent, ClientState> {
  final ClientRepository _repository;
  ClientBloc(this._repository) : super(ClientInitial()) {
    on<LoadClientsEvent>(_onLoadClientsEvent);
  }

  Future<void> _onLoadClientsEvent(LoadClientsEvent event, Emitter<ClientState> emit) async {
    emit(ClientLoadingState());
    final result = await _repository.getClients(page: event.page);

    await result.fold(
      onFailure: (error) async {
        emit(ClientErrorState(message: (error.errorMessage ?? AppStrings.somethingWentWrong)));
      },
      onSuccess: (clients) async {
        emit(ClientLoadedState(clients: clients));
      },
    );
  }
}

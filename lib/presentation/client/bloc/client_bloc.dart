import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:maori_health/core/config/app_strings.dart';
import 'package:maori_health/domain/client/entities/client.dart';
import 'package:maori_health/domain/client/usecases/get_clients_usecase.dart';

part 'client_event.dart';
part 'client_state.dart';

class ClientBloc extends Bloc<ClientEvent, ClientState> {
  final GetClientsUsecase _getClientsUsecase;
  ClientBloc(this._getClientsUsecase) : super(ClientInitial()) {
    on<LoadClientsEvent>(_onLoadClientsEvent);
  }

  Future<void> _onLoadClientsEvent(LoadClientsEvent event, Emitter<ClientState> emit) async {
    emit(ClientLoadingState());
    final result = await _getClientsUsecase(page: event.page);

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

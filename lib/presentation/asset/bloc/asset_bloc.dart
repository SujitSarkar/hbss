import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:maori_health/core/config/app_strings.dart';
import 'package:maori_health/domain/asset/repositories/asset_repository.dart';

import 'package:maori_health/presentation/asset/bloc/asset_event.dart';
import 'package:maori_health/presentation/asset/bloc/asset_state.dart';

class AssetBloc extends Bloc<AssetEvent, AssetState> {
  final AssetRepository _assetRepository;

  AssetBloc({required AssetRepository assetRepository})
    : _assetRepository = assetRepository,
      super(const AssetInitialState()) {
    on<AssetsLoadEvent>(_onLoadAssetsEvent);
    on<AssetAcceptEvent>(_onAcceptEvent);
  }

  Future<void> _onLoadAssetsEvent(AssetsLoadEvent event, Emitter<AssetState> emit) async {
    emit(const AssetLoadingState());

    final result = await _assetRepository.getAssets();
    await result.fold(
      onFailure: (error) async {
        emit(AssetErrorState(error.errorMessage ?? AppStrings.somethingWentWrong));
      },
      onSuccess: (assets) async {
        emit(AssetLoadedState(assets));
      },
    );
  }

  Future<void> _onAcceptEvent(AssetAcceptEvent event, Emitter<AssetState> emit) async {
    final currentState = state;
    if (currentState is! AssetLoadedState) {
      return;
    }
    emit(AssetAcceptLoadingState(List.of(currentState.assets)));

    final result = await _assetRepository.acceptAsset(event.assetId);
    await result.fold(
      onFailure: (error) async {
        emit(AssetErrorState(error.errorMessage ?? AppStrings.somethingWentWrong));
        emit(AssetLoadedState(List.of(currentState.assets)));
      },
      onSuccess: (updatedAsset) async {
        final updatedAssets = List.of(currentState.assets);
        final updatedIndex = updatedAssets.indexWhere((asset) => asset.asset.id == event.assetId);
        if (updatedIndex != -1) {
          updatedAssets[updatedIndex] = updatedAsset;
        }
        emit(AssetAcceptedState());
        emit(AssetLoadedState(updatedAssets));
      },
    );
  }
}

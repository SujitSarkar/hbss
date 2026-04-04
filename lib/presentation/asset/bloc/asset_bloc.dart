import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:maori_health/core/config/app_strings.dart';
import 'package:maori_health/domain/asset/usecases/accept_asset_usecase.dart';
import 'package:maori_health/domain/asset/usecases/get_assets_usecase.dart';

import 'package:maori_health/presentation/asset/bloc/asset_event.dart';
import 'package:maori_health/presentation/asset/bloc/asset_state.dart';

class AssetBloc extends Bloc<AssetEvent, AssetState> {
  final GetAssetsUsecase _getAssetsUsecase;
  final AcceptAssetUsecase _acceptAssetUsecase;

  AssetBloc({required GetAssetsUsecase getAssetsUsecase, required AcceptAssetUsecase acceptAssetUsecase})
    : _getAssetsUsecase = getAssetsUsecase,
      _acceptAssetUsecase = acceptAssetUsecase,
      super(const AssetInitialState()) {
    on<AssetsLoadEvent>(_onLoadAssetsEvent);
    on<AssetAcceptEvent>(_onAcceptEvent);
  }

  Future<void> _onLoadAssetsEvent(AssetsLoadEvent event, Emitter<AssetState> emit) async {
    emit(const AssetLoadingState());

    final result = await _getAssetsUsecase();
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

    final result = await _acceptAssetUsecase(event.assetId);
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

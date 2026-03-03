import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:maori_health/core/config/app_strings.dart';
import 'package:maori_health/core/di/injection.dart';
import 'package:maori_health/core/router/route_names.dart';
import 'package:maori_health/core/utils/extensions.dart';

import 'package:maori_health/presentation/asset/bloc/bloc.dart';
import 'package:maori_health/presentation/asset/widgets/asset_list_tile.dart';
import 'package:maori_health/presentation/asset/widgets/asset_page_shimmer.dart';
import 'package:maori_health/presentation/shared/widgets/common_app_bar.dart';
import 'package:maori_health/presentation/shared/widgets/error_view_widget.dart';
import 'package:maori_health/presentation/shared/widgets/loading_overlay.dart';
import 'package:maori_health/presentation/shared/widgets/swipe_refresh_wrapper.dart';

class AssetsPage extends StatelessWidget {
  const AssetsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (_) => getIt<AssetBloc>()..add(const AssetsLoadEvent()), child: const _AssetsView());
  }
}

class _AssetsView extends StatelessWidget {
  const _AssetsView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<AssetBloc, AssetState>(
      listener: (context, state) {
        if (state is AssetAcceptedState) {
          context.showSnackBar(AppStrings.assetAccepted);
        }
      },
      child: Scaffold(
        appBar: CommonAppBar(context: context, title: Text(AppStrings.assets)),
        body: BlocBuilder<AssetBloc, AssetState>(
          builder: (context, state) {
            if (state is AssetInitialState || state is AssetLoadingState) {
              return const AssetPageShimmer();
            } else if (state is AssetLoadedState || state is AssetAcceptLoadingState) {
              final loadedState = state as AssetLoadedState;
              return loadedState.assets.isEmpty
                  ? ErrorViewWidget(
                      message: AppStrings.noDataFound,
                      onRetry: () async => context.read<AssetBloc>().add(const AssetsLoadEvent()),
                    )
                  : LoadingOverlay(
                      isLoading: state is AssetAcceptLoadingState,
                      child: _buildAssetList(context, loadedState, state is AssetAcceptLoadingState),
                    );
            } else if (state is AssetErrorState) {
              return ErrorViewWidget(
                message: state.message,
                onRetry: () async => context.read<AssetBloc>().add(const AssetsLoadEvent()),
              );
            } else {
              return const SizedBox.shrink();
            }
          },
        ),
      ),
    );
  }

  Widget _buildAssetList(BuildContext context, AssetLoadedState state, bool isAccepting) {
    final assets = state.assets;
    return SwipeRefreshWrapper(
      onRefresh: () async => context.read<AssetBloc>().add(const AssetsLoadEvent()),
      child: ListView.separated(
        padding: const .fromLTRB(16, 8, 16, 16),
        itemCount: assets.length,
        separatorBuilder: (_, _) => const SizedBox(height: 14),
        itemBuilder: (context, index) {
          final asset = assets[index];
          return AssetListTile(
            asset: asset,
            onView: () => context.pushNamed(RouteNames.assetDetails, extra: asset),
            onAccept: isAccepting ? null : () => context.read<AssetBloc>().add(AssetAcceptEvent(asset.asset.id!)),
          );
        },
      ),
    );
  }
}

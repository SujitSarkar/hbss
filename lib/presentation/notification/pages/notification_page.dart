import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:maori_health/core/config/app_strings.dart';
import 'package:maori_health/core/router/route_names.dart';
import 'package:maori_health/core/utils/extensions.dart';

import 'package:maori_health/presentation/notification/bloc/bloc.dart';
import 'package:maori_health/presentation/notification/widgets/notification_shimmer.dart';
import 'package:maori_health/presentation/notification/widgets/notification_tile.dart';
import 'package:maori_health/presentation/shared/widgets/error_view_widget.dart';
import 'package:maori_health/presentation/shared/widgets/no_data_found_widget.dart';
import 'package:maori_health/presentation/shared/widgets/pagination_wrapper.dart';
import 'package:maori_health/presentation/shared/widgets/swipe_refresh_wrapper.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  @override
  void initState() {
    super.initState();
    context.read<NotificationBloc>().add(const NotificationsLoadEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<NotificationBloc, NotificationState>(
      listener: (context, state) {
        if (state is NotificationErrorState) {
          context.showSnackBar(state.errorMessage);
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const .fromLTRB(16, 16, 16, 0),
            child: Column(
              crossAxisAlignment: .start,
              children: [
                Text(AppStrings.notification, style: context.textTheme.headlineMedium?.copyWith(fontWeight: .bold)),
                const SizedBox(height: 12),
                Expanded(
                  child: BlocBuilder<NotificationBloc, NotificationState>(
                    builder: (context, state) {
                      return switch (state) {
                        NotificationLoadingState() => const NotificationShimmer(),
                        NotificationErrorState(:final errorMessage) => ErrorViewWidget(
                          message: errorMessage,
                          onRetry: () => context.read<NotificationBloc>().add(const NotificationsLoadEvent()),
                        ),
                        NotificationLoadedState() => _buildContent(context, state),
                        _ => const SizedBox.shrink(),
                      };
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onRefresh(BuildContext context) async {
    context.read<NotificationBloc>().add(const NotificationsLoadEvent());
  }

  Widget _buildContent(BuildContext context, NotificationLoadedState state) {
    if (state.notifications.isEmpty) {
      return SwipeRefreshWrapper(
        onRefresh: () => _onRefresh(context),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [SliverFillRemaining(child: NoDataFoundWidget(message: AppStrings.noDataFound))],
        ),
      );
    }

    return PaginationWrapper(
      hasMore: state.hasMore,
      isLoadingMore: state.isLoadingMore,
      onLoadMore: () => context.read<NotificationBloc>().add(const NotificationLoadMoreEvent()),
      child: SwipeRefreshWrapper(
        onRefresh: () => _onRefresh(context),
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const .symmetric(vertical: 8),
          itemCount: state.notifications.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (_, index) {
            final item = state.notifications[index];
            return NotificationTile(
              notification: item,
              onTap: () {
                if (!item.isRead) {
                  context.read<NotificationBloc>().add(NotificationReadEvent(item.id));
                }
                if (item.data.jobScheduleId != null) {
                  context.pushNamed(RouteNames.jobDetails, extra: item.data.jobScheduleId);
                }
              },
            );
          },
        ),
      ),
    );
  }
}

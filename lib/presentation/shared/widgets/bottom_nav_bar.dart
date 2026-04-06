import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:maori_health/core/config/app_strings.dart';
import 'package:maori_health/presentation/offline_sync/bloc/bloc.dart';
import 'package:maori_health/core/router/route_names.dart';
import 'package:maori_health/core/utils/utils.dart';

import 'package:maori_health/presentation/auth/bloc/bloc.dart';
import 'package:maori_health/presentation/client/bloc/client_bloc.dart';
import 'package:maori_health/presentation/employee/bloc/bloc.dart';
import 'package:maori_health/presentation/lookup_enums/bloc/bloc.dart';
import 'package:maori_health/presentation/notification/bloc/bloc.dart';
import 'package:maori_health/presentation/shared/widgets/loading_overlay.dart';

import 'package:maori_health/presentation/dashboard/pages/dashboard_page.dart';
import 'package:maori_health/presentation/schedule/pages/schedule_page.dart';
import 'package:maori_health/presentation/notification/pages/notification_page.dart';
import 'package:maori_health/presentation/settings/pages/settings_page.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _currentIndex = 0;
  bool _offlineSyncDialogOpen = false;

  /// Context of the sync overlay route; [Navigator.maybePop] does not dismiss [PopScope] with [canPop: false].
  BuildContext? _offlineSyncDialogContext;

  static const _pages = <Widget>[DashboardPage(), SchedulePage(), NotificationPage(), SettingsPage()];

  @override
  void initState() {
    super.initState();
    // Load app-settings, lookup enums, clients and employees
    context.read<LookupEnumsBloc>().add(const LoadLookupEnumsEvent());
    context.read<ClientBloc>().add(const LoadClientsEvent());
    context.read<EmployeeBloc>().add(const LoadEmployeeEvent());
  }

  void _onTabTapped(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final NotificationState notificationState = context.watch<NotificationBloc>().state;
    final int unReadNotification = notificationState is NotificationLoadedState ? notificationState.unreadCount : 0;

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is UnAuthenticatedState) {
          context.goNamed(RouteNames.login);
        }
      },
      builder: (context, authState) => BlocListener<OfflineSyncBloc, OfflineSyncState>(
        listenWhen: (prev, curr) => prev.status != curr.status,
        listener: (context, state) {
          if (state.status == OfflineSyncStatus.syncing) {
            if (_offlineSyncDialogOpen) return;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted || _offlineSyncDialogOpen) return;
              _offlineSyncDialogOpen = true;
              showDialog<void>(
                context: context,
                barrierDismissible: false,
                useRootNavigator: true,
                builder: (dialogContext) {
                  // Assign synchronously so dismiss can run in the next frame after [showDialog]'s builder runs.
                  _offlineSyncDialogContext = dialogContext;
                  return PopScope(
                    canPop: false,
                    child: AlertDialog(
                      content: Row(
                        children: [
                          const SizedBox(width: 28, height: 28, child: CircularProgressIndicator(strokeWidth: 2)),
                          const SizedBox(width: 20),
                          Expanded(child: Text(AppStrings.syncingOfflineData)),
                        ],
                      ),
                    ),
                  );
                },
              ).whenComplete(() {
                if (mounted) {
                  setState(() {
                    _offlineSyncDialogOpen = false;
                    _offlineSyncDialogContext = null;
                  });
                }
              });
            });
          } else if (state.status == OfflineSyncStatus.idle || state.status == OfflineSyncStatus.failure) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              final dialogCtx = _offlineSyncDialogContext;
              if (dialogCtx != null && dialogCtx.mounted) {
                Navigator.of(dialogCtx).pop();
              } else {
                final nav = Navigator.of(context, rootNavigator: true);
                if (nav.canPop()) nav.pop();
              }
            });
          }
        },
        child: LoadingOverlay(
          isLoading: authState is AuthLoadingState,
          child: Scaffold(
            body: IndexedStack(index: _currentIndex, children: _pages),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: _onTabTapped,
              items: [
                BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard_outlined),
                  activeIcon: Icon(Icons.dashboard),
                  label: AppStrings.dashboard,
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.calendar_today_outlined),
                  activeIcon: Icon(Icons.calendar_today),
                  label: AppStrings.schedule,
                ),
                BottomNavigationBarItem(
                  icon: Badge(
                    isLabelVisible: unReadNotification > 0,
                    label: Text(Utils.getNotificationBadgeLabel(unReadNotification), style: TextStyle(fontSize: 10)),
                    child: Icon(Icons.notifications_outlined),
                  ),
                  activeIcon: Badge(
                    isLabelVisible: unReadNotification > 0,
                    label: Text(Utils.getNotificationBadgeLabel(unReadNotification), style: TextStyle(fontSize: 10)),
                    child: Icon(Icons.notifications),
                  ),
                  label: AppStrings.notification,
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings_outlined),
                  activeIcon: Icon(Icons.settings),
                  label: AppStrings.settings,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:maori_health/core/config/app_strings.dart';
import 'package:maori_health/core/di/injection.dart';
import 'package:maori_health/core/router/route_names.dart';
import 'package:maori_health/core/utils/extensions.dart';
import 'package:maori_health/core/utils/utils.dart';
import 'package:maori_health/presentation/auth/bloc/bloc.dart';
import 'package:maori_health/presentation/client/bloc/client_bloc.dart';
import 'package:maori_health/presentation/notification/bloc/bloc.dart';
// import 'package:maori_health/presentation/employee/bloc/bloc.dart';
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
  // TODO: Replace with dynamic count from BLoC
  // final int _notificationCount = 120;

  // String get _badgeLabel => _notificationCount > 99 ? '99+' : '$_notificationCount';

  static const _pages = <Widget>[DashboardPage(), SchedulePage(), NotificationPage(), SettingsPage()];

  @override
  void initState() {
    super.initState();
    getIt<ClientBloc>().add(const LoadClientsEvent());
    // TODO: Uncomment when client and employee API is implemented
    // getIt<EmployeeBloc>().add(const LoadEmployeeEvent());
  }

  void _onTabTapped(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    final NotificationState notificationState = context.watch<NotificationBloc>().state;
    final int unReadNotification = notificationState is NotificationLoadedState ? notificationState.unreadCount : 0;

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is UnAuthenticatedState) {
          context.goNamed(RouteNames.login);
        }
      },
      builder: (context, authState) => LoadingOverlay(
        isLoading: authState is AuthLoadingState,
        child: Scaffold(
          body: IndexedStack(index: _currentIndex, children: _pages),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              boxShadow: [BoxShadow(color: theme.shadowColor, offset: const Offset(0, -2))],
            ),
            child: ClipRRect(
              borderRadius: const .only(topLeft: .circular(20), topRight: .circular(20)),
              child: BottomNavigationBar(
                currentIndex: _currentIndex,
                onTap: _onTabTapped,
                type: BottomNavigationBarType.fixed,
                backgroundColor: theme.colorScheme.primary,
                selectedItemColor: theme.colorScheme.onPrimary,
                unselectedItemColor: theme.colorScheme.onPrimary.withAlpha(160),
                selectedFontSize: 12,
                unselectedFontSize: 12,
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
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:maori_health/core/config/app_strings.dart';
import 'package:maori_health/core/di/injection.dart';
import 'package:maori_health/presentation/offline_sync/bloc/bloc.dart';
import 'package:maori_health/core/router/app_router.dart';
import 'package:maori_health/core/theme/app_theme.dart';

import 'package:maori_health/presentation/app/bloc/bloc.dart';
import 'package:maori_health/presentation/app_settings/bloc/app_settings_bloc.dart';
import 'package:maori_health/presentation/auth/bloc/bloc.dart';
import 'package:maori_health/presentation/client/bloc/client_bloc.dart';
import 'package:maori_health/presentation/dashboard/bloc/bloc.dart';
import 'package:maori_health/presentation/employee/bloc/bloc.dart';
import 'package:maori_health/presentation/lookup_enums/bloc/bloc.dart';
import 'package:maori_health/presentation/notification/bloc/bloc.dart';
import 'package:maori_health/presentation/schedule/bloc/schedule_bloc.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<AppBloc>()..add(const AppStarted())),
        BlocProvider(create: (_) => getIt<AuthBloc>()..add(const AuthLocalLoginEvent())),
        BlocProvider(create: (_) => getIt<AppSettingsBloc>()..add(LoadAppSettingsEvent())),
        BlocProvider(create: (_) => getIt<LookupEnumsBloc>()),
        BlocProvider(create: (_) => getIt<ClientBloc>()),
        BlocProvider(create: (_) => getIt<EmployeeBloc>()),
        BlocProvider(create: (_) => getIt<NotificationBloc>()),
        BlocProvider(create: (_) => getIt<DashboardBloc>()..add(const DashboardLoadEvent())),
        BlocProvider(create: (_) => getIt<ScheduleBloc>()),
        BlocProvider<OfflineSyncBloc>(create: (_) => getIt<OfflineSyncBloc>()..add(const OfflineSyncStarted())),
      ],
      child: const _AppView(),
    );
  }
}

class _AppView extends StatefulWidget {
  const _AppView();

  @override
  State<_AppView> createState() => _AppViewState();
}

class _AppViewState extends State<_AppView> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = AppRouter.router();
  }

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, appState) {
        return MaterialApp.router(
          title: AppStrings.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: appState.themeMode,
          routerConfig: _router,
        );
      },
    );
  }
}

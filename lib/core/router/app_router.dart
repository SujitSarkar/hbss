import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:maori_health/core/router/route_names.dart';
import 'package:maori_health/data/asset/models/asset_response_model.dart';
import 'package:maori_health/domain/schedule/entities/schedule.dart';

import 'package:maori_health/presentation/asset/pages/asset_details_page.dart';
import 'package:maori_health/presentation/asset/pages/assets_page.dart';
import 'package:maori_health/presentation/auth/pages/forgot_password_otp_page.dart';
import 'package:maori_health/presentation/auth/pages/forgot_password_page.dart';
import 'package:maori_health/presentation/auth/pages/login_page.dart';
import 'package:maori_health/presentation/auth/pages/reset_password_page.dart';
import 'package:maori_health/presentation/schedule/pages/schedule_details_page.dart';
import 'package:maori_health/presentation/profile/pages/profile_page.dart';
import 'package:maori_health/presentation/splash/splash_page.dart';
import 'package:maori_health/presentation/timesheet/pages/timesheet_page.dart';
import 'package:maori_health/presentation/shared/widgets/bottom_nav_bar.dart';

class AppRouter {
  AppRouter._();

  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static GoRouter router({List<NavigatorObserver>? observers}) {
    return GoRouter(
      navigatorKey: navigatorKey,
      initialLocation: RouteNames.splashPath,
      observers: observers ?? [],
      routes: [
        GoRoute(name: RouteNames.splash, path: RouteNames.splashPath, builder: (context, state) => const SplashPage()),
        GoRoute(name: RouteNames.login, path: RouteNames.loginPath, builder: (context, state) => const LoginPage()),
        GoRoute(
          name: RouteNames.forgotPassword,
          path: RouteNames.forgotPasswordPath,
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>;
            final email = extra['email'] as String?;
            return ForgotPasswordPage(email: email);
          },
        ),
        GoRoute(
          name: RouteNames.forgotPasswordOtp,
          path: RouteNames.forgotPasswordOtpPath,
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>;
            final email = extra['email'] as String;
            return ForgotPasswordOtpPage(email: email);
          },
        ),
        GoRoute(
          name: RouteNames.resetPassword,
          path: RouteNames.resetPasswordPath,
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>;
            return ResetPasswordPage(email: extra['email'] as String);
          },
        ),

        GoRoute(
          name: RouteNames.dashboard,
          path: RouteNames.dashboardPath,
          builder: (context, state) => const BottomNavBar(),
        ),
        GoRoute(
          name: RouteNames.profile,
          path: RouteNames.profilePath,
          builder: (context, state) => const ProfilePage(),
        ),
        GoRoute(name: RouteNames.assets, path: RouteNames.assetsPath, builder: (context, state) => const AssetsPage()),
        GoRoute(
          name: RouteNames.assetDetails,
          path: RouteNames.assetDetailsPath,
          builder: (context, state) => AssetDetailsPage(asset: state.extra! as AssetResponseModel),
        ),
        GoRoute(
          name: RouteNames.timeSheets,
          path: RouteNames.timeSheetsPath,
          builder: (context, state) => const TimeSheetPage(),
        ),
        GoRoute(
          name: RouteNames.scheduleDetails,
          path: RouteNames.scheduleDetailsPath,
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>;
            final fromScreenName = extra['fromScreenName'] as String;
            final schedule = extra['schedule'] as Schedule?;
            final scheduleId = extra['scheduleId'] as int?;
            return ScheduleDetailsPage(fromScreenName: fromScreenName, schedule: schedule, scheduleId: scheduleId);
          },
        ),
      ],
    );
  }
}

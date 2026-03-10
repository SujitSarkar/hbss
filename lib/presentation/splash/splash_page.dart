import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:maori_health/core/config/app_strings.dart';
import 'package:maori_health/core/router/route_names.dart';
import 'package:maori_health/core/theme/app_colors.dart';

import 'package:maori_health/presentation/auth/bloc/bloc.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthenticatedState) {
          context.goNamed(RouteNames.dashboard);
        } else if (state is UnAuthenticatedState) {
          context.goNamed(RouteNames.login);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.primary,
        body: Center(
          child: Text(
            AppStrings.appName,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: Colors.white, fontWeight: .bold),
          ),
        ),
      ),
    );
  }
}

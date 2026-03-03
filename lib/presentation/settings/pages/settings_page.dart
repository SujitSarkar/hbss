import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:maori_health/core/config/app_strings.dart';
import 'package:maori_health/core/router/route_names.dart';

import 'package:maori_health/presentation/app/bloc/bloc.dart';
import 'package:maori_health/presentation/auth/bloc/bloc.dart';
import 'package:maori_health/presentation/settings/widgets/settings_tile.dart';
import 'package:maori_health/presentation/shared/widgets/confirmation_dialog.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const .fromLTRB(12, 20, 12, 0),
          child: Column(
            crossAxisAlignment: .start,
            children: [
              Text(AppStrings.settings, style: theme.textTheme.headlineMedium?.copyWith(fontWeight: .bold)),
              const SizedBox(height: 12),
              Expanded(
                child: Container(
                  padding: const .symmetric(horizontal: 8, vertical: 12),
                  decoration: BoxDecoration(
                    borderRadius: .circular(16),
                    border: .all(color: theme.dividerColor),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SettingsTile(
                          icon: Icons.person_outline,
                          title: AppStrings.profile,
                          onTap: () => context.pushNamed(RouteNames.profile),
                        ),
                        SettingsTile(
                          icon: Icons.photo_library_outlined,
                          title: AppStrings.assets,
                          onTap: () => context.pushNamed(RouteNames.assets),
                        ),
                        SettingsTile(
                          icon: Icons.access_time_outlined,
                          title: AppStrings.timeSheets,
                          onTap: () => context.pushNamed(RouteNames.timeSheets),
                        ),
                        BlocBuilder<AppBloc, AppState>(
                          builder: (context, state) {
                            final isDark = state.themeMode == ThemeMode.dark;
                            return SettingsTile(
                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              icon: isDark ? Icons.dark_mode : Icons.light_mode_outlined,
                              title: AppStrings.darkMode,
                              trailing: Transform.scale(
                                scale: 0.9,
                                child: Switch.adaptive(
                                  value: isDark,
                                  activeTrackColor: theme.colorScheme.primary,
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  onChanged: (value) {
                                    context.read<AppBloc>().add(
                                      ThemeModeChanged(value ? ThemeMode.dark : ThemeMode.light),
                                    );
                                  },
                                ),
                              ),
                              onTap: () {
                                context.read<AppBloc>().add(
                                  ThemeModeChanged(isDark ? ThemeMode.light : ThemeMode.dark),
                                );
                              },
                            );
                          },
                        ),
                        SettingsTile(
                          icon: Icons.logout,
                          title: AppStrings.signOut,
                          color: theme.colorScheme.error,
                          onTap: () async {
                            final confirmed = await showConfirmationDialog(
                              context,
                              title: AppStrings.signOut,
                              message: AppStrings.areYouSureYouWantToSignOut,
                              confirmText: AppStrings.signOut,
                              confirmColor: theme.colorScheme.error,
                            );
                            if (confirmed && context.mounted) {
                              context.read<AuthBloc>().add(const AuthLogoutEvent());
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

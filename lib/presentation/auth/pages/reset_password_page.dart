import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:maori_health/core/config/app_strings.dart';
import 'package:maori_health/core/router/route_names.dart';
import 'package:maori_health/core/theme/app_colors.dart';
import 'package:maori_health/core/utils/extensions.dart';
import 'package:maori_health/core/utils/form_validators.dart';

import 'package:maori_health/presentation/auth/bloc/bloc.dart';
import 'package:maori_health/presentation/auth/widgets/auth_back_bar_widget.dart';
import 'package:maori_health/presentation/auth/widgets/auth_layout.dart';
import 'package:maori_health/presentation/shared/decorations/outline_input_decoration.dart';
import 'package:maori_health/presentation/shared/widgets/confirmation_dialog.dart';
import 'package:maori_health/presentation/shared/widgets/loading_overlay.dart';
import 'package:maori_health/presentation/shared/widgets/solid_button.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key, required this.email});
  final String email;

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isExitDialogOpen = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onResetPassword() {
    if (!_formKey.currentState!.validate()) return;

    context.read<AuthBloc>().add(
      AuthResetPasswordEvent(
        email: widget.email,
        newPassword: _passwordController.text.trim(),
        confirmPassword: _confirmPasswordController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = context.screenSize.height;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop || _isExitDialogOpen || !mounted) return;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted || _isExitDialogOpen) return;
          _pageExitConfirmation();
        });
      },
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthResetPasswordSuccessState) {
            context.showSnackBar(state.message, onTop: true);
            context.goNamed(RouteNames.login);
          } else if (state is AuthErrorState) {
            context.showSnackBar(state.errorMessage, isError: true, onTop: true);
          }
        },
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            return LoadingOverlay(
              isLoading: state is AuthForgotPasswordLoadingState,
              child: AuthLayout(child: _buildFormSection(screenHeight)),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFormSection(double screenHeight) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: .start,
        children: [
          AuthBackBarWidget(
            title: AppStrings.setAnewPassword,
            subTitle: AppStrings.createNewPassInstruction,
            onBackPressed: _pageExitConfirmation,
          ),
          const SizedBox(height: 40),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            keyboardType: TextInputType.visiblePassword,
            textInputAction: .next,
            validator: FormValidators.password(),
            autovalidateMode: .onUserInteraction,
            decoration: OutlineInputDecoration(
              context: context,
              labelText: AppStrings.password,
              suffixIcon: _visibilityToggle(
                _obscurePassword,
                () => setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            keyboardType: TextInputType.visiblePassword,
            textInputAction: .done,
            autovalidateMode: .onUserInteraction,
            decoration: OutlineInputDecoration(
              context: context,
              labelText: AppStrings.confirmPassword,
              suffixIcon: _visibilityToggle(
                _obscureConfirmPassword,
                () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
              ),
            ),
            validator: (value) {
              final base = FormValidators.password()(value);
              if (base != null) return base;
              if (value != _passwordController.text) {
                return AppStrings.passwordsDoNotMatch;
              }
              return null;
            },
          ),
          const SizedBox(height: 40),
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              return SolidButton(
                onPressed: state is AuthForgotPasswordLoadingState ? null : _onResetPassword,
                isLoading: state is AuthLoadingState,
                backgroundColor: AppColors.authButtonColor,
                foregroundColor: Colors.white,
                child: Text(
                  AppStrings.updatePassword,
                  style: context.textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: .bold),
                ),
              );
            },
          ),
          SizedBox(height: screenHeight * 0.25),
        ],
      ),
    );
  }

  void _pageExitConfirmation() async {
    if (_isExitDialogOpen || !mounted) return;
    _isExitDialogOpen = true;
    final contextToUse = context;
    final confirmed = await showConfirmationDialog(
      contextToUse,
      title: AppStrings.terminateProcess,
      message: AppStrings.terminateProcessInstruction,
      confirmText: AppStrings.yes,
      confirmColor: context.theme.colorScheme.error,
    );
    _isExitDialogOpen = false;
    if (contextToUse.mounted && confirmed) {
      contextToUse.goNamed(RouteNames.login);
    }
  }

  Widget _visibilityToggle(bool obscure, VoidCallback onToggle) {
    return IconButton(
      icon: Icon(obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 20),
      onPressed: onToggle,
    );
  }
}

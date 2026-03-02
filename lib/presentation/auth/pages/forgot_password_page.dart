import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:maori_health/core/config/string_constants.dart';
import 'package:maori_health/core/router/route_names.dart';
import 'package:maori_health/core/theme/app_colors.dart';
import 'package:maori_health/core/utils/extensions.dart';
import 'package:maori_health/core/utils/form_validators.dart';

import 'package:maori_health/presentation/auth/bloc/auth_bloc.dart';
import 'package:maori_health/presentation/auth/bloc/auth_event.dart';
import 'package:maori_health/presentation/auth/bloc/auth_state.dart';
import 'package:maori_health/presentation/auth/widgets/auth_back_bar_widget.dart';
import 'package:maori_health/presentation/auth/widgets/auth_layout.dart';
import 'package:maori_health/presentation/shared/decorations/outline_input_decoration.dart';
import 'package:maori_health/presentation/shared/widgets/loading_overlay.dart';
import 'package:maori_health/presentation/shared/widgets/solid_button.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key, this.email});
  final String? email;

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void initState() {
    if (widget.email != null) {
      _emailController.text = widget.email!;
    }
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _onResetPassword() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(AuthForgotPasswordEvent(email: _emailController.text.trim()));
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = context.screenSize.height;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthOtpSentSuccessState) {
          context.showSnackBar(state.message, onTop: true);
          context.pushNamed(RouteNames.forgotPasswordOtp, extra: {'email': _emailController.text.trim()});
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
    );
  }

  Widget _buildFormSection(double screenHeight) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: .start,
        children: [
          const AuthBackBarWidget(
            title: StringConstants.forgotPassword,
            subTitle: StringConstants.forgotPasswordInstruction,
          ),
          const SizedBox(height: 40),
          TextFormField(
            controller: _emailController,
            keyboardType: .emailAddress,
            textInputAction: .next,
            validator: FormValidators.email(),
            autovalidateMode: .onUserInteraction,
            decoration: OutlineInputDecoration(context: context, labelText: StringConstants.email),
          ),
          const SizedBox(height: 40),
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              return SolidButton(
                onPressed: state is AuthForgotPasswordLoadingState ? null : _onResetPassword,
                backgroundColor: AppColors.authButtonColor,
                foregroundColor: Colors.white,
                child: Text(
                  StringConstants.resetPassword,
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
}

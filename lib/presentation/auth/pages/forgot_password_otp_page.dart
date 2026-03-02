import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:maori_health/core/router/route_names.dart';
import 'package:maori_health/core/theme/app_colors.dart';
import 'package:maori_health/presentation/auth/bloc/bloc.dart';
import 'package:maori_health/presentation/shared/widgets/loading_overlay.dart';
import 'package:pinput/pinput.dart';

import 'package:maori_health/core/config/string_constants.dart';
import 'package:maori_health/core/utils/extensions.dart';

import 'package:maori_health/presentation/auth/widgets/auth_back_bar_widget.dart';
import 'package:maori_health/presentation/auth/widgets/auth_layout.dart';
import 'package:maori_health/presentation/shared/decorations/pin_decoration.dart';
import 'package:maori_health/presentation/shared/widgets/solid_button.dart';

class ForgotPasswordOtpPage extends StatefulWidget {
  const ForgotPasswordOtpPage({super.key, required this.email});
  final String email;

  @override
  State<ForgotPasswordOtpPage> createState() => _ForgotPasswordOtpPageState();
}

class _ForgotPasswordOtpPageState extends State<ForgotPasswordOtpPage> {
  final _otpController = TextEditingController();
  final _otpFocusNode = FocusNode();

  @override
  void initState() {
    _otpFocusNode.requestFocus();
    super.initState();
  }

  @override
  void dispose() {
    _otpFocusNode.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _onVerifyCode() {
    if (_otpController.text.trim().length != 6) {
      return;
    }
    context.read<AuthBloc>().add(AuthVerifyOtpEvent(email: widget.email, otp: _otpController.text.trim()));
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = context.screenSize.height;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthOtpVerifiedState) {
          context.showSnackBar(state.message, onTop: true);
          context.pushNamed(RouteNames.resetPassword, extra: {'email': widget.email});
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
    return Column(
      crossAxisAlignment: .start,
      children: [
        AuthBackBarWidget(
          title: StringConstants.checkYourEmail,
          subTitle: 'We sent a reset link to ${widget.email}\nenter 6 digit code that mentioned in the email',
        ),
        const SizedBox(height: 40),
        Pinput(
          controller: _otpController,
          focusNode: _otpFocusNode,
          length: 6,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          defaultPinTheme: DefaultPinTheme(),
          focusedPinTheme: FocusedPinTheme(),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
        const SizedBox(height: 40),
        BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            return SolidButton(
              onPressed: state is AuthForgotPasswordLoadingState ? null : _onVerifyCode,
              isLoading: state is AuthLoadingState,
              backgroundColor: AppColors.authButtonColor,
              foregroundColor: Colors.white,
              child: Text(
                StringConstants.verifyCode,
                style: context.textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: .bold),
              ),
            );
          },
        ),
        SizedBox(height: screenHeight * 0.25),
      ],
    );
  }
}

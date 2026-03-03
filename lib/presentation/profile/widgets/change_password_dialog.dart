import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:maori_health/core/config/app_strings.dart';
import 'package:maori_health/core/utils/extensions.dart';
import 'package:maori_health/core/utils/form_validators.dart';

import 'package:maori_health/presentation/auth/bloc/bloc.dart';
import 'package:maori_health/presentation/shared/decorations/outline_input_decoration.dart';
import 'package:maori_health/presentation/shared/widgets/solid_button.dart';

void showChangePasswordDialog(BuildContext context) {
  final authBloc = context.read<AuthBloc>();

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => BlocProvider.value(value: authBloc, child: const _ChangePasswordDialog()),
  );
}

class _ChangePasswordDialog extends StatefulWidget {
  const _ChangePasswordDialog();

  @override
  State<_ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<_ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(
      AuthChangePasswordEvent(
        oldPassword: _oldPasswordController.text,
        newPassword: _newPasswordController.text,
        confirmPassword: _confirmPasswordController.text,
      ),
    );
  }

  Widget _visibilityToggle(bool obscure, VoidCallback onToggle) {
    return IconButton(
      icon: Icon(obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 20),
      onPressed: onToggle,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is ChangePassSuccessState) {
          Navigator.pop(context);
          context.showSnackBar(state.message);
        } else if (state is AuthErrorState && state.user != null) {
          context.showSnackBar(state.errorMessage, isError: true, onTop: true);
        }
      },
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: .circular(16)),
        clipBehavior: Clip.antiAlias,
        insetPadding: const .symmetric(horizontal: 24, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: const .symmetric(vertical: 14),
              decoration: BoxDecoration(color: context.colorScheme.primary),
              child: Text(
                AppStrings.changePassword,
                textAlign: TextAlign.center,
                style: context.textTheme.titleMedium?.copyWith(fontWeight: .bold, color: context.colorScheme.onPrimary),
              ),
            ),
            SingleChildScrollView(
              padding: const .fromLTRB(20, 20, 20, 8),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _oldPasswordController,
                      obscureText: _obscureOld,
                      validator: FormValidators.password(),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: OutlineInputDecoration(
                        context: context,
                        hintText: AppStrings.oldPassword,
                        suffixIcon: _visibilityToggle(_obscureOld, () => setState(() => _obscureOld = !_obscureOld)),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _newPasswordController,
                      obscureText: _obscureNew,
                      validator: FormValidators.password(),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: OutlineInputDecoration(
                        context: context,
                        hintText: AppStrings.newPassword,
                        suffixIcon: _visibilityToggle(_obscureNew, () => setState(() => _obscureNew = !_obscureNew)),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirm,
                      validator: (value) {
                        final base = FormValidators.password()(value);
                        if (base != null) return base;
                        if (value != _newPasswordController.text) {
                          return AppStrings.passwordsDoNotMatch;
                        }
                        return null;
                      },
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: OutlineInputDecoration(
                        context: context,
                        hintText: AppStrings.confirmPassword,
                        suffixIcon: _visibilityToggle(
                          _obscureConfirm,
                          () => setState(() => _obscureConfirm = !_obscureConfirm),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const .fromLTRB(16, 8, 16, 16),
              child: BlocBuilder<AuthBloc, AuthState>(
                buildWhen: (prev, curr) => prev.runtimeType != curr.runtimeType,
                builder: (context, state) {
                  final isLoading = state is UpdatePassLoadingState;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SolidButton(
                        width: 110,
                        height: 42,
                        onPressed: isLoading ? null : () => Navigator.pop(context),
                        backgroundColor: context.theme.hintColor,
                        child: const Text(AppStrings.close),
                      ),
                      const SizedBox(width: 12),
                      SolidButton(
                        width: 110,
                        height: 42,
                        onPressed: isLoading ? null : _onSubmit,
                        isLoading: isLoading,
                        child: const Text(AppStrings.save),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

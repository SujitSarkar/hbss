import 'package:flutter/services.dart';

import 'package:maori_health/core/config/app_strings.dart';

class FormValidators {
  FormValidators._();

  static final RegExp _emailRegex = RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$');

  static final decimalOnly = FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$'));

  static String? Function(String?) required() {
    return (value) {
      if (value == null || value.trim().isEmpty) return AppStrings.thisFieldIsRequired;
      return null;
    };
  }

  static String? Function(String?) email() {
    return (value) {
      if (value == null || value.trim().isEmpty) return AppStrings.thisFieldIsRequired;
      if (!_emailRegex.hasMatch(value.trim())) return AppStrings.invalidEmail;
      return null;
    };
  }

  static String? Function(String?) name() {
    return (value) {
      if (value == null || value.trim().isEmpty) return AppStrings.thisFieldIsRequired;
      if (value.trim().length < 2) return AppStrings.nameTooShort;
      if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value.trim())) return AppStrings.invalidName;
      return null;
    };
  }

  static String? Function(String?) password({int minLength = 8}) {
    return (value) {
      if (value == null || value.isEmpty) return AppStrings.thisFieldIsRequired;
      if (value.length < minLength) return AppStrings.passwordTooShort;
      return null;
    };
  }

  static String? Function(String?) compose(List<String? Function(String?)> validators) {
    return (value) {
      for (final validator in validators) {
        final error = validator(value);
        if (error != null) return error;
      }
      return null;
    };
  }
}

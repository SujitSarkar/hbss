import 'package:flutter/material.dart';

import 'package:maori_health/core/config/app_strings.dart';
import 'package:maori_health/core/utils/extensions.dart';
import 'package:maori_health/presentation/shared/widgets/app_dialog.dart';

Future<bool> showConfirmationDialog(
  BuildContext context, {
  required String title,
  required String message,
  String? confirmText,
  String? cancelText,
  Color? confirmColor,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AppDialog(
      title: title,
      content: Text(message, style: context.theme.textTheme.bodyMedium),
      actions: [
        TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: Text(cancelText ?? AppStrings.cancel)),
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: Text(
            confirmText ?? AppStrings.ok,
            style: confirmColor != null ? TextStyle(color: confirmColor) : null,
          ),
        ),
      ],
    ),
  );

  return result ?? false;
}

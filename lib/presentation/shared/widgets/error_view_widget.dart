import 'package:flutter/material.dart';

import 'package:maori_health/core/config/app_strings.dart';
import 'package:maori_health/core/theme/app_colors.dart';

class ErrorViewWidget extends StatelessWidget {
  final String message;
  final String? retryLabel;
  final VoidCallback? onRetry;

  const ErrorViewWidget({super.key, required this.message, this.retryLabel, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: .center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.warning),
            const SizedBox(height: 16),
            Text(message, textAlign: .center),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              OutlinedButton(onPressed: onRetry, child: Text(retryLabel ?? AppStrings.refresh)),
            ],
          ],
        ),
      ),
    );
  }
}

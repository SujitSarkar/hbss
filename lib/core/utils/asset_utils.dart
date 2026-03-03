import 'package:flutter/material.dart';

import 'package:maori_health/core/config/app_strings.dart';
import 'package:maori_health/core/theme/app_colors.dart';

abstract class AssetUtils {
  static String statusLabel(int acknowledgementStatus) {
    return acknowledgementStatus == 1
        ? AppStrings.accepted
        : acknowledgementStatus == 2
        ? AppStrings.returned
        : AppStrings.pending;
  }

  static Color statusColor(int acknowledgementStatus) {
    return acknowledgementStatus == 1
        ? AppColors.success
        : acknowledgementStatus == 2
        ? AppColors.error
        : Colors.grey;
  }

  static bool isAcknowledged(int acknowledgementStatus) {
    return acknowledgementStatus == 1;
  }
}

import 'package:flutter/material.dart';

import 'package:maori_health/core/config/string_constants.dart';
import 'package:maori_health/core/theme/app_colors.dart';

abstract class AssetUtils {
  static String statusLabel(int acknowledgementStatus) {
    return acknowledgementStatus == 1
        ? StringConstants.accepted
        : acknowledgementStatus == 2
        ? StringConstants.returned
        : StringConstants.pending;
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

import 'package:flutter/material.dart';

import 'package:maori_health/core/config/app_strings.dart';
import 'package:maori_health/core/theme/app_colors.dart';
import 'package:maori_health/core/utils/extensions.dart';
import 'package:maori_health/domain/lookup_enums/entities/asset_status.dart';

abstract class AssetUtils {
  static String getAssetStatus({
    required String? status,
    required AssetStatus assetStatusKey,
    required AssetStatus assetStatusValue,
  }) {
    if (status == assetStatusKey.assigned) return assetStatusValue.assigned ?? '';
    if (status == assetStatusKey.available) return assetStatusValue.available ?? '';
    if (status == assetStatusKey.damaged) return assetStatusValue.damaged ?? '';
    if (status == assetStatusKey.expired) return assetStatusValue.expired ?? '';
    if (status == assetStatusKey.laptopInitiative) return assetStatusValue.laptopInitiative ?? '';
    if (status == assetStatusKey.missing) return assetStatusValue.missing ?? '';
    if (status == assetStatusKey.returned) return assetStatusValue.returned ?? '';
    if (status == assetStatusKey.stockOut) return assetStatusValue.stockOut ?? '';
    if (status == assetStatusKey.warranty) return assetStatusValue.warranty ?? '';
    return status?.capitalize() ?? '';
  }

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

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import 'package:maori_health/core/theme/app_colors.dart';
import 'package:maori_health/core/utils/extensions.dart';
import 'package:maori_health/presentation/shared/widgets/app_shimmer.dart';

class TimeSheetShimmer extends StatelessWidget {
  final int itemCount;

  const TimeSheetShimmer({super.key, this.itemCount = 10});

  @override
  Widget build(BuildContext context) {
    final isDark = context.theme.brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDark ? AppColors.shimmerBaseDark : AppColors.shimmerBaseLight,
      highlightColor: isDark ? AppColors.shimmerHighlightDark : AppColors.shimmerHighlightLight,
      child: Column(
        children: [
          _buildFilterShimmer(),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: itemCount,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (_, _) => const _ShimmerCard(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterShimmer() {
    return const Row(
      children: [
        Expanded(flex: 2, child: AppShimmer.text(width: double.infinity, height: 42)),
        SizedBox(width: 12),
        Expanded(flex: 1, child: AppShimmer.text(width: double.infinity, height: 42)),
      ],
    );
  }
}

class _ShimmerCard extends StatelessWidget {
  const _ShimmerCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const .symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: .circular(12),
        border: .all(color: context.theme.cardColor),
      ),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Row(
            mainAxisAlignment: .spaceBetween,
            children: [AppShimmer.text(width: 160, height: 20), AppShimmer.text(width: 60, height: 20)],
          ),
          SizedBox(height: 8),
          AppShimmer.text(width: 140, height: 12),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: .spaceBetween,
            children: [AppShimmer.text(width: 40, height: 14), AppShimmer.text(width: 40, height: 14)],
          ),
        ],
      ),
    );
  }
}

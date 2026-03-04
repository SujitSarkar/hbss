import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import 'package:maori_health/core/theme/app_colors.dart';
import 'package:maori_health/core/utils/extensions.dart';

import 'package:maori_health/presentation/shared/widgets/app_shimmer.dart';

class AssetPageShimmer extends StatelessWidget {
  final int itemCount;

  const AssetPageShimmer({super.key, this.itemCount = 8});

  @override
  Widget build(BuildContext context) {
    final isDark = context.theme.brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDark ? AppColors.shimmerBaseDark : AppColors.shimmerBaseLight,
      highlightColor: isDark ? AppColors.shimmerHighlightDark : AppColors.shimmerHighlightLight,
      child: ListView.separated(
        padding: const .fromLTRB(16, 8, 16, 16),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemCount,
        separatorBuilder: (_, _) => const SizedBox(height: 14),
        itemBuilder: (_, _) => const _ShimmerCard(),
      ),
    );
  }
}

class _ShimmerCard extends StatelessWidget {
  const _ShimmerCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const .all(12),
      decoration: BoxDecoration(
        borderRadius: .circular(14),
        border: .all(color: context.theme.cardColor),
      ),
      child: const Column(
        crossAxisAlignment: .start,
        children: [
          Row(
            crossAxisAlignment: .start,
            children: [
              AppShimmer.text(width: 38, height: 38, borderRadius: 8),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    AppShimmer.text(width: double.infinity, height: 14),
                    SizedBox(height: 6),
                    AppShimmer.text(width: 120, height: 12),
                  ],
                ),
              ),
              SizedBox(width: 8),
              AppShimmer.text(width: 64, height: 22, borderRadius: 6),
            ],
          ),
          SizedBox(height: 16),
          _InfoRowShimmer(),
          SizedBox(height: 12),
          _InfoRowShimmer(),
          SizedBox(height: 12),
          _InfoRowShimmer(),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: AppShimmer.text(width: double.infinity, height: 38, borderRadius: 10)),
              SizedBox(width: 12),
              Expanded(child: AppShimmer.text(width: double.infinity, height: 38, borderRadius: 10)),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoRowShimmer extends StatelessWidget {
  const _InfoRowShimmer();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        AppShimmer.circular(size: 16),
        SizedBox(width: 8),
        AppShimmer.text(width: 100, height: 12),
        Spacer(),
        AppShimmer.text(width: 70, height: 12),
      ],
    );
  }
}

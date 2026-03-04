import 'package:flutter/material.dart';

import 'package:maori_health/presentation/shared/widgets/app_shimmer.dart';

class DashboardShimmer extends StatelessWidget {
  const DashboardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const .fromLTRB(12, 12, 0, 24),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          _buildHeaderShimmer(),
          const SizedBox(height: 20),
          const AppShimmer.text(width: 140, height: 18),
          const SizedBox(height: 12),
          const AppShimmer.card(height: 150, borderRadius: 14),
          const SizedBox(height: 24),
          _buildStatsGridShimmer(),
          const SizedBox(height: 24),
          const AppShimmer.text(width: 140, height: 18),
          const SizedBox(height: 12),
          const _JobCardShimmer(),
          const SizedBox(height: 12),
          const AppShimmer.text(width: 140, height: 18),
          const SizedBox(height: 12),
          const _JobCardShimmer(),
          const SizedBox(height: 12),
          const AppShimmer.text(width: 140, height: 18),
          const SizedBox(height: 12),
          const _JobCardShimmer(),
          const SizedBox(height: 12),
          const _JobCardShimmer(),
        ],
      ),
    );
  }

  Widget _buildHeaderShimmer() {
    return const Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: .start,
            children: [
              AppShimmer.text(width: 160, height: 22, borderRadius: 6),
              SizedBox(height: 6),
              AppShimmer.text(width: 120, height: 14),
            ],
          ),
        ),
        AppShimmer.text(width: 48, height: 48, borderRadius: 8),
      ],
    );
  }

  Widget _buildStatsGridShimmer() {
    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: List.generate(4, (_) => const AppShimmer.card(borderRadius: 16)),
    );
  }
}

class _JobCardShimmer extends StatelessWidget {
  const _JobCardShimmer();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: .start,
      children: [
        AppShimmer.text(width: 180, height: 12),
        SizedBox(height: 8),
        AppShimmer.text(width: double.infinity, height: 16),
        SizedBox(height: 6),
        AppShimmer.text(width: 220, height: 12),
        SizedBox(height: 14),
        Row(
          children: [
            AppShimmer.text(width: 60, height: 28),
            SizedBox(width: 24),
            AppShimmer.text(width: 60, height: 28),
            Spacer(),
            AppShimmer.text(width: 60, height: 28),
          ],
        ),
      ],
    );
  }
}

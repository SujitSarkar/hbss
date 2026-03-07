import 'package:flutter/material.dart';
import 'package:maori_health/core/utils/extensions.dart';
import 'package:maori_health/presentation/shared/widgets/app_shimmer.dart';

class ScheduleShimmer extends StatelessWidget {
  const ScheduleShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.theme.scaffoldBackgroundColor,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const .fromLTRB(12, 12, 12, 24),
        child: Column(
          crossAxisAlignment: .start,
          children: [
            ListView.separated(
              padding: .zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) => const _JobCardShimmer(),
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemCount: 6,
            ),
          ],
        ),
      ),
    );
  }
}

class _JobCardShimmer extends StatelessWidget {
  const _JobCardShimmer();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const .all(12),
      decoration: BoxDecoration(
        color: context.theme.cardColor,
        borderRadius: .circular(14),
        border: .all(color: context.theme.dividerColor),
      ),
      child: const Column(
        crossAxisAlignment: .start,
        children: [
          Row(children: [AppShimmer.text(width: 180, height: 12), Spacer(), AppShimmer.text(width: 50, height: 12)]),
          SizedBox(height: 12),
          AppShimmer.text(width: double.infinity, height: 24),
          SizedBox(height: 12),
          AppShimmer.text(width: 220, height: 12),
          SizedBox(height: 12),
          Row(
            children: [
              AppShimmer.text(width: 60, height: 28),
              SizedBox(width: 24),
              AppShimmer.text(width: 60, height: 28),
              Spacer(),
              AppShimmer.text(width: 60, height: 28),
            ],
          ),
          SizedBox(height: 12),
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
      ),
    );
  }
}

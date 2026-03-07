import 'package:flutter/material.dart';

import 'package:maori_health/core/utils/extensions.dart';
import 'package:maori_health/presentation/shared/widgets/app_shimmer.dart';

class JobDetailsShimmer extends StatelessWidget {
  const JobDetailsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Scaffold(
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const .fromLTRB(12, 0, 12, 24),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: .start,
            children: [
              Container(
                width: double.infinity,
                padding: const .all(12),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  border: .all(color: theme.dividerColor),
                  borderRadius: .circular(14),
                ),
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    AppShimmer.text(height: 36, borderRadius: 14, width: context.screenSize.width * 0.4),
                    SizedBox(height: 10),
                    AppShimmer.text(height: 36, borderRadius: 14, width: double.infinity),
                    SizedBox(height: 12),
                    AppShimmer.text(height: 36, borderRadius: 14, width: context.screenSize.width * 0.4),
                    SizedBox(height: 10),
                    AppShimmer.text(height: 36, borderRadius: 14, width: double.infinity),
                    SizedBox(height: 12),
                    AppShimmer.text(height: 36, borderRadius: 14, width: context.screenSize.width * 0.4),
                    SizedBox(height: 10),
                    AppShimmer.text(height: 36, borderRadius: 14, width: double.infinity),
                    SizedBox(height: 20),

                    AppShimmer.text(height: 28, borderRadius: 14, width: double.infinity),
                    SizedBox(height: 10),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              AppShimmer.card(height: 54, borderRadius: 12),
              const SizedBox(height: 16),
              AppShimmer.card(height: 54, borderRadius: 12),
              const SizedBox(height: 16),
              AppShimmer.card(height: 54, borderRadius: 12),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

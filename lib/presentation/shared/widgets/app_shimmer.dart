import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import 'package:maori_health/core/theme/app_colors.dart';

class AppShimmer extends StatelessWidget {
  final Widget _child;

  const AppShimmer._({super.key, required Widget child}) : _child = child;

  const factory AppShimmer.text({Key? key, double width, double height, double borderRadius}) = _TextShimmer;
  const factory AppShimmer.card({Key? key, double height, double borderRadius}) = _CardShimmer;
  const factory AppShimmer.circular({Key? key, double size}) = _CircularShimmer;
  const factory AppShimmer.list({Key? key, int itemCount, double itemHeight, double spacing}) = _ListShimmer;

  static ({Color base, Color highlight}) _shimmerColors(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return (
      base: isDark ? AppColors.shimmerBaseDark : AppColors.shimmerBaseLight,
      highlight: isDark ? AppColors.shimmerHighlightDark : AppColors.shimmerHighlightLight,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = _shimmerColors(context);
    return Shimmer.fromColors(baseColor: colors.base, highlightColor: colors.highlight, child: _child);
  }
}

class _TextShimmer extends AppShimmer {
  final double width;
  final double height;
  final double borderRadius;

  const _TextShimmer({super.key, this.width = 200, this.height = 16, this.borderRadius = 4})
    : super._(child: const SizedBox.shrink());

  @override
  Widget build(BuildContext context) {
    final colors = AppShimmer._shimmerColors(context);
    return Shimmer.fromColors(
      baseColor: colors.base,
      highlightColor: colors.highlight,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: .circular(borderRadius)),
      ),
    );
  }
}

class _CardShimmer extends AppShimmer {
  final double height;
  final double borderRadius;

  const _CardShimmer({super.key, this.height = 120, this.borderRadius = 12}) : super._(child: const SizedBox.shrink());

  @override
  Widget build(BuildContext context) {
    final colors = AppShimmer._shimmerColors(context);
    return Shimmer.fromColors(
      baseColor: colors.base,
      highlightColor: colors.highlight,
      child: Container(
        width: double.infinity,
        height: height,
        decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: .circular(borderRadius)),
      ),
    );
  }
}

class _CircularShimmer extends AppShimmer {
  final double size;

  const _CircularShimmer({super.key, this.size = 48}) : super._(child: const SizedBox.shrink());

  @override
  Widget build(BuildContext context) {
    final colors = AppShimmer._shimmerColors(context);
    return Shimmer.fromColors(
      baseColor: colors.base,
      highlightColor: colors.highlight,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: Theme.of(context).cardColor, shape: BoxShape.circle),
      ),
    );
  }
}

class _ListShimmer extends AppShimmer {
  final int itemCount;
  final double itemHeight;
  final double spacing;

  const _ListShimmer({super.key, this.itemCount = 5, this.itemHeight = 72, this.spacing = 12})
    : super._(child: const SizedBox.shrink());

  @override
  Widget build(BuildContext context) {
    final colors = AppShimmer._shimmerColors(context);
    final cardColor = Theme.of(context).cardColor;

    return Shimmer.fromColors(
      baseColor: colors.base,
      highlightColor: colors.highlight,
      child: Padding(
        padding: const .symmetric(horizontal: 16),
        child: Column(
          children: List.generate(itemCount, (index) {
            return Padding(
              padding: .only(bottom: spacing),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(color: cardColor, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: .start,
                      children: [
                        Container(
                          width: double.infinity,
                          height: 14,
                          decoration: BoxDecoration(color: cardColor, borderRadius: .circular(4)),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 150,
                          height: 12,
                          decoration: BoxDecoration(color: cardColor, borderRadius: .circular(4)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../constants/app_colors.dart';
import '../design/anchor_theme.dart';

/// Skeleton loading shimmer for panels.
class SkeletonPanel extends StatelessWidget {
  final double height;
  const SkeletonPanel({super.key, this.height = 120});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surface,
      highlightColor: AppColors.surfaceRaised,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

/// Skeleton shimmer for text lines.
class SkeletonText extends StatelessWidget {
  final int lines;
  final double width;
  const SkeletonText({super.key, this.lines = 1, this.width = double.infinity});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surface,
      highlightColor: AppColors.surfaceRaised,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(lines, (i) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            height: 14,
            width: i == lines - 1 && width != double.infinity ? width * 0.6 : width,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(2),
            ),
          );
        }),
      ),
    );
  }
}

/// Skeleton shimmer for a list of items.
class SkeletonList extends StatelessWidget {
  final int itemCount;
  const SkeletonList({super.key, this.itemCount = 3});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surface,
      highlightColor: AppColors.surfaceRaised,
      child: Column(
        children: List.generate(itemCount, (i) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Container(width: 36, height: 36, decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(2),
                )),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(height: 14, width: double.infinity, decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(2),
                      )),
                      const SizedBox(height: 6),
                      Container(height: 10, width: 120, decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(2),
                      )),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

// ─── Anchor-specific skeletons (20px radius, AnchorTheme colors) ───

/// Shimmer skeleton for a standard card-sized panel.
class AnchorSkeletonCard extends StatelessWidget {
  final double? height;
  final EdgeInsets? padding;
  const AnchorSkeletonCard({super.key, this.height, this.padding});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AnchorTheme.cardBg,
      highlightColor: AnchorTheme.cardBgHigh,
      child: Container(
        height: height,
        padding: padding ?? const EdgeInsets.all(AnchorTheme.cardPadding),
        decoration: BoxDecoration(
          color: AnchorTheme.cardBg,
          borderRadius: BorderRadius.circular(AnchorTheme.radiusCard),
          border: Border.all(color: AnchorTheme.cardBorder, width: 1),
        ),
      ),
    );
  }
}

/// Shimmer skeleton for text lines inside a card.
class AnchorSkeletonText extends StatelessWidget {
  final int lines;
  final double width;
  const AnchorSkeletonText({super.key, this.lines = 1, this.width = double.infinity});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AnchorTheme.cardBg,
      highlightColor: AnchorTheme.cardBgHigh,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(lines, (i) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            height: 14,
            width: i == lines - 1 && width != double.infinity ? width * 0.6 : width,
            decoration: BoxDecoration(
              color: AnchorTheme.cardBg,
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }),
      ),
    );
  }
}

/// Shimmer skeleton for a task list item (dot + 2 lines).
class AnchorSkeletonTaskItem extends StatelessWidget {
  const AnchorSkeletonTaskItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AnchorTheme.cardBg,
      highlightColor: AnchorTheme.cardBgHigh,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 10,
            height: 10,
            margin: const EdgeInsets.only(top: 6, right: 12),
            decoration: const BoxDecoration(
              color: AnchorTheme.cardBg,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 14,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AnchorTheme.cardBg,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  height: 10,
                  width: 120,
                  decoration: BoxDecoration(
                    color: AnchorTheme.cardBg,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

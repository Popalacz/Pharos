import 'package:flutter/material.dart';

import '../../core/constants/pharos_layout.dart';
import '../../core/theme/app_colors.dart';
import 'shimmer_wave.dart';

/// Placeholder grid while products load — reads as “premium loading”, not a spinner-only state.
class ProductCatalogSkeleton extends StatelessWidget {
  const ProductCatalogSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerWave(
      child: GridView.builder(
        padding: const EdgeInsets.all(PharosLayout.spaceSm),
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: 6,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: PharosLayout.spaceSm,
          mainAxisSpacing: PharosLayout.spaceSm,
        ),
        itemBuilder: (BuildContext context, int index) {
          return Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(PharosLayout.radiusMd),
              border: Border.all(color: AppColors.black.withValues(alpha: 0.35)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(PharosLayout.spaceXs),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(PharosLayout.radiusSm),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    PharosLayout.spaceSm,
                    0,
                    PharosLayout.spaceSm,
                    PharosLayout.spaceSm,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 12,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const SizedBox(height: PharosLayout.spaceXs),
                      Container(
                        height: 12,
                        width: 96,
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const SizedBox(height: PharosLayout.spaceXs),
                      Container(
                        height: 14,
                        width: 72,
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

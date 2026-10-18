import 'package:pharos/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class BannerShimmer extends StatelessWidget {
  const BannerShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Shimmer.fromColors(
        baseColor: AppColors.text.withOpacity(0.08),
        highlightColor: AppColors.text.withOpacity(0.18),
        child: Container(
          height: 200,
          decoration: BoxDecoration(
            color: AppColors.text,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../core/app_assets.dart';
import '../../core/theme/app_colors.dart';

/// Compact brand row for [AppBar.title] (logo + name).
class StoreBrandTitle extends StatelessWidget {
  const StoreBrandTitle({super.key, this.logoHeight = 30});

  final double logoHeight;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          AppAssets.storeLogo,
          height: logoHeight,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.medium,
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            'Pharos Store',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.text,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
          ),
        ),
      ],
    );
  }
}

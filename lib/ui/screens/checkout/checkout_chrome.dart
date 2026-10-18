import 'package:flutter/material.dart';
import 'package:pharos/core/constants/pharos_layout.dart';
import 'package:pharos/core/theme/app_colors.dart';
import 'package:pharos/core/theme/app_spacing.dart';

class CheckoutSectionHeader extends StatelessWidget {
  const CheckoutSectionHeader({super.key, required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: AppColors.accent.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, size: 16, color: AppColors.accentText),
          ),
          const SizedBox(width: AppSpacing.s12),
          Text(title.toUpperCase(), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.text, letterSpacing: 1.2)),
          const SizedBox(width: AppSpacing.s12),
          Expanded(child: Divider(color: AppColors.text.withOpacity(0.05), thickness: 1)),
        ],
      ),
    );
  }
}

class CheckoutValidationBanner extends StatelessWidget {
  const CheckoutValidationBanner({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.12),
          borderRadius: BorderRadius.circular(PharosLayout.radiusMd),
          border: Border.all(color: AppColors.error.withOpacity(0.35)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.info_outline, color: AppColors.error, size: 20),
            const SizedBox(width: AppSpacing.s12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: AppColors.text, fontSize: 13, height: 1.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

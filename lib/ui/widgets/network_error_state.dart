import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/pharos_layout.dart';
import '../../core/theme/app_colors.dart';

/// Friendly offline / API failure panel with a clear retry action.
class NetworkErrorState extends StatelessWidget {
  const NetworkErrorState({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(PharosLayout.spaceLg),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(PharosLayout.radiusLg),
              border: Border.all(color: AppColors.black.withValues(alpha: 0.35)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(PharosLayout.spaceLg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.wifi_tethering_error_rounded,
                    size: 56,
                    color: AppColors.accent.withValues(alpha: 0.95),
                  ),
                  const SizedBox(height: PharosLayout.spaceMd),
                  Text(
                    'Nie udało się pobrać katalogu',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.text,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: PharosLayout.spaceSm),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.text.withValues(alpha: 0.78),
                          height: 1.35,
                        ),
                  ),
                  const SizedBox(height: PharosLayout.spaceMd),
                  FilledButton.icon(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      onRetry();
                    },
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Spróbuj ponownie'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

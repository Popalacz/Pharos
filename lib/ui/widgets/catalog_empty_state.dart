import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../core/constants/pharos_layout.dart';
import '../../core/theme/app_colors.dart';
import 'pharos_button.dart';

class CatalogEmptyState extends StatelessWidget {
  const CatalogEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(PharosLayout.spaceLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.network(
              'https://assets10.lottiefiles.com/packages/lf20_dmw3t0vg.json',
              height: 150,
              repeat: true,
              errorBuilder: (context, error, stackTrace) => Icon(
                Icons.inventory_2_outlined,
                size: 64,
                color: AppColors.text.withValues(alpha: 0.35),
              ),
            ),
            const SizedBox(height: PharosLayout.spaceMd),
            Text(
              'BRAK PRODUKTÓW',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.text,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
            ),
            const SizedBox(height: PharosLayout.spaceSm),
            Text(
              'W tej kategorii nie ma obecnie żadnych dostępnych produktów. Zapraszamy wkrótce!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.text.withValues(alpha: 0.5),
                    height: 1.5,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class CatalogNoSearchResults extends StatelessWidget {
  const CatalogNoSearchResults({
    super.key,
    required this.query,
    required this.onClearQuery,
  });

  final String query;
  final VoidCallback onClearQuery;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(PharosLayout.spaceLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.manage_search_rounded,
              size: 64,
              color: AppColors.text.withValues(alpha: 0.35),
            ),
            const SizedBox(height: PharosLayout.spaceMd),
            Text(
              'Brak wyników',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.text,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: PharosLayout.spaceXs),
            Text(
              'Dla zapytania „$query” nie znaleziono produktów.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.text.withValues(alpha: 0.72),
                    height: 1.35,
                  ),
            ),
            const SizedBox(height: PharosLayout.spaceMd),
            PharosButton(
              style: PharosButtonStyle.outline,
              label: 'Wyczyść wyszukiwanie',
              onPressed: onClearQuery,
            ),
          ],
        ),
      ),
    );
  }
}

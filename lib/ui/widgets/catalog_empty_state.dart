import 'package:flutter/material.dart';

import '../../core/constants/pharos_layout.dart';
import '../../core/theme/app_colors.dart';

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
            Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: AppColors.text.withOpacity(0.35),
            ),
            const SizedBox(height: PharosLayout.spaceMd),
            Text(
              'Brak produktów',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.text,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: PharosLayout.spaceXs),
            Text(
              'Sprawdź połączenie z PrestaShop lub odśwież katalog z menu.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.text.withOpacity(0.72),
                    height: 1.35,
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
              color: AppColors.text.withOpacity(0.35),
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
                    color: AppColors.text.withOpacity(0.72),
                    height: 1.35,
                  ),
            ),
            const SizedBox(height: PharosLayout.spaceMd),
            OutlinedButton(
              onPressed: onClearQuery,
              child: const Text('Wyczyść wyszukiwanie'),
            ),
          ],
        ),
      ),
    );
  }
}

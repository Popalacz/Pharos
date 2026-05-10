import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_assets.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/product_provider.dart';

/// Side navigation — structure only; most entries show “coming soon” for now.
class PharosNavigationDrawer extends StatelessWidget {
  const PharosNavigationDrawer({
    super.key,
    required this.onRefreshCatalog,
  });

  final VoidCallback onRefreshCatalog;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Drawer(
      backgroundColor: AppColors.surface,
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.surface,
                    AppColors.background,
                  ],
                ),
                border: Border(
                  bottom: BorderSide(color: AppColors.accent, width: 3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(
                    AppAssets.storeLogo,
                    height: 48,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.medium,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Witaj w Pharos',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppColors.text,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Przeglądaj i zamawiaj wygodnie.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.text.withOpacity(0.75),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Consumer<ProductProvider>(
                    builder: (BuildContext context, ProductProvider catalog, Widget? _) {
                      final int count = catalog.products.length;

                      return Text(
                        'Produkty w katalogu: $count',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: AppColors.accent,
                          fontWeight: FontWeight.w800,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home_outlined, color: AppColors.text),
              title: const Text('Strona główna'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.grid_view_rounded, color: AppColors.text),
              title: const Text('Kategorie'),
              onTap: () {
                final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
                Navigator.pop(context);
                messenger.hideCurrentSnackBar();
                messenger.showSnackBar(
                  const SnackBar(content: Text('Ta funkcja pojawi się wkrótce.')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.local_offer_outlined, color: AppColors.text),
              title: const Text('Promocje'),
              onTap: () {
                final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
                Navigator.pop(context);
                messenger.hideCurrentSnackBar();
                messenger.showSnackBar(
                  const SnackBar(content: Text('Ta funkcja pojawi się wkrótce.')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.favorite_outline, color: AppColors.text),
              title: const Text('Ulubione'),
              onTap: () {
                final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
                Navigator.pop(context);
                messenger.hideCurrentSnackBar();
                messenger.showSnackBar(
                  const SnackBar(content: Text('Ta funkcja pojawi się wkrótce.')),
                );
              },
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.refresh_rounded, color: AppColors.accent),
              title: const Text('Odśwież katalog'),
              onTap: () {
                onRefreshCatalog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined, color: AppColors.text),
              title: const Text('Ustawienia'),
              onTap: () {
                final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
                Navigator.pop(context);
                messenger.hideCurrentSnackBar();
                messenger.showSnackBar(
                  const SnackBar(content: Text('Ta funkcja pojawi się wkrótce.')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

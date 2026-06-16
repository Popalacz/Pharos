import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pharos/ui/screens/categories_screen.dart';
import 'package:pharos/ui/screens/wishlist_screen.dart';
import 'package:pharos/ui/screens/localization_settings_screen.dart';
import 'package:pharos/core/theme/app_colors.dart';
import 'package:pharos/core/providers/settings_provider.dart';

class PharosNavigationDrawer extends StatelessWidget {
  const PharosNavigationDrawer({
    super.key,
    required this.onRefreshCatalog,
  });

  final VoidCallback onRefreshCatalog;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final settings = context.watch<SettingsProvider>().settings;

    return Drawer(
      backgroundColor: const Color(0xFF121212),
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              decoration: const BoxDecoration(
                color: Color(0xFF1A1A1A),
                border: Border(
                  bottom: BorderSide(color: Colors.orange, width: 2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    settings.storeName.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 24,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Premium E-commerce Experience',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            _buildMenuItem(context, Icons.home_outlined, 'Strona główna', () {
              Navigator.pop(context);
            }),
            _buildMenuItem(context, Icons.grid_view_rounded, 'Kategorie', () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const CategoriesScreen()));
            }),
            _buildMenuItem(context, Icons.favorite_outline, 'Ulubione', () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const WishlistScreen()));
            }),
            _buildMenuItem(context, Icons.language_outlined, 'Język i Waluta', () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const LocalizationSettingsScreen()));
            }),
            const Divider(color: Colors.white10, height: 32),
            _buildMenuItem(context, Icons.refresh_rounded, 'Odśwież sklep', () {
              Navigator.pop(context);
              onRefreshCatalog();
            }, iconColor: Colors.orange),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, IconData icon, String title, VoidCallback onTap, {Color? iconColor}) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? Colors.white70),
      title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      onTap: onTap,
      hoverColor: Colors.orange.withOpacity(0.1),
    );
  }
}

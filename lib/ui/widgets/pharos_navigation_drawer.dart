import 'package:pharos/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:pharos/core/theme/app_spacing.dart';
import 'package:provider/provider.dart';
import 'package:pharos/ui/screens/categories_screen.dart';
import 'package:pharos/ui/screens/wishlist_screen.dart';
import 'package:pharos/ui/screens/localization_settings_screen.dart';
import 'package:pharos/ui/screens/events_screen.dart';
import 'package:pharos/core/providers/settings_provider.dart';
import 'package:pharos/l10n/app_localizations.dart';

class PharosNavigationDrawer extends StatelessWidget {
  const PharosNavigationDrawer({
    super.key,
    required this.onRefreshCatalog,
  });

  final VoidCallback onRefreshCatalog;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
                  bottom: BorderSide(color: AppColors.accentText, width: 2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    settings.storeName.toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.text,
                      fontWeight: FontWeight.w900,
                      fontSize: 24,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s8),
                  Text(
                    l10n.drawerTagline,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            _buildMenuItem(context, Icons.home_outlined, l10n.drawerHome, () {
              Navigator.pop(context);
            }),
            _buildMenuItem(context, Icons.grid_view_rounded, l10n.drawerCategories, () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const CategoriesScreen()));
            }),
            _buildMenuItem(context, Icons.favorite_outline, l10n.wishlist, () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const WishlistScreen()));
            }),
            _buildMenuItem(context, Icons.calendar_month_outlined, l10n.calendar, () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const EventsScreen()));
            }),
            _buildMenuItem(context, Icons.language_outlined, l10n.drawerLanguageCurrency, () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const LocalizationSettingsScreen()));
            }),
            const Divider(color: AppColors.divider, height: 32),
            _buildMenuItem(context, Icons.refresh_rounded, l10n.drawerRefreshStore, () {
              Navigator.pop(context);
              onRefreshCatalog();
            }, iconColor: AppColors.accentText),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, IconData icon, String title, VoidCallback onTap, {Color? iconColor}) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? AppColors.textSecondary),
      title: Text(title, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.w600)),
      onTap: onTap,
      hoverColor: AppColors.accentText.withOpacity(0.1),
    );
  }
}

import 'package:pharos/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:pharos/core/theme/app_spacing.dart';
import 'package:provider/provider.dart';
import 'package:pharos/core/providers/localization_provider.dart';
import 'package:pharos/core/providers/settings_provider.dart';
import 'package:pharos/core/providers/user_provider.dart';
import 'package:pharos/core/services/notification_service.dart';
import 'package:pharos/data/repositories/product_repository.dart';
import 'package:pharos/ui/widgets/list_shimmer.dart';
import 'package:pharos/ui/widgets/network_error_state.dart';
import 'package:pharos/l10n/app_localizations.dart';

class LocalizationSettingsScreen extends StatelessWidget {
  const LocalizationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final locProvider = context.watch<LocalizationProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.regionalSettings, style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: locProvider.isLoading
          ? const Padding(padding: EdgeInsets.all(20), child: ListShimmer(itemCount: 4))
          : locProvider.languages.isEmpty && locProvider.currencies.isEmpty
              ? NetworkErrorState(
                  message: AppLocalizations.of(context)!.regionalSettingsEmpty,
                  onRetry: () => locProvider.reload(),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (locProvider.showLanguageSelector) ...[
                        _buildSectionHeader('WYBIERZ JĘZYK'),
                        const SizedBox(height: AppSpacing.s12),
                        _buildLanguageList(context, locProvider),
                        const SizedBox(height: AppSpacing.s40),
                      ],
                      if (locProvider.showCurrencySelector) ...[
                        _buildSectionHeader('WYBIERZ WALUTĘ'),
                        const SizedBox(height: AppSpacing.s12),
                        _buildCurrencyList(context, locProvider),
                        const SizedBox(height: AppSpacing.s40),
                      ],
                      _buildInfoText(AppLocalizations.of(context)!.currencyRecalcInfo),
                    ],
                  ),
                ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.accentText, letterSpacing: 1.2, fontSize: 13),
    );
  }

  Widget _buildLanguageList(BuildContext context, LocalizationProvider provider) {
    return Material(
      color: Theme.of(context).cardTheme.color,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.text.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: provider.languages.map((lang) => RadioListTile(
          value: lang.id,
          groupValue: provider.currentLanguage?.id,
          title: Text(lang.name, style: const TextStyle(color: AppColors.text)),
          secondary: Text(lang.isoCode.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.accentText)),
          activeColor: AppColors.accentText,
          onChanged: (val) async {
            await provider.setLanguage(lang);
            if (!context.mounted) return;
            await context.read<SettingsProvider>().reload();
            await context.read<IProductRepository>().getProducts();
            final userProvider = context.read<UserProvider>();
            await NotificationService().resyncCurrentToken(
              customerId: userProvider.isLoggedIn ? userProvider.user?.id : null,
              languageId: lang.id,
            );
          },
        )).toList(),
      ),
    );
  }

  Widget _buildCurrencyList(BuildContext context, LocalizationProvider provider) {
    return Material(
      color: Theme.of(context).cardTheme.color,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.text.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: provider.currencies.map((curr) => RadioListTile(
          value: curr.id,
          groupValue: provider.currentCurrency?.id,
          title: Text(curr.name, style: const TextStyle(color: AppColors.text)),
          secondary: Text(curr.isoCode, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.accentText)),
          activeColor: AppColors.accentText,
          onChanged: (val) => provider.setCurrency(curr),
        )).toList(),
      ),
    );
  }

  Widget _buildInfoText(String text) {
    return Text(text, style: TextStyle(color: AppColors.text.withValues(alpha: 0.5), fontSize: 13, height: 1.5));
  }
}

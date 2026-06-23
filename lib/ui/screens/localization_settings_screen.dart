import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pharos/core/providers/localization_provider.dart';
import 'package:pharos/ui/widgets/list_shimmer.dart';
import 'package:pharos/ui/widgets/network_error_state.dart';

class LocalizationSettingsScreen extends StatelessWidget {
  const LocalizationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final locProvider = context.watch<LocalizationProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ustawienia regionalne', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: locProvider.isLoading
          ? const Padding(padding: EdgeInsets.all(20), child: ListShimmer(itemCount: 4))
          : locProvider.languages.isEmpty && locProvider.currencies.isEmpty
              ? NetworkErrorState(
                  message: 'Brak skonfigurowanych języków lub walut w sklepie.',
                  onRetry: () => locProvider.reload(),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (locProvider.showLanguageSelector) ...[
                        _buildSectionHeader('WYBIERZ JĘZYK'),
                        const SizedBox(height: 12),
                        _buildLanguageList(context, locProvider),
                        const SizedBox(height: 40),
                      ],
                      if (locProvider.showCurrencySelector) ...[
                        _buildSectionHeader('WYBIERZ WALUTĘ'),
                        const SizedBox(height: 12),
                        _buildCurrencyList(context, locProvider),
                        const SizedBox(height: 40),
                      ],
                      _buildInfoText('Ceny produktów zostaną automatycznie przeliczone zgodnie z aktualnym kursem w Twoim sklepie.'),
                    ],
                  ),
                ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange, letterSpacing: 1.2, fontSize: 13),
    );
  }

  Widget _buildLanguageList(BuildContext context, LocalizationProvider provider) {
    return Material(
      color: Theme.of(context).cardTheme.color,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: provider.languages.map((lang) => RadioListTile(
          value: lang.id,
          groupValue: provider.currentLanguage?.id,
          title: Text(lang.name, style: const TextStyle(color: Colors.white)),
          secondary: Text(lang.isoCode.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
          activeColor: Colors.orange,
          onChanged: (val) => provider.setLanguage(lang),
        )).toList(),
      ),
    );
  }

  Widget _buildCurrencyList(BuildContext context, LocalizationProvider provider) {
    return Material(
      color: Theme.of(context).cardTheme.color,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: provider.currencies.map((curr) => RadioListTile(
          value: curr.id,
          groupValue: provider.currentCurrency?.id,
          title: Text(curr.name, style: const TextStyle(color: Colors.white)),
          secondary: Text(curr.isoCode, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
          activeColor: Colors.orange,
          onChanged: (val) => provider.setCurrency(curr),
        )).toList(),
      ),
    );
  }

  Widget _buildInfoText(String text) {
    return Text(text, style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 13, height: 1.5));
  }
}

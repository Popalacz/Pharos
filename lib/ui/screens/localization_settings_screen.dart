import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pharos/core/providers/localization_provider.dart';

class LocalizationSettingsScreen extends StatelessWidget {
  const LocalizationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final locProvider = context.watch<LocalizationProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Język i Waluta', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('WYBIERZ JĘZYK', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
            const SizedBox(height: 12),
            _buildLanguageList(context, locProvider),
            
            const SizedBox(height: 40),
            const Text('WYBIERZ WALUTĘ', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
            const SizedBox(height: 12),
            _buildCurrencyList(context, locProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageList(BuildContext context, LocalizationProvider provider) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color, 
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
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
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color, 
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: provider.currencies.map((curr) => RadioListTile(
          value: curr.id,
          groupValue: provider.currentCurrency?.id,
          title: Text(curr.name, style: const TextStyle(color: Colors.white)),
          secondary: Text(curr.symbol, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.orange)),
          activeColor: Colors.orange,
          onChanged: (val) => provider.setCurrency(curr),
        )).toList(),
      ),
    );
  }
}

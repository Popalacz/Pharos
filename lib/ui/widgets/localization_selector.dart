import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pharos/core/providers/localization_provider.dart';
import 'package:pharos/data/models/localization_models.dart';

class LocalizationSelector extends StatelessWidget {
  const LocalizationSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LocalizationProvider>(
      builder: (context, loc, child) {
        if (loc.languages.isEmpty && loc.currencies.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLanguagePicker(context, loc),
              Container(width: 1, height: 20, color: Colors.white10, margin: const EdgeInsets.symmetric(horizontal: 12)),
              _buildCurrencyPicker(context, loc),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLanguagePicker(BuildContext context, LocalizationProvider loc) {
    return InkWell(
      onTap: () => _showLanguageDialog(context, loc),
      child: Row(
        children: [
          const Icon(Icons.language, size: 16, color: Colors.orange),
          const SizedBox(width: 8),
          Text(
            loc.currentLanguage?.isoCode.toUpperCase() ?? '--',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyPicker(BuildContext context, LocalizationProvider loc) {
    return InkWell(
      onTap: () => _showCurrencyDialog(context, loc),
      child: Row(
        children: [
          const Icon(Icons.payments_outlined, size: 16, color: Colors.orange),
          const SizedBox(width: 8),
          Text(
            loc.currentCurrency?.isoCode ?? '--',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, LocalizationProvider loc) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Wybierz język'),
        backgroundColor: const Color(0xFF1A1A1A),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: loc.languages.length,
            itemBuilder: (context, index) {
              final lang = loc.languages[index];
              return ListTile(
                title: Text(lang.name, style: const TextStyle(color: Colors.white)),
                trailing: loc.currentLanguage?.id == lang.id ? const Icon(Icons.check, color: Colors.orange) : null,
                onTap: () {
                  loc.setLanguage(lang);
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _showCurrencyDialog(BuildContext context, LocalizationProvider loc) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Wybierz walutę'),
        backgroundColor: const Color(0xFF1A1A1A),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: loc.currencies.length,
            itemBuilder: (context, index) {
              final curr = loc.currencies[index];
              return ListTile(
                title: Text('${curr.name} (${curr.symbol})', style: const TextStyle(color: Colors.white)),
                trailing: loc.currentCurrency?.id == curr.id ? const Icon(Icons.check, color: Colors.orange) : null,
                onTap: () {
                  loc.setCurrency(curr);
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

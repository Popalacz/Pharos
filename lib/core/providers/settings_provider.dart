import 'package:flutter/material.dart';
import 'package:pharos/data/models/remote_settings_model.dart';

class SettingsProvider extends ChangeNotifier {
  RemoteSettings? _settings;

  RemoteSettings? get settings => _settings;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    // Symulacja pobrania ustawień z modułu PrestaShop (np. /api/pharos_config)
    await Future.delayed(const Duration(milliseconds: 500));
    
    _settings = RemoteSettings(
      registrationRequired: false,
      showStock: true,
      enableGooglePay: true,
      supportEmail: 'biuro@pharos-shop.pl',
      theme: {
        'primary_color': '#FF9800',
        'font_family': 'Roboto',
      },
      enabledPaymentMethods: ['GooglePay', 'BLIK', 'Card'],
    );
    
    notifyListeners();
  }
}

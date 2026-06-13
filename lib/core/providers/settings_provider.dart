import 'package:flutter/material.dart';
import 'package:pharos/data/models/remote_settings_model.dart';
import '../network/api_service.dart';

class SettingsProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  RemoteSettings _settings = RemoteSettings.defaultSettings();

  RemoteSettings get settings => _settings;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      // W prawdziwej aplikacji: final response = await _apiService.dio.get('/pharos/config');
      // _settings = RemoteSettings.fromJson(response.data);
      
      // Symulacja pobrania danych z modułu PrestaShop
      await Future.delayed(const Duration(milliseconds: 300));
      
      // Jeśli backend zwróci dane, nadpisujemy defaultowe
      final remoteData = {
        'store_name': 'PHAROS PREMIUM',
        'logo_url': 'https://pharos-shop.pl/img/logo.png',
        'reg_required': false,
        'theme': {'primary_color': '#FF9800'},
      };

      _settings = RemoteSettings.fromJson(remoteData);
    } catch (e) {
      debugPrint('Błąd ładowania ustawień zdalnych, używam podstawowych: $e');
      // _settings zostaje jako defaultSettings()
    }
    
    notifyListeners();
  }
}

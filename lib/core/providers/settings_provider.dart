import 'package:flutter/material.dart';
import 'package:pharos/data/models/remote_settings_model.dart';
import '../network/api_service.dart';

class SettingsProvider extends ChangeNotifier {
  final ApiService apiService = ApiService();
  RemoteSettings _settings = RemoteSettings.defaultSettings();

  RemoteSettings get settings => _settings;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      // Pobieranie konfiguracji z dedykowanego endpointu modułu pharos_api
      final response = await apiService.dio.get('/module/pharos_api/config');
      
      if (response.statusCode == 200) {
        _settings = RemoteSettings.fromJson(response.data);
        debugPrint('Konfiguracja Pharos załadowana pomyślnie.');
      }
    } catch (e) {
      debugPrint('Błąd ładowania ustawień zdalnych (Używam domyślnych): $e');
      // _settings pozostaje zainicjalizowane przez defaultSettings() w modelu
    }
    
    notifyListeners();
  }
}

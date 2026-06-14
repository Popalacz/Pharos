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
      // Używamy bezpośredniego wywołania kontrolera modułu
      final response = await apiService.dio.get('/index.php', queryParameters: {
        'fc': 'module',
        'module': 'pharosapi',
        'controller': 'config',
      });
      
      if (response.statusCode == 200) {
        _settings = RemoteSettings.fromJson(response.data);
        debugPrint('Konfiguracja Pharos załadowana pomyślnie.');
      }
    } catch (e) {
      debugPrint('Błąd ładowania ustawień zdalnych: $e');
    }
    notifyListeners();
  }
}

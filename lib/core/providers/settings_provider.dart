import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pharos/data/models/remote_settings_model.dart';
import 'package:dio/dio.dart';
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
      debugPrint('SETTINGS: Start loading from Pharos API...');
      final response = await apiService.dio.get('/index.php', queryParameters: {
        'fc': 'module',
        'module': 'pharosapi',
        'controller': 'config',
      });
      
      if (response.statusCode == 200) {
        dynamic data = response.data;
        if (data is String) {
          debugPrint('SETTINGS: Data is String, decoding manually...');
          data = jsonDecode(data);
        }
        
        if (data is Map<String, dynamic>) {
           _settings = RemoteSettings.fromJson(data);
           debugPrint('Konfiguracja Pharos załadowana pomyślnie: ${_settings.storeName}');
        }
      } else {
        debugPrint('SETTINGS: Server returned status ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Błąd ładowania ustawień zdalnych: $e');
      if (e is DioException) {
        debugPrint('Dio Error Type: ${e.type}');
        debugPrint('Dio Error Message: ${e.message}');
        debugPrint('Dio Response: ${e.response?.data}');
      }
    }
    notifyListeners();
  }
}

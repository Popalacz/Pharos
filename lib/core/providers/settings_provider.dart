import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:pharos/data/models/remote_settings_model.dart';
import 'package:pharos/data/repositories/system_repository.dart';
import 'package:dio/dio.dart';
import '../network/api_service.dart';

class SettingsProvider extends ChangeNotifier {
  final ApiService apiService;
  final SystemRepository _systemRepository;
  RemoteSettings _settings = RemoteSettings.defaultSettings();

  RemoteSettings get settings => _settings;

  SettingsProvider({required this.apiService}) 
    : _systemRepository = SystemRepository(apiService: apiService) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      // 1. Próba pobrania zaawansowanej konfiguracji z dedykowanego modułu Pharos
      final response = await apiService.dio.get('/index.php', queryParameters: {
        'fc': 'module',
        'module': 'pharosapi',
        'controller': 'config',
      });
      
      if (response.statusCode == 200) {
        dynamic data = response.data;
        if (data is String) data = jsonDecode(data);
        if (data is Map<String, dynamic>) {
           _settings = RemoteSettings.fromJson(data);
        }
      }
    } catch (e) {
      final result = await _systemRepository.getConfiguration('PS_SHOP_NAME');
      result.fold(
        (failure) => debugPrint('Settings Load Failure: $failure'),
        (shopName) {
          if (shopName != null) {
            _settings = _settings.copyWith(storeName: shopName);
          }
        },
      );
    }
    notifyListeners();
  }
}



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

  Future<void> reload() async {
    await _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
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

    await _applyContactFallback();
    notifyListeners();
  }

  Future<void> _applyContactFallback() async {
    final bool needsEmail = !_hasText(_settings.storeEmail);
    final bool needsPhone = !_hasText(_settings.storePhone);
    final bool needsAddress = !_hasText(_settings.storeAddress);

    if (!needsEmail && !needsPhone && !needsAddress) {
      return;
    }

    final result = await _systemRepository.getMultipleConfigurations([
      'PS_SHOP_EMAIL',
      'PS_SHOP_PHONE',
      'PS_SHOP_ADDR1',
      'PS_SHOP_ADDR2',
      'PS_SHOP_CODE',
      'PS_SHOP_CITY',
    ]);

    result.fold(
      (failure) => debugPrint('Contact fallback failure: $failure'),
      (configs) {
        final addressParts = <String>[
          if (_hasText(configs['PS_SHOP_ADDR1'])) configs['PS_SHOP_ADDR1']!,
          if (_hasText(configs['PS_SHOP_ADDR2'])) configs['PS_SHOP_ADDR2']!,
        ];

        final postcode = configs['PS_SHOP_CODE']?.trim() ?? '';
        final city = configs['PS_SHOP_CITY']?.trim() ?? '';
        if (postcode.isNotEmpty || city.isNotEmpty) {
          addressParts.add('$postcode $city'.trim());
        }

        _settings = _settings.copyWith(
          storeEmail: needsEmail ? _readOptionalConfig(configs['PS_SHOP_EMAIL']) : _settings.storeEmail,
          storePhone: needsPhone ? _readOptionalConfig(configs['PS_SHOP_PHONE']) : _settings.storePhone,
          storeAddress: needsAddress && addressParts.isNotEmpty
              ? addressParts.join(', ')
              : _settings.storeAddress,
        );
      },
    );
  }

  bool _hasText(String? value) => value != null && value.trim().isNotEmpty;

  String? _readOptionalConfig(String? value) {
    if (value == null) return null;
    final normalized = value.trim();
    return normalized.isEmpty ? null : normalized;
  }
}



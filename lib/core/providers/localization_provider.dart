import 'package:flutter/material.dart';
import 'package:pharos/data/models/localization_models.dart';
import '../network/api_service.dart';

class LocalizationProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<LanguageModel> _languages = [];
  List<CurrencyModel> _currencies = [];

  LanguageModel? _currentLanguage;
  CurrencyModel? _currentCurrency;
  bool _isLoading = true;

  List<LanguageModel> get languages => _languages;
  List<CurrencyModel> get currencies => _currencies;
  LanguageModel? get currentLanguage => _currentLanguage;
  CurrencyModel? get currentCurrency => _currentCurrency;
  bool get isLoading => _isLoading;
  bool get showLanguageSelector => _languages.length > 1;
  bool get showCurrencySelector => _currencies.length > 1;

  LocalizationProvider() {
    _loadFromPrestaShop();
  }

  Future<void> reload() => _loadFromPrestaShop();

  Future<void> _loadFromPrestaShop() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.dio.get('/index.php', queryParameters: {
        'fc': 'module',
        'module': 'pharosapi',
        'controller': 'config',
      });

      if (response.data['localization'] != null) {
        final locData = response.data['localization'];

        _languages = (locData['languages'] as List)
            .map((e) => LanguageModel.fromJson(e))
            .toList();

        _currencies = (locData['currencies'] as List)
            .map((e) => CurrencyModel.fromJson(e))
            .toList();

        if (_languages.isNotEmpty) {
          _currentLanguage = _languages.firstWhere(
            (l) => l.isoCode == (locData['language_code'] ?? locData['locale'] ?? ''),
            orElse: () => _languages.first,
          );
        } else {
          _currentLanguage = null;
        }

        if (_currencies.isNotEmpty) {
          _currentCurrency = _currencies.first;
        } else {
          _currentCurrency = null;
        }
      }
    } catch (e) {
      debugPrint('Localization Load Error: $e');
      _languages = [];
      _currencies = [];
      _currentLanguage = null;
      _currentCurrency = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  void setLanguage(LanguageModel lang) {
    _currentLanguage = lang;
    notifyListeners();
  }

  void setCurrency(CurrencyModel curr) {
    _currentCurrency = curr;
    notifyListeners();
  }

  String formatPrice(double price) {
    if (_currentCurrency == null) return price.toStringAsFixed(2);
    final double converted = price * _currentCurrency!.conversionRate;
    return '${converted.toStringAsFixed(2)} ${_currentCurrency!.symbol}';
  }
}

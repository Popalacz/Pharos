import 'package:flutter/material.dart';
import 'package:pharos/data/models/localization_models.dart';

class LocalizationProvider extends ChangeNotifier {
  List<LanguageModel> _languages = [];
  List<CurrencyModel> _currencies = [];
  
  LanguageModel? _currentLanguage;
  CurrencyModel? _currentCurrency;

  List<LanguageModel> get languages => _languages;
  List<CurrencyModel> get currencies => _currencies;
  LanguageModel? get currentLanguage => _currentLanguage;
  CurrencyModel? get currentCurrency => _currentCurrency;

  LocalizationProvider() {
    _loadFromPrestaShop();
  }

  Future<void> _loadFromPrestaShop() async {
    // Symulacja pobrania z API PrestaShop
    await Future.delayed(const Duration(milliseconds: 500));
    
    _languages = [
      LanguageModel(id: 1, name: 'Polski', isoCode: 'pl', languageCode: 'pl'),
      LanguageModel(id: 2, name: 'English', isoCode: 'gb', languageCode: 'en'),
    ];
    
    _currencies = [
      CurrencyModel(id: 1, name: 'Złoty', isoCode: 'PLN', symbol: 'zł', conversionRate: 1.0),
      CurrencyModel(id: 2, name: 'Euro', isoCode: 'EUR', symbol: '€', conversionRate: 0.23),
    ];

    _currentLanguage = _languages.first;
    _currentCurrency = _currencies.first;
    notifyListeners();
  }

  void setLanguage(LanguageModel lang) {
    _currentLanguage = lang;
    // Tu docelowo odświeżamy API
    notifyListeners();
  }

  void setCurrency(CurrencyModel curr) {
    _currentCurrency = curr;
    notifyListeners();
  }

  // Helper do formatowania cen zgodnie z wybraną walutą
  String formatPrice(double price) {
    if (_currentCurrency == null) return '${price.toStringAsFixed(2)} PLN';
    double converted = price * _currentCurrency!.conversionRate;
    return '${converted.toStringAsFixed(2)} ${_currentCurrency!.symbol}';
  }
}

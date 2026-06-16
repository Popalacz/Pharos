import 'package:flutter/material.dart';
import 'package:pharos/data/models/localization_models.dart';
import '../network/api_service.dart';

class LocalizationProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
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

        // Ustawienie domyślnych wartości (np. pierwszy z listy lub polski)
        _currentLanguage = _languages.firstWhere((l) => l.isoCode == 'pl', orElse: () => _languages.first);
        _currentCurrency = _currencies.firstWhere((c) => c.isoCode == 'PLN', orElse: () => _currencies.first);
      }
    } catch (e) {
      debugPrint('Localization Load Error: $e');
      // Backup/Default values
      _languages = [LanguageModel(id: 1, name: 'Polski', isoCode: 'pl', languageCode: 'pl')];
      _currencies = [CurrencyModel(id: 1, name: 'Złoty', isoCode: 'PLN', symbol: 'zł', conversionRate: 1.0)];
      _currentLanguage = _languages.first;
      _currentCurrency = _currencies.first;
    }
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

  // Formatowanie ceny z uwzględnieniem wybranej waluty i jej kursu
  String formatPrice(double price) {
    if (_currentCurrency == null) return '${price.toStringAsFixed(2)} PLN';
    
    // PrestaShop przesyła ceny w walucie domyślnej (zazwyczaj PLN lub EUR)
    // Jeśli użytkownik wybrał inną walutę, przeliczamy ją wg kursu z Presty
    double converted = price * _currentCurrency!.conversionRate;
    return '${converted.toStringAsFixed(2)} ${_currentCurrency!.symbol}';
  }
}

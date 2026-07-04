import 'package:flutter/material.dart';
import 'package:pharos/data/models/localization_models.dart';
import '../network/api_service.dart';

class LocalizationProvider extends ChangeNotifier {
  final ApiService _apiService;

  LocalizationProvider({ApiService? apiService})
      : _apiService = apiService ?? ApiService() {
    _loadFromPrestaShop();
  }
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

  Locale get locale {
    final languageCode = _currentLanguage?.languageCode ?? 'pl';
    return Locale(languageCode.split('-').first);
  }

  String get currentLanguageCode => _currentLanguage?.languageCode ?? 'pl';

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

        final int serverLangId = int.tryParse(locData['current_language_id']?.toString() ?? '') ?? 0;
        final int serverCurrId = int.tryParse(locData['current_currency_id']?.toString() ?? '') ?? 0;

        if (_languages.isNotEmpty) {
          // Senior Fix: Zachowujemy aktualny język jeśli już był wybrany, 
          // w przeciwnym razie bierzemy z serwera.
          if (_currentLanguage != null) {
             _currentLanguage = _languages.firstWhere(
              (l) => l.id == _currentLanguage!.id,
              orElse: () => _languages.first,
            );
          } else {
            _currentLanguage = _languages.firstWhere(
              (l) => l.id == serverLangId,
              orElse: () => _languages.first,
            );
          }

          if (_currentLanguage != null) {
            ApiService.defaultLanguageId = _currentLanguage!.id;
          }
        }

        if (_currencies.isNotEmpty) {
          _currentCurrency = _currencies.firstWhere(
            (c) => c.id == serverCurrId,
            orElse: () => _currencies.first,
          );
        }
      }
    } catch (e) {
      debugPrint('Localization Load Error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> setLanguage(LanguageModel lang) async {
    debugPrint('Switching language to: ${lang.name} (${lang.languageCode})');
    _currentLanguage = lang;
    ApiService.defaultLanguageId = lang.id;
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

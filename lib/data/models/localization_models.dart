class LanguageModel {
  final int id;
  final String name;
  final String isoCode;
  final String languageCode; // np. 'pl', 'en'

  LanguageModel({
    required this.id,
    required this.name,
    required this.isoCode,
    required this.languageCode,
  });

  factory LanguageModel.fromJson(Map<String, dynamic> json) {
    return LanguageModel(
      id: int.parse(json['id'].toString()),
      name: json['name'],
      isoCode: json['iso_code'],
      languageCode: json['language_code']?.split('-')[0] ?? 'pl',
    );
  }
}

class CurrencyModel {
  final int id;
  final String name;
  final String isoCode; // np. 'PLN', 'EUR'
  final String symbol;
  final double conversionRate;

  CurrencyModel({
    required this.id,
    required this.name,
    required this.isoCode,
    required this.symbol,
    required this.conversionRate,
  });

  factory CurrencyModel.fromJson(Map<String, dynamic> json) {
    return CurrencyModel(
      id: int.parse(json['id'].toString()),
      name: json['name'],
      isoCode: json['iso_code'],
      symbol: json['symbol'] ?? json['iso_code'],
      conversionRate: double.parse(json['conversion_rate'].toString()),
    );
  }
}

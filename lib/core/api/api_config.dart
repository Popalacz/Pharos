import 'dart:convert';

class ApiConfig {
  /// KLUCZOWY PRZEŁĄCZNIK: 
  /// true  -> Aplikacja używa danych mockupowych (Google/Mock) - działa bez internetu/backendu.
  /// false -> Aplikacja łączy się z Twoim PrestaShop (Live).
  static const bool forceMockData = false;

  static const String mockProductsJsonAssetPath =
      'assets/mock/products_api_response.json';

  /// Konfiguracja połączenia z PrestaShop
  static const String baseUrl = 'https://pharos-api.tech/api';
  static const String apiKey = 'PHAROS00008RLIS6EBBLYEYGUPP1XPFA';


  static Map<String, String> get headers {
    final String basicAuth = 'Basic ${base64Encode(utf8.encode('$apiKey:'))}';

    return {
      'Authorization': basicAuth,
      'Output-Format': 'JSON',
      'Content-Type': 'application/json',
    };
  }
}
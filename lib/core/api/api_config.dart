import 'dart:convert';

class ApiConfig {
  static const bool forceMockData = false;
  static const String mockProductsJsonAssetPath = 'assets/mock/products_api_response.json';

  static const String baseUrl = String.fromEnvironment(
    'PHAROS_API_BASE_URL',
    defaultValue: 'https://pharos-api.tech/api',
  );

  static const String apiKey = String.fromEnvironment(
    'PHAROS_API_KEY',
    defaultValue: 'PHAROS00008RLIS6EBBLYEYGUPP1XPFA',
  );

  static Map<String, String> get headers {
    final String basicAuth = 'Basic ${base64Encode(utf8.encode('$apiKey:'))}';
    return {
      'Authorization': basicAuth,
      'Output-Format': 'JSON',
      'Content-Type': 'application/json',
    };
  }
}

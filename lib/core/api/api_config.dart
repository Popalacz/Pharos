import 'dart:convert';

class ApiConfig {
  static const bool forceMockData = false;
  static const String mockProductsJsonAssetPath = 'assets/mock/products_api_response.json';

  /// PrestaShop WebService base (always `/api` on production).
  static const String baseUrl = String.fromEnvironment(
    'PHAROS_API_BASE_URL',
    defaultValue: 'https://pharos-api.tech/api',
  );

  /// Shop origin without `/api` suffix (module routes: `/index.php`, images, etc.).
  static const String originUrl = String.fromEnvironment(
    'PHAROS_API_ORIGIN_URL',
    defaultValue: 'https://pharos-api.tech',
  );

  static const String apiKey = String.fromEnvironment(
    'PHAROS_API_KEY',
    defaultValue: '',
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

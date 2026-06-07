import 'dart:convert';

class ApiConfig {
  static const bool useMockProductsJson = false;

  static const String mockProductsJsonAssetPath =
      'assets/mock/products_api_response.json';

  // static const String baseUrl = 'http://localhost:8111/api';
  // static const String apiKey = 'NVDCB76VU3UTJFY5GMXPFE7RGIFZ8LNS';

  /// PrestaShop Web Services base (path must end with `/api`).
  static const String baseUrl = 'http://localhost:8112/api';

  /// Use when the emulator/device cannot reach `localhost` (e.g. Docker on host).
  // static const String baseUrl = 'http://172.30.123.47:8112/api';

  // static const String apiKey = 'PHAROS00008RLIS6EBBLYEYGUPP1XPFA'; // Presta base
  static const String apiKey = 'PHAROS00008RLIS6EBBLYEYGUPP1XPFA'; // HMP


  static Map<String, String> get headers {
    final String basicAuth = 'Basic ${base64Encode(utf8.encode('$apiKey:'))}';

    return {
      'Authorization': basicAuth,
      'Output-Format': 'JSON',
      'Content-Type': 'application/json',
    };
  }
}
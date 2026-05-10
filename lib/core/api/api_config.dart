class ApiConfig {
  /// Gdy [true] — lista produktów jest wczytywana z lokalnego JSON-a (backup jak z API),
  /// bez wywołania sieci. Ustaw na [false], gdy backend jest dostępny.
  static const bool useMockProductsJson = true;

  static const String mockProductsJsonAssetPath =
      'assets/mock/products_api_response.json';

  // static const String baseUrl = 'http://localhost:8111/api';
  // static const String apiKey = 'NVDCB76VU3UTJFY5GMXPFE7RGIFZ8LNS';

  static const String baseUrl = 'http://localhost:8007/api';
  static const String apiKey = 'PHAROS0000PKY3M59VKK41RCSRP7TSFP';

  static Map<String, String> get headers => {
    'Authorization': 'Basic ${Uri.encodeComponent(apiKey)}:', // Presta wymaga ":" na końcu
    'Output-Format': 'JSON',
  };
}
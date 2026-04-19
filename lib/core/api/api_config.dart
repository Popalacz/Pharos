class ApiConfig {
  static const String baseUrl = 'http://localhost:8111/api';
  static const String apiKey = 'NVDCB76VU3UTJFY5GMXPFE7RGIFZ8LNS';
  

  static Map<String, String> get headers => {
    'Authorization': 'Basic ${Uri.encodeComponent(apiKey)}:', // Presta wymaga ":" na końcu
    'Output-Format': 'JSON',
  };
}
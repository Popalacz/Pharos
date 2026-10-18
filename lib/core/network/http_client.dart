import 'package:dio/dio.dart';

/// Jedno miejsce konfiguracji klienta HTTP (limity czasu, nagłówki).
Dio createHttpClient({String? baseUrl, Map<String, dynamic>? headers}) {
  return Dio(BaseOptions(
    baseUrl: baseUrl ?? '',
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
    headers: headers,
  ));
}

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  final Dio dio;
  static const String baseUrl = 'https://pharos-shop.pl/api';
  static const String apiKey = 'TWÓJ_KLUCZ_API'; // Docelowo z .env

  ApiService() : dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    queryParameters: {'output_format': 'JSON'},
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  )) {
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // Autoryzacja PrestaShop (Basic Auth lub Token)
        options.headers['Authorization'] = 'Basic ${base64Encode(utf8.encode('$apiKey:'))}';
        return handler.next(options);
      },
      onError: (e, handler) {
        debugPrint('API ERROR: ${e.message}');
        return handler.next(e);
      },
    ));
    
    if (kDebugMode) {
      dio.interceptors.add(LogInterceptor(responseBody: true, requestBody: true));
    }
  }
}
import 'dart:convert';

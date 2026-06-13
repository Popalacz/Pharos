import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  final Dio dio;
  static const String baseUrl = 'https://pharos-shop.pl/api';
  static const String apiKey = 'TWÓJ_KLUCZ_API'; // Docelowo z .env

  ApiService() : dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    queryParameters: {'output_format': 'JSON'},
    connectTimeout: const Duration(seconds: 5), // Szybszy feedback dla użytkownika
    receiveTimeout: const Duration(seconds: 5),
    headers: {
      'Accept': 'application/json',
      'X-Pharos-Platform': 'mobile-flutter',
    },
  )) {
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        options.headers['Authorization'] = 'Basic ${base64Encode(utf8.encode('$apiKey:'))}';
        return handler.next(options);
      },
      onResponse: (response, handler) {
        // Tu można dodać cache'owanie odpowiedzi dla poprawy wydajności
        return handler.next(response);
      },
      onError: (e, handler) {
        if (e.type == DioExceptionType.connectionTimeout) {
          debugPrint('API Timeout - Sprawdź połączenie');
        }
        return handler.next(e);
      },
    ));
    
    if (kDebugMode) {
      dio.interceptors.add(LogInterceptor(responseBody: true, requestBody: true));
    }
  }
}
import 'dart:convert';

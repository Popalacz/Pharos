import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  final Dio dio;
  
  // TWÓJ PRODUKCYJNY ENDPOINT NA SEOHOST
  static const String prodUrl = 'https://pharos-api.tech';
  
  static const String apiKey = 'PHAROS00008RLIS6EBBLYEYGUPP1XPFA';

  ApiService() : dio = Dio(BaseOptions(
    baseUrl: prodUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
    headers: {
      'Accept': 'application/json',
      'X-Pharos-Platform': 'mobile-flutter',
      'X-Pharos-Device': kIsWeb ? 'web' : defaultTargetPlatform.name.toLowerCase(),
    },
  )) {
    
    // Ominięcie weryfikacji certyfikatu SSL dla fazy deweloperskiej (Senior Debug)
    if (!kIsWeb) {
      (dio.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate = (client) {
        client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
        return client;
      };
    }

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // Zawsze żądamy formatu JSON od PrestaShop
        options.queryParameters['output_format'] = 'JSON';

        // Autoryzacja przez Basic Auth (Klucz : puste hasło)
        options.headers['Authorization'] = 'Basic ${base64Encode(utf8.encode('$apiKey:'))}';

        return handler.next(options);
      },
      onError: (e, handler) {
        debugPrint('--- PHAROS PRODUCTION API ERROR ---');
        debugPrint('URL: ${e.requestOptions.uri}');
        debugPrint('Status: ${e.response?.statusCode}');
        debugPrint('Error Type: ${e.type}');
        debugPrint('Message: ${e.message}');
        return handler.next(e);
      },
    ));
    
    if (kDebugMode) {
      dio.interceptors.add(LogInterceptor(
        responseBody: true, 
        requestBody: true,
        requestHeader: true,
      ));
    }
  }
}

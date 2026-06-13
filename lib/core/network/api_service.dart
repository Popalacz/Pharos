import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  final Dio dio;
  
  // KONFIGURACJA DLA WAMP / LOCALHOST
  // Jeśli używasz emulatora Android: 10.0.2.2
  // Jeśli używasz fizycznego urządzenia: wpisz IP komputera (np. 192.168.1.XX)
  // Jeśli PrestaShop jest w podfolderze, dodaj go: 'http://10.0.2.2/presta-folder'
  static const String localUrl = 'http://10.0.2.2'; 
  static const String prodUrl = 'https://pharos-shop.pl';
  
  static const String apiKey = 'PHAROS00008RLIS6EBBLYEYGUPP1XPFA';

  ApiService() : dio = Dio(BaseOptions(
    baseUrl: kDebugMode ? localUrl : prodUrl,
    queryParameters: {'output_format': 'JSON'},
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
    headers: {
      'Accept': 'application/json',
      'X-Pharos-Platform': 'mobile-flutter',
      'X-Pharos-Device': kIsWeb ? 'web' : defaultTargetPlatform.name.toLowerCase(),
    },
  )) {
    
    // Bypass SSL dla WAMP (self-signed certificates)
    if (kDebugMode && !kIsWeb) {
      (dio.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate = (client) {
        client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
        return client;
      };
    }

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        options.headers['Authorization'] = 'Basic ${base64Encode(utf8.encode('$apiKey:'))}';
        return handler.next(options);
      },
      onError: (e, handler) {
        debugPrint('--- PHAROS API ERROR ---');
        debugPrint('Full URL: ${e.requestOptions.uri}');
        debugPrint('Status: ${e.response?.statusCode}');
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

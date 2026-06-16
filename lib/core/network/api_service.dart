import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../api/api_config.dart';

class ApiService {
  final Dio dio;
  static String? _sessionCookie; 
  
  static void clearSession() {
    _sessionCookie = null;
    debugPrint('SESSION: Cleared session cookie');
  }
  
  // Pobieramy czysty host bez /api
  static String get baseUrl => ApiConfig.baseUrl.split('/api').first;
  static String get apiKey => ApiConfig.apiKey;

  ApiService() : dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
    headers: {
      'Accept': 'application/json',
      'X-Pharos-Platform': 'mobile-flutter',
    },
  )) {
    
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // Logika ścieżek
        if (!options.path.contains('index.php') && !options.path.startsWith('/api')) {
           options.path = '/api${options.path.startsWith('/') ? '' : '/'}${options.path}';
        }

        // Webservice (/api) wymaga ws_key LUB Authorization. 
        // Twój test w przeglądarce potwierdził, że ws_key działa najlepiej.
        if (options.path.contains('/api/')) {
          options.queryParameters['output_format'] = 'JSON';
          options.queryParameters['ws_key'] = apiKey;
          options.headers.remove('Authorization'); 
        } else {
          // Zapytania do MODUŁU (index.php) NIE MOGĄ mieć Authorization Basic
          options.headers.remove('Authorization');
        }
        
        if (_sessionCookie != null) {
          options.headers['Cookie'] = _sessionCookie;
        }

        return handler.next(options);
      },
      onResponse: (response, handler) {
        final cookies = response.headers['set-cookie'];
        if (cookies != null && cookies.isNotEmpty) {
          _sessionCookie = cookies.first.split(';').first;
        }
        return handler.next(response);
      },
      onError: (e, handler) {
        debugPrint('API ERROR: ${e.message}');
        return handler.next(e);
      },
    ));
    
    if (kDebugMode) {
      dio.interceptors.add(LogInterceptor(responseBody: true, requestHeader: true));
    }
  }
}

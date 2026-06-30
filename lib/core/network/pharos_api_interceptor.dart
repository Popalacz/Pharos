import 'package:dio/dio.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:pharos/core/api/api_config.dart';
import 'package:pharos/core/network/api_service.dart';

class PharosApiInterceptor extends Interceptor {
  PharosApiInterceptor({this.cartId});

  int? cartId;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (!options.path.contains('index.php') && !options.path.startsWith('/api')) {
      options.path = '/api${options.path.startsWith('/') ? '' : '/'}${options.path}';
    }

    if (options.path.contains('/api/')) {
      options.queryParameters['output_format'] = 'JSON';
      options.queryParameters['ws_key'] = ApiConfig.apiKey;
      if (!options.queryParameters.containsKey('language')) {
        options.queryParameters['language'] = ApiService.defaultLanguageId.toString();
      }
    }

    if (options.path.contains('index.php') || options.path.contains('pharosapi')) {
      options.headers['Authorization'] = ApiConfig.headers['Authorization'];
    }

    if (ApiService.sessionCookie != null) {
      options.headers['Cookie'] = ApiService.sessionCookie;
    }

    if (cartId != null && cartId! > 0) {
      options.headers['X-Pharos-Cart-Id'] = cartId.toString();
    }

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (response.data is String) {
      final rawData = response.data as String;
      final jsonStart = rawData.indexOf('{');
      final jsonArrayStart = rawData.indexOf('[');
      int start = -1;

      if (jsonStart != -1 && jsonArrayStart != -1) {
        start = jsonStart < jsonArrayStart ? jsonStart : jsonArrayStart;
      } else {
        start = jsonStart != -1 ? jsonStart : jsonArrayStart;
      }

      if (start != -1) {
        try {
          response.data = ApiService.decodeJson(rawData.substring(start));
        } catch (e) {
          debugPrint('API JSON Clean Error: $e');
        }
      }
    }

    final cookies = response.headers['set-cookie'];
    if (cookies != null && cookies.isNotEmpty) {
      ApiService.setSessionCookie(cookies.first.split(';').first);
    }

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint('--- API ERROR ---');
    debugPrint('Path: ${err.requestOptions.path}');
    debugPrint('Type: ${err.type}');
    debugPrint('Message: ${err.message}');

    final statusCode = err.response?.statusCode;
    if (statusCode != null) {
      debugPrint('Status Code: $statusCode');
      debugPrint('Data: ${err.response?.data}');
    }

    if (statusCode == 401 || statusCode == 403 || statusCode == 500) {
      FirebaseCrashlytics.instance.recordError(
        err,
        err.stackTrace,
        reason: 'API $statusCode: ${err.requestOptions.path}',
        fatal: false,
      );
    }

    handler.next(err);
  }
}

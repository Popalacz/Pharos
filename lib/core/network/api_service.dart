import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';
import '../api/api_config.dart';
import '../error/failures.dart';

class ApiService {
  late final Dio dio;
  static String? _sessionCookie;
  
  static void clearSession() {
    _sessionCookie = null;
  }

  static int defaultLanguageId = 1;

  ApiService() {
    dio = Dio(BaseOptions(
      baseUrl: ApiConfig.baseUrl.split('/api').first,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Accept': 'application/json',
        'X-Pharos-Platform': 'mobile-flutter',
      },
    ));
    
    (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      final client = HttpClient();
      client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
      return client;
    };

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // Obsługa ścieżek API vs custom controllers
        if (!options.path.contains('index.php') && !options.path.startsWith('/api')) {
           options.path = '/api${options.path.startsWith('/') ? '' : '/'}${options.path}';
        }

        // Dodawanie parametrów specyficznych dla PrestaShop WebService
        if (options.path.contains('/api/')) {
          options.queryParameters['output_format'] = 'JSON';
          options.queryParameters['ws_key'] = ApiConfig.apiKey;
          
          if (!options.queryParameters.containsKey('language')) {
            options.queryParameters['language'] = defaultLanguageId.toString();
          }
        }
        
        if (_sessionCookie != null) {
          options.headers['Cookie'] = _sessionCookie;
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        // Defensive parsing for PrestaShop: 
        // PrestaShop sometimes returns text warnings before JSON
        if (response.data is String) {
          final String rawData = response.data;
          final int jsonStart = rawData.indexOf('{');
          final int jsonArrayStart = rawData.indexOf('[');
          int start = -1;
          
          if (jsonStart != -1 && jsonArrayStart != -1) {
            start = jsonStart < jsonArrayStart ? jsonStart : jsonArrayStart;
          } else {
            start = jsonStart != -1 ? jsonStart : jsonArrayStart;
          }
          
          if (start != -1) {
             try {
               response.data = jsonDecode(rawData.substring(start));
             } catch (e) {
               debugPrint('API JSON Clean Error: $e');
             }
          }
        }

        final cookies = response.headers['set-cookie'];
        if (cookies != null && cookies.isNotEmpty) {
          _sessionCookie = cookies.first.split(';').first;
        }
        return handler.next(response);
      },
      onError: (e, handler) {
        // Zapewniamy, że błąd jest zalogowany i nie "wybucha" niespodziewanie
        debugPrint('--- API ERROR ---');
        debugPrint('Path: ${e.requestOptions.path}');
        debugPrint('Type: ${e.type}');
        debugPrint('Message: ${e.message}');
        if (e.response != null) {
          debugPrint('Status Code: ${e.response?.statusCode}');
          debugPrint('Data: ${e.response?.data}');
        }
        return handler.next(e);
      },
    ));
  }

  /// Wykonuje żądanie GET w sposób bezpieczny, zwracając Either<Failure, T>
  /// Gwarantuje brak rzucanych wyjątków DioException.
  Future<Either<Failure, T>> getSafe<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    required T Function(dynamic json) mapper,
  }) async {
    try {
      final response = await dio.get(path, queryParameters: queryParameters, options: options);
      return Right(mapper(response.data));
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ParsingFailure('Mapping error: $e'));
    }
  }

  /// Wykonuje żądanie POST w sposób bezpieczny, zwracając Either<Failure, T>
  Future<Either<Failure, T>> postSafe<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    required T Function(dynamic json) mapper,
  }) async {
    try {
      final response = await dio.post(path, data: data, queryParameters: queryParameters, options: options);
      return Right(mapper(response.data));
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ParsingFailure('Mapping error: $e'));
    }
  }

  Failure _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return const NetworkFailure();
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final dynamic data = e.response?.data;
        
        // Próba wyciągnięcia błędu z odpowiedzi PrestaShop
        String message = 'Błąd serwera ($statusCode)';
        if (data is Map) {
          message = data['message'] ?? data['error'] ?? message;
          if (data['errors'] is List && (data['errors'] as List).isNotEmpty) {
            message = data['errors'][0].toString();
          }
        }
        
        if (statusCode == 401 || statusCode == 403) {
          return AuthFailure(message);
        }
        return ServerFailure(message, code: statusCode);
      default:
        return ServerFailure('Problem z połączeniem: ${e.message}');
    }
  }
}



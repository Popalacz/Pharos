import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';
import '../api/api_config.dart';
import '../error/failures.dart';
import 'pharos_api_interceptor.dart';

class ApiService {
  late final Dio dio;
  PharosApiInterceptor? _apiInterceptor;

  static String? _sessionCookie;
  static String? get sessionCookie => _sessionCookie;

  static void setSessionCookie(String? cookie) {
    _sessionCookie = cookie;
  }

  static void clearSession() {
    _sessionCookie = null;
  }

  static int defaultLanguageId = 1;

  static dynamic decodeJson(String source) => jsonDecode(source);

  ApiService() {
    dio = Dio(BaseOptions(
      baseUrl: ApiConfig.originUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Accept': 'application/json',
        'X-Pharos-Platform': 'mobile-flutter',
      },
    ));

    if (kDebugMode) {
      debugPrint('Pharos API origin: ${ApiConfig.originUrl}');
      debugPrint('Pharos API webservice: ${ApiConfig.baseUrl}');
    }

    (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      final client = HttpClient();
      client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
      return client;
    };

    _apiInterceptor = PharosApiInterceptor();
    dio.interceptors.add(_apiInterceptor!);
  }

  void updateCartId(int? cartId) {
    if (_apiInterceptor != null) {
      _apiInterceptor!.cartId = cartId;
    }
  }

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

  Future<Either<Failure, T>> postSafe<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    dynamic data,
    Options? options,
    required T Function(dynamic json) mapper,
  }) async {
    try {
      final response = await dio.post(
        path,
        queryParameters: queryParameters,
        data: data,
        options: options,
      );
      return Right(mapper(response.data));
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ParsingFailure('Mapping error: $e'));
    }
  }

  Failure _handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return const NetworkFailure();
    }

    final statusCode = e.response?.statusCode;
    final message = e.response?.data is Map
        ? (e.response?.data['message'] ?? e.response?.data['error'] ?? 'Server error').toString()
        : (e.message ?? 'Server error');

    if (statusCode == 401 || statusCode == 403) {
      return AuthFailure(message);
    }

    return ServerFailure(message, code: statusCode);
  }
}

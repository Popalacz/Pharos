import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';

import '../core/api/api_config.dart';
import '../models/product_model.dart';

class PrestaApiService {
  final Dio _dio;

  PrestaApiService({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: ApiConfig.baseUrl,
                connectTimeout: const Duration(seconds: 10),
                receiveTimeout: const Duration(seconds: 10),
                headers: {
                  'Authorization':
                      'Basic ${base64Encode(utf8.encode('${ApiConfig.apiKey}:'))}',
                },
              ),
            );

  Future<List<Product>> getProducts() async {
    if (ApiConfig.useMockProductsJson) {
      try {
        final String jsonString =
            await rootBundle.loadString(ApiConfig.mockProductsJsonAssetPath);
        final Object? decoded = json.decode(jsonString);

        if (decoded is! Map<String, dynamic>) {
          return const [];
        }

        return _mapProductsFromPayload(decoded);
      } catch (e) {
        throw Exception('Błąd podczas ładowania lokalnego JSON-a: $e');
      }
    }

    try {
      final response = await _dio.get<Object>('/products', queryParameters: {
        'display': 'full',
        'output_format': 'JSON',
      });

      final Map<String, dynamic>? payload =
          _decodeResponseBodyToMap(response.data);

      if (payload != null && payload['products'] != null) {
        return _mapProductsFromPayload(payload);
      }

      return const [];
    } on DioException catch (e) {
      throw Exception('Problem z połączeniem z serwerem: ${e.message}');
    } catch (e) {
      throw Exception('Błąd podczas przetwarzania danych: $e');
    }
  }

  Map<String, dynamic>? _decodeResponseBodyToMap(Object? data) {
    if (data == null) return null;
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);

    if (data is String) {
      final Object? decoded = json.decode(data);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    }

    return null;
  }

  List<Product> _mapProductsFromPayload(Map<String, dynamic> payload) {
    final Object? rawProducts = payload['products'];
    if (rawProducts == null) return const [];

    List<dynamic> productList = [];
    if (rawProducts is List) {
      productList = rawProducts;
    } else if (rawProducts is Map) {
      productList = [rawProducts];
    }

    return productList.map((item) {
      final Map<String, dynamic> itemMap = item is Map
          ? Map<String, dynamic>.from(item)
          : const <String, dynamic>{};
      return Product.fromJson(itemMap);
    }).toList();
  }
}
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';

import '../core/api/api_config.dart';
import '../models/product_model.dart';

class PrestaApiService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: ApiConfig.baseUrl,
    headers: {
      'Authorization':
          'Basic ${base64Encode(utf8.encode('${ApiConfig.apiKey}:'))}',
    },
  ));

  Future<List<Product>> getProducts() async {
    if (ApiConfig.useMockProductsJson) {
      try {
        final String jsonString =
            await rootBundle.loadString(ApiConfig.mockProductsJsonAssetPath);
        final Object? decoded = json.decode(jsonString);

        if (decoded is! Map<String, dynamic>) {
          return [];
        }

        return _mapProductsFromPayload(decoded);
      } catch (e) {
        throw Exception('Błąd podczas ładowania lokalnego JSON-a: $e');
      }
    }

    try {
      final response = await _dio.get('/products', queryParameters: {
        'display': 'full',
        'output_format': 'JSON',
      });

      if (response.data != null && response.data['products'] != null) {
        return _mapProductsFromPayload(
          Map<String, dynamic>.from(response.data as Map),
        );
      }

      return [];
    } on DioException catch (e) {
      throw Exception('Problem z połączeniem z serwerem: ${e.message}');
    } catch (e) {
      throw Exception('Błąd podczas przetwarzania danych: $e');
    }
  }

  List<Product> _mapProductsFromPayload(Map<String, dynamic> payload) {
    final Object? rawProducts = payload['products'];

    if (rawProducts == null) {
      return [];
    }

    List<dynamic> productList = [];

    if (rawProducts is List) {
      productList = rawProducts;
    } else if (rawProducts is Map) {
      productList = [rawProducts];
    }

    return productList
        .map((item) => Product.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }
}
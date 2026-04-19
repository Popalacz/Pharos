import 'package:dio/dio.dart';
import '../core/api/api_config.dart';
import '../models/product_model.dart';
import 'dart:convert';

class PrestaApiService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: ApiConfig.baseUrl,
    headers: {
      'Authorization': 'Basic ${base64Encode(utf8.encode('${ApiConfig.apiKey}:'))}',
    },
  ));

  Future<List<Product>> getProducts() async {
    try {
      final response = await _dio.get('/products', queryParameters: {
        'display': 'full',
        'output_format': 'JSON',
      });

      if (response.data != null && response.data['products'] != null) {
        final List data = response.data['products'];
        return data.map((item) => Product.fromJson(item)).toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception('Problem z połączeniem z serwerem: ${e.message}');
    }
  }
}
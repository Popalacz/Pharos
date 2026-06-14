import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import '../../core/network/api_service.dart';
import '../models/product_model.dart';

abstract class IProductRepository {
  Future<List<ProductModel>> getProducts({int? categoryId});
  Future<List<ProductModel>> searchProducts(String query);
}

class ProductRepository implements IProductRepository {
  final ApiService _apiService = ApiService();
  final bool useMockData;

  ProductRepository({this.useMockData = false});

  @override
  Future<List<ProductModel>> getProducts({int? categoryId}) async {
    if (useMockData) {
      return _loadMockData();
    }
    
    try {
      final Map<String, dynamic> params = {
        'display': 'full',
        'limit': '50',
      };

      if (categoryId != null) {
        params['filter[id_category_default]'] = '[$categoryId]';
      }

      final response = await _apiService.dio.get('/api/products', queryParameters: params);
      final dynamic rawData = response.data['products'];
      
      if (rawData == null || rawData == '') return [];
      if (rawData is Map) return [ProductModel.fromJson(rawData as Map<String, dynamic>)];
      if (rawData is List) return rawData.map((json) => ProductModel.fromJson(json)).toList();
      
      return [];
    } catch (e) {
      debugPrint('LIVE Product Fetch Error: $e');
      return []; 
    }
  }

  @override
  Future<List<ProductModel>> searchProducts(String query) async {
    try {
      final response = await _apiService.dio.get('/api/products', queryParameters: {
        'display': 'full',
        'filter[name]': '%$query%',
      });
      
      final dynamic rawData = response.data['products'];
      if (rawData == null || rawData == '') return [];
      if (rawData is Map) return [ProductModel.fromJson(rawData as Map<String, dynamic>)];
      if (rawData is List) return rawData.map((json) => ProductModel.fromJson(json)).toList();
      
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<ProductModel>> _loadMockData() async {
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      final String response = await rootBundle.loadString('assets/mock/products_api_response.json');
      final data = await json.decode(response);
      return (data['products'] as List)
          .map((e) => ProductModel.fromJson(e))
          .toList();
    } catch (e) {
      return [];
    }
  }
}

import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import '../../core/network/api_service.dart';
import '../models/product_model.dart';

abstract class IProductRepository {
  Future<List<ProductModel>> getProducts({int? categoryId, Map<String, List<String>>? filters});
  Future<List<ProductModel>> searchProducts(String query, {Map<String, List<String>>? filters});
}

class ProductRepository implements IProductRepository {
  final ApiService _apiService = ApiService();
  final bool useMockData;

  ProductRepository({this.useMockData = false});

  @override
  Future<List<ProductModel>> getProducts({int? categoryId, Map<String, List<String>>? filters}) async {
    if (useMockData) {
      return _loadMockData();
    }
    
    try {
      final Map<String, dynamic> params = {
        'display': 'full',
        'limit': '100', // Zwiększamy limit dla Seniora
        'date': DateTime.now().millisecondsSinceEpoch.toString(), 
      };

      // Zawsze dodajemy sortowanie po ID malejąco, by widzieć najnowsze produkty
      params['sort'] = '[id_DESC]';

      if (categoryId != null) {
        params['filter[id_category_default]'] = '[$categoryId]';
      }

      // Integracja z filtrami (Advanced Faceted Search)
      if (filters != null && filters.isNotEmpty) {
        filters.forEach((key, values) {
          if (values.isNotEmpty) {
            params['filter[$key]'] = '[${values.join('|')}]';
          }
        });
      }

      final response = await _apiService.dio.get('/api/products', queryParameters: params);
      
      if (kDebugMode) {
        debugPrint('API PRODUCT DATA SAMPLE: ${response.data.toString().substring(0, response.data.toString().length > 500 ? 500 : response.data.toString().length)}');
      }

      final dynamic rawData = response.data['products'];
      
      if (rawData == null || rawData == '') return [];
      
      List productsJson = [];
      if (rawData is List) {
        productsJson = rawData;
      } else if (rawData is Map) {
        productsJson = [rawData];
      }
      
      return productsJson.map((json) => ProductModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('LIVE Product Fetch Error: $e');
      return []; 
    }
  }

  @override
  Future<List<ProductModel>> searchProducts(String query, {Map<String, List<String>>? filters}) async {
    try {
      final Map<String, dynamic> params = {
        'display': 'full',
        'filter[name]': '%$query%',
      };

      if (filters != null && filters.isNotEmpty) {
        filters.forEach((key, values) {
          if (values.isNotEmpty) {
            params['filter[$key]'] = '[${values.join('|')}]';
          }
        });
      }

      final response = await _apiService.dio.get('/api/products', queryParameters: params);
      
      final dynamic rawData = response.data['products'];
      if (rawData == null || rawData == '') return [];
      
      List productsJson = [];
      if (rawData is List) {
        productsJson = rawData;
      } else if (rawData is Map) {
        productsJson = [rawData];
      }
      
      return productsJson.map((json) => ProductModel.fromJson(json)).toList();
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

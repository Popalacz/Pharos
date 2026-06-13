import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import '../../core/network/api_service.dart';
import '../models/product_model.dart';

abstract class IProductRepository {
  Future<List<ProductModel>> getProducts();
  Future<List<ProductModel>> searchProducts(String query);
}

class ProductRepository implements IProductRepository {
  final ApiService _apiService = ApiService();
  final bool useMockData;

  ProductRepository({this.useMockData = false});

  @override
  Future<List<ProductModel>> getProducts() async {
    if (useMockData) {
      return _loadMockData();
    }
    
    try {
      // Pobieranie listy produktów z natywnego API PrestaShop
      final response = await _apiService.dio.get('/api/products', queryParameters: {
        'display': 'full',
        'limit': '20',
      });
      
      final List productsJson = response.data['products'] ?? [];
      return productsJson.map((json) => ProductModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('PrestaShop Product Fetch Error: $e');
      return _loadMockData(); // Backup data for better UX (UAT 6.2)
    }
  }

  @override
  Future<List<ProductModel>> searchProducts(String query) async {
    if (useMockData) {
      final allProducts = await _loadMockData();
      return allProducts.where((p) => 
        p.name.toLowerCase().contains(query.toLowerCase()) || 
        p.description.toLowerCase().contains(query.toLowerCase())
      ).toList();
    }

    try {
      // Wyszukiwanie produktów z parametrem filtra
      final response = await _apiService.dio.get('/api/products', queryParameters: {
        'display': 'full',
        'filter[name]': '%$query%',
      });
      
      final List productsJson = response.data['products'] ?? [];
      return productsJson.map((json) => ProductModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Search Error: $e');
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

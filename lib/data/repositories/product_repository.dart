import '../models/product_model.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

abstract class IProductRepository {
  Future<List<ProductModel>> getProducts();
  Future<List<ProductModel>> searchProducts(String query);
}

class ProductRepository implements IProductRepository {
  final bool useMockData;

  ProductRepository({this.useMockData = true});

  @override
  Future<List<ProductModel>> getProducts() async {
    if (useMockData) {
      return _loadMockData();
    }
    // ... PrestaShop implementation
    return _loadMockData();
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
    // Tu docelowo wywołanie dio.get('/products', queryParameters: {'filter[name]': '%$query%'})
    return [];
  }

  Future<List<ProductModel>> _loadMockData() async {
    // Symulacja opóźnienia sieci dla testu Shimmer Effect
    await Future.delayed(const Duration(seconds: 2));
    
    final String response = await rootBundle.loadString('assets/mock/products_api_response.json');
    final data = await json.decode(response);
    
    return (data['products'] as List)
        .map((e) => ProductModel.fromJson(e))
        .toList();
  }
}

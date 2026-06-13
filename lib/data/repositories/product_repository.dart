import '../models/product_model.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

abstract class IProductRepository {
  Future<List<ProductModel>> getProducts();
}

class ProductRepository implements IProductRepository {
  final bool useMockData;

  ProductRepository({this.useMockData = true});

  @override
  Future<List<ProductModel>> getProducts() async {
    if (useMockData) {
      return _loadMockData();
    }
    
    try {
      // Tu docelowo będzie wywołanie Dio do PrestaShop
      // return await _fetchFromPrestaShop();
      return _loadMockData(); 
    } catch (e) {
      return _loadMockData(); // Backup w razie błędu sieci
    }
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

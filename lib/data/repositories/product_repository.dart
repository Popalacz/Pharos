import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';
import '../../core/network/api_service.dart';
import '../../core/error/failures.dart';
import '../models/product_model.dart';

abstract class IProductRepository {
  Future<Either<Failure, List<ProductModel>>> getProducts({int? categoryId, Map<String, List<String>>? filters});
  Future<Either<Failure, List<ProductModel>>> searchProducts(String query, {Map<String, List<String>>? filters});
  Future<Either<Failure, ProductModel>> getProductDetails(int productId);
}

class ProductRepository implements IProductRepository {
  final ApiService _apiService;
  final bool useMockData;

  ProductRepository({ApiService? apiService, this.useMockData = false}) 
    : _apiService = apiService ?? ApiService();

  @override
  Future<Either<Failure, List<ProductModel>>> getProducts({int? categoryId, Map<String, List<String>>? filters}) async {
    if (useMockData) return Right(await _loadMockData());
    
    final Map<String, dynamic> params = {
      'fc': 'module',
      'module': 'pharosapi',
      'controller': 'products',
      'action': 'list',
      'limit': '24',
    };

    if (categoryId != null) {
      params['id_category'] = categoryId.toString();
    }

    return _apiService.getSafe(
      '/index.php',
      queryParameters: params,
      mapper: (json) {
        if (json is Map && json['status'] == 'success') {
          final List rawList = json['data'] ?? [];
          return rawList.map((j) => ProductModel.fromJson(j)).toList();
        }
        throw Exception('Invalid API response structure');
      },
    );
  }

  @override
  Future<Either<Failure, ProductModel>> getProductDetails(int productId) async {
    return _apiService.getSafe(
      '/index.php',
      queryParameters: {
        'fc': 'module',
        'module': 'pharosapi',
        'controller': 'products',
        'action': 'details',
        'id_product': productId,
      },
      mapper: (json) {
        if (json is Map && json['status'] == 'success') {
          return ProductModel.fromJson(json['product']);
        }
        throw Exception('Failed to load product details');
      },
    );
  }

  @override
  Future<Either<Failure, List<ProductModel>>> searchProducts(String query, {Map<String, List<String>>? filters}) async {
    return _apiService.getSafe(
      '/index.php',
      queryParameters: {
        'fc': 'module',
        'module': 'pharosapi',
        'controller': 'products',
        'action': 'search',
        'query': query,
      },
      mapper: (json) {
        if (json is Map && json['status'] == 'success') {
          final List rawList = json['data'] ?? [];
          return rawList.map((j) => ProductModel.fromJson(j)).toList();
        }
        return [];
      },
    );
  }

  Future<List<ProductModel>> _loadMockData() async {
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      final String response = await rootBundle.loadString('assets/mock/products_api_response.json');
      final data = await json.decode(response);
      return (data['products'] as List).map((e) => ProductModel.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }
}



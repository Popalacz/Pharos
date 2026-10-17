import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';
import '../../core/network/api_service.dart';
import '../../core/error/failures.dart';
import '../../core/services/database/local_db_service.dart';
import '../models/product_model.dart';
import '../../core/utils/product_list_filters.dart';

abstract class IProductRepository {
  Future<Either<Failure, List<ProductModel>>> getProducts({int? categoryId, Map<String, List<String>>? filters});
  Future<Either<Failure, List<ProductModel>>> searchProducts(String query, {Map<String, List<String>>? filters});
  Future<Either<Failure, ProductModel>> getProductDetails(int productId);
  Future<Either<Failure, List<ProductModel>>> getRelatedProducts(int productId);
}

class ProductRepository implements IProductRepository {
  final ApiService _apiService;
  final bool useMockData;

  ProductRepository({ApiService? apiService, this.useMockData = false}) 
    : _apiService = apiService ?? ApiService();

  @override
  Future<Either<Failure, List<ProductModel>>> getProducts({int? categoryId, Map<String, List<String>>? filters}) async {
    if (useMockData) {
      final products = await _loadMockData();
      return Right(ProductListFilters.apply(products: products, selectedFilters: filters ?? {}));
    }

    final listQuery = ProductListFilters.buildQuery(
      selectedFilters: filters ?? {},
      catalogCategoryId: categoryId,
    );

    final Map<String, dynamic> params = {
      'fc': 'module',
      'module': 'pharosapi',
      'controller': 'products',
      'action': 'list',
      'limit': _resolveLimit(listQuery, filters ?? {}),
      'order_by': listQuery.orderBy,
      'order_way': listQuery.orderWay,
    };

    if (listQuery.categoryId != null) {
      params['id_category'] = listQuery.categoryId.toString();
    }
    if (listQuery.priceMin != null) {
      params['price_min'] = listQuery.priceMin.toString();
    }
    if (listQuery.priceMax != null) {
      params['price_max'] = listQuery.priceMax.toString();
    }

    params.addAll(ProductListFilters.buildAttributeAndFeatureParams(filters ?? {}));

    final response = await _apiService.getSafe(
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

    return response.fold(
      (failure) async {
        if (failure is NetworkFailure) {
          final cached = await LocalDbService().getCachedProducts();
          if (cached.isNotEmpty) {
            return Right(ProductListFilters.apply(products: cached, selectedFilters: filters ?? {}));
          }
        }
        return Left(failure);
      },
      (products) async {
        final filteredProducts = ProductListFilters.apply(
          products: products,
          selectedFilters: filters ?? {},
        );

        if (categoryId == null) {
          await LocalDbService().cacheProducts(filteredProducts);
        }
        return Right(filteredProducts);
      },
    );
  }

  String _resolveLimit(ProductListQuery listQuery, Map<String, List<String>> selectedFilters) {
    if (listQuery.priceMin != null ||
        listQuery.priceMax != null ||
        ProductListFilters.hasServerSideFilters(selectedFilters)) {
      return '100';
    }
    return '48';
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
    final Map<String, dynamic> params = {
      'fc': 'module',
      'module': 'pharosapi',
      'controller': 'products',
      'action': 'search',
      'query': query,
    };

    params.addAll(ProductListFilters.buildAttributeAndFeatureParams(filters ?? {}));

    final response = await _apiService.getSafe(
      '/index.php',
      queryParameters: params,
      mapper: (json) {
        if (json is Map && json['status'] == 'success') {
          final List rawList = json['data'] ?? [];
          return rawList.map((j) => ProductModel.fromJson(j)).toList();
        }
        return <ProductModel>[];
      },
    );

    return response.fold(
      (failure) => Left(failure),
      (products) => Right(
        ProductListFilters.apply(
          products: products,
          selectedFilters: filters ?? {},
        ),
      ),
    );
  }

  @override
  Future<Either<Failure, List<ProductModel>>> getRelatedProducts(int productId) async {
    return _apiService.getSafe(
      '/index.php',
      queryParameters: {
        'fc': 'module',
        'module': 'pharosapi',
        'controller': 'products',
        'action': 'related',
        'id_product': productId,
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



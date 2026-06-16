import 'package:flutter/foundation.dart';
import '../models/product_model.dart';
import '../../core/network/api_service.dart';

abstract class IWishlistRepository {
  Future<List<ProductModel>> getWishlist(int customerId);
  Future<bool> toggleWishlist(int customerId, int productId);
}

class WishlistRepository implements IWishlistRepository {
  final ApiService _apiService = ApiService();
  final bool useMockData;

  WishlistRepository({this.useMockData = false});

  @override
  Future<List<ProductModel>> getWishlist(int customerId) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 500));
      return []; 
    }
    
    try {
      final response = await _apiService.dio.get('/index.php', queryParameters: {
        'fc': 'module',
        'module': 'pharosapi',
        'controller': 'wishlist',
        'action': 'get',
        'id_customer': customerId,
      });

      final dynamic rawData = response.data['products'];
      if (rawData == null || rawData == '') return [];
      
      List productsJson = (rawData is List) ? rawData : [rawData];
      return productsJson.map((json) => ProductModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Wishlist API Error: $e');
      return [];
    }
  }

  @override
  Future<bool> toggleWishlist(int customerId, int productId) async {
    if (useMockData) return true;
    try {
      final response = await _apiService.dio.post('/index.php', queryParameters: {
        'fc': 'module',
        'module': 'pharosapi',
        'controller': 'wishlist',
        'action': 'toggle',
      }, data: {
        'id_customer': customerId,
        'id_product': productId,
      });
      return response.data['success'] == true;
    } catch (e) {
      return false;
    }
  }
}

import 'package:pharos/core/network/api_service.dart';
import 'package:flutter/foundation.dart';

abstract class ICartRepository {
  Future<Map<String, dynamic>> syncCart({
    int? cartId,
    int? customerId,
    required List<Map<String, dynamic>> items,
  });
  Future<Map<String, dynamic>?> getCart(int cartId);
}

class CartRepository implements ICartRepository {
  final ApiService _apiService = ApiService();

  @override
  Future<Map<String, dynamic>> syncCart({
    int? cartId,
    int? customerId,
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      final response = await _apiService.dio.post('/index.php', queryParameters: {
        'fc': 'module',
        'module': 'pharosapi',
        'controller': 'cart',
        'action': 'sync',
      }, data: {
        'id_cart': cartId,
        'id_customer': customerId,
        'items': items,
      });

      return response.data;
    } catch (e) {
      debugPrint('Cart Sync Error: $e');
      return {'success': false};
    }
  }

  @override
  Future<Map<String, dynamic>?> getCart(int cartId) async {
    try {
      final response = await _apiService.dio.get('/index.php', queryParameters: {
        'fc': 'module',
        'module': 'pharosapi',
        'controller': 'cart',
        'action': 'get',
        'id_cart': cartId,
      });
      return response.data;
    } catch (e) {
      return null;
    }
  }
}

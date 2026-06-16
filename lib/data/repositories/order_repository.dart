import 'package:pharos/core/network/api_service.dart';
import 'package:pharos/data/models/order_model.dart';
import 'package:flutter/foundation.dart';

abstract class IOrderRepository {
  Future<List<OrderModel>> getCustomerOrders(int customerId);
  Future<OrderModel?> getOrderDetails(int orderId);
}

class OrderRepository implements IOrderRepository {
  final ApiService _apiService = ApiService();

  @override
  Future<List<OrderModel>> getCustomerOrders(int customerId) async {
    try {
      final response = await _apiService.dio.get('/api/orders', queryParameters: {
        'display': 'full',
        'filter[id_customer]': '[$customerId]',
        'sort': '[id_DESC]',
      });

      final dynamic rawData = response.data['orders'];
      if (rawData == null || rawData == '') return [];

      List jsonList = (rawData is List) ? rawData : [rawData];
      return jsonList.map((e) => OrderModel.fromJson(e)).toList();
    } catch (e) {
      debugPrint('Fetch Orders Error: $e');
      return [];
    }
  }

  @override
  Future<OrderModel?> getOrderDetails(int orderId) async {
    try {
      final response = await _apiService.dio.get('/api/orders/$orderId', queryParameters: {
        'display': 'full',
      });

      final dynamic rawData = response.data['orders'];
      if (rawData == null || rawData == '') return null;

      // PrestaShop zwraca mapę jeśli jest jeden wynik lub listę jeśli wiele
      final Map<String, dynamic> json = (rawData is List) ? rawData.first : rawData;
      return OrderModel.fromJson(json);
    } catch (e) {
      debugPrint('Fetch Order Details Error: $e');
      return null;
    }
  }
}

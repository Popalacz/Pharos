import 'package:fpdart/fpdart.dart';
import 'package:pharos/core/network/api_service.dart';
import 'package:pharos/data/models/order_model.dart';
import '../../core/error/failures.dart';

abstract class IOrderRepository {
  Future<Either<Failure, List<OrderModel>>> getCustomerOrders(int customerId);
  Future<Either<Failure, OrderModel>> getOrderDetails(int orderId);
}

class OrderRepository implements IOrderRepository {
  final ApiService _apiService;

  OrderRepository({ApiService? apiService}) : _apiService = apiService ?? ApiService();

  @override
  Future<Either<Failure, List<OrderModel>>> getCustomerOrders(int customerId) async {
    return _apiService.getSafe(
      '/index.php',
      queryParameters: {
        'fc': 'module',
        'module': 'pharosapi',
        'controller': 'order',
        'action': 'list',
        'id_customer': customerId,
      },
      mapper: (json) {
        final List ordersJson = json['orders'] ?? [];
        return ordersJson.map((e) => OrderModel.fromJson(e as Map<String, dynamic>)).toList();
      },
    );
  }

  @override
  Future<Either<Failure, OrderModel>> getOrderDetails(int orderId) async {
    return _apiService.getSafe(
      '/index.php',
      queryParameters: {
        'fc': 'module',
        'module': 'pharosapi',
        'controller': 'order',
        'action': 'details',
        'id_order': orderId,
      },
      mapper: (json) {
        final orderData = json['order'];
        if (orderData == null) {
          throw Exception('Order not found');
        }
        return OrderModel.fromJson(orderData as Map<String, dynamic>);
      },
    );
  }
}

import 'package:fpdart/fpdart.dart';
import 'package:pharos/core/api/api_config.dart';
import '../../core/network/api_service.dart';import '../../core/error/failures.dart';
import '../models/checkout_models.dart';

abstract class ICheckoutRepository {
  Future<Either<Failure, List<CarrierModel>>> getCarriers();
  Future<Either<Failure, List<PaymentMethodModel>>> getPaymentMethods();
  Future<Either<Failure, Map<String, dynamic>>> createOrder(Map<String, dynamic> orderData);
  Future<Either<Failure, Map<String, dynamic>>> getShippingCosts({
    required int cartId,
    required int addressId,
    int? carrierId,
  });
}

class CheckoutRepository implements ICheckoutRepository {
  final ApiService _apiService;
  final bool useMockData;

  CheckoutRepository({ApiService? apiService, bool? useMockData})
      : _apiService = apiService ?? ApiService(),
        useMockData = useMockData ?? ApiConfig.forceMockData;

  @override
  Future<Either<Failure, List<CarrierModel>>> getCarriers() async {
    if (useMockData) {
      return Right([
        CarrierModel(id: 1, name: 'Google Express (Mock)', delay: '1-2 dni', price: 0.0),
        CarrierModel(id: 2, name: 'Standard Delivery', delay: '3-5 dni', price: 10.0),
      ]);
    }

    return _apiService.getSafe(
      '/index.php',
      queryParameters: {
        'fc': 'module',
        'module': 'pharosapi',
        'controller': 'config',
      },
      mapper: (json) {
        final List carriers = json['carriers'] ?? [];
        return carriers.map((e) => CarrierModel.fromJson(e)).toList();
      },
    );
  }

  @override
  Future<Either<Failure, List<PaymentMethodModel>>> getPaymentMethods() async {
    if (useMockData) {
      return Right([
        PaymentMethodModel(id: 'blik', name: 'Google Pay / BLIK (Mock)', description: 'Symulacja płatności'),
        PaymentMethodModel(id: 'ps_wirepayment', name: 'Przelew (Mock)', description: 'Dane do przelewu'),
      ]);
    }

    return _apiService.getSafe(
      '/index.php',
      queryParameters: {
        'fc': 'module',
        'module': 'pharosapi',
        'controller': 'config',
      },
      mapper: (json) {
        final List methods = json['payments'] ?? [];
        return methods.map((e) => PaymentMethodModel.fromJson(e)).toList();
      },
    );
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> createOrder(Map<String, dynamic> orderData) async {
    return _apiService.postSafe(
      '/index.php',
      queryParameters: {
        'fc': 'module',
        'module': 'pharosapi',
        'controller': 'order',
        'action': 'create',
      },
      data: orderData,
      mapper: (json) => json as Map<String, dynamic>,
    );
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getShippingCosts({
    required int cartId,
    required int addressId,
    int? carrierId,
  }) async {
    return _apiService.getSafe(
      '/index.php',
      queryParameters: {
        'fc': 'module',
        'module': 'pharosapi',
        'controller': 'cart',
        'action': 'get_shipping_costs',
        'id_cart': cartId,
        'id_address_delivery': addressId,
        if (carrierId != null) 'id_carrier': carrierId,
      },
      mapper: (json) => json as Map<String, dynamic>,
    );
  }
}

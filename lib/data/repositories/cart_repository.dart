import 'package:fpdart/fpdart.dart';
import 'package:pharos/core/network/api_service.dart';
import '../../core/error/failures.dart';
import 'package:pharos/core/api/api_config.dart';

abstract class ICartRepository {
  Future<Either<Failure, Map<String, dynamic>>> syncCart({
    int? cartId,
    int? customerId,
    required List<Map<String, dynamic>> items,
  });
  Future<Either<Failure, Map<String, dynamic>>> getCart(int cartId);
  Future<Either<Failure, Map<String, dynamic>>> applyVoucher({
    required int cartId,
    required String code,
  });
  Future<Either<Failure, Map<String, dynamic>>> removeVoucher({
    required int cartId,
    required int cartRuleId,
  });
}

class CartRepository implements ICartRepository {
  final ApiService _apiService;
  final bool useMockData;

  CartRepository({ApiService? apiService, bool? useMockData})
      : _apiService = apiService ?? ApiService(),
        useMockData = useMockData ?? ApiConfig.forceMockData;

  @override
  Future<Either<Failure, Map<String, dynamic>>> syncCart({
    int? cartId,
    int? customerId,
    required List<Map<String, dynamic>> items,
  }) async {
    if (useMockData) {
      return Right({
        'success': true,
        'id_cart': cartId ?? 999,
        'total': items.length * 100.0,
      });
    }

    return _apiService.postSafe(
      '/index.php',
      queryParameters: {
        'fc': 'module',
        'module': 'pharosapi',
        'controller': 'cart',
        'action': 'sync',
      },
      data: {
        'id_cart': cartId,
        'id_customer': customerId,
        'items': items,
      },
      mapper: (json) => json as Map<String, dynamic>,
    );
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getCart(int cartId) async {
    return _apiService.getSafe(
      '/index.php',
      queryParameters: {
        'fc': 'module',
        'module': 'pharosapi',
        'controller': 'cart',
        'action': 'get',
        'id_cart': cartId,
      },
      mapper: (json) => json as Map<String, dynamic>,
    );
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> applyVoucher({
    required int cartId,
    required String code,
  }) async {
    return _apiService.postSafe(
      '/index.php',
      queryParameters: {
        'fc': 'module',
        'module': 'pharosapi',
        'controller': 'cart',
        'action': 'apply_voucher',
      },
      data: {
        'id_cart': cartId,
        'code': code,
      },
      mapper: (json) => json as Map<String, dynamic>,
    );
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> removeVoucher({
    required int cartId,
    required int cartRuleId,
  }) async {
    return _apiService.postSafe(
      '/index.php',
      queryParameters: {
        'fc': 'module',
        'module': 'pharosapi',
        'controller': 'cart',
        'action': 'remove_voucher',
      },
      data: {
        'id_cart': cartId,
        'id_cart_rule': cartRuleId,
      },
      mapper: (json) => json as Map<String, dynamic>,
    );
  }
}

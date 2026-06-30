import 'package:flutter_test/flutter_test.dart';
import 'package:pharos/data/repositories/cart_repository.dart';
import 'package:pharos/core/network/api_service.dart';
import 'package:pharos/core/error/failures.dart';
import 'package:fpdart/fpdart.dart';
import 'package:dio/dio.dart';

class MockApiService implements ApiService {
  String? lastPath;
  Map<String, dynamic>? lastQueryParams;
  dynamic lastData;

  @override
  Dio get dio => Dio();

  set dio(Dio value) {}

  @override
  void updateCartId(int? cartId) {}

  @override
  Future<Either<Failure, T>> getSafe<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    required T Function(dynamic json) mapper,
  }) async {
    lastPath = path;
    lastQueryParams = queryParameters;
    
    // Simulate successful response for getCart
    if (queryParameters?['action'] == 'get') {
      return Right(mapper({'success': true, 'id_cart': 123}));
    }
    
    return Left(ServerFailure('Not implemented in mock'));
  }

  @override
  Future<Either<Failure, T>> postSafe<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    dynamic data,
    Options? options,
    required T Function(dynamic json) mapper,
  }) async {
    lastPath = path;
    lastQueryParams = queryParameters;
    lastData = data;

    if (queryParameters?['action'] == 'sync') {
      return Right(mapper({
        'success': true, 
        'id_cart': 123,
        'total': 200.0
      }));
    }

    return Left(ServerFailure('Not implemented in mock'));
  }
}

void main() {
  late CartRepository repository;
  late MockApiService mockApiService;

  setUp(() {
    mockApiService = MockApiService();
    repository = CartRepository(apiService: mockApiService, useMockData: false);
  });

  group('CartRepository Tests', () {
    test('syncCart calls the correct endpoint with data', () async {
      final items = [
        {'id_product': 1, 'quantity': 2}
      ];
      
      final result = await repository.syncCart(
        cartId: null,
        customerId: 45,
        items: items,
      );

      expect(result.isRight(), true);
      expect(mockApiService.lastPath, '/index.php');
      expect(mockApiService.lastQueryParams?['controller'], 'cart');
      expect(mockApiService.lastQueryParams?['action'], 'sync');
      expect(mockApiService.lastData['id_customer'], 45);
      expect(mockApiService.lastData['items'], items);
    });

    test('getCart calls the correct endpoint', () async {
      final result = await repository.getCart(123);

      expect(result.isRight(), true);
      expect(mockApiService.lastQueryParams?['action'], 'get');
      expect(mockApiService.lastQueryParams?['id_cart'], 123);
    });
  });
}

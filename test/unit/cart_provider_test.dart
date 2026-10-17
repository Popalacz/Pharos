import 'package:flutter_test/flutter_test.dart';
import 'package:pharos/core/providers/cart_provider.dart';
import 'package:pharos/data/models/product_model.dart';
import 'package:pharos/data/repositories/cart_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:pharos/core/error/failures.dart';
import 'dart:async';

class MockCartRepository implements ICartRepository {
  bool syncCalled = false;
  Map<String, dynamic>? lastSyncData;
  
  Completer<Either<Failure, Map<String, dynamic>>>? syncCompleter;

  @override
  Future<Either<Failure, Map<String, dynamic>>> syncCart({
    int? cartId,
    int? customerId,
    required List<Map<String, dynamic>> items,
  }) async {
    syncCalled = true;
    lastSyncData = {
      'cartId': cartId,
      'customerId': customerId,
      'items': items,
    };
    
    if (syncCompleter != null) {
      return syncCompleter!.future;
    }

    return const Right({
      'success': true,
      'id_cart': 123,
      'total': 150.0,
      'total_products': 130.0,
      'total_shipping': 20.0,
    });
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> applyVoucher({required int cartId, required String code}) async {
    return const Right({'success': true});
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getCart(int cartId) async {
    return const Right({'success': true});
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> removeVoucher({required int cartId, required int cartRuleId}) async {
    return const Right({'success': true});
  }
}

void main() {
  late CartProvider cartProvider;
  late MockCartRepository mockRepository;

  final testProduct = ProductModel(
    id: 1,
    name: 'Test Product',
    description: 'Description',
    price: 50.0,
    images: [],
    imageUrl: '',
    stockQuantity: 10,
    allowOutOfStockOrders: true,
    availableForOrder: true,
  );

  setUp(() {
    mockRepository = MockCartRepository();
    cartProvider = CartProvider(repository: mockRepository);
  });

  group('CartProvider Tests', () {
    test('Initial state is empty', () {
      expect(cartProvider.items.isEmpty, true);
      expect(cartProvider.totalAmount, 0.0);
    });

    test('Adding item updates local state and triggers sync', () async {
      cartProvider.addItem(testProduct);

      expect(cartProvider.items.length, 1);
      expect(cartProvider.itemCount, 1);
      expect(cartProvider.subtotalAmount, 50.0);
      
      // Sync has debounce 800ms
      expect(mockRepository.syncCalled, false);
      
      await Future.delayed(const Duration(milliseconds: 900));
      
      expect(mockRepository.syncCalled, true);
      expect(mockRepository.lastSyncData?['items'][0]['id_product'], 1);
    });

    test('Server response updates totals in provider', () async {
      cartProvider.addItem(testProduct);
      
      // Wait for debounce and sync execution
      await Future.delayed(const Duration(milliseconds: 1000));
      
      expect(cartProvider.idCart, 123);
      expect(cartProvider.totalAmount, 150.0);
      expect(cartProvider.subtotalAmount, 130.0);
      expect(cartProvider.shippingAmount, 20.0);
    });

    test('Updating quantity triggers re-sync', () async {
      cartProvider.addItem(testProduct);
      await Future.delayed(const Duration(milliseconds: 900));
      mockRepository.syncCalled = false; // Reset flag

      cartProvider.updateQuantity(cartProvider.items.keys.first, 1);
      
      await Future.delayed(const Duration(milliseconds: 900));
      expect(mockRepository.syncCalled, true);
      expect(mockRepository.lastSyncData?['items'][0]['quantity'], 2);
    });

    test('Clear cart resets all values', () {
      cartProvider.addItem(testProduct);
      cartProvider.clear();

      expect(cartProvider.items.isEmpty, true);
      expect(cartProvider.idCart, null);
      expect(cartProvider.totalAmount, 0.0);
    });
  });
}

import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:pharos/data/models/product_model.dart';
import 'package:pharos/data/repositories/cart_repository.dart';
import 'package:pharos/core/providers/user_provider.dart';
import 'package:flutter/services.dart';
import 'dart:async';

class CartItem {
  final ProductModel product;
  final int attributeId;
  final int customizationId;
  int quantity;

  CartItem({
    required this.product, 
    this.attributeId = 0,
    this.customizationId = 0,
    this.quantity = 1,
  });

  String get key => '${product.id}_${attributeId}_$customizationId';
}

class CartProvider extends ChangeNotifier {
  final ICartRepository _repository;
  final Map<String, CartItem> _items = {};
  int? _idCart;
  UserProvider? _userProvider;
  Timer? _syncDebounce;

  CartProvider({ICartRepository? repository}) : _repository = repository ?? CartRepository();

  double _serverTotal = 0.0;
  double _serverProductsTotal = 0.0;
  double _serverShippingTotal = 0.0;
  bool _isSyncing = false;

  Map<String, CartItem> get items => {..._items};
  int? get idCart => _idCart;
  bool get isSyncing => _isSyncing;

  int get itemCount => _items.values.fold(0, (sum, item) => sum + item.quantity);

  // Zwracamy sumę z serwera jeśli jest dostępna (Single Source of Truth)
  double get totalAmount => _serverTotal > 0 ? _serverTotal : subtotalAmount;

  double get subtotalAmount => _serverProductsTotal > 0 ? _serverProductsTotal : _items.values.fold(
      0.0, (sum, item) => sum + (item.product.price * item.quantity));

  double get shippingAmount => _serverShippingTotal;

  void updateUser(UserProvider userProvider) {
    _userProvider = userProvider;
    if (userProvider.isLoggedIn && _items.isNotEmpty) {
      _triggerSync();
    }
  }

  void addItem(ProductModel product, {int attributeId = 0, int customizationId = 0}) {
    HapticFeedback.lightImpact();
    final String key = '${product.id}_${attributeId}_$customizationId';
    
    if (_items.containsKey(key)) {
      _items[key]!.quantity += 1;
    } else {
      _items[key] = CartItem(
        product: product,
        attributeId: attributeId,
        customizationId: customizationId,
      );
    }
    notifyListeners();
    _triggerSync();
  }

  void updateQuantity(String key, int delta) {
    if (!_items.containsKey(key)) return;
    
    HapticFeedback.selectionClick();
    _items[key]!.quantity += delta;
    
    if (_items[key]!.quantity <= 0) {
      _items.remove(key);
    }
    notifyListeners();
    _triggerSync();
  }

  void removeItem(String key) {
    _items.remove(key);
    notifyListeners();
    _triggerSync();
  }

  void clear() {
    _items.clear();
    _idCart = null;
    _serverTotal = 0.0;
    _serverProductsTotal = 0.0;
    _serverShippingTotal = 0.0;
    notifyListeners();
  }

  Future<String?> applyVoucher(String code) async {
    if (_idCart == null || code.trim().isEmpty) return 'Brak koszyka lub kodu.';
    final result = await _repository.applyVoucher(cartId: _idCart!, code: code.trim());
    return result.fold(
      (failure) => failure.message,
      (data) {
        if (data['success'] == true) {
          _updateTotalsFromResponse(data);
          notifyListeners();
          return null;
        }
        return data['message']?.toString() ?? 'Nie udało się zastosować kodu.';
      },
    );
  }

  void _updateTotalsFromResponse(Map<String, dynamic> data) {
    if (data['total'] != null) {
      _serverTotal = double.tryParse(data['total'].toString()) ?? _serverTotal;
    }
    if (data['total_products'] != null) {
      _serverProductsTotal = double.tryParse(data['total_products'].toString()) ?? _serverProductsTotal;
    }
    if (data['total_shipping'] != null) {
      _serverShippingTotal = double.tryParse(data['total_shipping'].toString()) ?? _serverShippingTotal;
    }
  }

  void _triggerSync() {
    if (_syncDebounce?.isActive ?? false) _syncDebounce!.cancel();
    
    _isSyncing = true;
    notifyListeners();

    _syncDebounce = Timer(const Duration(milliseconds: 800), () async {
      final List<Map<String, dynamic>> itemsJson = _items.values.map((item) => {
        'id_product': item.product.id,
        'id_product_attribute': item.attributeId,
        'id_customization': item.customizationId,
        'quantity': item.quantity,
      }).toList();

      final result = await _repository.syncCart(
        cartId: _idCart,
        customerId: _userProvider?.user?.id,
        items: itemsJson,
      );

      _isSyncing = false;

      result.fold(
        (failure) => debugPrint('CART SYNC FAILURE: $failure'),
        (data) {
          if (data['success'] == true) {
            if (data['id_cart'] != null) {
              _idCart = int.tryParse(data['id_cart'].toString());
            }
            _updateTotalsFromResponse(data);
            
            debugPrint('CART REAL-TIME SYNC: Success. ID: $_idCart, Total: $_serverTotal, Shipping: $_serverShippingTotal');
          }
        },
      );
      notifyListeners();
    });
  }
}

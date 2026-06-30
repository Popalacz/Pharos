import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:pharos/core/services/analytics_service.dart';
import 'package:pharos/data/models/cart_model.dart';
import 'package:pharos/data/models/product_model.dart';
import 'package:pharos/data/repositories/cart_repository.dart';
import 'package:pharos/core/providers/user_provider.dart';
import 'package:pharos/core/network/api_service.dart';
import 'package:flutter/services.dart';
import 'dart:async';

class CartProvider extends ChangeNotifier {
  final ICartRepository _repository;
  final AnalyticsService? _analytics;
  final ApiService? _apiService;
  final Map<String, CartItemModel> _items = {};
  int? _idCart;
  UserProvider? _userProvider;
  Timer? _syncDebounce;

  CartProvider({
    ICartRepository? repository,
    AnalyticsService? analytics,
    ApiService? apiService,
  })  : _repository = repository ?? CartRepository(),
        _analytics = analytics,
        _apiService = apiService;

  double _serverTotal = 0.0;
  double _serverProductsTotal = 0.0;
  double _serverShippingTotal = 0.0;
  bool _isSyncing = false;

  Map<String, CartItemModel> get items => {..._items};
  int? get idCart => _idCart;
  bool get isSyncing => _isSyncing;

  int get itemCount => _items.values.fold(0, (sum, item) => sum + item.quantity);

  double get totalAmount => _serverTotal > 0 ? _serverTotal : (subtotalAmount + shippingAmount);

  double get subtotalAmount => _serverProductsTotal > 0
      ? _serverProductsTotal
      : _items.values.fold(0.0, (sum, item) => sum + (item.product.price * item.quantity));

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
      _items[key] = CartItemModel(
        product: product,
        attributeId: attributeId,
        customizationId: customizationId,
      );
    }

    _analytics?.logAddToCart(
      itemId: product.id.toString(),
      itemName: product.name,
      price: product.price,
    );

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
    HapticFeedback.mediumImpact();
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
    _apiService?.updateCartId(null);
    notifyListeners();
  }

  void updateServerTotals({double? total, double? subtotal, double? shipping}) {
    if (total != null) _serverTotal = total;
    if (subtotal != null) _serverProductsTotal = subtotal;
    if (shipping != null) _serverShippingTotal = shipping;
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
      final List<Map<String, dynamic>> itemsJson = _items.values
          .map((item) => {
                'id_product': item.product.id,
                'id_product_attribute': item.attributeId,
                'id_customization': item.customizationId,
                'quantity': item.quantity,
              })
          .toList();

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
              _apiService?.updateCartId(_idCart);
            }
            _updateTotalsFromResponse(data);
          }
        },
      );
      notifyListeners();
    });
  }
}

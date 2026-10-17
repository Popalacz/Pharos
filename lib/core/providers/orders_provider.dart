import 'package:flutter/material.dart';
import 'package:pharos/core/providers/user_provider.dart';
import 'package:pharos/data/models/order_model.dart';
import 'package:pharos/data/repositories/order_repository.dart';

class OrdersProvider extends ChangeNotifier {
  OrdersProvider({IOrderRepository? repository})
      : _repository = repository ?? OrderRepository();

  final IOrderRepository _repository;
  UserProvider? _userProvider;

  List<OrderModel> _orders = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<OrderModel> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void updateUser(UserProvider userProvider) {
    final bool wasLoggedIn = _userProvider?.isLoggedIn ?? false;
    final int? previousUserId = _userProvider?.user?.id;
    _userProvider = userProvider;

    if (!userProvider.isLoggedIn) {
      _orders = [];
      _errorMessage = null;
      _isLoading = false;
      notifyListeners();
      return;
    }

    if (!wasLoggedIn || userProvider.user?.id != previousUserId) {
      fetchOrders();
    }
  }

  Future<void> fetchOrders() async {
    final int? customerId = _userProvider?.user?.id;
    if (customerId == null) {
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.getCustomerOrders(customerId);

    result.fold(
      (failure) => _errorMessage = failure.message,
      (loadedOrders) {
        _orders = loadedOrders;
        _errorMessage = null;
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  OrderModel? findOrderById(int orderId) {
    for (final order in _orders) {
      if (order.id == orderId) {
        return order;
      }
    }
    return null;
  }
}

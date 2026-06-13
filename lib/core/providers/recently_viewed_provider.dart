import 'package:flutter/material.dart';
import 'package:pharos/data/models/product_model.dart';

class RecentlyViewedProvider extends ChangeNotifier {
  final List<ProductModel> _recentProducts = [];

  List<ProductModel> get recentProducts => _recentProducts;

  void addProduct(ProductModel product) {
    // Usuń jeśli już jest (aby przesunąć na początek)
    _recentProducts.removeWhere((p) => p.id == product.id);
    
    // Dodaj na początek
    _recentProducts.insert(0, product);
    
    // Trzymaj tylko ostatnie 10
    if (_recentProducts.length > 10) {
      _recentProducts.removeLast();
    }
    
    notifyListeners();
  }
}

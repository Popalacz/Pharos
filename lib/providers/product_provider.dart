import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/presta_api_service.dart';

class ProductProvider with ChangeNotifier {
  final PrestaApiService _apiService = PrestaApiService();
  
  List<Product> _products = [];
  bool _isLoading = false;
  String _errorMessage = '';

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<void> fetchAllProducts() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners(); 

    try {
      _products = await _apiService.getProducts();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners(); 
    }
  }
}
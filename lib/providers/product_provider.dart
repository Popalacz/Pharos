import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/presta_api_service.dart';

enum ProductState { loading, success, error, empty }

class ProductProvider with ChangeNotifier {
  final PrestaApiService _apiService;
  
  List<Product> _products = [];
  ProductState _state = ProductState.empty;
  String _errorMessage = '';

  ProductProvider({PrestaApiService? apiService}) 
      : _apiService = apiService ?? PrestaApiService();

  List<Product> get products => _products;
  ProductState get state => _state;
  String get errorMessage => _errorMessage;


  bool get isLoading => _state == ProductState.loading;
  bool get hasError => _state == ProductState.error;

  Future<void> fetchAllProducts() async {
    _state = ProductState.loading;
    _errorMessage = '';
    notifyListeners(); 

    try {
      _products = await _apiService.getProducts();
      
      if (_products.isEmpty) {
        _state = ProductState.empty;
      } else {
        _state = ProductState.success;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _state = ProductState.error;
    } finally {
      notifyListeners(); 
    }
  }
}
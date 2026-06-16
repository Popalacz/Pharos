import '../../core/network/api_service.dart';
import '../models/checkout_models.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';

abstract class ICheckoutRepository {
  Future<List<CarrierModel>> getCarriers();
  Future<List<PaymentMethodModel>> getPaymentMethods();
  Future<Map<String, dynamic>> createOrder(Map<String, dynamic> orderData);
}

class CheckoutRepository implements ICheckoutRepository {
  final ApiService _apiService = ApiService();
  final bool useMockData;

  CheckoutRepository({this.useMockData = false});

  @override
  Future<List<CarrierModel>> getCarriers() async {
    try {
      final response = await _apiService.dio.get('/index.php', queryParameters: {
        'fc': 'module',
        'module': 'pharosapi',
        'controller': 'config',
      });
      
      dynamic data = response.data;
      if (data is String) data = jsonDecode(data);
      
      final List carriers = data['carriers'] ?? [];
      return carriers.map((e) => CarrierModel.fromJson(e)).toList();
    } catch (e) {
      debugPrint('FETCH CARRIERS ERROR: $e');
      return [];
    }
  }

  @override
  Future<List<PaymentMethodModel>> getPaymentMethods() async {
    try {
      final response = await _apiService.dio.get('/index.php', queryParameters: {
        'fc': 'module',
        'module': 'pharosapi',
        'controller': 'config',
      });
      
      dynamic data = response.data;
      if (data is String) data = jsonDecode(data);
      
      final List methods = data['payments'] ?? [];

      if (methods.isEmpty) {
        return [
          PaymentMethodModel(id: 'ps_wirepayment', name: 'Przelew bankowy', description: 'Zapłać tradycyjnym przelewem'),
          PaymentMethodModel(id: 'ps_checkpayment', name: 'Płatność przy odbiorze', description: 'Zapłać kurierowi przy dostawie'),
        ];
      }
      
      return methods.map((e) => PaymentMethodModel.fromJson(e)).toList();
    } catch (e) {
      debugPrint('FETCH PAYMENTS ERROR: $e');
      return [];
    }
  }

  @override
  Future<Map<String, dynamic>> createOrder(Map<String, dynamic> orderData) async {
    try {
      // Senior Strategy: Zamiast wysyłać listę produktów, wysyłamy id_cart, 
      // który PrestaShop już zna i ma przeliczony (zniżki, podatki).
      final response = await _apiService.dio.post('/index.php', 
        queryParameters: {
          'fc': 'module',
          'module': 'pharosapi',
          'controller': 'order', // Zmieniamy na kontroler zamówień
          'action': 'create',
        },
        data: orderData
      );
      
      return response.data;
    } catch (e) {
      debugPrint('ORDER CREATION CRITICAL ERROR: $e');
      rethrow;
    }
  }
}

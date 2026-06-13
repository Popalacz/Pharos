import '../../core/network/api_service.dart';
import '../models/checkout_models.dart';
import 'package:flutter/foundation.dart';

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
      // Pobieranie kurierów (można filtrować po aktywnych)
      final response = await _apiService.dio.get('/api/carriers', queryParameters: {
        'display': 'full',
        'filter[active]': '1',
      });
      
      final List carriers = response.data['carriers'] ?? [];
      return carriers.map((e) => CarrierModel.fromJson(e)).toList();
    } catch (e) {
      debugPrint('Carrier Fetch Error: $e');
      return [];
    }
  }

  @override
  Future<List<PaymentMethodModel>> getPaymentMethods() async {
    try {
      // Pobieranie aktywnych metod płatności z dedykowanego endpointu modułu pharos_api
      // Zgodnie z PHAROS_MODULE_GUIDELINES.md: Lista płatności pobierana z systemu
      final response = await _apiService.dio.get('/module/pharos_api/payments');
      
      final List methods = response.data['methods'] ?? [];
      return methods.map((e) => PaymentMethodModel.fromJson(e)).toList();
    } catch (e) {
      debugPrint('Payment Methods Fetch Error: $e');
      return [];
    }
  }

  @override
  Future<Map<String, dynamic>> createOrder(Map<String, dynamic> orderData) async {
    try {
      // Tworzenie zamówienia w PrestaShop
      final response = await _apiService.dio.post('/api/orders', data: orderData);
      return response.data;
    } catch (e) {
      debugPrint('Order Creation Error: $e');
      rethrow;
    }
  }
}

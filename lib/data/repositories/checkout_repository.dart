import '../models/checkout_models.dart';
import '../../core/network/api_service.dart';

abstract class ICheckoutRepository {
  Future<List<CarrierModel>> getCarriers();
  Future<List<PaymentMethodModel>> getPaymentMethods();
  Future<Map<String, dynamic>> createOrder(Map<String, dynamic> orderData);
}

class CheckoutRepository implements ICheckoutRepository {
  final ApiService _apiService = ApiService();
  final bool useMockData;

  CheckoutRepository({this.useMockData = true});

  @override
  Future<List<CarrierModel>> getCarriers() async {
    if (useMockData) {
      return [
        CarrierModel(id: 1, name: 'InPost Paczkomaty', delay: '24h', price: 14.99),
        CarrierModel(id: 2, name: 'DPD Kurier', delay: '1-2 dni', price: 19.00),
        CarrierModel(id: 3, name: 'Odbiór osobisty', delay: 'Natychmiast', price: 0.0),
      ];
    }
    
    final response = await _apiService.dio.get('/carriers');
    return (response.data['carriers'] as List)
        .map((e) => CarrierModel.fromJson(e))
        .toList();
  }

  @override
  Future<List<PaymentMethodModel>> getPaymentMethods() async {
    if (useMockData) {
      return [
        PaymentMethodModel(id: 'blik', name: 'BLIK', description: 'Szybki przelew kodem'),
        PaymentMethodModel(id: 'ps_checkout', name: 'Karta Płatnicza', description: 'Visa, Mastercard'),
        PaymentMethodModel(id: 'google_pay', name: 'Google Pay', description: 'Płatność jednym kliknięciem'),
      ];
    }
    
    final response = await _apiService.dio.get('/pharos/payment-methods');
    return (response.data['methods'] as List)
        .map((e) => PaymentMethodModel.fromJson(e))
        .toList();
  }

  @override
  Future<Map<String, dynamic>> createOrder(Map<String, dynamic> orderData) async {
    if (useMockData) {
      await Future.delayed(const Duration(seconds: 2));
      return {'success': true, 'order_id': 'PH-MOCK-123'};
    }
    
    final response = await _apiService.dio.post('/orders', data: orderData);
    return response.data;
  }
}

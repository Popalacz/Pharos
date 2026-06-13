import '../models/checkout_models.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

abstract class ICheckoutRepository {
  Future<List<CarrierModel>> getCarriers();
  Future<List<PaymentMethodModel>> getPaymentMethods();
}

class CheckoutRepository implements ICheckoutRepository {
  final bool useMockData;

  CheckoutRepository({this.useMockData = true});

  @override
  Future<List<CarrierModel>> getCarriers() async {
    if (useMockData) {
      // W Senior Architect zawsze mamy backup danych do testów UI
      return [
        CarrierModel(id: 1, name: 'InPost Paczkomaty', delay: '24h', price: 14.99),
        CarrierModel(id: 2, name: 'DPD Kurier', delay: '1-2 dni', price: 19.00),
        CarrierModel(id: 3, name: 'Odbiór osobisty', delay: 'Natychmiast', price: 0.0),
      ];
    }
    // Tu docelowo: dio.get('/carriers') z Twojego modułu pharos_api
    return [];
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
    return [];
  }
}

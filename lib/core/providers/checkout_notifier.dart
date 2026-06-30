import 'package:flutter/material.dart';
import 'package:pharos/core/providers/cart_provider.dart';
import 'package:pharos/core/services/analytics_service.dart';
import 'package:pharos/data/models/address_model.dart';
import 'package:pharos/data/models/checkout_models.dart';
import 'package:pharos/data/repositories/cart_repository.dart';
import 'package:pharos/data/repositories/checkout_repository.dart';

enum CheckoutStep { address, shipping, payment, review, placingOrder, success }

class CheckoutNotifier extends ChangeNotifier {
  CheckoutNotifier({
    required CheckoutRepository checkoutRepository,
    required ICartRepository cartRepository,
    AnalyticsService? analyticsService,
  })  : _checkoutRepository = checkoutRepository,
        _cartRepository = cartRepository,
        _analytics = analyticsService ?? AnalyticsService();

  final CheckoutRepository _checkoutRepository;
  final ICartRepository _cartRepository;
  final AnalyticsService _analytics;

  CheckoutStep step = CheckoutStep.address;
  AddressModel? selectedAddress;
  CarrierModel? selectedCarrier;
  PaymentMethodModel? selectedPayment;

  List<CarrierModel>? carriers;
  List<PaymentMethodModel>? payments;
  bool carriersError = false;
  bool paymentsError = false;
  bool isLoadingOptions = false;
  bool isPlacingOrder = false;
  String? errorMessage;
  double? shippingCost;

  bool get hasValidAddress => selectedAddress != null;
  bool get hasValidShipping => selectedCarrier != null;
  bool get hasValidPayment => selectedPayment != null;

  Future<void> loadOptions({required int? cartId}) async {
    isLoadingOptions = true;
    carriersError = false;
    paymentsError = false;
    notifyListeners();

    final carriersResult = await _checkoutRepository.getCarriers(cartId: cartId);
    final paymentsResult = await _checkoutRepository.getPaymentMethods();

    carriersResult.fold(
      (_) => carriersError = true,
      (loadedCarriers) {
        carriers = loadedCarriers;
        if (loadedCarriers.length == 1) {
          selectedCarrier = loadedCarriers.first;
        }
      },
    );

    paymentsResult.fold(
      (_) => paymentsError = true,
      (loadedPayments) {
        payments = loadedPayments;
        if (loadedPayments.length == 1) {
          selectedPayment = loadedPayments.first;
        }
      },
    );

    isLoadingOptions = false;
    notifyListeners();
  }

  void selectAddress(AddressModel? address) {
    selectedAddress = address;
    notifyListeners();
  }

  void selectCarrier(CarrierModel? carrier) {
    selectedCarrier = carrier;
    notifyListeners();
  }

  void selectPayment(PaymentMethodModel? payment) {
    selectedPayment = payment;
    notifyListeners();
  }

  Future<void> refreshShippingCost({required CartProvider cart}) async {
    if (cart.idCart == null || selectedAddress == null || selectedCarrier == null) {
      shippingCost = null;
      notifyListeners();
      return;
    }

    final result = await _checkoutRepository.getShippingCosts(
      cartId: cart.idCart!,
      addressId: selectedAddress!.id,
      carrierId: selectedCarrier!.id,
    );

    result.fold(
      (_) => shippingCost = selectedCarrier?.price,
      (data) {
        if (data['success'] == true) {
          shippingCost = (data['shipping_cost'] as num?)?.toDouble() ?? selectedCarrier?.price ?? 0.0;
          final total = (data['total_with_shipping'] as num?)?.toDouble() ??
              (cart.subtotalAmount + (shippingCost ?? 0));
          cart.updateServerTotals(shipping: shippingCost, total: total);
        }
      },
    );
    notifyListeners();
  }

  bool validateCurrentStep({required bool guestAddressValid}) {
    switch (step) {
      case CheckoutStep.address:
        return guestAddressValid || hasValidAddress;
      case CheckoutStep.shipping:
        return hasValidShipping;
      case CheckoutStep.payment:
        return hasValidPayment;
      case CheckoutStep.review:
        return hasValidAddress && hasValidShipping && hasValidPayment;
      default:
        return false;
    }
  }

  void goToNextStep({required bool guestAddressValid}) {
    errorMessage = null;
    switch (step) {
      case CheckoutStep.address:
        if (!validateCurrentStep(guestAddressValid: guestAddressValid)) {
          errorMessage = 'Uzupełnij poprawny adres dostawy.';
          break;
        }
        step = (carriers?.isNotEmpty ?? false) ? CheckoutStep.shipping : CheckoutStep.payment;
        break;
      case CheckoutStep.shipping:
        if (!hasValidShipping) {
          errorMessage = 'Wybierz metodę dostawy.';
          break;
        }
        step = (payments?.isNotEmpty ?? false) ? CheckoutStep.payment : CheckoutStep.review;
        break;
      case CheckoutStep.payment:
        if (!hasValidPayment) {
          errorMessage = 'Wybierz metodę płatności.';
          break;
        }
        step = CheckoutStep.review;
        break;
      case CheckoutStep.review:
        break;
      default:
        break;
    }
    notifyListeners();
  }

  void goToPreviousStep() {
    errorMessage = null;
    switch (step) {
      case CheckoutStep.shipping:
        step = CheckoutStep.address;
        break;
      case CheckoutStep.payment:
        step = (carriers?.isNotEmpty ?? false) ? CheckoutStep.shipping : CheckoutStep.address;
        break;
      case CheckoutStep.review:
        step = (payments?.isNotEmpty ?? false) ? CheckoutStep.payment : CheckoutStep.shipping;
        break;
      default:
        break;
    }
    notifyListeners();
  }

  Future<bool> verifyPricesAndStock(CartProvider cart) async {
    if (cart.idCart == null) return false;

    final cartResult = await _cartRepository.syncCart(
      cartId: cart.idCart,
      customerId: null,
      items: cart.items.values
          .map((item) => {
                'id_product': item.product.id,
                'id_product_attribute': item.attributeId,
                'id_customization': item.customizationId,
                'quantity': item.quantity,
              })
          .toList(),
    );

    return cartResult.fold(
      (_) => false,
      (data) {
        if (data['success'] != true) return false;
        cart.updateServerTotals(
          total: (data['total'] as num?)?.toDouble(),
          subtotal: (data['total_products'] as num?)?.toDouble(),
          shipping: (data['total_shipping'] as num?)?.toDouble(),
        );
        return true;
      },
    );
  }

  Future<Map<String, dynamic>?> prepareOrder({
    required CartProvider cart,
    required bool guestAddressValid,
    required String currencyIso,
  }) async {
    if (!validateCurrentStep(guestAddressValid: guestAddressValid)) {
      errorMessage = 'Uzupełnij wszystkie kroki checkoutu.';
      notifyListeners();
      return null;
    }

    step = CheckoutStep.placingOrder;
    isPlacingOrder = true;
    notifyListeners();

    await _analytics.logBeginCheckout(cart.totalAmount, currency: currencyIso);

    final isValid = await verifyPricesAndStock(cart);
    if (!isValid) {
      errorMessage = 'Ceny lub dostępność produktów uległy zmianie. Sprawdź koszyk.';
      step = CheckoutStep.address;
      isPlacingOrder = false;
      notifyListeners();
      return null;
    }

    isPlacingOrder = false;
    notifyListeners();
    return {
      'carrier_id': selectedCarrier!.id,
      'payment_module': selectedPayment!.id,
      'address_id': selectedAddress?.id,
    };
  }

  void markSuccess() {
    step = CheckoutStep.success;
    notifyListeners();
  }
}

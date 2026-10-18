import 'package:pharos/core/utils/app_logger.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

/// Checkout funnel events. Every funnel event carries the checkout variant (`A` or `B`).
class AnalyticsService {
  /// Variant of the checkout shown to the user. Set by the experiment (E4), `A` is the current flow.
  static String checkoutVariant = 'A';

  static const String stepAddress = 'address';
  static const String stepShipping = 'shipping';
  static const String stepPayment = 'payment';

  FirebaseAnalytics? get _analytics {
    try {
      return FirebaseAnalytics.instance;
    } catch (_) {
      return null;
    }
  }

  Map<String, Object> _withVariant([Map<String, Object> params = const {}]) => {
        ...params,
        'checkout_variant': checkoutVariant,
      };

  Future<void> _log(String name, Map<String, Object> params) async {
    try {
      await _analytics?.logEvent(name: name, parameters: _withVariant(params));
    } catch (e) {
      AppLog.e('Analytics event $name failed: $e');
    }
  }

  Future<void> logAddToCart({
    required String itemId,
    required String itemName,
    required double price,
    String currency = 'PLN',
  }) async {
    await _analytics?.logAddToCart(
      items: [
        AnalyticsEventItem(
          itemId: itemId,
          itemName: itemName,
          price: price,
          quantity: 1,
        ),
      ],
      value: price,
      currency: currency,
    );
  }

  Future<void> logViewCart(double value, int itemCount, {String currency = 'PLN'}) =>
      _log('view_cart', {'value': value, 'item_count': itemCount, 'currency': currency});

  Future<void> logBeginCheckout(double value, {String currency = 'PLN', bool isGuest = false}) =>
      _log('begin_checkout', {'value': value, 'currency': currency, 'is_guest': isGuest ? 1 : 0});

  Future<void> logCheckoutStepComplete(String step) => _log('checkout_step_complete', {'step': step});

  Future<void> logCheckoutValidationError(String reason, {int? fieldCount}) => _log(
        'checkout_validation_error',
        {'reason': reason, 'field_count': ?fieldCount},
      );

  Future<void> logPurchase(String transactionId, double value, {String currency = 'PLN', bool isGuest = false}) =>
      _log('purchase', {
        'transaction_id': transactionId,
        'value': value,
        'currency': currency,
        'is_guest': isGuest ? 1 : 0,
      });

  Future<void> logAccountCreatedAfterPurchase(String transactionId) =>
      _log('account_created_after_purchase', {'transaction_id': transactionId});
}

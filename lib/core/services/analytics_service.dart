import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  Future<void> logAddToCart({
    required String itemId,
    required String itemName,
    required double price,
    String currency = 'PLN',
  }) async {
    await _analytics.logAddToCart(
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

  Future<void> logBeginCheckout(double value, {String currency = 'PLN'}) async {
    await _analytics.logBeginCheckout(
      value: value,
      currency: currency,
    );
  }

  Future<void> logPurchase(String transactionId, double value, {String currency = 'PLN'}) async {
    await _analytics.logPurchase(
      transactionId: transactionId,
      value: value,
      currency: currency,
    );
  }
}

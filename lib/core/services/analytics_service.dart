import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  Future<void> logAddToCart({required String itemId, required String itemName, required double price}) async {
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
      currency: 'PLN',
    );
  }

  Future<void> logBeginCheckout(double value) async {
    await _analytics.logBeginCheckout(
      value: value,
      currency: 'PLN',
    );
  }

  Future<void> logPurchase(String transactionId, double value) async {
    await _analytics.logPurchase(
      transactionId: transactionId,
      value: value,
      currency: 'PLN',
    );
  }
}

import 'package:flutter_test/flutter_test.dart';
import 'package:pharos/core/services/analytics_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AnalyticsService', () {
    test('defaults to checkout variant A', () {
      expect(AnalyticsService.checkoutVariant, 'A');
    });

    test('funnel events do not throw when Firebase is not initialised', () async {
      final analytics = AnalyticsService();

      await analytics.logViewCart(100, 2);
      await analytics.logBeginCheckout(100, isGuest: true);
      await analytics.logCheckoutStepComplete(AnalyticsService.stepAddress);
      await analytics.logCheckoutValidationError('missing_fields', fieldCount: 3);
      await analytics.logPurchase('PH-1', 100);
      await analytics.logAccountCreatedAfterPurchase('PH-1');
    });
  });
}

import 'package:pharos/core/services/analytics_service.dart';

/// Wariant ekranu finalizacji zamówienia, mierzony w analityce lejka.
/// A: jedna strona ze wszystkimi sekcjami. B: kroki jeden po drugim.
enum CheckoutVariant {
  single,
  stepped;

  String get code => this == CheckoutVariant.stepped ? 'B' : 'A';

  static CheckoutVariant fromCode(String code) =>
      code.toUpperCase() == 'B' ? CheckoutVariant.stepped : CheckoutVariant.single;

  /// Wariant aktualnie ustawiony w analityce (domyślnie A).
  static CheckoutVariant get current => fromCode(AnalyticsService.checkoutVariant);
}

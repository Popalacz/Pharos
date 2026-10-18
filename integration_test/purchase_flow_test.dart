import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pharos/main.dart' as app;
import 'package:pharos/ui/widgets/pharos_product_card.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Krytyczna Ścieżka Zakupowa (End-to-End)', () {
    testWidgets('Pełny proces: od strony głównej do potwierdzenia zamówienia',
        (tester) async {
      
      app.main();
      await tester.pumpAndSettle();
      
      // Dajemy aplikacji czas na ewentualne retry lub wolny DNS
      await Future.delayed(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // 1. Sprawdzenie stanu (Sukces lub Błąd API)
      final errorState = find.textContaining('Błąd synchronizacji');
      if (tester.any(errorState)) {
        fail('Aplikacja wyświetla błąd połączenia z API. Test wymaga działającego backendu.');
      }

      // Szukamy nazwy sklepu (Pharos) - upewnij się, że nazwa w BO zawiera ten ciąg
      expect(find.textContaining('PHAROS'), findsAtLeast(1));

      // 2. Wejście w pierwszy produkt z listy
      final productCard = find.byType(PharosProductCard).first;
      expect(productCard, findsOneWidget);
      await tester.tap(productCard);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // 3. Dodanie do koszyka
      final addToCartBtn = find.text('DODAJ DO KOSZYKA');
      expect(addToCartBtn, findsOneWidget);
      await tester.tap(addToCartBtn);
      await tester.pumpAndSettle();

      // 4. Przejście do koszyka przez dolną nawigację
      final cartTab = find.byIcon(Icons.shopping_bag_outlined);
      await tester.tap(cartTab);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // 5. Sprawdzenie czy produkt jest w koszyku i przejście do kasy
      expect(find.text('Twój Koszyk'), findsOneWidget);
      final checkoutBtn = find.text('PRZEJDŹ DO KASY');
      expect(checkoutBtn, findsOneWidget);
      await tester.tap(checkoutBtn);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // 6. Weryfikacja sekcji Checkoutu
      expect(find.text('Finalizacja zamówienia'), findsOneWidget);
      expect(find.text('1. Adres dostawy'), findsOneWidget);
      expect(find.textContaining('2. Metoda dostawy'), findsOneWidget);
      expect(find.textContaining('3. Płatność'), findsOneWidget);

      // Uwaga: Dalsze kroki (płatność) wymagają realnych danych lub mocków.
      // Test kończymy na weryfikacji gotowości do zapłaty.
    });
  });
}

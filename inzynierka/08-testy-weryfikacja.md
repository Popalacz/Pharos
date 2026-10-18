# 08. Testy i weryfikacja

## Zestaw testów (stan 18.10.2026)

| Plik | Typ | Przypadki | Co sprawdza |
|------|-----|-----------|-------------|
| `test/unit/cart_provider_test.dart` | jednostkowy | 5 | koszyk, synchronizacja, sumy |
| `test/unit/cart_repository_test.dart` | jednostkowy | 2 | endpointy i mapowanie danych |
| `test/unit/analytics_service_test.dart` | jednostkowy | 2 | zdarzenia lejka z parametrem wariantu |
| `test/unit/l10n_arb_test.dart` | jednostkowy | 4 | zgodność kluczy i placeholderów en i pl |
| `test/widget/checkout_widgets_test.dart` | widżetowy | 11 | pasek kroków, formularz gościa, podsumowanie |
| `integration_test/purchase_flow_test.dart` | integracyjny | 1 | ścieżka od strony głównej do potwierdzenia |
| moduł: `tests/` (PHPUnit) | jednostkowy | 4 | bramka bearer, źródło `id_customer` |

Razem po stronie aplikacji 25 przypadków według liczenia wzorców `test(` i `testWidgets(` (dokładną liczbę podaje `flutter test`).

## Wyniki ostatnich przebiegów

- `checkout_widgets_test` i `l10n_arb_test`: 15 z 15 zielonych.
- Pełny `flutter test`: niezaliczone tylko stare przypadki (`cart_provider_test`, 4 przypadki, oraz `widget_test.dart`, błąd ładowania). Nie są związane ze zmianami E4 i E5.
- `dart analyze`: brak błędów w plikach checkoutu, 44 uwagi (ostrzeżenia i informacje, głównie stare). Cały projekt: ok. 205 uwag.

## Czego nie ma (uczciwie)

- Test integracyjny pełnej ścieżki zakupu (TEST-3) istnieje, ale zależy od sieci i prawdziwego backendu i nie był uruchomiony w CI. Do poprawy w E6.
- Test PHPUnit na prawdziwej instalacji PrestaShop (TEST-2).
- Weryfikacja zdarzeń w Firebase DebugView (E3).
- Testy na urządzeniu fizycznym i czytnikiem ekranu (TalkBack).
- Brak automatycznego CI w repozytorium aplikacji.

## Komendy pomiarowe (powtarzalne)

```bash
# tokeny i style
grep -rn "Colors\." lib/ui | wc -l
grep -rn "Theme.of" lib/ui | wc -l
grep -rnE "fontSize: (9|10|11)\b" lib/ui | wc -l
# teksty i dostępność
grep -rnE "Text\((const )?'[^']" lib/ui | wc -l
grep -rn "Semantics(" lib/ui | wc -l
grep -rn "tooltip:" lib/ui | wc -l
grep -rn "autofillHints" lib | wc -l
# rozmiar i testy
find lib -name '*.dart' | wc -l
flutter test
dart analyze lib test
```

## Dla pracy

Wstaw: tabelę zestawu testów, wynik `flutter test` (zrzut terminala, plik 11 sekcja D), tabelę "przed i po" z pliku 05. Wyniki wykonuj tuż przed oddaniem pracy, bo liczby się zmieniają.

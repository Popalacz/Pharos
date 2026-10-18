# 08. Testy i weryfikacja

## Zestaw testów (stan 18.10.2026, po E6)

| Plik | Typ | Przypadki | Co sprawdza |
|------|-----|-----------|-------------|
| `test/unit/cart_provider_test.dart` | jednostkowy | 5 | koszyk, synchronizacja, sumy |
| `test/unit/cart_repository_test.dart` | jednostkowy | 2 | endpointy i mapowanie danych |
| `test/unit/analytics_service_test.dart` | jednostkowy | 2 | zdarzenia lejka z parametrem wariantu |
| `test/unit/l10n_arb_test.dart` | jednostkowy | 4 | zgodność kluczy i placeholderów en i pl |
| `test/unit/form_validation_test.dart` | jednostkowy | 4 | komunikaty walidacji po polsku i angielsku, liczba mnoga „znak/znaki/znaków” |
| `test/widget/checkout_widgets_test.dart` | widżetowy | 11 | pasek kroków, formularz gościa, podsumowanie |
| `integration_test/purchase_flow_test.dart` | integracyjny | 1 | ścieżka od strony głównej do potwierdzenia |
| moduł: `tests/` (PHPUnit) | jednostkowy | 4 | bramka bearer, źródło `id_customer` |

Razem `flutter test` uruchamia 28 przypadków (test integracyjny uruchamia się osobno, na urządzeniu).

## Wyniki ostatnich przebiegów

- `checkout_widgets_test` i `l10n_arb_test`: 15 z 15 zielonych.
- Pełny `flutter test` po E6: **24 z 24 zielone**. Naprawiono `cart_provider_test` (brak inicjalizacji bindingu przy haptyce w `addItem`) i usunięto szablonowy `widget_test.dart` (licznik z generatora, nie dotyczył aplikacji).
- `dart analyze` (lib/core, lib/services, lib/ui/sdui, test, integration_test): 0 błędów, 17 ostrzeżeń i informacji, głównie starych (nieużywane importy). Cały projekt: ok. 205 uwag przed E6.

## Czego nie ma (uczciwie)

- Test integracyjny ścieżki zakupu (TEST-3) zależy od sieci i prawdziwego backendu. W E6 przy błędzie API kończy się niepowodzeniem (wcześniej cicho się zaliczał). **Nie był uruchomiony** (brak urządzenia), a jego teksty (np. `DODAJ DO KOSZYKA`) mogą być nieaktualne po lokalizacji.
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

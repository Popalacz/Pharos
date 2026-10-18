# 10. Ograniczenia i dalsze prace

## Ograniczenia

1. **Eksperyment A/B nie został przeprowadzony.** Hipotezy i narzędzia są gotowe, brak danych.
2. **Przełącznik wariantu bez Remote Config.** Wariant ustawia się w kodzie (domyślnie A).
3. **Audyt statyczny.** Liczby pochodzą z kodu, nie z użycia. Zrzuty z emulatora i test z czytnikiem ekranu nie zostały wykonane.
4. **Kolory poza tokenami (UI-6).** `Colors.*` w `lib/ui`: 524 przed, 529 po E5. PR #13 zamienia 467 użyć na `AppColors` (zostaje 22 `Colors.transparent`), po scaleniu licznik wynosi 22. Przycisk `danger` poprawiony: tło `AppColors.errorFill` (`#C62828`), biały tekst ok. 5,6:1 (wcześniej `#FF5252`, ok. 3:1).
5. ~~Walidatory `FormValidation` po polsku~~ zlokalizowane (en i pl, liczba mnoga w pl) i objęte testem. Otwarte: część błędów w `home_screen.dart`.
6. **Tłumaczenia angielskie robocze**, bez korekty native speakera.
7. **Moduł nietestowany na prawdziwej instalacji PrestaShop** (TEST-2). Test integracyjny aplikacji zależy od sieci.
8. ~~Stare testy niezaliczone~~ naprawione w E6 (24 z 24 zielone). Test integracyjny nadal nieuruchomiony.
9. **Brak CI** w repozytorium aplikacji.
10. **Ryzyka wdrożeniowe E1** opisane w pliku 06 (Authorization w Apache, status płatności, rotacja kluczy).

## Dalsze prace

| Kierunek | Opis |
|----------|------|
| Eksperyment | Dokończyć mechanizm wariantu (Remote Config), zebrać dane, SUS |
| Tokeny | Zamknąć UI-6, przejście na `Theme.of` |
| Lokalizacja | Walidatory i pozostałe komunikaty do ARB, korekta tłumaczeń |
| Testy | CI (analiza i testy na każdym PR), testy na urządzeniu i z TalkBack |
| Bezpieczeństwo | Rotacja kluczy, test PHPUnit na instalacji, zabezpieczenie koszyka gościa |
| Architektura | Zrobione w E6: logger `AppLog`, fabryka klienta HTTP, usunięte puste katalogi. Do zrobienia: podział `checkout_screen.dart` (874 linie) |
| Funkcje | Motyw jasny, tryb offline, publikacja w sklepach z aplikacjami |

## Wnioski do rozwinięcia w pracy

- Audyt oparty na kodzie szybko wskazuje problemy mierzalne (kontrast, brak etykiet, teksty na sztywno), ale nie zastępuje testów z użytkownikami.
- Najwięcej ryzyka niosła warstwa API (brak autoryzacji klienta), nie interfejs.
- Przyrostowa realizacja z osobnymi PR ułatwiła przegląd i cofanie zmian.

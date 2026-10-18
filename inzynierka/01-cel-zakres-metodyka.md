# 01. Cel, zakres i metodyka

## Problem

Sklepy oparte na PrestaShop mają zwykle tylko responsywny front webowy. Aplikacja natywna pozwala na szybsze zakupy, powiadomienia push i płatności mobilne, ale wymaga własnego API, bezpiecznej autoryzacji i dopracowanego interfejsu. Pharos to próba zbudowania takiego rozwiązania "headless": PrestaShop jako zaplecze, Flutter jako klient.

## Cel pracy

Zaprojektowanie i wykonanie aplikacji mobilnej dla sklepu PrestaShop oraz poprawa jej interfejsu i bezpieczeństwa na podstawie audytu, z weryfikacją wpływu uproszczonej ścieżki zakupu na konwersję.

## Cele szczegółowe

1. Zaprojektować architekturę aplikacji i modułu API (plik 02).
2. Zaimplementować katalog, koszyk, checkout, konto, listę życzeń, opinie, powiadomienia (plik 03).
3. Wykonać audyt interfejsu i usunąć wskazane problemy (pliki 04 i 05).
4. Zabezpieczyć komunikację i dostęp do danych klienta (plik 06).
5. Przygotować dwa warianty checkoutu i instrumentację lejka do eksperymentu (plik 07).

## Pytania badawcze i hipotezy

| Pytanie | Hipoteza |
|---------|----------|
| Czy zakup jako gość z autouzupełnianiem zwiększa odsetek ukończonych zamówień? | B ukończy więcej osób niż A |
| Czy skraca czas do zamówienia? | B szybsze dzięki mniejszej liczbie pól |
| Czy zmniejsza liczbę błędów walidacji? | B ma mniej błędów |
| Czy poprawia odczuwaną użyteczność? | B zyska wyższy wynik SUS |
| Czy odroczone zakładanie konta obniża liczbę kont? | Odsetek kont w B zbliżony do A |

## Metodyka

- **Analiza statyczna kodu**: liczenie wystąpień wzorców (`Colors.*`, `Text('...')`, `Semantics`), długości plików, struktury katalogów.
- **Obliczenia kontrastu** wg wzoru WCAG na tokenach kolorów.
- **Przegląd heurystyczny** wg 10 heurystyk Nielsena oraz kryteriów WCAG.
- **Przyrostowa realizacja**: osobne gałęzie i pull requesty, przegląd przed scaleniem (plik 09).
- **Eksperyment kontrolowany A/B** z dwiema grupami, zdarzeniami Firebase Analytics i ankietą SUS (plik 07).

## Zakres

Wchodzi: aplikacja Flutter (Android jako platforma testowa), moduł `pharosapi` dla PrestaShop 8 i 9, poprawki interfejsu, bezpieczeństwa, lokalizacji i dostępności.
Nie wchodzi: własny system płatności, panel administracyjny poza konfiguracją modułu, publikacja w sklepach z aplikacjami, pełne testy obciążeniowe.

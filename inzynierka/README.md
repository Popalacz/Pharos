# Materiały do pracy inżynierskiej: Pharos

Zbiór notatek, diagramów i wizualizacji z realizacji projektu Pharos (aplikacja Flutter + moduł PrestaShop `pharosapi`). Pliki są pisane jako materiał źródłowy: dane i fakty są sprawdzone w kodzie i historii git, a opisy do przeredagowania własnymi słowami w pracy.

Stan danych: 18.10.2026 (po scaleniu PR #1 do #8, PR #9 otwarty).

## Spis plików

| Plik | Rozdział pracy | Zawartość |
|------|----------------|-----------|
| [01-cel-zakres-metodyka.md](01-cel-zakres-metodyka.md) | Wstęp, cel, metodyka | Problem, cel, pytania badawcze, zakres, metody |
| [02-architektura.md](02-architektura.md) | Projekt systemu | Architektura, warstwy, diagramy komponentów i sekwencji |
| [03-implementacja.md](03-implementacja.md) | Implementacja | Stos, moduły, endpointy, SDUI, integracje Google |
| [04-audyt-interfejsu.md](04-audyt-interfejsu.md) | Analiza stanu wyjściowego | Audyt UI z liczbami i heurystykami |
| [05-system-designu.md](05-system-designu.md) | Projekt interfejsu | Tokeny, kontrast, typografia, odstępy, dostępność |
| [06-bezpieczenstwo.md](06-bezpieczenstwo.md) | Bezpieczeństwo | Luki, poprawki E1, diagramy autoryzacji |
| [07-checkout-i-eksperyment.md](07-checkout-i-eksperyment.md) | Część badawcza | Warianty A/B, lejek, plan eksperymentu, SUS |
| [08-testy-weryfikacja.md](08-testy-weryfikacja.md) | Testy | Co przetestowano, wyniki, czego brakuje |
| [09-proces-wytworczy.md](09-proces-wytworczy.md) | Organizacja pracy | Git flow, etapy E0 do E7, oś czasu, nakłady |
| [10-ograniczenia-dalsze-prace.md](10-ograniczenia-dalsze-prace.md) | Podsumowanie | Ograniczenia, ryzyka, dalsze prace |
| [11-zdjecia-i-wizualizacje.md](11-zdjecia-i-wizualizacje.md) | Załączniki | Lista zrzutów do wykonania i gotowe grafiki |
| [12-zrodla.md](12-zrodla.md) | Bibliografia | Normy, heurystyki, dokumentacja |

Grafiki gotowe do wstawienia: `images/` (SVG: paleta, kontrast, makiety wariantów A i B).

## Jak użyć diagramów

Diagramy są w składni Mermaid (blok ` ```mermaid `). Do Worda wyeksportuj je do PNG lub SVG:

```bash
npx @mermaid-js/mermaid-cli -i plik.md -o diagram.png
```

albo wklej kod na mermaid.live i pobierz obraz. SVG z `images/` wstawisz do Worda bezpośrednio (Wstaw, Obrazy).

## Zasady rzetelności (do uwzględnienia w pracy)

- Liczby z audytu (kontrast, liczba tekstów, użyć `Colors.*`) pochodzą z przeszukania kodu z 16.10.2026. Ich stan "po" jest w plikach 05 i 08.
- Wygląd interfejsu na urządzeniu **nie był jeszcze potwierdzony zrzutami**. Lista zrzutów: plik 11.
- Eksperyment A/B (plik 07) **nie został jeszcze przeprowadzony**. Makiety i hipotezy to projekt badania, nie wyniki.
- Tłumaczenia angielskie są robocze, bez korekty native speakera.
- Do uzgodnienia z promotorem: forma opisu użycia narzędzi AI przy tworzeniu kodu i dokumentacji.

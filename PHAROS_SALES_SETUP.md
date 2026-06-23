# Konfiguracja sprzedażowa pharos-api.tech

Checklist konfiguracji sklepu PrestaShop i panelu Pharos przed uruchomieniem aplikacji mobilnej w trybie produkcyjnym (`forceMockData: false`).

## 1. Katalog (PrestaShop BO)

- [ ] Utworzyć 5–8 aktywnych kategorii top-level z przypisanymi produktami (*Katalog → Kategorie*)
- [ ] Każdy produkt: zdjęcie okładki, cena brutto, stan magazynowy (lub „zamówienie bez stanu”), opis, `active=1`
- [ ] Promocje cenowe / ceny specjalne (*Katalog → Promocje*)
- [ ] Opcjonalnie: kategorie „Bestsellery”, „Sale” do sekcji `PRODUCT_GRID` w SDUI

## 2. Checkout (PrestaShop BO)

- [ ] Kurierzy aktywni ze strefami i cenami (*Wysyłka → Kurierzy*)
- [ ] Metody płatności włączone (*Płatności → Metody płatności*)
- [ ] `CartRule` darmowej dostawy (np. kwota ≥ X zł) — włącza pasek postępu w koszyku
- [ ] `CartRule` z kodem rabatowym (np. `APP10`) — włącza pole kodu w koszyku

## 3. Panel Pharos (moduł pharosapi)

- [ ] SDUI home: banery `BANNER_SLIDER`, sekcje `CATEGORY_CHIPS`, `PRODUCT_GRID` z realnymi `id_category` z PS
- [ ] Logo, kolory, typografia (`store_info`, `design_overrides`)
- [ ] Onboarding — slajdy informacyjne (pomijany gdy `slides: []`)
- [ ] Flash sale — `promo_id` = ID istniejącej reguły `CartRule`
- [ ] Kategoria podarunków — `gift_category_id` w ustawieniach modułu

## 4. Lokalizacja

- [ ] Aktywne języki i waluty w PS — przełączniki w app widoczne tylko gdy >1 pozycja

## 5. Konto i zamówienia

- [ ] Klienci testowi z adresami dostawy
- [ ] Stany zamówień PS skonfigurowane (śledzenie w profilu)

## 6. Wdrożenie modułu

- [ ] Moduł `pharosapi` zainstalowany i aktywny na `https://pharos-api.tech`
- [ ] Endpoint testowy: `GET /index.php?fc=module&module=pharosapi&controller=config` zwraca JSON z `carriers`, `payments`, `localization`
- [ ] Klucz API Webservice skonfigurowany w aplikacji (`.env` / secure storage)

## 7. Test E2E (ręczny)

1. Logowanie (email/hasło lub Google)
2. Przeglądanie home SDUI i katalogu
3. Dodanie produktu do koszyka + synchronizacja
4. Zastosowanie kodu rabatowego (gdy skonfigurowany)
5. Checkout: adres → kurier → płatność → zamówienie
6. Historia zamówień w profilu ze `status_name` z API

## Zasada widoczności w aplikacji

| Stan API | Zachowanie UI |
|---|---|
| `[]` / brak klucza | Sekcja pominięta (`SizedBox.shrink()`) |
| Błąd sieci | `NetworkErrorState` + Retry |
| Pusty koszyk użytkownika | Empty State + CTA do katalogu |

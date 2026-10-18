# 03. Implementacja

## Stos technologiczny

| Obszar | Technologia |
|--------|-------------|
| Aplikacja | Flutter, Dart, `provider`, `dio`, `freezed`, `json_serializable`, `sqflite`, `shimmer`, `lottie` |
| Lokalizacja | `flutter gen-l10n`, pliki ARB (en, pl), 186 kluczy w `app_pl.arb` |
| Zaplecze | PrestaShop 8 i 9, moduł PHP `pharosapi` (PSR-12, PHPUnit, PHPStan) |
| Google | Firebase (Analytics, FCM, Crashlytics), Google Sign-In, Google Calendar API, Google Places, Google Pay |
| Urządzenie | Biometria przy płatności, skaner kodów, linki aplikacyjne |

## Ekrany (21)

home, catalog, categories, search, product_details, cart, checkout, order_confirmation, order_tracking, login, profile, edit_profile, address_management, address_form, address_selection, wishlist, review_form, contact, events, scanner, localization_settings.

## Moduł `pharosapi`: endpointy

| Kontroler | Akcje | Źródło klienta (po E1) |
|-----------|-------|------------------------|
| auth | login, register, google_login, update_profile, change_password, register_fcm | token sesji (login i rejestracja go wydają), Google przez zweryfikowany `id_token` |
| address | list, add, update, delete | token sesji |
| order | create, list, details | token sesji (create także dane gościa) |
| cart | get, sync, apply_voucher, remove_voucher, get_shipping_costs | token sesji lub koszyk gościa |
| wishlist | get, toggle | token sesji |
| reviews | add_product_review, add_order_review, get_product_reviews | token sesji |
| products, categories, config, home, payments | listy, szczegóły, wyszukiwanie, filtry | publiczne |
| notifications | process_abandoned_carts | token crona porównywany przez `hash_equals` |

Szczegóły zmian bezpieczeństwa w pliku 06.

## Kluczowe funkcje aplikacji

- **Koszyk z synchronizacją**: lokalny stan w `CartProvider`, każda zmiana ilości wyzwala synchronizację z serwerem, sumy pochodzą z odpowiedzi serwera.
- **Checkout**: adres, dostawa, płatność, kod rabatowy, zakup jako gość i opcjonalne założenie konta po zakupie.
- **Powiadomienia**: FCM, odzyskiwanie porzuconych koszyków po stronie modułu.
- **Wzrost sprzedaży**: pasek darmowej dostawy, ostatnio oglądane, baner odzyskiwania koszyka.
- **Zamówienia w kalendarzu Google**: zdarzenia logistyczne dla nowych zamówień.
- **Bezpieczeństwo urządzenia**: biometria przed finalizacją zamówienia (`security_service`).

## Obsługa błędów

Interceptor `pharos_api_interceptor.dart` czyści odpowiedzi JSON (obsługa śmieci przed i po JSON) i mapuje błędy sieci na komunikaty. Niepowodzenie ładowania przewoźników i płatności pokazuje komunikat zamiast pustego ekranu.

## Dla pracy

Wstaw: tabelę stosu, tabelę endpointów (skrócona), diagram sekwencji z pliku 02. Zrzuty ekranów: plik 11 (sekcje A i B).

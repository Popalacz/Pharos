# Pharos

Aplikacja mobilna Flutter dla sklepu PrestaShop (headless commerce), rozwijana jako praca inżynierska. Backend to moduł `pharosapi` w osobnym repozytorium (`Popalacz/Pharos-Api`). Katalog `prestashop_module/` w tym repozytorium jest ignorowany przez git i służy tylko jako lokalna kopia robocza.

## Funkcje

* **Server-Driven UI:** układ ekranu głównego pochodzi z JSON-a z modułu, z lokalnym zapasowym układem.
* **Zakup jako gość** z opcjonalnym założeniem konta po zakupie.
* **Checkout w dwóch wariantach** (A: jedna strona, B: kroki Adres, Dostawa, Płatność) do eksperymentu A/B.
* **Analityka lejka** (Firebase Analytics): `view_cart`, `begin_checkout`, `checkout_step_complete`, `checkout_validation_error`, `purchase`, `account_created_after_purchase`, każde z parametrem `checkout_variant`.
* **Logowanie** e-mailem i przez Google, powiadomienia FCM, lista życzeń, opinie, skaner kodów.
* **Lokalizacja** en i pl (gen-l10n, pliki ARB w `lib/l10n/`).
* **System designu:** tokeny kolorów i odstępów w `lib/core/theme/`, kontrast zgodny z WCAG AA dla tekstu.

## Stos technologiczny

* Flutter i Dart, stan: `provider` (`ChangeNotifier`), bez BLoC.
* Sieć: `dio` z jedną fabryką klienta (`lib/core/network/http_client.dart`) i interceptorem Pharos.
* Modele: `freezed` i `json_serializable`. Błędy: `Either` z `fpdart`.
* Logowanie: `AppLog` (`lib/core/utils/app_logger.dart`), w wydaniu wyłączone.
* Backend: moduł PHP `pharosapi`. Uwierzytelnianie klienta tokenem sesji (`Authorization: Bearer`), klucz API i token nie są w kodzie aplikacji.

## Struktura

```text
lib/
├── core/      # konfiguracja API, sieć, providery, serwisy, motyw, narzędzia
├── data/      # modele i repozytoria
├── l10n/      # tłumaczenia (ARB)
├── services/  # integracja z Google Calendar
└── ui/        # ekrany, widżety, sekcje SDUI
test/          # testy jednostkowe i widżetowe
integration_test/  # test ścieżki zakupu (wymaga urządzenia i backendu)
inzynierka/    # materiały do pracy dyplomowej
```

## Uruchomienie

1. `flutter pub get`
2. Skonfiguruj adres sklepu i klucz w `lib/core/api/api_config.dart` oraz `GOOGLE_SERVER_CLIENT_ID` przez `--dart-define` (dodaj SHA-1 w Firebase).
3. `flutter run`

Moduł `pharosapi` w wersji 1.0.2 lub nowszej musi być wdrożony **przed** aplikacją, bo aplikacja zakłada uwierzytelnianie tokenem po stronie serwera.

## Testy

```bash
flutter test                 # jednostkowe i widżetowe
flutter test integration_test # wymaga urządzenia i działającego backendu
dart analyze lib test
```

Test ścieżki zakupu wymaga sieci i prawdziwych danych sklepu. Przy błędzie połączenia kończy się niepowodzeniem, a nie cichym zaliczeniem.

## Dokumentacja

`PHAROS_ARCHITECTURE_GUIDE.md`, `PHAROS_PRESTASHOP_INTEGRATION.md`, `PHAROS_BACKOFFICE_CONFIG.md`, `PHAROS_MODULE_GUIDELINES.md`, `PHAROS_SALES_SETUP.md`, `PHAROS_TEST_CHECKLIST.md`.

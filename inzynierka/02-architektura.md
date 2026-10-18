# 02. Architektura systemu

Dane z przeszukania kodu (stan 16.10.2026): 103 pliki Dart w `lib/` (ok. 16,2 tys. linii; po zmianach E4 i E5: 108 plików, ok. 18,2 tys. linii), 21 ekranów, 12 repozytoriów, 10 providerów stanu. Moduł: 16 kontrolerów front i 1 admin, 78 plików PHP w `src/` z kontrolerami, 2 tabele (lista życzeń, tokeny FCM).

## Widok ogólny

```mermaid
flowchart LR
    subgraph Klient[Aplikacja Flutter]
        UI[Ekrany i widgety]
        ST[Provider: stan]
        RE[Repozytoria]
        API[ApiService Dio + interceptor]
        UI --> ST --> RE --> API
    end
    subgraph Zaplecze[PrestaShop 8/9]
        MOD[Moduł pharosapi: kontrolery front]
        WS[Webservice PrestaShop]
        DB[(Baza danych)]
        MOD --> DB
        WS --> DB
    end
    subgraph Google
        FB[Firebase: Analytics, FCM, Crashlytics]
        GS[Google Sign-In]
        GP[Google Places]
        GC[Google Calendar]
    end
    API -- HTTPS + Bearer --> MOD
    API -- HTTPS ws_key --> WS
    UI --> FB
    UI --> GS
    UI --> GP
    ST --> GC
```

## Warstwy aplikacji

```mermaid
flowchart TB
    A[ui/screens + ui/widgets] --> B[core/providers - stan]
    B --> C[data/repositories - 12]
    C --> D[core/network/api_service.dart]
    C --> M[data/models - freezed + json_serializable]
    B --> S[core/services: analytics, security, notification, payment, scanner, deeplink, database sqflite]
    A --> T[core/theme: app_colors, app_spacing, app_theme]
    A --> L[l10n: ARB en, pl]
```

Rzeczywista struktura różni się od opisanej w pierwotnym README (Clean Architecture z warstwą `domain/`, BLoC, JWT). W kodzie nie ma katalogu `domain/`, nie ma BLoC (tylko `provider`), a uwierzytelnianie opiera się na kluczu `ws_key` i, od E1, tokenie sesji. README zostanie dostosowane w E6 (plik 09).

## Przepływ zamówienia (sekwencja)

```mermaid
sequenceDiagram
    participant U as Użytkownik
    participant A as Aplikacja
    participant M as pharosapi
    participant P as PrestaShop
    U->>A: Dodaje produkt do koszyka
    A->>M: cart/sync
    M->>P: aktualizacja koszyka
    M-->>A: sumy, koszyk
    U->>A: Przechodzi do checkoutu
    A->>A: zdarzenie begin_checkout
    A->>M: pobranie przewoźników i płatności
    U->>A: Potwierdza (biometria)
    A->>M: order/create
    M->>P: utworzenie zamówienia
    M-->>A: id zamówienia
    A->>A: zdarzenie purchase
```

## Strona główna sterowana z serwera (SDUI)

Układ składa `sdui_mapper.dart` z konfiguracji modułu. Pięć typów sekcji: `BannerSlider`, `CategoryChips`, `SectionHeader`, `ProductGrid`, `Recommendations`. Zmiana układu w panelu administratora PrestaShop nie wymaga aktualizacji aplikacji.

```mermaid
flowchart LR
    BO[Panel admin: AdminPharosApiSettings] --> CFG[Konfiguracja sekcji]
    CFG --> EP[endpoint home / config]
    EP --> MAP[sdui_mapper.dart]
    MAP --> W[Widgety sekcji na ekranie głównym]
```

## Model danych modułu

Dwie własne tabele: lista życzeń (klient, produkt) oraz tokeny FCM (klient, token urządzenia). Pozostałe dane (koszyki, zamówienia, adresy, opinie) korzystają ze struktur PrestaShop.

## Gdzie wstawić diagramy

Diagram widoku ogólnego do rozdziału "Projekt systemu", sekwencję zamówienia do opisu realizacji checkoutu, SDUI do opisu konfiguracji zaplecza.

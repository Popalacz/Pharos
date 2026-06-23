# 🏗️ Pharos Project - Architecture & UX Standards Guide

Ten dokument opisuje standardy techniczne wdrożone w projekcie Pharos, zapewniające wydajność 60+ FPS, politykę zero-crash oraz pełną integrację z PrestaShop 8/9.

---

## 1. Core Architecture (Clean Architecture)
Aplikacja jest podzielona na warstwy, co zapewnia separację logiki biznesowej od prezentacji.

*   **Data Layer (`lib/data/`)**: Repozytoria i modele. Obsługują surowe dane z PrestaShop.
    *   *Przykład:* `lib/data/repositories/product_repository.dart`
*   **Domain Layer (`lib/core/providers/`)**: Stan aplikacji i logika biznesowa (używamy Provider/ChangeNotifier).
    *   *Przykład:* `lib/core/providers/cart_provider.dart`
*   **Presentation Layer (`lib/ui/`)**: Widgety i ekrany. Tylko UI.
    *   *Przykład:* `lib/ui/screens/home_screen.dart`

---

## 2. Server-Driven UI (SDUI)
Układ ekranu głównego jest dynamicznie budowany na podstawie JSON-a z PrestaShop.

*   **Implementacja:** `HomeScreen` w `lib/ui/screens/home_screen.dart` metodą `_buildUnifiedSection`.
*   **Fallback:** Jeśli API zawiedzie, metoda `_getLegacySections` dostarcza stabilną strukturę lokalną.

---

## 3. UI/UX & State Handling (4 Mandatory States)
Każdy widok pobierający dane musi implementować 4 stany:

1.  **LOADING**: Używamy **Shimmer** (Skeleton Loaders).
    *   *Przykład:* `lib/ui/widgets/product_shimmer.dart` użyty w `HomeScreen`.
2.  **SUCCESS**: Responsywny układ z użyciem `Sliver` dla płynnego przewijania.
    *   *Przykład:* `CustomScrollView` w `lib/ui/screens/home_screen.dart`.
3.  **ERROR**: Czytelny komunikat + przycisk "Spróbuj ponownie".
    *   *Przykład:* `_buildErrorState()` w `HomeScreen`.
4.  **EMPTY**: Pusty koszyk/lista z jasnym wezwaniem do działania (CTA).
    *   *Przykład:* `_buildEmptyCart()` w `lib/ui/screens/cart_screen.dart`.

---

## 4. Defensywne Parsowanie (Zero-Crash Policy)
Backend PrestaShop bywa niespójny. Aplikacja musi przetrwać każdą daną.

*   **Pancerny Parser:** Metoda `ProductModel.fromJson` w `lib/data/models/product_model.dart`.
    *   Obsługuje brakujące zdjęcia (`_stabilizeImageUrl`).
    *   Obsługuje różne formaty cen (`parsePrice`).
    *   Obsługuje lokalizowane pola tekstowe (`parseString`).

---

## 5. Walidacja zgodna z PrestaShop
Walidacja po stronie Fluttera musi być lustrzanym odbiciem klasy `Validate.php` z PrestaShop.

*   **Implementacja:** `lib/ui/screens/login_screen.dart` (metody `_emailValidator`, `_passwordValidator`).
*   **Reguły:** Min. 5 znaków dla hasła, regex dla emaila, blokada znaków HTML w polach tekstowych.

---

## 6. Performance (60+ FPS)
*   **Repaint Boundaries:** Izolacja ciężkich widgetów.
    *   *Przykład:* `PharosProductCard` w `lib/ui/widgets/pharos_product_card.dart`.
*   **Image Optimization:** Użycie `memCacheWidth` dla miniatur.
    *   *Przykład:* `CachedNetworkImage` w `PharosProductCard`.
*   **Const Constructors:** Masowe użycie `const` w całym projekcie.

---

## 7. Google Ecosystem
*   **Google Pay & BLIK:** Symulacja procesów w `lib/core/services/payment_service.dart`.
*   **Calendar API:** Automatyzacja logistyki zamówień w `lib/services/google_calendar_service.dart`.
*   **FCM:** Notyfikacje w `lib/core/services/notification_service.dart`.

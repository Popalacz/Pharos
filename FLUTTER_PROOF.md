# Pharos — Flutter Proof (wymagania projektowe)

Dokument potwierdza spełnienie wymagań akademicznych dla aplikacji mobilnej **Pharos** (headless e-commerce, PrestaShop + Flutter).

---

## 1. Dane z API (własne API)

**Backend:** moduł PrestaShop `pharosapi` + WebService  
**Konfiguracja:** `lib/core/api/api_config.dart` → `https://pharos-api.tech/api`

| Ekran / warstwa | Co pobiera | Endpoint / repozytorium |
|---|---|---|
| **HomeScreen** | Layout SDUI (bannery, siatka produktów, chipy kategorii) | `GET /index.php?fc=module&module=pharosapi&controller=home` |
| **CategoriesScreen** | Lista kategorii | `CategoryRepository.getCategories()` |
| **CatalogScreen** | Produkty z filtrami | `ProductRepository.getProducts()` |
| **SearchScreen** | Autouzupełnianie + wyniki wyszukiwania | `SearchProvider` → API `pharosapi` |
| **ProductDetailsScreen** | Opinie, podobne produkty | `ReviewRepository`, `ProductRepository.getRelatedProducts()` |
| **WishlistScreen** | Ulubione produkty | `WishlistRepository` |
| **CartScreen** | Koszyk, synchronizacja | `CartRepository` |
| **CheckoutScreen** | Przewoźnicy, płatności, vouchery | `CheckoutRepository` |
| **ProfileScreen** | Historia zamówień | `OrderRepository.getCustomerOrders()` |
| **OrderTrackingScreen** | Szczegóły zamówienia (refresh) | `OrderRepository.getOrderDetails()` |
| **ContactScreen** | Adres sklepu, godziny, współrzędne | `SettingsProvider` (config z API) |
| **LoginScreen** | Logowanie / rejestracja | `AuthRepository` → `pharosapi` |

Wszystkie repozytoria w `lib/data/repositories/` używają parametru `module=pharosapi`.

---

## 2. Minimalna liczba ekranów (≥ 4)

**Główna nawigacja** (`lib/main.dart`, `BottomNavigationBar`) — **5 ekranów**:

| # | Ekran | Plik |
|---|---|---|
| 1 | Strona główna | `lib/ui/screens/home_screen.dart` |
| 2 | Ulubione | `lib/ui/screens/wishlist_screen.dart` |
| 3 | Koszyk | `lib/ui/screens/cart_screen.dart` |
| 4 | Kontakt | `lib/ui/screens/contact_screen.dart` |
| 5 | Konto / profil | `lib/ui/screens/profile_screen.dart` |

**Dodatkowe ekrany** (drawer / nawigacja w głąb): `CategoriesScreen`, `CatalogScreen`, `SearchScreen`, `ProductDetailsScreen`, `CheckoutScreen`, `OrderTrackingScreen`, `OrderConfirmationScreen`, `EventsScreen`, `LoginScreen` i inne.

---

## 3. Mapa (Google Maps / OpenStreetMap)

| Ekran | Technologia | Gdzie w kodzie |
|---|---|---|
| **ContactScreen** | Google Maps | widget `_ContactMapSection` — mapa sklepu z markerem |
| **OrderTrackingScreen** | Google Maps | metoda `_buildMapHeader()` — trasa kuriera, markery magazyn/adres/kurier |

**OpenStreetMap** — nie zaimplementowane (brak `flutter_map` / OSM w projekcie).

---

## 4. Zmiana sposobu prezentacji danych przez `setState()`

| Ekran | Co się zmienia | Mechanizm |
|---|---|---|
| **HomeScreen** | Po wyborze chipa kategorii przebudowuje się cały widok SDUI (inne sekcje/produkty z API) | `_onCategorySelected()` → `setState()` → `_loadData()` |
| **CheckoutScreen** | Przełączenie formularza gościa ↔ karta adresu zalogowanego użytkownika | `setState()` + `AnimatedSwitcher` w `_buildAnimatedAddressSection()` |
| **SearchScreen** | Pusty stan → lista sugestii → siatka wyników | `_isListening` via `setState()` + `SearchProvider` |
| **ProductDetailsScreen** | Galeria zdjęć — zmiana aktywnego slajdu i wskaźników | `setState(() => _currentImageIndex = index)` w `PageView` |

**Rekomendowane do raportu:** `HomeScreen` (filtrowanie kategorii przebudowuje widok) lub `CheckoutScreen` (zmiana layoutu adresu).

---

## 5. Animacja na ekranie

| Ekran / komponent | Rodzaj animacji | Szczegóły |
|---|---|---|
| **OrderConfirmationScreen** | Pojawienie się elementów + Lottie | `AnimationController`, `FadeTransition`, animacja sukcesu po zakupie |
| **main.dart** + karty produktów | Ruch produktu do koszyka | `AddToCartAnimation` — produkt „leci” do ikony koszyka |
| **PharosProductCard** | Trigger animacji fly-to-cart | `triggerFlyToCart()` w `UiFeedbackProvider` |
| **CheckoutScreen** | Fade + slide, zmiana kształtu | `AnimatedSwitcher`, `AnimatedContainer` (przewoźnik, płatność) |
| **ProductImageGallery** | Zmiana kształtu miniatur | `AnimatedContainer` przy wyborze zdjęcia |
| **WishlistScreen / CartScreen** | Animacja Lottie | pusty stan koszyka / listy życzeń |
| **ShimmerWave** (widget) | Fala skeleton loadera | `AnimationController` + `AnimatedBuilder` |

**Rekomendowane do raportu:** `OrderConfirmationScreen` (pełna animacja na poziomie ekranu) lub animacja „fly to cart” w `main.dart`.

---

## 6. To NIE jest aplikacja TODO

Aplikacja to **headless e-commerce** (PrestaShop + Flutter): katalog, koszyk, checkout, śledzenie zamówień, ulubione, kontakt ze sklepem.

---

## Checklista wymagań

| Wymaganie | Status | Gdzie |
|---|---|---|
| API (własne) | ✅ | `pharosapi` + repozytoria, m.in. `HomeScreen` |
| ≥ 4 ekrany | ✅ | 5 w bottom nav + ~15 pod-ekranów |
| Mapa | ✅ Google Maps | `ContactScreen`, `OrderTrackingScreen` |
| OpenStreetMap | ❌ | brak |
| `setState()` — zmiana widoku | ✅ | `HomeScreen`, `CheckoutScreen` |
| Animacja | ✅ | `OrderConfirmationScreen`, `AddToCartAnimation` |
| Nie TODO | ✅ | e-commerce Pharos |

---

## Kluczowe pliki

```
lib/main.dart                          — nawigacja główna (5 ekranów), animacja koszyka
lib/core/api/api_config.dart           — konfiguracja API
lib/data/repositories/                 — warstwa dostępu do pharosapi
lib/ui/screens/home_screen.dart        — SDUI + setState (kategorie)
lib/ui/screens/contact_screen.dart     — Google Maps (sklep)
lib/ui/screens/order_tracking_screen.dart — Google Maps (kurier)
lib/ui/screens/checkout_screen.dart    — setState + AnimatedSwitcher
lib/ui/screens/order_confirmation_screen.dart — AnimationController + Lottie
lib/ui/widgets/pharos_product_card.dart — fly-to-cart animation
prestashop_module/pharosapi/           — własne API backendu
```

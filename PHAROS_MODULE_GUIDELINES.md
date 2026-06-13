# Pharos Project - Backend (PrestaShop) Development Guidelines

## 1. Cel Architektoniczny
Moduł `pharos_api` ma przekształcić PrestaShop w system **Headless Commerce**. PrestaShop zarządza logiką biznesową, a aplikacja Flutter (Pharos Mobile) odpowiada za prezentację.

## 2. Standardy API
- **Format:** Wszystkie odpowiedzi MUSZĄ być w formacie JSON.
- **Parametry:** Zawsze dodawaj `&output_format=JSON` do natywnych endpointów webservice.
- **Bezpieczeństwo:** Wykorzystaj klucze API Webservice z ograniczonymi uprawnieniami (ACL).
- **CORS:** Upewnij się, że nagłówki pozwalają na komunikację z aplikacji mobilnej.

## 3. SDUI & Configuration Endpoint
**URL:** `/module/pharos_api/config`
**Metoda:** `GET`
**Zwraca:**
- `store_info`: Nazwa, URL logo, kolor przewodny.
- `home_config`: Tablica sekcji (BANNER_SLIDER, CATEGORY_CHIPS, PRODUCT_GRID).
- `localization`: Lista aktywnych języków i walut z kursami.

## 4. API Endpoint Map (Niezbędne do działania aplikacji)

### Produkty i Discovery:
- `GET /products?display=full&output_format=JSON` - Lista produktów.
- `GET /products?filter[name]=%query%` - Wyszukiwarka.
- `GET /products?filter[ean13]=code` - Skaner EAN.
- `GET /categories?display=full` - Kategorie dla Chipsów.

### Konta i Adresy:
- `GET /addresses?filter[id_customer]=ID` - Lista adresów klienta.
- `POST /addresses` - Dodanie nowego adresu.
- `DELETE /addresses/ID` - Usunięcie adresu.

### Koszyk i Zamówienia (Checkout):
- `GET /carriers?id_address_delivery=ID` - Lista dostępnych kurierów dla adresu.
- `GET /module/pharos_api/payments` - Lista aktywnych metod płatności w aplikacji.
- `POST /orders` - Finalizacja zamówienia (Tworzenie zamówienia w PrestaShop).

### Funkcje Społecznościowe i Push:
- `GET /module/pharos_api/wishlist` - Pobranie ulubionych.
- `POST /module/pharos_api/wishlist/toggle` - Dodaj/Usuń z ulubionych.
- `GET /module/pharos_api/reviews?id_product=ID` - Pobranie opinii (moduł productcomments).
- `POST /module/pharos_api/fcm-token` - Rejestracja tokena Push urządzenia.

## 5. UI/UX Settings (Zarządzanie z Panelu PrestaShop)
Administrator w panelu modułu musi mieć możliwość:
- Zmiany nazwy wyświetlanej sklepu (`PHAROS_STORE_NAME`).
- Wgrania logotypu aplikacji (`PHAROS_LOGO_URL`).
- Zarządzania banerami (grafika + link do produktu).
- Włączania/wyłączania metod płatności (BLIK, Google Pay).
- Podglądu logów z Google Calendar Automation.


## 6. Wydajność
- Stosuj Cache dla ciężkich zapytań SQL (np. lista produktów na stronie głównej).
- Obrazy produktów powinny być serwowane w formatach zoptymalizowanych (WebP/JPG) przez natywny mechanizm PrestaShop.

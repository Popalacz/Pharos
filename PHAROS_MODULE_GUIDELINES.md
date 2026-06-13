# Pharos Project - Backend (PrestaShop) Development Guidelines

## 1. Cel Architektoniczny
Moduł `pharos_api` ma przekształcić PrestaShop w system **Headless Commerce**. PrestaShop zarządza logiką biznesową, a aplikacja Flutter (Pharos Mobile) odpowiada za prezentację.

## 2. Standardy API
- **Format:** Wszystkie odpowiedzi MUSZĄ być w formacie JSON.
- **Parametry:** Zawsze dodawaj `&output_format=JSON` do natywnych endpointów webservice.
- **Bezpieczeństwo:** Wykorzystaj klucze API Webservice z ograniczonymi uprawnieniami (ACL).
- **CORS:** Upewnij się, że nagłówki pozwalają na komunikację z aplikacji mobilnej.

## 2. Dynamiczne Źródła Danych (1:1 z PrestaShop)
Moduł `pharos_api` nie powinien posiadać własnej bazy aktywnych walut czy metod płatności. Dane muszą być pobierane z klas rdzennych:
- **Waluty:** `Currency::getCurrencies(true, true)`
- **Języki:** `Language::getLanguages(true, Context::getContext()->shop->id)`
- **Metody Płatności:** Pobranie listy modułów z hookiem `displayPaymentEU` lub `actionPaymentOptions`.
- **Kurierzy:** `Carrier::getCarriers(...)` z uwzględnieniem stref i grup klientów.

## 3. SDUI & Configuration Endpoint
**URL:** `/module/pharos_api/config`
Endpoint ten musi agregować dane z:
1. Tabeli `ps_configuration` (branding, kolory).
2. Tabeli modułu (układ sekcji strony głównej).
3. Klasy `Language` i `Currency` (aktualnie dostępne opcje).

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

## 5. Google Calendar Automation (Integracja Serwerowa)
Przy każdym nowym zamówieniu (`hookActionValidateOrder`), moduł PHP powinien:
1. Pobrać `Service Account JSON` z konfiguracji modułu.
2. Użyć biblioteki `google/apiclient` do autoryzacji.
3. Dodać wpis do `Kalendarza ID` z danymi zamówienia.

## 6. Narzędzia Rozwoju
Moduł musi wystawiać logi w formacie przyjaznym dla Fluttera (`tail -f` logów API), abyś mógł śledzić błędy w czasie rzeczywistym podczas developmentu.

## 7. Deep Linking & SEO (Growth Hacks)
Moduł `pharos_api` musi generować tzw. **Universal Links** (iOS) oraz **App Links** (Android).
- Każdy link do produktu na stronie WWW powinien mieć swój odpowiednik otwierający aplikację: `https://twojsklep.pl/produkt-id` -> otwiera `ProductDetailsScreen(id)`.

## 9. Real-time Stock Management
Aplikacja musi otrzymywać precyzyjne dane o dostępności:
- `quantity`: Aktualny stan magazynowy.
- `out_of_stock`: Flaga czy zezwalać na zamówienia po wyczerpaniu (0 - nie, 1 - tak, 2 - globalne).
- `minimal_quantity`: Minimalna ilość do koszyka.
- API musi zwracać błąd 409 (Conflict), jeśli w momencie finalizacji zamówienia produkt został wyprzedany.

## 10. Accessibility (Włączanie Cyfrowe)
Wszystkie widgety Fluttera muszą posiadać atrybuty `Semantics`. Obrazy produktów muszą mieć opis alternatywny (`alt_text`) przesyłany z PrestaShop.



## 6. Wydajność
- Stosuj Cache dla ciężkich zapytań SQL (np. lista produktów na stronie głównej).
- Obrazy produktów powinny być serwowane w formatach zoptymalizowanych (WebP/JPG) przez natywny mechanizm PrestaShop.

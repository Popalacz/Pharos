# Pharos Project - Backend (PrestaShop) Development Guidelines

## 1. Cel Architektoniczny
Moduł `pharos_api` ma przekształcić PrestaShop w system **Headless Commerce**. PrestaShop zarządza logiką biznesową, a aplikacja Flutter (Pharos Mobile) odpowiada za prezentację.

## 2. Standardy API
- **Format:** Wszystkie odpowiedzi MUSZĄ być w formacie JSON.
- **Parametry:** Zawsze dodawaj `&output_format=JSON` do natywnych endpointów webservice.
- **Bezpieczeństwo:** Wykorzystaj klucze API Webservice z ograniczonymi uprawnieniami (ACL).
- **CORS:** Upewnij się, że nagłówki pozwalają na komunikację z aplikacji mobilnej.

## 3. SDUI (Server-Driven UI) - Specyfikacja
Punkt końcowy `/module/pharos_api/config` musi zwracać strukturę zgodną z modelami Flutter:
- `BANNER_SLIDER`: Tablica obiektów `image` i `title`.
- `CATEGORY_CHIPS`: Lista kategorii z ikonami.
- `PRODUCT_GRID`: Dynamiczna lista ID produktów.

## 4. Integracja Google Ecosystem
### Google Calendar Automation:
Przy hooku `actionValidateOrder`, moduł powinien:
1. Pobrać dane o nowym zamówieniu.
2. Sformatować je dla Google Calendar (zgodnie ze strukturą `orderId`, `customerName`, `totalAmount`).
3. Wysłać powiadomienie do aplikacji (poprzez Firebase FCM) lub bezpośrednio do API Google, jeśli administrator jest zalogowany.

### Firebase FCM:
Implementacja w PHP wysyłania powiadomień Push przy:
- Zmianie statusu zamówienia.
- Porzuconym koszyku (CRON job co 24h).

## 5. UI/UX Settings (Zarządzanie z Panelu PrestaShop)
Administrator w panelu modułu musi mieć możliwość:
- Zmiany koloru przewodniego aplikacji (`PHAROS_PRIMARY_COLOR`).
- Włączania/wyłączania trybu "Tylko dla zalogowanych".
- Wyboru metod płatności aktywnych w aplikacji (Google Pay, BLIK).

## 6. Wydajność
- Stosuj Cache dla ciężkich zapytań SQL (np. lista produktów na stronie głównej).
- Obrazy produktów powinny być serwowane w formatach zoptymalizowanych (WebP/JPG) przez natywny mechanizm PrestaShop.

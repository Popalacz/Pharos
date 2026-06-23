# 🚀 Pharos PrestaShop Integration Guide

Aby aplikacja Pharos działała błyskawicznie i stabilnie, przygotowałem dedykowany "Gateway Controller" dla Twojego modułu `pharosapi`.

## 1. Dedykowany Kontroler (PHP)
Skopiuj poniższą logikę do swojego modułu PrestaShop (`/modules/pharosapi/controllers/front/gateway.php`). Ten kontroler agreguje wszystkie dane potrzebne aplikacji w jednym zapytaniu, co eliminuje opóźnienia sieciowe.

```php
<?php
class PharosApiGatewayModuleFrontController extends ModuleFrontController {
    public function initContent() {
        header('Content-Type: application/json');
        
        $action = Tools::getValue('action');
        $response = ['status' => 'error', 'message' => 'Invalid action'];

        try {
            switch ($action) {
                case 'boot':
                    // Zwraca wszystko co potrzebne na start (Layout + Config)
                    $response = [
                        'status' => 'success',
                        'config' => Configuration::getMultiple(['PS_SHOP_NAME', 'PS_STREET', 'PS_CITY']),
                        'home_layout' => $this->getHomeLayout(),
                        'currencies' => Currency::getCurrencies(false, true),
                        'languages' => Language::getLanguages(true, $this->context->shop->id)
                    ];
                    break;
                    
                case 'sync_cart':
                    // Ultra-bezpieczna synchronizacja koszyka
                    $id_cart = (int)Tools::getValue('id_cart');
                    $id_customer = (int)Tools::getValue('id_customer');
                    $items = json_decode(file_get_contents('php://input'), true)['items'];
                    
                    $cart = new Cart($id_cart);
                    if (!Validate::isLoadedObject($cart)) {
                        $cart = new Cart();
                        $cart->id_currency = $this->context->currency->id;
                        $cart->id_lang = $this->context->language->id;
                        $cart->id_customer = $id_customer;
                        $cart->add();
                    }
                    
                    // Czyścimy i dodajemy na nowo (Single Source of Truth)
                    $cart->deleteProducts();
                    foreach ($items as $item) {
                        $cart->updateQty($item['quantity'], $item['id_product'], $item['id_product_attribute']);
                    }
                    
                    $response = [
                        'status' => 'success',
                        'id_cart' => $cart->id,
                        'total' => $cart->getOrderTotal(),
                        'total_products' => $cart->getOrderTotal(false, Cart::ONLY_PRODUCTS)
                    ];
                    break;
            }
        } catch (Exception $e) {
            $response = ['status' => 'error', 'message' => $e->getMessage()];
        }

        die(json_encode($response));
    }

    private function getHomeLayout() {
        // Tu możesz zdefiniować SDUI (Server-Driven UI)
        return [
            ['type' => 'BANNER_SLIDER', 'items' => [['image' => 'url', 'title' => 'Sale']]],
            ['type' => 'PRODUCT_GRID', 'items' => Product::getNewProducts(1, 0, 4)]
        ];
    }
}
```

## 2. Dostęp do obrazów (BARDZO WAŻNE)
Aby obrazy zawsze działały bez błędów 403/401, dodaj to do swojego pliku `.htaccess` w głównym katalogu PrestaShop:

```apache
<IfModule mod_headers.c>
    Header set Access-Control-Allow-Origin "*"
</IfModule>
```

## 3. Przełączanie trybu w aplikacji (Flutter)
W pliku `lib/core/api/api_config.dart` znajdziesz stałą:

```dart
static const bool forceMockData = false;
```

*   Ustaw na `true` -> Aplikacja używa **Google/Mock Data**. Idealne do testów UI bez internetu.
*   Ustaw na `false` -> Aplikacja łączy się z **Twoją Prestą**.

## 4. Bezpieczeństwo
Aplikacja Pharos używa autoryzacji `Basic Auth` przez WebService Key. Upewnij się, że w panelu PrestaShop (Zaawansowane -> WebService) Twój klucz ma uprawnienia (GET/POST/PUT) dla:
*   `products`, `categories`, `carts`, `orders`, `addresses`, `customers`.

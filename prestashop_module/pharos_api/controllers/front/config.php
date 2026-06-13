<?php
/**
 * Kontroler wystawiający konfigurację SDUI dla aplikacji Flutter
 */

class Pharos_ApiConfigModuleFrontController extends ModuleFrontController
{
    public function initContent()
    {
        header('Content-Type: application/json');

        $config = [
            'store_info' => [
                'name' => Configuration::get('PS_SHOP_NAME'),
                'primary_color' => Configuration::get('PHAROS_PRIMARY_COLOR') ?: '#FF9800',
                'currency' => Context::getContext()->currency->iso_code,
            ],
            'home_config' => $this->getHomeLayout(),
        ];

        die(json_encode($config));
    }

    private function getHomeLayout()
    {
        // W przyszłości dane te będą pobierane z bazy danych modułu (z Panelu Admina)
        return [
            ['type' => 'BANNER_SLIDER', 'data' => $this->getBanners()],
            ['type' => 'CATEGORY_CHIPS', 'data' => $this->getCategories()],
            ['type' => 'SECTION_HEADER', 'data' => ['title' => 'Polecane dla Ciebie']],
            ['type' => 'PRODUCT_GRID', 'data' => 'featured_products']
        ];
    }

    private function getBanners() { /* Logika pobierania banerów */ }
    private function getCategories() { /* Logika pobierania kategorii */ }
}

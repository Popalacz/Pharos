<?php
/**
 * PHAROS - Headless E-commerce API Module
 *
 * @author    Patrycja & Pharos Architect
 * @copyright 2024 Pharos
 * @license   Proprietary
 */

if (!defined('_PS_VERSION_')) {
    exit;
}

class Pharos_Api extends Module
{
    public function __construct()
    {
        $this->name = 'pharos_api';
        $this->tab = 'front_office_features';
        $this->version = '1.0.0';
        $this->author = 'Pharos';
        $this->need_instance = 0;
        $this->bootstrap = true;

        parent::__construct();

        $this->displayName = $this->l('Pharos Headless API');
        $this->description = $this->l('Zasila aplikację Flutter danymi SDUI, integruje Kalendarz Google i zarządza Omnichannel.');
        $this->ps_versions_compliancy = ['min' => '1.7', 'max' => _PS_VERSION_];
    }

    public function install()
    {
        return parent::install()
            && $this->registerHook('actionValidateOrder') // Dla Google Calendar
            && $this->registerHook('displayAdminProductsExtra'); // Dla SDUI opcji produktu
    }

    // Hook wyzwalany po złożeniu zamówienia - tutaj integrujemy Google Calendar API
    public function hookActionValidateOrder($params)
    {
        $order = $params['order'];
        $customer = $params['customer'];

        // Logika wysyłania danych do Google Calendar API (przez Firebase FCM lub bezpośrednio)
        // Wytyczne w pliku PHAROS_GUIDELINES.md
    }

    public function getContent()
    {
        // Panel admina ogranicza się do:
        // 1. Kolorów mobile
        // 2. Zarządzania kolejnością sekcji SDUI
        // 3. Konfiguracji Firebase
        return $this->renderConfigForm();
    }

    protected function renderConfigForm()
    {
        $helper = new HelperForm();
        // ... standardowa logika HelperForm dla PHAROS_PRIMARY_COLOR, PHAROS_SDUI_LAYOUT itp.
        return $helper->generateForm([/* pola konfiguracji */]);
    }
}

# Pharos Project - Headless E-commerce Solution

Pharos is a premium, high-performance headless e-commerce ecosystem integrating **Flutter** with **PrestaShop 8/9**. It is designed for maximum stability, scalability, and conversion.

## 🚀 Key Features

*   **Headless Commerce:** PrestaShop acts as the powerful backend engine, while Flutter provides a smooth 60+ FPS frontend experience.
*   **Server-Driven UI (SDUI):** Dynamic home screen layouts manageable via the PrestaShop admin panel without requiring app updates.
*   **Guest Checkout:** Seamless shopping experience without mandatory registration, significantly increasing conversion rates.
*   **Automatic Registration:** Optional one-click account creation during the guest checkout process.
*   **Omnichannel Integration:** Real-time inventory, pricing, and unified order history.
*   **Google Ecosystem:** 
    *   **Google Calendar API:** Automated logistics events for new orders.
    *   **Firebase FCM:** Push notifications for order status and marketing.
    *   **Google Pay:** Integrated fast payments.
*   **Multilingual & Multicurrency:** Full support for global markets with automatic price conversion.

## 🛠 Tech Stack

### Frontend (Flutter)
*   **Architecture:** Clean Architecture (Data, Domain, Presentation).
*   **State Management:** Flutter BLoC / Provider.
*   **Networking:** Dio with custom interceptors for API security and logging.
*   **Models:** Type-safe data handling with `freezed` and `json_serializable`.
*   **UI Components:** Shimmer effects for loading states, responsive layouts with `LayoutBuilder`.

### Backend (PrestaShop)
*   **Module:** `pharosapi` - Custom PHP module extending PrestaShop Webservice.
*   **Standards:** PSR-12, PrestaShop 8/9 core compatibility.
*   **Security:** Secure API Key authentication and JWT session handling.

## 📦 Project Structure

```text
Pharos/
├── lib/
│   ├── core/          # API config, network, providers, services
│   ├── data/          # Models, repositories, DTOs
│   ├── domain/        # Entities, business logic
│   └── ui/            # Screens, widgets, themes
├── test/              # Unit and widget tests
├── assets/            # Mock data, images, fonts
├── prestashop_module/ # Custom 'pharosapi' module for PrestaShop
└── README.md          # Project documentation
```

## 🧪 Testing

The project includes unit tests for core business logic:
*   **Cart Tests:** Validation of real-time synchronization, server response handling, and item management in `test/unit/cart_provider_test.dart`.
*   **Repository Tests:** API endpoint verification and data mapping in `test/unit/cart_repository_test.dart`.

Run tests using:
```bash
flutter test
```

## ⚙️ Configuration

### PrestaShop Setup
1. Install the `pharosapi` module located in the `prestashop_module/` directory.
2. Configure your API Key in the PrestaShop Webservice settings.
3. Enable the `pharosapi` endpoints in the module configuration.

### Flutter Setup
1. Update `lib/core/api/api_config.dart` with your PrestaShop `baseUrl` and `apiKey`.
2. Run `flutter pub get` to install dependencies.
3. Use `flutter run` to launch the application.

## 🛡 Stability Policy
Pharos implements a **Zero-Crash Policy**:
*   Defensive JSON parsing with custom converters.
*   Functional error handling (Result/Either pattern).
*   Mandatory fallback mechanisms for network failures and SDUI corruption.
*   Haptic feedback and micro-animations for an intuitive "Native Feel".

---
*Developed with Passion by Patrycja*

## Moduł PrestaShop

Katalog `prestashop_module/pharosapi` jest osobnym repozytorium git (własny `.git`) i nie jest śledzony przez repozytorium aplikacji (wpis w `.gitignore`). Historia zmian modułu żyje w jego repozytorium. Katalog `prestashop_module/_extracted/pharosapi` to rozjechana kopia modułu (pliki kontrolerów się różnią), nieużywana przez aplikację.

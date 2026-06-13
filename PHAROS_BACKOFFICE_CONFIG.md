# Pharos - Specyfikacja Panelu Admina (PrestaShop)

Ten panel zarządza funkcjami, których PrestaShop nie posiada w standardzie, a które są niezbędne dla klasy Premium Mobile UX.

## 1. Zakładka: Branding & Styl (Design Overrides)
- **Mobilna Typografia:** [Dropdown] - Wybór czcionki z Google Fonts (np. Montserrat, Poppins).
- **Styl Karty Produktu:** [Dropdown] - (Standard, Minimal, Compact).
- **Animacja przejść:** [Dropdown] - Wybór stylu animacji między ekranami (Slide, Fade, Zoom).
- **Tryb Ciemny (Dark Mode):** [Switch] - Wymuszony / Zależny od systemu.

## 2. Zakładka: Marketing & Onboarding (Pierwsze wrażenie)
- **Ekrany Powitalne (Onboarding):** [Zarządzanie listą] - Dodaj obrazek + Tytuł + Opis (pokazywane tylko przy 1. uruchomieniu).
- **Licznik "Flash Sales":** [ID Promocji] - Wyświetla zegar odliczający czas do końca promocji na stronie głównej aplikacji.
- **App-Only Discount:** [Kod rabatowy] - Specjalny kod widoczny tylko dla użytkowników aplikacji mobilnej.
- **Popup Promocyjny:** [Wgraj grafikę] - Okno wyskakujące po wejściu do aplikacji (np. "Zapisz się do Newslettera").

## 3. Zakładka: Engagement & Loyalty (Retencja)
- **Trigger "Oceń aplikację":** [Liczba zamówień] - Po ilu udanych zakupach poprosić użytkownika o ocenę w Google Play / App Store.
- **Powiadomienie o porzuconym koszyku:** [Liczba godzin] - Po jakim czasie wysłać automatyczny Push, jeśli klient zostawił produkty.
- **Integracja WhatsApp/Messenger:** [Numer/Link] - Przycisk szybkiego kontaktu widoczny w rogu ekranu (Floating Action Button).

## 4. Zakładka: Ustawienia Techniczne & Maintenance
- **Tryb Pracy (Maintenance):** [Switch] - Możesz wyłączyć samą aplikację (np. na czas aktualizacji modułu) zostawiając sklep WWW aktywny.
- **Wymuś Aktualizację (Force Update):** [Numer wersji] - Jeśli wpiszesz "1.2.0", użytkownicy ze starszą wersją zobaczą blokadę z prośbą o update.
- **Changelog:** [Textarea] - Treść nowości wyświetlana po aktualizacji.

## 5. Zakładka: Google & Automatyzacja (Narzędzia Zewnętrzne)
- **Google Service Account (JSON):** Klucz do Kalendarza i Analytics.
- **Firebase Server Key:** Klucz do wysyłki powiadomień Push.
- **Google Maps API Key:** Jeśli chcesz używać map do punktów odbioru.

## 6. Zakładka: Social Media (Mobilny Footer)
*Linki do profili, które otworzą się bezpośrednio w natywnych aplikacjach Instagram/TikTok:*
- **Instagram URL / TikTok URL / Facebook URL**

---
## Dlaczego to jest ważne?
Standardowa PrestaShop nie wie, co to jest "Numer wersji aplikacji" ani "Ekran powitalny". Dodając te pola do modułu, dajesz sobie pełną kontrolę nad cyklem życia aplikacji bez angażowania programisty Fluttera do każdej zmiany.

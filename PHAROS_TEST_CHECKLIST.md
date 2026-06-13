# Pharos Project - Acceptance Test Checklist (UAT)

Użyj tej listy, aby zweryfikować poprawność działania aplikacji po podpięciu pod produkcyjne API PrestaShop.

## 1. Branding & SDUI (Zdalna Konfiguracja)
- [ ] **Store Info:** Czy nazwa sklepu w AppBarze i Profilu zmienia się po zmianie w module PHP?
- [ ] **Logo:** Czy logo wczytuje się poprawnie z podanego URL? (Sprawdź zachowanie przy błędnym URL - powinien być tekst).
- [ ] **Layout:** Czy zmiana kolejności sekcji w JSON (np. przesunięcie banerów pod produkty) jest widoczna natychmiast po odświeżeniu?
- [ ] **Shimmer Effect:** Czy podczas ładowania widoczne są Skeleton Loaders zamiast białego ekranu?

## 2. Discovery (Odkrywanie Produktów)
- [ ] **Search:** Czy wyniki wyszukiwania pojawiają się po ~500ms od wpisania frazy?
- [ ] **Filters:** Czy wybór koloru/kategorii poprawnie zawęża listę produktów?
- [ ] **Scanner:** Czy zeskanowanie kodu kreskowego (EAN) otwiera poprawną kartę produktu?
- [ ] **Hero Animation:** Czy zdjęcie produktu płynnie "przeskakuje" z listy do widoku detali?

## 3. Customer Journey (Konto & Koszyk)
- [ ] **Google Sign-In:** Czy po zalogowaniu w Profilu widać Twoje imię i zdjęcie z konta Google?
- [ ] **Address Book:** Czy dodanie adresu w aplikacji powoduje jego pojawienie się w panelu PrestaShop?
- [ ] **Wishlist:** Czy produkty oznaczone sercem są widoczne w zakładce "Ulubione" po restarcie aplikacji?
- [ ] **Cart Sync:** Czy zmiana ilości w koszyku poprawnie przelicza sumę (Subtotal)?

## 4. Checkout & Payments (Finalizacja)
- [ ] **Dynamic Carriers:** Czy lista kurierów zmienia się w zależności od kraju/wagi koszyka prosto z Presty?
- [ ] **Multi-Currency:** Czy zmiana waluty na EUR poprawnie przelicza wszystkie ceny w aplikacji?
- [ ] **Payment Flow:** Czy animacja Lottie (Sukces) pojawia się po symulacji płatności?
- [ ] **Order History:** Czy nowo złożone zamówienie jest widoczne na liście w Profilu ze statusem "Oczekiwanie"?

## 5. Google Automation (Logistyka)
- [ ] **Calendar API:** Czy po złożeniu zamówienia w Twoim Kalendarzu Google pojawia się nowe wydarzenie z ID zamówienia i listą produktów?
- [ ] **Analytics:** Czy zdarzenie `add_to_cart` jest widoczne w panelu Firebase DebugView?

## 6. Performance & Stability
- [ ] **Smoothness:** Czy przewijanie listy 100+ produktów odbywa się bez "zacięć" (60 FPS)?
- [ ] **Offline Mode:** Czy po wyłączeniu internetu pojawia się czytelny komunikat z przyciskiem "Spróbuj ponownie"?
- [ ] **Error Handling:** Czy błąd API PrestaShop (np. 500 Internal Error) nie powoduje zamknięcia aplikacji?

---
**Status Projektu:** Produkcyjny MVP.
**Technologia:** Flutter + PrestaShop 8/9 Headless.

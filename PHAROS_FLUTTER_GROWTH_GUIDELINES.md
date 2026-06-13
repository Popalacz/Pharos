# Pharos Flutter Growth & UX Guidelines

## Cel
Ten dokument opisuje, jakie dane z PrestaShop warto przekazywac do Fluttera, aby zwiekszyc konwersje, AOV i retencje.

## KPI, ktore warto mierzyc
- Konwersja sesja -> zakup
- AOV (Average Order Value)
- Add to cart rate
- Checkout completion rate
- Purchase repeat rate (30 dni)
- Open rate / CTR push

## Priorytet 1: Szybkie wzrosty sprzedazy (High Impact)
1. Progress darmowej dostawy
- Dane z Presty: prog darmowej dostawy per waluta i kraj, wartosc koszyka.
- UI: pasek "Brakuje 17.50 PLN do darmowej dostawy".
- Efekt: wzrost AOV.

2. Produkty komplementarne i powiazane
- Dane z Presty: akcesoria, cross-selling, same category bestsellery.
- UI: sekcje "Dobierz do tego" i "Klienci kupili rowniez".
- Efekt: wzrost liczby pozycji na zamowienie.

3. Personalizowane rekomendacje
- Dane z Presty: historia zamowien klienta, ostatnio ogladane, preferowane kategorie.
- UI: feed rekomendacji na home i PDP.
- Efekt: wzrost konwersji i retencji.

4. Alerty niskiego stanu magazynowego
- Dane z Presty: quantity, out_of_stock, minimal_quantity.
- UI: badge "Zostaly 2 sztuki".
- Efekt: szybsze decyzje zakupowe.

## Priorytet 2: Retencja i odzyskiwanie porzucen
5. Banner odzyskiwania koszyka
- Dane z Presty: aktualny koszyk klienta, data modyfikacji, wartosc.
- UI: stale widoczna belka po powrocie do aplikacji.

6. Alerty "powrot na stan"
- Dane z Presty: subskrypcje produktu + zmiana quantity > 0.
- UI: push + deeplink do produktu.

7. Ostatnio ogladane
- Dane z Presty: lista produktow klienta/urzadzenia.
- UI: sekcja "Ostatnio ogladane" na home i search empty state.

## Priorytet 3: Zaufanie i UX checkout
8. Estymowany termin dostawy
- Dane z Presty: delay przewoznika + kraj + waga.
- UI: "Dostawa: wtorek-sroda" przed checkoutem.

9. Jasna komunikacja kosztow
- Dane z Presty: shipping, discount, tax split.
- UI: podsumowanie ceny bez niespodzianek.

10. Jednoznaczne statusy zamowienia
- Dane z Presty: status order history + timeline.
- UI: timeline z lokalizowanymi nazwami statusow.

## Priorytet 4: Eksperymenty i growth loops
11. Bundle i zestawy
- Dane z Presty: reguly zestawow / rekomendacje parowania.
- UI: "Kup w zestawie i oszczedz 8%".

12. Gamifikacja lojalnosci
- Dane z Presty: punkty, progi, kupony.
- UI: licznik punktow i prog kolejnej nagrody.

## Co juz jest sterowane z BO modulu pharosapi
W module sa juz przełączniki dla sekcji growth i UX:
- growth_experience
- personalized_recommendations
- related_products
- complementary_products
- free_shipping_progress
- low_stock_badge
- back_in_stock_alert
- bundle_offers
- recently_viewed
- cart_recovery_banner

## Dodatkowe praktyki techniczne
- Wszystkie endpointy zwracaja JSON + output_format=JSON dla webservice.
- W produkcji wlacz CORS strict allowlist i wpisz domeny aplikacji.
- Utrzymuj endpoint debug wlaczony tylko na testach lub z silnym tokenem.
- Uzywaj cache po stronie Flutter (TTL 5-15 min) dla config i discovery.
- Wysylaj eventy analityczne po stronie app i backend (add_to_cart, begin_checkout, purchase).

## Proponowana mapa roadmapy (8 tygodni)
- Tydzien 1-2: progress darmowej dostawy, related/complementary, low stock badges
- Tydzien 3-4: personalizacja feedu i ostatnio ogladane
- Tydzien 5-6: odzyskiwanie koszyka + alerty powrotu na stan
- Tydzien 7-8: bundle offers i eksperymenty A/B

## Definition of Done dla kazdej funkcji
- Jest przełącznik ON/OFF w BO i flaga w app_config
- Jest test manualny w checklist
- Jest event analityczny i metryka sukcesu
- Jest fallback UI, gdy API nie zwraca danych

## Jak konfigurowac Flutter bez edycji kodu

### Zasada glowna
Flutter powinien byc traktowany jako renderer konfiguracji. Zespol sklepu zmienia zachowanie aplikacji przez BackOffice i dane API, a nie przez nowy build aplikacji.

### Co musi byc stale zaszyte tylko raz w aplikacji
To jedyne elementy wymagajace implementacji developerskiej jednorazowo:
- klient config pobierajacy dane z endpointu config przy starcie i po odswiezeniu
- parser flag i sekcji SDUI
- fallback cache na wypadek braku sieci
- mapowanie kilku predefiniowanych typow sekcji, np. banner, grid, chips, rekomendacje

Po wdrozeniu tego fundamentu codzienne zmiany robisz bez edycji kodu.

### Obszary no-code do codziennej konfiguracji
1. Layout i kolejnosc sekcji
- Zmieniasz home_config_json i home_banners_json w BO.
- Flutter tylko renderuje nowe kolejnosci i widocznosc sekcji.

2. Feature flags
- Wlaczanie i wylaczanie funkcji przez app_config.
- Przyklady: free_shipping_progress, bundle_offers, cart_recovery_banner.

3. Komunikaty i kampanie
- Tresci onboardingu, popupow i promo kodow trzymane po stronie config.
- Bez releasu aplikacji mozesz odpalic i zatrzymac kampanie.

4. Bezpieczenstwo i operacje
- CORS strict allowlist oraz debug endpoint token z BO.
- Bez dotykania Fluttera przechodzisz ze staging do produkcji.

### Praktyczny model rollout bez releasu aplikacji
1. Tworzysz kampanie w BO i ustawiasz wszystkie flagi na off.
2. Testujesz na staging przez debug endpoint i whitelist CORS.
3. Wlaczysz kampanie dla 10-20 procent ruchu przez warunek segmentu po stronie API.
4. Obserwujesz KPI.
5. Skalujesz do 100 procent albo rollback jednym przełącznikiem.

### Co jeszcze warto dodac, aby no-code dzialal jeszcze lepiej
1. Segmenty odbiorcow
- Segment key zwracany przez API, np. nowy klient, VIP, odzyskany.
- Flutter pokazuje inne bloki na bazie segmentu.

2. Harmonogramy aktywacji
- Daty start i koniec kampanii trzymane w konfiguracji.
- Kampanie wygaszaja sie automatycznie bez interwencji.

3. Warianty A/B
- API zwraca variant A albo B.
- Flutter renderuje gotowy wariant i raportuje event konwersji.

4. Slownik i lokalizacje
- Napisy promocyjne i CTA trzymane po stronie API, nie na stale w appce.

5. Priorytety i konflikty
- Kazda sekcja ma priority i enabled.
- Unikasz konfliktow miedzy kilkoma kampaniami jednoczesnie.

### Minimalny kontrakt no-code dla backendu
W konfiguracji powinny zawsze byc:
- enabled: true albo false dla kazdej funkcji
- priority: liczba porzadkujaca sekcje
- schedule: start_at i end_at
- audience: segment, kraj, jezyk, waluta
- tracking: nazwa eventu i campaign_id

### Checklist operacyjny dla zespolu biznesowego
Przed publikacja kampanii:
- czy flaga enabled jest poprawna
- czy campaign_id jest unikalne
- czy daty kampanii sa poprawne
- czy jest fallback, gdy sekcja nie ma danych
- czy eventy analityczne sa przypisane

Po publikacji:
- monitoruj konwersje, AOV i add_to_cart rate
- porownuj warianty A/B
- zatrzymaj kampanie jednym przełącznikiem, jesli metryki spadaja

## Gotowe szablony kampanii (bez edycji kodu Flutter)

Poniższe szablony sa przygotowane tak, aby zespol biznesowy mogl je uruchamiac przez konfiguracje BO i API.

### Szablon 1: Nowy klient (first purchase boost)

Cel:
- Szybka pierwsza konwersja i aktywacja konta.

Konfiguracja biznesowa:
- campaign_id: NEW_USER_FIRST_ORDER_10
- audience.segment: new_customer
- schedule.start_at: natychmiast
- schedule.end_at: +30 dni
- priority: 90
- app_discount_enabled: on
- app_discount_code: START10
- onboarding_enabled: on
- promo_popup_enabled: on
- free_shipping_progress_enabled: on
- related_products_enabled: on

Sekcje SDUI na home (kolejnosc):
- onboarding
- promo_popup
- banner_slider
- product_grid
- recently_viewed

Eventy do monitoringu:
- campaign_view_NEW_USER_FIRST_ORDER_10
- apply_coupon_START10
- first_purchase_completed

Warunek sukcesu (7 dni):
- wzrost first purchase conversion o minimum 8 procent.

Przyklad payloadu logicznego:
{
	"campaign_id": "NEW_USER_FIRST_ORDER_10",
	"enabled": true,
	"audience": {"segment": "new_customer"},
	"schedule": {"start_at": "2026-06-13T00:00:00Z", "end_at": "2026-07-13T23:59:59Z"},
	"priority": 90,
	"tracking": {"event_name": "campaign_view_NEW_USER_FIRST_ORDER_10"}
}

### Szablon 2: Porzucony koszyk (cart recovery)

Cel:
- Odzyskanie porzuconych koszykow i domkniecie checkout.

Konfiguracja biznesowa:
- campaign_id: ABANDONED_CART_RECOVERY_24H
- audience.segment: abandoned_cart
- audience.cart_age_hours_min: 2
- audience.cart_age_hours_max: 24
- schedule: always_on
- priority: 100
- cart_recovery_banner_enabled: on
- abandoned_cart_push_enabled: on
- abandoned_cart_hours: 4
- app_discount_enabled: on
- app_discount_code: WRACAM5
- quick_contact_enabled: on

Sekcje i elementy UI:
- sticky banner w home i cart
- CTA: "Wroc do koszyka"
- fallback CTA: kontakt z doradca

Eventy do monitoringu:
- cart_recovery_banner_view
- cart_recovery_banner_click
- recovered_order_completed

Warunek sukcesu (14 dni):
- wzrost recovered carts o minimum 12 procent.

Przyklad payloadu logicznego:
{
	"campaign_id": "ABANDONED_CART_RECOVERY_24H",
	"enabled": true,
	"audience": {"segment": "abandoned_cart", "cart_age_hours_min": 2, "cart_age_hours_max": 24},
	"schedule": {"start_at": "2026-06-13T00:00:00Z", "end_at": "2030-01-01T00:00:00Z"},
	"priority": 100,
	"tracking": {"event_name": "cart_recovery_banner_view"}
}

### Szablon 3: Klient powracajacy (repeat purchase)

Cel:
- Zwiekszenie repeat rate i AOV przez personalizacje.

Konfiguracja biznesowa:
- campaign_id: RETURNING_CUSTOMER_SMART_UPSELL
- audience.segment: returning_customer
- audience.last_order_days_min: 15
- audience.last_order_days_max: 60
- priority: 80
- personalized_recommendations_enabled: on
- complementary_products_enabled: on
- bundle_offers_enabled: on
- recently_viewed_enabled: on
- low_stock_badge_enabled: on
- flash_sales_enabled: opcjonalnie on

Sekcje SDUI na home/PDP:
- recently_viewed
- personalized_recommendations
- complementary_products
- bundle_offers

Eventy do monitoringu:
- repeat_user_recommendation_click
- bundle_offer_add_to_cart
- repeat_purchase_completed

Warunek sukcesu (30 dni):
- wzrost repeat purchase rate o minimum 10 procent.

Przyklad payloadu logicznego:
{
	"campaign_id": "RETURNING_CUSTOMER_SMART_UPSELL",
	"enabled": true,
	"audience": {"segment": "returning_customer", "last_order_days_min": 15, "last_order_days_max": 60},
	"schedule": {"start_at": "2026-06-13T00:00:00Z", "end_at": "2026-12-31T23:59:59Z"},
	"priority": 80,
	"tracking": {"event_name": "repeat_user_recommendation_click"}
}

## Procedura uruchomienia szablonu przez biznes (15 minut)
1. W BO ustaw flagi kampanii na off.
2. Wklej parametry kampanii do odpowiednich pol BO (kody, JSON, harmonogram).
3. Zweryfikuj endpoint debug i active_flags.
4. Wlacz kampanie na staging.
5. Zrob smoke test app:
- home
- PDP
- cart
- checkout
6. Wlacz kampanie produkcyjnie.
7. Po 24h sprawdz KPI i podejmij decyzje: skaluj, popraw, zatrzymaj.

## Matryca rollback (bez releasu)
- Problem z konwersja: wylacz campaign enabled.
- Problem z API: wylacz tylko sekcje konfliktowe (np. bundle_offers).
- Problem z UX: zmniejsz priority lub ukryj popup.
- Problem z CORS: tymczasowo CORS strict off, po diagnozie ponownie on.

## MAX Sales Mode: Plan na maksymalne wyniki

### 1. Cele kwartalne (North Star + guardrails)
North Star:
- Przychod na aktywnego uzytkownika (RPU) miesiecznie.

Cele glówne (90 dni):
- +20 procent konwersji sesja -> zakup
- +15 procent AOV
- +25 procent odzyskanych porzuconych koszykow
- +12 procent repeat purchase rate

Guardrails (zeby wzrost nie psul jakosci):
- refund rate nie moze wzrosnac powyzej +2 pp
- crash-free sessions > 99.5 procent
- checkout error rate < 1.5 procent

### 2. Growth Operating System (cykl tygodniowy)
Poniedzialek:
- analiza KPI tydzien do tygodnia
- selekcja 3 eksperymentow o najwyzszym impact

Wtorek:
- konfiguracja kampanii w BO
- QA staging przez endpoint debug

Sroda-Czwartek:
- rollout 20 procent ruchu
- monitoring eventow i guardrails

Piatek:
- decyzja scale do 100 procent, iteracja, albo rollback
- dokumentacja wnioskow i aktualizacja backlogu

### 3. Priorytetowy backlog eksperymentow (ICE)
Skala ICE: Impact 1-10, Confidence 1-10, Ease 1-10.

1. Checkout express CTA + progress darmowej dostawy
- Impact: 9, Confidence: 8, Ease: 8
- Hipoteza: jasna sciezka i progress podniosa AOV i domkniecia checkout.

2. Porzucony koszyk: push + banner + kod WRACAM5
- Impact: 9, Confidence: 8, Ease: 7
- Hipoteza: 2-stopniowe przypomnienie odzyska porzucone koszyki.

3. PDP: produkty komplementarne + bundle oferta
- Impact: 8, Confidence: 7, Ease: 8
- Hipoteza: zwiekszy srednia liczbe pozycji na zamowienie.

4. Home personalizacja dla returning_customer
- Impact: 8, Confidence: 6, Ease: 6
- Hipoteza: personalizowany feed zwiekszy repeat purchase.

5. Low stock urgency + social proof
- Impact: 7, Confidence: 8, Ease: 9
- Hipoteza: efekt pilnosci skroci czas decyzji zakupowej.

### 4. Matryca segmentacji (co pokazujemy komu)
new_customer:
- onboarding, first-order coupon, bestseller grid

abandoned_cart:
- cart recovery banner, push reminder, quick contact

returning_customer:
- personalized recommendations, complementary products, bundle

vip_high_aov:
- early access flash sales, premium bundles, concierge contact

dormant_30d_plus:
- reactivation popup, limitowany kod, top categories reminder

### 5. Automatyzacje lifecycle (must-have)
1. D0 welcome flow:
- onboarding + kupon startowy + bestsellery

2. D1 cart reminder:
- push po 4h + banner po powrocie do app

3. D3 urgency follow-up:
- drugi push z low stock lub time-limited discount

4. D7 repeat nudge:
- personalizowane rekomendacje i bundle

5. Back in stock:
- automatyczny push + deeplink na PDP

### 6. Optymalizacja checkout (najwiekszy lejek)
Do wdrozenia i stalego testu:
- domyslny przewoznik z najlepszym ratio cena/czas
- czytelny split kosztow: produkty, dostawa, rabat, lacznie
- stale CTA podsumowania zamowienia na mobile
- maksymalnie 1 krok mniej w checkout jesli mozliwe
- komunikat bledu z konkretnym next step, nigdy tylko "blad"

### 7. Pricing i promocje: zasady skutecznosci
- zawsze test A/B dla kuponu procent vs kwota
- limit czasu i jasny deadline kampanii
- jeden glowny CTA na ekran, bez rozpraszaczy
- promo stack tylko gdy marza to dopuszcza
- monitoruj contribution margin, nie tylko revenue

### 8. Dashboard operacyjny (codziennie rano)
Musi pokazywac 8 metryk:
- sessions
- conversion rate
- add to cart rate
- checkout completion rate
- AOV
- recovered carts
- repeat purchase rate
- revenue per active user

Alerty automatyczne:
- spadek konwersji > 10 procent dzien do dnia
- wzrost checkout error rate > 2x srednia 7-dniowa
- brak eventow purchase przez 15 minut

### 9. Standard wdrozenia eksperymentu (SOP)
1. Hipoteza + metryka sukcesu
2. Definicja segmentu i ruchu testowego
3. Konfiguracja flag i harmonogramu
4. QA staging i smoke test
5. Start 20 procent ruchu
6. Ocena po 24h i 72h
7. Scale/rollback + zapis lekcji

### 10. Plan 30/60/90 dni
0-30 dni:
- uruchom pelny cykl abandoned cart
- wdroz progress darmowej dostawy
- uruchom low stock badge i related products

31-60 dni:
- personalizacja home dla returning_customer
- bundle offers na top 20 SKU
- AB test kuponow i popupow

61-90 dni:
- automatyzacje lifecycle D7 i D30
- dopracowanie segmentu VIP i dormant
- optymalizacja marzy kampanii i skalowanie zwyciezcow

### 11. Zasada max wynikow
Nigdy nie prowadz kampanii bez:
- jednoznacznej hipotezy
- eventu pomiarowego
- warunku rollback
- wlasciciela biznesowego

To jest najszybsza droga do wzrostu sprzedazy bez chaosu i bez przepalania budzetu.

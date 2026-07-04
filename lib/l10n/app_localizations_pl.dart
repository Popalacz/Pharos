// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get appTitle => 'Pharos';

  @override
  String get home => 'Główna';

  @override
  String get wishlist => 'Ulubione';

  @override
  String get cart => 'Koszyk';

  @override
  String get contact => 'Kontakt';

  @override
  String get account => 'Konto';

  @override
  String get search => 'Szukaj';

  @override
  String get checkout => 'Kasa';

  @override
  String get delivery => 'Dostawa';

  @override
  String get payment => 'Płatność';

  @override
  String get total => 'Łącznie';

  @override
  String get addToCart => 'Dodaj do koszyka';

  @override
  String get outOfStock => 'Brak w magazynie';

  @override
  String get orderSuccess => 'Sukces!';

  @override
  String get tracking => 'Śledzenie';

  @override
  String get email => 'E-mail';

  @override
  String get phone => 'Telefon';

  @override
  String get address => 'Adres';

  @override
  String get openingHours => 'GODZINY OTWARCIA';

  @override
  String get followUs => 'OBSERWUJ NAS';

  @override
  String get officialMobileApp => 'Oficjalna aplikacja mobilna';

  @override
  String get unexpectedError =>
      'Wystąpił nieoczekiwany błąd. Spróbuj ponownie później.';

  @override
  String get maintenanceTitle => 'PRZERWA TECHNICZNA';

  @override
  String get maintenanceMessage =>
      'Właśnie ulepszamy nasz sklep, aby zakupy były jeszcze przyjemniejsze. Wróć do nas za chwilę!';

  @override
  String get checkAgain => 'SPRAWDŹ PONOWNIE';

  @override
  String get updateRequiredTitle => 'WYMAGANA AKTUALIZACJA';

  @override
  String get updateRequiredMessage =>
      'Twoja wersja aplikacji jest nieaktualna. Aby kontynuować zakupy, pobierz najnowszą wersję z oficjalnego sklepu.';

  @override
  String get downloadUpdate => 'POBIERZ AKTUALIZACJĘ';

  @override
  String get myProfile => 'MÓJ PROFIL';

  @override
  String get drawerTagline => 'Premium E-commerce Experience';

  @override
  String get drawerHome => 'Strona główna';

  @override
  String get drawerCategories => 'Kategorie';

  @override
  String get drawerLanguageCurrency => 'Język i Waluta';

  @override
  String get drawerRefreshStore => 'Odśwież sklep';

  @override
  String get calendar => 'Wydarzenia';

  @override
  String get calendarUnavailable => 'Kalendarz jest obecnie niedostępny.';

  @override
  String get calendarLoadError => 'Nie udało się wczytać kalendarza.';

  @override
  String get retry => 'Spróbuj ponownie';

  @override
  String get openInMaps => 'Otwórz w Mapach';

  @override
  String get orderStatusUpdating => 'Aktualizacja...';

  @override
  String get yourCart => 'Twój Koszyk';

  @override
  String get cartEmpty => 'Koszyk jest pusty';

  @override
  String get contactUnavailable => 'Dane kontaktowe są obecnie niedostępne.';

  @override
  String get yourPromoCode => 'TWÓJ KOD RABATOWY:';

  @override
  String get finishShopping => 'Dokończ zakupy!';

  @override
  String cartRecoveryMessage(Object price) {
    return 'W Twoim koszyku czekają produkty o wartości $price';
  }

  @override
  String get recentlyViewed => 'Ostatnio oglądane';

  @override
  String get syncErrorTitle => 'Błąd synchronizacji z Pharos API';

  @override
  String get syncErrorMessage =>
      'Sprawdź połączenie z internetem i spróbuj ponownie.';

  @override
  String get tryAgain => 'SPRÓBUJ PONOWNIE';

  @override
  String get cartEmptyMessage =>
      'Wygląda na to, że jeszcze nic nie wybrałeś. Twoje wymarzone produkty czekają!';

  @override
  String get startShopping => 'ZACZNIJ ZAKUPY';

  @override
  String get freeShippingUnlocked => 'Darmowa dostawa odblokowana!';

  @override
  String freeShippingMissing(Object price) {
    return 'Brakuje Ci $price do darmowej dostawy';
  }

  @override
  String get subtotal => 'Suma częściowa';

  @override
  String get shipping => 'Dostawa';

  @override
  String get checkoutButton => 'PRZEJDŹ DO KASY';

  @override
  String get voucherLabel => 'Kod rabatowy';

  @override
  String get voucherApplied => 'Kod rabatowy zastosowany';

  @override
  String get removedFromCart => 'Usunięto z koszyka';

  @override
  String get discount => 'Rabat';

  @override
  String get productsTotal => 'Suma produktów';
}

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

  @override
  String get addressSavedSuccess => 'Adres został zapisany pomyślnie';

  @override
  String get newAddress => 'Nowy adres';

  @override
  String get editAddress => 'Edytuj adres';

  @override
  String get saveAddressButton => 'ZAPISZ ADRES';

  @override
  String get chooseAddress => 'Wybierz adres';

  @override
  String get addNewAddressButton => 'DODAJ NOWY ADRES';

  @override
  String get editProfileTitle => 'EDYTUJ PROFIL';

  @override
  String get firstName => 'Imię';

  @override
  String get lastName => 'Nazwisko';

  @override
  String get saveChangesButton => 'ZAPISZ ZMIANY';

  @override
  String get profileUpdated => 'Profil zaktualizowany!';

  @override
  String get myAddressesTitle => 'MOJE ADRESY';

  @override
  String get noSavedAddresses => 'Nie masz jeszcze zapisanych adresów';

  @override
  String get deleteAddress => 'Usuń adres';

  @override
  String get cancelButton => 'ANULUJ';

  @override
  String get deleteButton => 'USUŃ';

  @override
  String get regionalSettings => 'Ustawienia regionalne';

  @override
  String get categoriesTitle => 'KATEGORIE';

  @override
  String get wishlistTitle => 'ULUBIONE';

  @override
  String get wishlistEmpty => 'TWOJA LISTA JEST PUSTA';

  @override
  String get startDiscovering => 'ZACZNIJ ODKRYWAĆ';

  @override
  String get orderSuccessTitle => 'SUKCES!';

  @override
  String get orderValue => 'WARTOŚĆ ZAMÓWIENIA';

  @override
  String get paidBadge => 'OPŁACONE';

  @override
  String get continueShopping => 'KONTYNUUJ ZAKUPY';

  @override
  String get warehouseMarker => 'Magazyn Pharos';

  @override
  String get yourAddressMarker => 'Twój Adres';

  @override
  String get courierMarker => 'Kurier Pharos';

  @override
  String get trackingPlacedTitle => 'ZAMÓWIENIE ZŁOŻONE';

  @override
  String get trackingPlacedDesc => 'Otrzymaliśmy Twoje zamówienie.';

  @override
  String get trackingPreparingTitle => 'W PRZYGOTOWANIU';

  @override
  String get trackingPreparingDesc => 'Twoje produkty są pakowane.';

  @override
  String get trackingShippedTitle => 'W DRODZE';

  @override
  String get trackingShippedDesc => 'Kurier odebrał paczkę.';

  @override
  String get trackingDeliveredTitle => 'DOSTARCZONO';

  @override
  String get trackingDeliveredDesc => 'Zamówienie dotarło!';

  @override
  String get orderStatusTitle => 'STATUS ZAMÓWIENIA';

  @override
  String get fulfillmentHistory => 'HISTORIA REALIZACJI';

  @override
  String get referenceLabel => 'REFERENCJA';

  @override
  String get rateProductsQuestion => 'JAK OCENIASZ PRODUKTY?';

  @override
  String get addReviewButton => 'DODAJ OPINIĘ';

  @override
  String get technicalHelp => 'POMOC TECHNICZNA';

  @override
  String get askQuestionButton => 'ZADAJ PYTANIE';

  @override
  String get recentSearches => 'OSTATNIE WYSZUKIWANIA';

  @override
  String get clearLabel => 'Wyczyść';

  @override
  String get suggestions => 'PODPOWIEDZI';

  @override
  String get profileHeading => 'TWÓJ PROFIL PHAROS';

  @override
  String get loginOrRegister => 'ZALOGUJ SIĘ LUB ZAŁÓŻ KONTO';

  @override
  String get orderHistory => 'HISTORIA ZAMÓWIEŃ';

  @override
  String get accountSettings => 'USTAWIENIA KONTA';

  @override
  String get languageCurrency => 'Język i Waluta';

  @override
  String get languageCurrencySubtitle => 'Zmień ustawienia regionalne';

  @override
  String get myData => 'Moje dane';

  @override
  String get myDataSubtitle => 'Edytuj informacje o profilu';

  @override
  String get myAddresses => 'Moje adresy';

  @override
  String get myAddressesSubtitle => 'Zarządzaj adresami dostaw';

  @override
  String get noOrderHistory => 'Brak historii zamówień';

  @override
  String get scanProduct => 'SKANUJ PRODUKT';

  @override
  String get scanHint => 'Umieść kod kreskowy w ramce';

  @override
  String get seeAll => 'Zobacz wszystko';

  @override
  String get reviewHeading => 'TWOJA OPINIA JEST DLA NAS WAŻNA';

  @override
  String get submitReview => 'WYŚLIJ OPINIĘ';

  @override
  String get reviewThanks => 'Dziękujemy za Twoją opinię!';

  @override
  String get rateProduct => 'Oceń produkt';

  @override
  String get addButton => 'DODAJ';

  @override
  String get buyOnOrder => 'KUP NA ZAMÓWIENIE';

  @override
  String get addToCartUpper => 'DODAJ DO KOSZYKA';

  @override
  String get addedOnOrder => 'Dodano produkt (Na zamówienie)';

  @override
  String get addedToCart => 'Dodano do koszyka';

  @override
  String get cartUpper => 'KOSZYK';

  @override
  String get notifyAvailability => 'POWIADOM O DOSTĘPNOŚCI';

  @override
  String get notifySaved => 'Zapisano Cię na powiadomienie o dostępności!';

  @override
  String get productUnavailable => 'PRODUKT NIEDOSTĘPNY';

  @override
  String get loginTitle => 'KONTO PHAROS';

  @override
  String get password => 'Hasło';

  @override
  String get loginButton => 'ZALOGUJ SIĘ';

  @override
  String get orSeparator => 'LUB';

  @override
  String get registerButton => 'ZAŁÓŻ KONTO';

  @override
  String get continueWithGoogle => 'KONTYNUUJ PRZEZ GOOGLE';

  @override
  String get chooseLanguage => 'Wybierz język';

  @override
  String get chooseCurrency => 'Wybierz walutę';

  @override
  String get filtering => 'FILTROWANIE';

  @override
  String get clearUpper => 'WYCZYŚĆ';

  @override
  String get showResults => 'POKAŻ WYNIKI';

  @override
  String get catalogFetchFailed => 'Nie udało się pobrać katalogu';

  @override
  String get tryAgainSentence => 'Spróbuj ponownie';

  @override
  String get favoritesAdded => 'Dodano do ulubionych';

  @override
  String get favoritesRemoved => 'Usunięto z ulubionych';

  @override
  String get noProductsTitle => 'BRAK PRODUKTÓW';

  @override
  String get noResults => 'Brak wyników';

  @override
  String get clearSearch => 'Wyczyść wyszukiwanie';

  @override
  String get a11yBack => 'Wstecz';

  @override
  String get a11yClose => 'Zamknij';

  @override
  String get a11yRemove => 'Usuń';

  @override
  String get a11yAddToFavorites => 'Dodaj do ulubionych';

  @override
  String get a11yRemoveFromFavorites => 'Usuń z ulubionych';

  @override
  String get a11yEdit => 'Edytuj';

  @override
  String get a11yShowPassword => 'Pokaż hasło';

  @override
  String get a11yHidePassword => 'Ukryj hasło';

  @override
  String get a11yScanBarcode => 'Skanuj kod kreskowy';

  @override
  String get a11yFilters => 'Filtry';

  @override
  String get a11yIncreaseQuantity => 'Zwiększ ilość';

  @override
  String get a11yDecreaseQuantity => 'Zmniejsz ilość';

  @override
  String get a11yOpenMenu => 'Otwórz menu';

  @override
  String deleteAddressConfirm(String alias) {
    return 'Czy na pewno chcesz usunąć adres \"$alias\"?';
  }

  @override
  String searchFor(String query) {
    return 'Szukaj \"$query\"';
  }

  @override
  String get a11yLogout => 'Wyloguj';

  @override
  String get a11yRefresh => 'Odśwież';

  @override
  String get a11yVoiceSearch => 'Wyszukiwanie głosowe';

  @override
  String get a11yApplyVoucher => 'Zastosuj kod rabatowy';

  @override
  String a11yRateStars(int count) {
    return 'Oceń na $count z 5';
  }

  @override
  String galleryImageLabel(int index, int total) {
    return 'Zdjęcie $index z $total';
  }

  @override
  String addedProduct(String name) {
    return 'Dodano: $name';
  }

  @override
  String get currencyRecalcInfo =>
      'Ceny produktów zostaną automatycznie przeliczone zgodnie z aktualnym kursem w Twoim sklepie.';

  @override
  String get noSavedAddressesDot => 'Nie masz jeszcze zapisanych adresów.';

  @override
  String get listening => 'SŁUCHAM...';

  @override
  String searchInStore(String store) {
    return 'Szukaj w $store...';
  }

  @override
  String orderNumber(String reference) {
    return 'Zamówienie #$reference';
  }

  @override
  String get reviewPlaceholder => 'Napisz coś więcej...';

  @override
  String get reviewSendError => 'Wystąpił błąd podczas wysyłania opinii.';

  @override
  String get reviewsLoadError => 'Błąd podczas ładowania opinii.';

  @override
  String get reviewsFetchFailed => 'Nie udało się pobrać opinii.';

  @override
  String get noReviews => 'Brak opinii o tym produkcie.';

  @override
  String get reviewTitle => 'Opinia';

  @override
  String get checkoutScreenTitle => 'Finalizacja zamówienia';

  @override
  String get processingOrder => 'Przetwarzanie zamówienia...';

  @override
  String get doNotCloseApp => 'Proszę nie zamykać aplikacji';

  @override
  String get deliveryAddressHeader => 'Adres dostawy';

  @override
  String get deliveryMethodHeader => 'Metoda dostawy';

  @override
  String get noDeliveryMethods => 'Brak metod dostawy dla tego koszyka.';

  @override
  String get noPaymentMethods => 'Brak metod płatności dla tego koszyka.';

  @override
  String get haveAccountQuestion => 'Masz już konto?';

  @override
  String get loginForSavedAddresses =>
      'Zaloguj się, aby użyć zapisanych adresów i szybciej dokończyć zamówienie.';

  @override
  String get orContinueAsGuest => 'LUB KONTYNUUJ JAKO GOŚĆ';

  @override
  String get whereToShip => 'Gdzie mamy wysłać paczkę?';

  @override
  String get tapToChooseAddress => 'Kliknij, aby wybrać adres';

  @override
  String get tapToAddShippingData => 'Kliknij, aby dodać dane do wysyłki';

  @override
  String get enterVoucherCode => 'Wpisz kod rabatowy.';

  @override
  String get addProductsBeforeVoucher =>
      'Dodaj produkty do koszyka, zanim użyjesz kodu rabatowego.';

  @override
  String get voucherAppliedSuccess =>
      'Kod rabatowy został pomyślnie naliczony!';

  @override
  String get nextDelivery => 'DALEJ: DOSTAWA';

  @override
  String get nextPayment => 'DALEJ: PŁATNOŚĆ';

  @override
  String get chooseAddressCta => 'WYBIERZ ADRES';

  @override
  String get completeDetailsCta => 'UZUPEŁNIJ DANE';

  @override
  String get chooseDeliveryCta => 'WYBIERZ DOSTAWĘ';

  @override
  String get choosePaymentCta => 'WYBIERZ PŁATNOŚĆ';

  @override
  String get missingCartItems => 'produktów w koszyku';

  @override
  String get missingSyncedCart => 'zsynchronizowanego koszyka';

  @override
  String get missingDeliveryAddress => 'adresu dostawy';

  @override
  String get missingDeliveryMethod => 'metody dostawy';

  @override
  String get missingPaymentMethod => 'metody płatności';

  @override
  String get biometricCancelled =>
      'Anulowano weryfikację tożsamości. Zamówienie nie zostało złożone.';

  @override
  String get cartVerifyFailed => 'Nie udało się zweryfikować koszyka.';

  @override
  String get cartNotSynced => 'Koszyk nie został zsynchronizowany z serwerem.';

  @override
  String get orderRejected => 'Serwer odrzucił zamówienie.';

  @override
  String get orderFallbackRef => 'Zamówienie';

  @override
  String get guestEmailLabel => 'Adres e-mail';

  @override
  String get guestStreetLabel => 'Ulica i numer';

  @override
  String get guestPostcodeLabel => 'Kod pocztowy';

  @override
  String get guestCityLabel => 'Miasto';

  @override
  String get guestPhoneLabel => 'Numer telefonu';

  @override
  String get createAccountForFaster =>
      'Chcę założyć konto dla szybszych zakupów';

  @override
  String get shippingFree => 'GRATIS';

  @override
  String get carriersLoadFailed => 'Nie udało się pobrać metod dostawy.';

  @override
  String get paymentsLoadFailed => 'Nie udało się pobrać metod płatności.';

  @override
  String get stepDone => 'ukończony';

  @override
  String get stepCurrent => 'bieżący';

  @override
  String get stepTodo => 'do wykonania';

  @override
  String get voucherHint => 'Wpisz kod...';

  @override
  String get voucherUseButton => 'UŻYJ';

  @override
  String payAmount(String amount) {
    return 'ZAPŁAĆ $amount';
  }

  @override
  String missingFieldsMessage(String fields) {
    return 'Brakuje: $fields.';
  }

  @override
  String stepSemanticsLabel(int index, int total, String label, String state) {
    return 'Krok $index z $total: $label, $state';
  }

  @override
  String validationRequired(String field) {
    return '$field jest wymagane';
  }

  @override
  String get validationEmailInvalid => 'Wprowadź poprawny adres e-mail';

  @override
  String validationMinChars(String field, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$field musi mieć co najmniej $count znaków',
      many: '$field musi mieć co najmniej $count znaków',
      few: '$field musi mieć co najmniej $count znaki',
      one: '$field musi mieć co najmniej $count znak',
    );
    return '$_temp0';
  }

  @override
  String validationInvalidChars(String field) {
    return '$field zawiera niedozwolone znaki';
  }

  @override
  String validationTooShort(String field) {
    return '$field jest za krótkie';
  }

  @override
  String validationPostcodeFormat(String field) {
    return '$field musi być w formacie 00-000';
  }

  @override
  String validationPhoneFormat(String field) {
    return '$field ma nieprawidłowy format';
  }

  @override
  String validationPhoneDigits(String field) {
    return '$field musi zawierać co najmniej 9 cyfr';
  }

  @override
  String get addressAliasLabel => 'Nazwa adresu';

  @override
  String get reviewCommentLabel => 'Treść opinii';

  @override
  String get categoriesLoadFailed => 'Nie udało się pobrać kategorii.';

  @override
  String get categoriesEmpty => 'Brak kategorii do wyświetlenia.';

  @override
  String get regionalSettingsEmpty =>
      'Brak skonfigurowanych języków lub walut w sklepie.';

  @override
  String get reviewLoginRequired => 'Zaloguj się, aby dodać opinię.';

  @override
  String get profileGuestPrompt =>
      'Zaloguj się, aby śledzić zamówienia i korzystać z pełnej funkcjonalności aplikacji.';
}

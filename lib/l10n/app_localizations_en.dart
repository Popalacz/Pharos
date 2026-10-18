// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Pharos';

  @override
  String get home => 'Home';

  @override
  String get wishlist => 'Wishlist';

  @override
  String get cart => 'Cart';

  @override
  String get contact => 'Contact';

  @override
  String get account => 'Account';

  @override
  String get search => 'Search';

  @override
  String get checkout => 'Checkout';

  @override
  String get delivery => 'Delivery';

  @override
  String get payment => 'Payment';

  @override
  String get total => 'Total';

  @override
  String get addToCart => 'Add to cart';

  @override
  String get outOfStock => 'Out of stock';

  @override
  String get orderSuccess => 'Success!';

  @override
  String get tracking => 'Tracking';

  @override
  String get email => 'Email';

  @override
  String get phone => 'Phone';

  @override
  String get address => 'Address';

  @override
  String get openingHours => 'OPENING HOURS';

  @override
  String get followUs => 'FOLLOW US';

  @override
  String get officialMobileApp => 'Official mobile app';

  @override
  String get unexpectedError =>
      'An unexpected error occurred. Please try again later.';

  @override
  String get maintenanceTitle => 'MAINTENANCE BREAK';

  @override
  String get maintenanceMessage =>
      'We are improving our store to make shopping even better. Please check back soon!';

  @override
  String get checkAgain => 'CHECK AGAIN';

  @override
  String get updateRequiredTitle => 'UPDATE REQUIRED';

  @override
  String get updateRequiredMessage =>
      'Your app version is outdated. Download the latest version from the official store to continue shopping.';

  @override
  String get downloadUpdate => 'DOWNLOAD UPDATE';

  @override
  String get myProfile => 'MY PROFILE';

  @override
  String get drawerTagline => 'Premium E-commerce Experience';

  @override
  String get drawerHome => 'Home';

  @override
  String get drawerCategories => 'Categories';

  @override
  String get drawerLanguageCurrency => 'Language & Currency';

  @override
  String get drawerRefreshStore => 'Refresh store';

  @override
  String get calendar => 'Events';

  @override
  String get calendarUnavailable => 'Calendar is currently unavailable.';

  @override
  String get calendarLoadError => 'Could not load calendar.';

  @override
  String get retry => 'Retry';

  @override
  String get openInMaps => 'Open in Maps';

  @override
  String get orderStatusUpdating => 'Updating...';

  @override
  String get yourCart => 'Your Cart';

  @override
  String get cartEmpty => 'Your cart is empty';

  @override
  String get contactUnavailable => 'Contact details are currently unavailable.';

  @override
  String get yourPromoCode => 'YOUR PROMO CODE:';

  @override
  String get finishShopping => 'Complete your purchase!';

  @override
  String cartRecoveryMessage(Object price) {
    return 'Items worth $price are waiting in your cart';
  }

  @override
  String get recentlyViewed => 'Recently viewed';

  @override
  String get syncErrorTitle => 'Pharos API Sync Error';

  @override
  String get syncErrorMessage =>
      'Check your internet connection and try again.';

  @override
  String get tryAgain => 'TRY AGAIN';

  @override
  String get cartEmptyMessage =>
      'It looks like you haven\'t chosen anything yet. Your dream products are waiting!';

  @override
  String get startShopping => 'START SHOPPING';

  @override
  String get freeShippingUnlocked => 'Free shipping unlocked!';

  @override
  String freeShippingMissing(Object price) {
    return 'You\'re $price away from free shipping';
  }

  @override
  String get subtotal => 'Subtotal';

  @override
  String get shipping => 'Shipping';

  @override
  String get checkoutButton => 'PROCEED TO CHECKOUT';

  @override
  String get voucherLabel => 'Discount code';

  @override
  String get voucherApplied => 'Discount code applied';

  @override
  String get removedFromCart => 'Removed from cart';

  @override
  String get discount => 'Discount';

  @override
  String get productsTotal => 'Products total';

  @override
  String get addressSavedSuccess => 'Address saved successfully';

  @override
  String get newAddress => 'New address';

  @override
  String get editAddress => 'Edit address';

  @override
  String get saveAddressButton => 'SAVE ADDRESS';

  @override
  String get chooseAddress => 'Choose address';

  @override
  String get addNewAddressButton => 'ADD NEW ADDRESS';

  @override
  String get editProfileTitle => 'EDIT PROFILE';

  @override
  String get firstName => 'First name';

  @override
  String get lastName => 'Last name';

  @override
  String get saveChangesButton => 'SAVE CHANGES';

  @override
  String get profileUpdated => 'Profile updated!';

  @override
  String get myAddressesTitle => 'MY ADDRESSES';

  @override
  String get noSavedAddresses => 'You have no saved addresses yet';

  @override
  String get deleteAddress => 'Delete address';

  @override
  String get cancelButton => 'CANCEL';

  @override
  String get deleteButton => 'DELETE';

  @override
  String get regionalSettings => 'Regional settings';

  @override
  String get categoriesTitle => 'CATEGORIES';

  @override
  String get wishlistTitle => 'FAVORITES';

  @override
  String get wishlistEmpty => 'YOUR LIST IS EMPTY';

  @override
  String get startDiscovering => 'START EXPLORING';

  @override
  String get orderSuccessTitle => 'SUCCESS!';

  @override
  String get orderValue => 'ORDER VALUE';

  @override
  String get paidBadge => 'PAID';

  @override
  String get continueShopping => 'CONTINUE SHOPPING';

  @override
  String get warehouseMarker => 'Pharos warehouse';

  @override
  String get yourAddressMarker => 'Your address';

  @override
  String get courierMarker => 'Pharos courier';

  @override
  String get trackingPlacedTitle => 'ORDER PLACED';

  @override
  String get trackingPlacedDesc => 'We have received your order.';

  @override
  String get trackingPreparingTitle => 'BEING PREPARED';

  @override
  String get trackingPreparingDesc => 'Your products are being packed.';

  @override
  String get trackingShippedTitle => 'ON THE WAY';

  @override
  String get trackingShippedDesc => 'The courier has picked up the parcel.';

  @override
  String get trackingDeliveredTitle => 'DELIVERED';

  @override
  String get trackingDeliveredDesc => 'Your order has arrived!';

  @override
  String get orderStatusTitle => 'ORDER STATUS';

  @override
  String get fulfillmentHistory => 'FULFILLMENT HISTORY';

  @override
  String get referenceLabel => 'REFERENCE';

  @override
  String get rateProductsQuestion => 'HOW DO YOU RATE THE PRODUCTS?';

  @override
  String get addReviewButton => 'ADD REVIEW';

  @override
  String get technicalHelp => 'TECHNICAL SUPPORT';

  @override
  String get askQuestionButton => 'ASK A QUESTION';

  @override
  String get recentSearches => 'RECENT SEARCHES';

  @override
  String get clearLabel => 'Clear';

  @override
  String get suggestions => 'SUGGESTIONS';

  @override
  String get profileHeading => 'YOUR PHAROS PROFILE';

  @override
  String get loginOrRegister => 'LOG IN OR CREATE AN ACCOUNT';

  @override
  String get orderHistory => 'ORDER HISTORY';

  @override
  String get accountSettings => 'ACCOUNT SETTINGS';

  @override
  String get languageCurrency => 'Language & Currency';

  @override
  String get languageCurrencySubtitle => 'Change regional settings';

  @override
  String get myData => 'My details';

  @override
  String get myDataSubtitle => 'Edit your profile information';

  @override
  String get myAddresses => 'My addresses';

  @override
  String get myAddressesSubtitle => 'Manage delivery addresses';

  @override
  String get noOrderHistory => 'No order history';

  @override
  String get scanProduct => 'SCAN PRODUCT';

  @override
  String get scanHint => 'Place the barcode inside the frame';

  @override
  String get seeAll => 'See all';

  @override
  String get reviewHeading => 'YOUR OPINION MATTERS TO US';

  @override
  String get submitReview => 'SUBMIT REVIEW';

  @override
  String get reviewThanks => 'Thank you for your review!';

  @override
  String get rateProduct => 'Rate product';

  @override
  String get addButton => 'ADD';

  @override
  String get buyOnOrder => 'BUY ON ORDER';

  @override
  String get addToCartUpper => 'ADD TO CART';

  @override
  String get addedOnOrder => 'Product added (on order)';

  @override
  String get addedToCart => 'Added to cart';

  @override
  String get cartUpper => 'CART';

  @override
  String get notifyAvailability => 'NOTIFY ME WHEN AVAILABLE';

  @override
  String get notifySaved => 'You will be notified when it is available!';

  @override
  String get productUnavailable => 'PRODUCT UNAVAILABLE';

  @override
  String get loginTitle => 'PHAROS ACCOUNT';

  @override
  String get password => 'Password';

  @override
  String get loginButton => 'LOG IN';

  @override
  String get orSeparator => 'OR';

  @override
  String get registerButton => 'CREATE ACCOUNT';

  @override
  String get continueWithGoogle => 'CONTINUE WITH GOOGLE';

  @override
  String get chooseLanguage => 'Choose language';

  @override
  String get chooseCurrency => 'Choose currency';

  @override
  String get filtering => 'FILTERS';

  @override
  String get clearUpper => 'CLEAR';

  @override
  String get showResults => 'SHOW RESULTS';

  @override
  String get catalogFetchFailed => 'Could not load the catalog';

  @override
  String get tryAgainSentence => 'Try again';

  @override
  String get favoritesAdded => 'Added to favorites';

  @override
  String get favoritesRemoved => 'Removed from favorites';

  @override
  String get noProductsTitle => 'NO PRODUCTS';

  @override
  String get noResults => 'No results';

  @override
  String get clearSearch => 'Clear search';

  @override
  String get a11yBack => 'Back';

  @override
  String get a11yClose => 'Close';

  @override
  String get a11yRemove => 'Remove';

  @override
  String get a11yAddToFavorites => 'Add to favorites';

  @override
  String get a11yRemoveFromFavorites => 'Remove from favorites';

  @override
  String get a11yEdit => 'Edit';

  @override
  String get a11yShowPassword => 'Show password';

  @override
  String get a11yHidePassword => 'Hide password';

  @override
  String get a11yScanBarcode => 'Scan barcode';

  @override
  String get a11yFilters => 'Filters';

  @override
  String get a11yIncreaseQuantity => 'Increase quantity';

  @override
  String get a11yDecreaseQuantity => 'Decrease quantity';

  @override
  String get a11yOpenMenu => 'Open menu';

  @override
  String deleteAddressConfirm(String alias) {
    return 'Are you sure you want to delete the address \"$alias\"?';
  }

  @override
  String searchFor(String query) {
    return 'Search for \"$query\"';
  }

  @override
  String get a11yLogout => 'Log out';

  @override
  String get a11yRefresh => 'Refresh';

  @override
  String get a11yVoiceSearch => 'Voice search';

  @override
  String get a11yApplyVoucher => 'Apply discount code';

  @override
  String a11yRateStars(int count) {
    return 'Rate $count out of 5';
  }

  @override
  String galleryImageLabel(int index, int total) {
    return 'Image $index of $total';
  }

  @override
  String addedProduct(String name) {
    return 'Added: $name';
  }

  @override
  String get currencyRecalcInfo =>
      'Product prices will be converted automatically at the current rate in your store.';

  @override
  String get noSavedAddressesDot => 'You have no saved addresses yet.';

  @override
  String get listening => 'LISTENING...';

  @override
  String searchInStore(String store) {
    return 'Search in $store...';
  }

  @override
  String orderNumber(String reference) {
    return 'Order #$reference';
  }

  @override
  String get reviewPlaceholder => 'Write something more...';

  @override
  String get reviewSendError =>
      'An error occurred while submitting your review.';

  @override
  String get reviewsLoadError => 'Error while loading reviews.';

  @override
  String get reviewsFetchFailed => 'Could not load reviews.';

  @override
  String get noReviews => 'No reviews for this product yet.';

  @override
  String get reviewTitle => 'Review';

  @override
  String get checkoutScreenTitle => 'Order checkout';

  @override
  String get processingOrder => 'Processing your order...';

  @override
  String get doNotCloseApp => 'Please do not close the app';

  @override
  String get deliveryAddressHeader => 'Delivery address';

  @override
  String get deliveryMethodHeader => 'Delivery method';

  @override
  String get noDeliveryMethods => 'No delivery methods for this cart.';

  @override
  String get noPaymentMethods => 'No payment methods for this cart.';

  @override
  String get haveAccountQuestion => 'Already have an account?';

  @override
  String get loginForSavedAddresses =>
      'Log in to use your saved addresses and finish your order faster.';

  @override
  String get orContinueAsGuest => 'OR CONTINUE AS A GUEST';

  @override
  String get whereToShip => 'Where should we send your parcel?';

  @override
  String get tapToChooseAddress => 'Tap to choose an address';

  @override
  String get tapToAddShippingData => 'Tap to add shipping details';

  @override
  String get enterVoucherCode => 'Enter a discount code.';

  @override
  String get addProductsBeforeVoucher =>
      'Add products to your cart before using a discount code.';

  @override
  String get voucherAppliedSuccess => 'Discount code applied successfully!';

  @override
  String get nextDelivery => 'NEXT: DELIVERY';

  @override
  String get nextPayment => 'NEXT: PAYMENT';

  @override
  String get chooseAddressCta => 'CHOOSE ADDRESS';

  @override
  String get completeDetailsCta => 'COMPLETE YOUR DETAILS';

  @override
  String get chooseDeliveryCta => 'CHOOSE DELIVERY';

  @override
  String get choosePaymentCta => 'CHOOSE PAYMENT';

  @override
  String get missingCartItems => 'products in the cart';

  @override
  String get missingSyncedCart => 'a synced cart';

  @override
  String get missingDeliveryAddress => 'a delivery address';

  @override
  String get missingDeliveryMethod => 'a delivery method';

  @override
  String get missingPaymentMethod => 'a payment method';

  @override
  String get biometricCancelled =>
      'Identity verification cancelled. The order was not placed.';

  @override
  String get cartVerifyFailed => 'Could not verify the cart.';

  @override
  String get cartNotSynced => 'The cart was not synced with the server.';

  @override
  String get orderRejected => 'The server rejected the order.';

  @override
  String get orderFallbackRef => 'Order';

  @override
  String get guestEmailLabel => 'Email address';

  @override
  String get guestStreetLabel => 'Street and number';

  @override
  String get guestPostcodeLabel => 'Postal code';

  @override
  String get guestCityLabel => 'City';

  @override
  String get guestPhoneLabel => 'Phone number';

  @override
  String get createAccountForFaster =>
      'I want to create an account for faster shopping';

  @override
  String get shippingFree => 'FREE';

  @override
  String get carriersLoadFailed => 'Could not load delivery methods.';

  @override
  String get paymentsLoadFailed => 'Could not load payment methods.';

  @override
  String get stepDone => 'completed';

  @override
  String get stepCurrent => 'current';

  @override
  String get stepTodo => 'to do';

  @override
  String get voucherHint => 'Enter code...';

  @override
  String get voucherUseButton => 'APPLY';

  @override
  String payAmount(String amount) {
    return 'PAY $amount';
  }

  @override
  String missingFieldsMessage(String fields) {
    return 'Missing: $fields.';
  }

  @override
  String stepSemanticsLabel(int index, int total, String label, String state) {
    return 'Step $index of $total: $label, $state';
  }
}

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
}

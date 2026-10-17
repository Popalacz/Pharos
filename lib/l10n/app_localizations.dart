import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pl.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pl'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Pharos'**
  String get appTitle;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @wishlist.
  ///
  /// In en, this message translates to:
  /// **'Wishlist'**
  String get wishlist;

  /// No description provided for @cart.
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get cart;

  /// No description provided for @contact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get contact;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @checkout.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get checkout;

  /// No description provided for @delivery.
  ///
  /// In en, this message translates to:
  /// **'Delivery'**
  String get delivery;

  /// No description provided for @payment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get payment;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @addToCart.
  ///
  /// In en, this message translates to:
  /// **'Add to cart'**
  String get addToCart;

  /// No description provided for @outOfStock.
  ///
  /// In en, this message translates to:
  /// **'Out of stock'**
  String get outOfStock;

  /// No description provided for @orderSuccess.
  ///
  /// In en, this message translates to:
  /// **'Success!'**
  String get orderSuccess;

  /// No description provided for @tracking.
  ///
  /// In en, this message translates to:
  /// **'Tracking'**
  String get tracking;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @openingHours.
  ///
  /// In en, this message translates to:
  /// **'OPENING HOURS'**
  String get openingHours;

  /// No description provided for @followUs.
  ///
  /// In en, this message translates to:
  /// **'FOLLOW US'**
  String get followUs;

  /// No description provided for @officialMobileApp.
  ///
  /// In en, this message translates to:
  /// **'Official mobile app'**
  String get officialMobileApp;

  /// No description provided for @unexpectedError.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred. Please try again later.'**
  String get unexpectedError;

  /// No description provided for @maintenanceTitle.
  ///
  /// In en, this message translates to:
  /// **'MAINTENANCE BREAK'**
  String get maintenanceTitle;

  /// No description provided for @maintenanceMessage.
  ///
  /// In en, this message translates to:
  /// **'We are improving our store to make shopping even better. Please check back soon!'**
  String get maintenanceMessage;

  /// No description provided for @checkAgain.
  ///
  /// In en, this message translates to:
  /// **'CHECK AGAIN'**
  String get checkAgain;

  /// No description provided for @updateRequiredTitle.
  ///
  /// In en, this message translates to:
  /// **'UPDATE REQUIRED'**
  String get updateRequiredTitle;

  /// No description provided for @updateRequiredMessage.
  ///
  /// In en, this message translates to:
  /// **'Your app version is outdated. Download the latest version from the official store to continue shopping.'**
  String get updateRequiredMessage;

  /// No description provided for @downloadUpdate.
  ///
  /// In en, this message translates to:
  /// **'DOWNLOAD UPDATE'**
  String get downloadUpdate;

  /// No description provided for @myProfile.
  ///
  /// In en, this message translates to:
  /// **'MY PROFILE'**
  String get myProfile;

  /// No description provided for @drawerTagline.
  ///
  /// In en, this message translates to:
  /// **'Premium E-commerce Experience'**
  String get drawerTagline;

  /// No description provided for @drawerHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get drawerHome;

  /// No description provided for @drawerCategories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get drawerCategories;

  /// No description provided for @drawerLanguageCurrency.
  ///
  /// In en, this message translates to:
  /// **'Language & Currency'**
  String get drawerLanguageCurrency;

  /// No description provided for @drawerRefreshStore.
  ///
  /// In en, this message translates to:
  /// **'Refresh store'**
  String get drawerRefreshStore;

  /// No description provided for @calendar.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get calendar;

  /// No description provided for @calendarUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Calendar is currently unavailable.'**
  String get calendarUnavailable;

  /// No description provided for @calendarLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load calendar.'**
  String get calendarLoadError;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @openInMaps.
  ///
  /// In en, this message translates to:
  /// **'Open in Maps'**
  String get openInMaps;

  /// No description provided for @orderStatusUpdating.
  ///
  /// In en, this message translates to:
  /// **'Updating...'**
  String get orderStatusUpdating;

  /// No description provided for @yourCart.
  ///
  /// In en, this message translates to:
  /// **'Your Cart'**
  String get yourCart;

  /// No description provided for @cartEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your cart is empty'**
  String get cartEmpty;

  /// No description provided for @contactUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Contact details are currently unavailable.'**
  String get contactUnavailable;

  /// No description provided for @yourPromoCode.
  ///
  /// In en, this message translates to:
  /// **'YOUR PROMO CODE:'**
  String get yourPromoCode;

  /// No description provided for @finishShopping.
  ///
  /// In en, this message translates to:
  /// **'Complete your purchase!'**
  String get finishShopping;

  /// No description provided for @cartRecoveryMessage.
  ///
  /// In en, this message translates to:
  /// **'Items worth {price} are waiting in your cart'**
  String cartRecoveryMessage(Object price);

  /// No description provided for @recentlyViewed.
  ///
  /// In en, this message translates to:
  /// **'Recently viewed'**
  String get recentlyViewed;

  /// No description provided for @syncErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Pharos API Sync Error'**
  String get syncErrorTitle;

  /// No description provided for @syncErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Check your internet connection and try again.'**
  String get syncErrorMessage;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'TRY AGAIN'**
  String get tryAgain;

  /// No description provided for @cartEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'It looks like you haven\'t chosen anything yet. Your dream products are waiting!'**
  String get cartEmptyMessage;

  /// No description provided for @startShopping.
  ///
  /// In en, this message translates to:
  /// **'START SHOPPING'**
  String get startShopping;

  /// No description provided for @freeShippingUnlocked.
  ///
  /// In en, this message translates to:
  /// **'Free shipping unlocked!'**
  String get freeShippingUnlocked;

  /// No description provided for @freeShippingMissing.
  ///
  /// In en, this message translates to:
  /// **'You\'re {price} away from free shipping'**
  String freeShippingMissing(Object price);

  /// No description provided for @subtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get subtotal;

  /// No description provided for @shipping.
  ///
  /// In en, this message translates to:
  /// **'Shipping'**
  String get shipping;

  /// No description provided for @checkoutButton.
  ///
  /// In en, this message translates to:
  /// **'PROCEED TO CHECKOUT'**
  String get checkoutButton;

  /// No description provided for @voucherLabel.
  ///
  /// In en, this message translates to:
  /// **'Discount code'**
  String get voucherLabel;

  /// No description provided for @voucherApplied.
  ///
  /// In en, this message translates to:
  /// **'Discount code applied'**
  String get voucherApplied;

  /// No description provided for @removedFromCart.
  ///
  /// In en, this message translates to:
  /// **'Removed from cart'**
  String get removedFromCart;

  /// No description provided for @discount.
  ///
  /// In en, this message translates to:
  /// **'Discount'**
  String get discount;

  /// No description provided for @productsTotal.
  ///
  /// In en, this message translates to:
  /// **'Products total'**
  String get productsTotal;

  /// No description provided for @addressSavedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Address saved successfully'**
  String get addressSavedSuccess;

  /// No description provided for @newAddress.
  ///
  /// In en, this message translates to:
  /// **'New address'**
  String get newAddress;

  /// No description provided for @editAddress.
  ///
  /// In en, this message translates to:
  /// **'Edit address'**
  String get editAddress;

  /// No description provided for @saveAddressButton.
  ///
  /// In en, this message translates to:
  /// **'SAVE ADDRESS'**
  String get saveAddressButton;

  /// No description provided for @chooseAddress.
  ///
  /// In en, this message translates to:
  /// **'Choose address'**
  String get chooseAddress;

  /// No description provided for @addNewAddressButton.
  ///
  /// In en, this message translates to:
  /// **'ADD NEW ADDRESS'**
  String get addNewAddressButton;

  /// No description provided for @editProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'EDIT PROFILE'**
  String get editProfileTitle;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get lastName;

  /// No description provided for @saveChangesButton.
  ///
  /// In en, this message translates to:
  /// **'SAVE CHANGES'**
  String get saveChangesButton;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated!'**
  String get profileUpdated;

  /// No description provided for @myAddressesTitle.
  ///
  /// In en, this message translates to:
  /// **'MY ADDRESSES'**
  String get myAddressesTitle;

  /// No description provided for @noSavedAddresses.
  ///
  /// In en, this message translates to:
  /// **'You have no saved addresses yet'**
  String get noSavedAddresses;

  /// No description provided for @deleteAddress.
  ///
  /// In en, this message translates to:
  /// **'Delete address'**
  String get deleteAddress;

  /// No description provided for @cancelButton.
  ///
  /// In en, this message translates to:
  /// **'CANCEL'**
  String get cancelButton;

  /// No description provided for @deleteButton.
  ///
  /// In en, this message translates to:
  /// **'DELETE'**
  String get deleteButton;

  /// No description provided for @regionalSettings.
  ///
  /// In en, this message translates to:
  /// **'Regional settings'**
  String get regionalSettings;

  /// No description provided for @categoriesTitle.
  ///
  /// In en, this message translates to:
  /// **'CATEGORIES'**
  String get categoriesTitle;

  /// No description provided for @wishlistTitle.
  ///
  /// In en, this message translates to:
  /// **'FAVORITES'**
  String get wishlistTitle;

  /// No description provided for @wishlistEmpty.
  ///
  /// In en, this message translates to:
  /// **'YOUR LIST IS EMPTY'**
  String get wishlistEmpty;

  /// No description provided for @startDiscovering.
  ///
  /// In en, this message translates to:
  /// **'START EXPLORING'**
  String get startDiscovering;

  /// No description provided for @orderSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'SUCCESS!'**
  String get orderSuccessTitle;

  /// No description provided for @orderValue.
  ///
  /// In en, this message translates to:
  /// **'ORDER VALUE'**
  String get orderValue;

  /// No description provided for @paidBadge.
  ///
  /// In en, this message translates to:
  /// **'PAID'**
  String get paidBadge;

  /// No description provided for @continueShopping.
  ///
  /// In en, this message translates to:
  /// **'CONTINUE SHOPPING'**
  String get continueShopping;

  /// No description provided for @warehouseMarker.
  ///
  /// In en, this message translates to:
  /// **'Pharos warehouse'**
  String get warehouseMarker;

  /// No description provided for @yourAddressMarker.
  ///
  /// In en, this message translates to:
  /// **'Your address'**
  String get yourAddressMarker;

  /// No description provided for @courierMarker.
  ///
  /// In en, this message translates to:
  /// **'Pharos courier'**
  String get courierMarker;

  /// No description provided for @trackingPlacedTitle.
  ///
  /// In en, this message translates to:
  /// **'ORDER PLACED'**
  String get trackingPlacedTitle;

  /// No description provided for @trackingPlacedDesc.
  ///
  /// In en, this message translates to:
  /// **'We have received your order.'**
  String get trackingPlacedDesc;

  /// No description provided for @trackingPreparingTitle.
  ///
  /// In en, this message translates to:
  /// **'BEING PREPARED'**
  String get trackingPreparingTitle;

  /// No description provided for @trackingPreparingDesc.
  ///
  /// In en, this message translates to:
  /// **'Your products are being packed.'**
  String get trackingPreparingDesc;

  /// No description provided for @trackingShippedTitle.
  ///
  /// In en, this message translates to:
  /// **'ON THE WAY'**
  String get trackingShippedTitle;

  /// No description provided for @trackingShippedDesc.
  ///
  /// In en, this message translates to:
  /// **'The courier has picked up the parcel.'**
  String get trackingShippedDesc;

  /// No description provided for @trackingDeliveredTitle.
  ///
  /// In en, this message translates to:
  /// **'DELIVERED'**
  String get trackingDeliveredTitle;

  /// No description provided for @trackingDeliveredDesc.
  ///
  /// In en, this message translates to:
  /// **'Your order has arrived!'**
  String get trackingDeliveredDesc;

  /// No description provided for @orderStatusTitle.
  ///
  /// In en, this message translates to:
  /// **'ORDER STATUS'**
  String get orderStatusTitle;

  /// No description provided for @fulfillmentHistory.
  ///
  /// In en, this message translates to:
  /// **'FULFILLMENT HISTORY'**
  String get fulfillmentHistory;

  /// No description provided for @referenceLabel.
  ///
  /// In en, this message translates to:
  /// **'REFERENCE'**
  String get referenceLabel;

  /// No description provided for @rateProductsQuestion.
  ///
  /// In en, this message translates to:
  /// **'HOW DO YOU RATE THE PRODUCTS?'**
  String get rateProductsQuestion;

  /// No description provided for @addReviewButton.
  ///
  /// In en, this message translates to:
  /// **'ADD REVIEW'**
  String get addReviewButton;

  /// No description provided for @technicalHelp.
  ///
  /// In en, this message translates to:
  /// **'TECHNICAL SUPPORT'**
  String get technicalHelp;

  /// No description provided for @askQuestionButton.
  ///
  /// In en, this message translates to:
  /// **'ASK A QUESTION'**
  String get askQuestionButton;

  /// No description provided for @recentSearches.
  ///
  /// In en, this message translates to:
  /// **'RECENT SEARCHES'**
  String get recentSearches;

  /// No description provided for @clearLabel.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clearLabel;

  /// No description provided for @suggestions.
  ///
  /// In en, this message translates to:
  /// **'SUGGESTIONS'**
  String get suggestions;

  /// No description provided for @profileHeading.
  ///
  /// In en, this message translates to:
  /// **'YOUR PHAROS PROFILE'**
  String get profileHeading;

  /// No description provided for @loginOrRegister.
  ///
  /// In en, this message translates to:
  /// **'LOG IN OR CREATE AN ACCOUNT'**
  String get loginOrRegister;

  /// No description provided for @orderHistory.
  ///
  /// In en, this message translates to:
  /// **'ORDER HISTORY'**
  String get orderHistory;

  /// No description provided for @accountSettings.
  ///
  /// In en, this message translates to:
  /// **'ACCOUNT SETTINGS'**
  String get accountSettings;

  /// No description provided for @languageCurrency.
  ///
  /// In en, this message translates to:
  /// **'Language & Currency'**
  String get languageCurrency;

  /// No description provided for @languageCurrencySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Change regional settings'**
  String get languageCurrencySubtitle;

  /// No description provided for @myData.
  ///
  /// In en, this message translates to:
  /// **'My details'**
  String get myData;

  /// No description provided for @myDataSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Edit your profile information'**
  String get myDataSubtitle;

  /// No description provided for @myAddresses.
  ///
  /// In en, this message translates to:
  /// **'My addresses'**
  String get myAddresses;

  /// No description provided for @myAddressesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage delivery addresses'**
  String get myAddressesSubtitle;

  /// No description provided for @noOrderHistory.
  ///
  /// In en, this message translates to:
  /// **'No order history'**
  String get noOrderHistory;

  /// No description provided for @scanProduct.
  ///
  /// In en, this message translates to:
  /// **'SCAN PRODUCT'**
  String get scanProduct;

  /// No description provided for @scanHint.
  ///
  /// In en, this message translates to:
  /// **'Place the barcode inside the frame'**
  String get scanHint;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// No description provided for @reviewHeading.
  ///
  /// In en, this message translates to:
  /// **'YOUR OPINION MATTERS TO US'**
  String get reviewHeading;

  /// No description provided for @submitReview.
  ///
  /// In en, this message translates to:
  /// **'SUBMIT REVIEW'**
  String get submitReview;

  /// No description provided for @reviewThanks.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your review!'**
  String get reviewThanks;

  /// No description provided for @rateProduct.
  ///
  /// In en, this message translates to:
  /// **'Rate product'**
  String get rateProduct;

  /// No description provided for @addButton.
  ///
  /// In en, this message translates to:
  /// **'ADD'**
  String get addButton;

  /// No description provided for @buyOnOrder.
  ///
  /// In en, this message translates to:
  /// **'BUY ON ORDER'**
  String get buyOnOrder;

  /// No description provided for @addToCartUpper.
  ///
  /// In en, this message translates to:
  /// **'ADD TO CART'**
  String get addToCartUpper;

  /// No description provided for @addedOnOrder.
  ///
  /// In en, this message translates to:
  /// **'Product added (on order)'**
  String get addedOnOrder;

  /// No description provided for @addedToCart.
  ///
  /// In en, this message translates to:
  /// **'Added to cart'**
  String get addedToCart;

  /// No description provided for @cartUpper.
  ///
  /// In en, this message translates to:
  /// **'CART'**
  String get cartUpper;

  /// No description provided for @notifyAvailability.
  ///
  /// In en, this message translates to:
  /// **'NOTIFY ME WHEN AVAILABLE'**
  String get notifyAvailability;

  /// No description provided for @notifySaved.
  ///
  /// In en, this message translates to:
  /// **'You will be notified when it is available!'**
  String get notifySaved;

  /// No description provided for @productUnavailable.
  ///
  /// In en, this message translates to:
  /// **'PRODUCT UNAVAILABLE'**
  String get productUnavailable;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'PHAROS ACCOUNT'**
  String get loginTitle;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'LOG IN'**
  String get loginButton;

  /// No description provided for @orSeparator.
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get orSeparator;

  /// No description provided for @registerButton.
  ///
  /// In en, this message translates to:
  /// **'CREATE ACCOUNT'**
  String get registerButton;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'CONTINUE WITH GOOGLE'**
  String get continueWithGoogle;

  /// No description provided for @chooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose language'**
  String get chooseLanguage;

  /// No description provided for @chooseCurrency.
  ///
  /// In en, this message translates to:
  /// **'Choose currency'**
  String get chooseCurrency;

  /// No description provided for @filtering.
  ///
  /// In en, this message translates to:
  /// **'FILTERS'**
  String get filtering;

  /// No description provided for @clearUpper.
  ///
  /// In en, this message translates to:
  /// **'CLEAR'**
  String get clearUpper;

  /// No description provided for @showResults.
  ///
  /// In en, this message translates to:
  /// **'SHOW RESULTS'**
  String get showResults;

  /// No description provided for @catalogFetchFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load the catalog'**
  String get catalogFetchFailed;

  /// No description provided for @tryAgainSentence.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgainSentence;

  /// No description provided for @favoritesAdded.
  ///
  /// In en, this message translates to:
  /// **'Added to favorites'**
  String get favoritesAdded;

  /// No description provided for @favoritesRemoved.
  ///
  /// In en, this message translates to:
  /// **'Removed from favorites'**
  String get favoritesRemoved;

  /// No description provided for @noProductsTitle.
  ///
  /// In en, this message translates to:
  /// **'NO PRODUCTS'**
  String get noProductsTitle;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No results'**
  String get noResults;

  /// No description provided for @clearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get clearSearch;

  /// No description provided for @a11yBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get a11yBack;

  /// No description provided for @a11yClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get a11yClose;

  /// No description provided for @a11yRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get a11yRemove;

  /// No description provided for @a11yAddToFavorites.
  ///
  /// In en, this message translates to:
  /// **'Add to favorites'**
  String get a11yAddToFavorites;

  /// No description provided for @a11yRemoveFromFavorites.
  ///
  /// In en, this message translates to:
  /// **'Remove from favorites'**
  String get a11yRemoveFromFavorites;

  /// No description provided for @a11yEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get a11yEdit;

  /// No description provided for @a11yShowPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get a11yShowPassword;

  /// No description provided for @a11yHidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get a11yHidePassword;

  /// No description provided for @a11yScanBarcode.
  ///
  /// In en, this message translates to:
  /// **'Scan barcode'**
  String get a11yScanBarcode;

  /// No description provided for @a11yFilters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get a11yFilters;

  /// No description provided for @a11yIncreaseQuantity.
  ///
  /// In en, this message translates to:
  /// **'Increase quantity'**
  String get a11yIncreaseQuantity;

  /// No description provided for @a11yDecreaseQuantity.
  ///
  /// In en, this message translates to:
  /// **'Decrease quantity'**
  String get a11yDecreaseQuantity;

  /// No description provided for @a11yOpenMenu.
  ///
  /// In en, this message translates to:
  /// **'Open menu'**
  String get a11yOpenMenu;

  /// No description provided for @deleteAddressConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete the address \"{alias}\"?'**
  String deleteAddressConfirm(String alias);

  /// No description provided for @searchFor.
  ///
  /// In en, this message translates to:
  /// **'Search for \"{query}\"'**
  String searchFor(String query);

  /// No description provided for @a11yLogout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get a11yLogout;

  /// No description provided for @a11yRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get a11yRefresh;

  /// No description provided for @a11yVoiceSearch.
  ///
  /// In en, this message translates to:
  /// **'Voice search'**
  String get a11yVoiceSearch;

  /// No description provided for @a11yApplyVoucher.
  ///
  /// In en, this message translates to:
  /// **'Apply discount code'**
  String get a11yApplyVoucher;

  /// No description provided for @a11yRateStars.
  ///
  /// In en, this message translates to:
  /// **'Rate {count} out of 5'**
  String a11yRateStars(int count);

  /// No description provided for @galleryImageLabel.
  ///
  /// In en, this message translates to:
  /// **'Image {index} of {total}'**
  String galleryImageLabel(int index, int total);

  /// No description provided for @addedProduct.
  ///
  /// In en, this message translates to:
  /// **'Added: {name}'**
  String addedProduct(String name);

  /// No description provided for @currencyRecalcInfo.
  ///
  /// In en, this message translates to:
  /// **'Product prices will be converted automatically at the current rate in your store.'**
  String get currencyRecalcInfo;

  /// No description provided for @noSavedAddressesDot.
  ///
  /// In en, this message translates to:
  /// **'You have no saved addresses yet.'**
  String get noSavedAddressesDot;

  /// No description provided for @listening.
  ///
  /// In en, this message translates to:
  /// **'LISTENING...'**
  String get listening;

  /// No description provided for @searchInStore.
  ///
  /// In en, this message translates to:
  /// **'Search in {store}...'**
  String searchInStore(String store);

  /// No description provided for @orderNumber.
  ///
  /// In en, this message translates to:
  /// **'Order #{reference}'**
  String orderNumber(String reference);

  /// No description provided for @reviewPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Write something more...'**
  String get reviewPlaceholder;

  /// No description provided for @reviewSendError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while submitting your review.'**
  String get reviewSendError;

  /// No description provided for @reviewsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Error while loading reviews.'**
  String get reviewsLoadError;

  /// No description provided for @reviewsFetchFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load reviews.'**
  String get reviewsFetchFailed;

  /// No description provided for @noReviews.
  ///
  /// In en, this message translates to:
  /// **'No reviews for this product yet.'**
  String get noReviews;

  /// No description provided for @reviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get reviewTitle;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'pl'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pl':
      return AppLocalizationsPl();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

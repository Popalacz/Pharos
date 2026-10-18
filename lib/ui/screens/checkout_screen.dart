import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:pharos/core/api/api_config.dart';
import 'package:pharos/core/theme/app_colors.dart';
import 'package:pharos/core/theme/app_spacing.dart';
import 'package:pharos/core/providers/checkout_notifier.dart';
import 'package:pharos/core/network/api_service.dart';
import 'package:pharos/core/providers/cart_provider.dart';
import 'package:pharos/data/repositories/checkout_repository.dart';
import 'package:pharos/data/models/checkout_models.dart';
import 'package:pharos/data/models/address_model.dart';
import 'package:pharos/core/providers/user_provider.dart';
import 'package:pharos/core/providers/localization_provider.dart';
import 'package:pharos/core/constants/pharos_layout.dart';
import 'package:pharos/core/services/analytics_service.dart';
import 'package:pharos/core/services/google_places_service.dart';
import 'package:pharos/ui/screens/checkout/checkout_chrome.dart';
import 'package:pharos/ui/screens/checkout/checkout_guest_form.dart';
import 'package:pharos/ui/screens/checkout/checkout_option_cards.dart';
import 'package:pharos/ui/screens/checkout/checkout_step_indicator.dart';
import 'package:pharos/ui/screens/checkout/checkout_summary.dart';
import 'package:pharos/ui/screens/checkout/checkout_variant.dart';
import 'package:pharos/ui/screens/login_screen.dart';
import 'package:pharos/ui/screens/order_confirmation_screen.dart';
import 'package:pharos/ui/screens/address_selection_screen.dart';
import 'package:pharos/ui/widgets/pharos_button.dart';
import 'package:pharos/core/utils/form_validation.dart';
import 'package:pharos/core/utils/validation_feedback.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key, this.variant});

  /// Wymusza wariant (testy, eksperyment); domyślnie wariant z analityki.
  final CheckoutVariant? variant;

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  static const _stepLabels = ['Adres', 'Dostawa', 'Płatność'];
  static const _lastStep = 2;

  CarrierModel? _selectedCarrier;
  PaymentMethodModel? _selectedPayment;
  AddressModel? _selectedAddress;
  bool _isProcessing = false;
  bool _createAccount = false;
  final AnalyticsService _analytics = AnalyticsService();
  final Set<String> _completedSteps = {};
  String? _validationMessage;
  final _guestFormKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  late final CheckoutVariant _variant;
  int _step = 0;

  final _guest = GuestFormController();
  final _voucherController = TextEditingController();

  List<CarrierModel>? _carriers;
  bool _isApplyingVoucher = false;
  List<PaymentMethodModel>? _payments;
  bool _carriersError = false;
  bool _paymentsError = false;
  double? _shippingCost;

  late CheckoutRepository _checkoutRepository;
  late CheckoutNotifier _checkoutNotifier;
  GooglePlacesService? _placesService;
  List<dynamic> _addressSuggestions = [];
  Timer? _placesDebounce;

  bool get _isStepped => _variant == CheckoutVariant.stepped;

  @override
  void initState() {
    super.initState();
    _variant = widget.variant ?? CheckoutVariant.current;
    AnalyticsService.checkoutVariant = _variant.code;
    _checkoutRepository = CheckoutRepository(
      apiService: context.read<ApiService>(),
      useMockData: ApiConfig.forceMockData,
    );
    _checkoutNotifier = CheckoutNotifier(
      checkoutRepository: _checkoutRepository,
    );
    _placesService = GooglePlacesService(ApiConfig.apiKey);
    _refreshCheckoutData();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = context.read<UserProvider>();
      _analytics.logBeginCheckout(
        context.read<CartProvider>().totalAmount,
        currency: context.read<LocalizationProvider>().currentCurrency?.isoCode ?? 'PLN',
        isGuest: !userProvider.isLoggedIn,
      );
      if (userProvider.addresses.isNotEmpty) {
        setState(() => _selectedAddress = userProvider.addresses.first);
        _updateShippingCost();
      }
    });
  }

  @override
  void dispose() {
    _guest.dispose();
    _voucherController.dispose();
    _scrollController.dispose();
    _placesDebounce?.cancel();
    super.dispose();
  }


  Future<void> _refreshCheckoutData() async {
    setState(() {
      _carriers = null;
      _payments = null;
      _carriersError = false;
      _paymentsError = false;
    });

    final cartId = context.read<CartProvider>().idCart;
    await _checkoutNotifier.loadOptions(cartId: cartId);

    if (!mounted) return;

    setState(() {
      _carriers = _checkoutNotifier.carriers;
      _payments = _checkoutNotifier.payments;
      _carriersError = _checkoutNotifier.carriersError;
      _paymentsError = _checkoutNotifier.paymentsError;
      _selectedCarrier = _checkoutNotifier.selectedCarrier;
      _selectedPayment = _checkoutNotifier.selectedPayment;
    });

    _updateShippingCost();
  }

  Future<void> _updateShippingCost() async {
    final cart = context.read<CartProvider>();
    if (cart.idCart == null || _selectedAddress == null || _selectedCarrier == null) {
      setState(() => _shippingCost = null);
      return;
    }

    final result = await _checkoutRepository.getShippingCosts(
      cartId: cart.idCart!,
      addressId: _selectedAddress!.id,
      carrierId: _selectedCarrier!.id,
    );

    if (!mounted) return;

    result.fold(
      (_) => setState(() => _shippingCost = _selectedCarrier?.price),
      (data) {
        if (data['success'] == true) {
          final double newShipping = (data['shipping_cost'] as num?)?.toDouble() ?? _selectedCarrier?.price ?? 0.0;
          final double newTotal = (data['total_with_shipping'] as num?)?.toDouble() ?? (cart.subtotalAmount + newShipping);
          
          setState(() => _shippingCost = newShipping);
          
          // Update global cart provider to sync UI everywhere
          cart.updateServerTotals(shipping: newShipping, total: newTotal);
        }
      },
    );
  }

  double get _resolvedShippingCost => _shippingCost ?? _selectedCarrier?.price ?? 0.0;
  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final loc = context.watch<LocalizationProvider>();
    final userProvider = context.watch<UserProvider>();
    final isGuest = !userProvider.isLoggedIn;

    // Final total calculation: Trust the server combined total if available,
    // otherwise sum products total with current shipping cost.
    final double total = cart.totalAmount;
    final String formattedTotal = loc.formatPrice(total);

    return PopScope(
      canPop: !(_isStepped && _step > 0),
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _goBack();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Finalizacja zamówienia', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.text)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            tooltip: 'Wstecz',
            icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppColors.text),
            onPressed: _handleBackButton,
          ),
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: PharosLayout.spaceLg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: PharosLayout.spaceMd),
                    _buildStepProgress(isGuest),
                    const SizedBox(height: PharosLayout.spaceLg),
                    if (_validationMessage != null) ...[
                      CheckoutValidationBanner(message: _validationMessage!),
                      const SizedBox(height: AppSpacing.s16),
                    ],
                    if (_showSection(0)) ..._addressSection(userProvider),
                    if (_showSection(1)) ..._shippingSection(loc),
                    if (_showSection(2)) ..._paymentSection(cart, loc, total),
                    const SizedBox(height: 140),
                  ],
                ),
              ),
            ),
            if (_isProcessing)
              Container(
                color: AppColors.black.withOpacity(0.85),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: AppColors.accentText),
                      SizedBox(height: AppSpacing.s24),
                      Text('Przetwarzanie zamówienia...', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 18)),
                      SizedBox(height: AppSpacing.s8),
                      Text('Proszę nie zamykać aplikacji', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                    ],
                  ),
                ),
              ),
          ],
        ),
        bottomNavigationBar: _buildBottomBar(cart, total, formattedTotal),
      ),
    );
  }

  /// Wariant A pokazuje wszystkie sekcje, wariant B tylko bieżący krok.
  bool _showSection(int step) => !_isStepped || _step == step;

  List<Widget> _addressSection(UserProvider userProvider) {
    return [
      const CheckoutSectionHeader(title: 'Adres dostawy', icon: Icons.location_on_rounded),
      _buildAnimatedAddressSection(userProvider),
      const SizedBox(height: AppSpacing.s32),
    ];
  }

  List<Widget> _shippingSection(LocalizationProvider loc) {
    final noOptions = _carriers != null && _carriers!.isEmpty && !_carriersError;
    if (!_isStepped && !_carriersError && !(_carriers?.isNotEmpty ?? false)) return const [];
    return [
      const CheckoutSectionHeader(title: 'Metoda dostawy', icon: Icons.local_shipping_rounded),
      if (noOptions)
        const Text('Brak metod dostawy dla tego koszyka.', style: TextStyle(color: AppColors.textSecondary, fontSize: 14))
      else
        CheckoutCarrierList(
          carriers: _carriers,
          hasError: _carriersError,
          selected: _selectedCarrier,
          selectedShippingCost: _resolvedShippingCost,
          loc: loc,
          onSelect: (carrier) {
            setState(() => _selectedCarrier = carrier);
            _updateShippingCost();
          },
          onRetry: _refreshCheckoutData,
        ),
      const SizedBox(height: AppSpacing.s32),
    ];
  }

  List<Widget> _paymentSection(CartProvider cart, LocalizationProvider loc, double total) {
    final noOptions = _payments != null && _payments!.isEmpty && !_paymentsError;
    return [
      if (!noOptions || _isStepped) ...[
        const CheckoutSectionHeader(title: 'Płatność', icon: Icons.account_balance_wallet_rounded),
        if (noOptions)
          const Text('Brak metod płatności dla tego koszyka.', style: TextStyle(color: AppColors.textSecondary, fontSize: 14))
        else
          CheckoutPaymentList(
            payments: _payments,
            hasError: _paymentsError,
            selected: _selectedPayment,
            onSelect: (method) => setState(() => _selectedPayment = method),
            onRetry: _refreshCheckoutData,
          ),
        const SizedBox(height: AppSpacing.s32),
      ],
      CheckoutVoucherSection(
        controller: _voucherController,
        isApplying: _isApplyingVoucher,
        onApply: _applyVoucher,
      ),
      const SizedBox(height: AppSpacing.s24),
      CheckoutOrderSummary(
        subtotal: cart.subtotalAmount,
        shipping: _resolvedShippingCost,
        total: total,
        loc: loc,
      ),
    ];
  }

  bool get _hasCarrierOptions => _carriers != null && _carriers!.isNotEmpty;
  bool get _hasPaymentOptions => _payments != null && _payments!.isNotEmpty;

  Widget _buildStepProgress(bool isGuest) {
    final hasAddress = isGuest ? _guest.isValid : _selectedAddress != null;
    final hasCarrier = _selectedCarrier != null;
    final hasPayment = _selectedPayment != null;
    _trackStepCompletion(hasAddress, hasCarrier, hasPayment);

    return CheckoutStepIndicator(
      labels: _stepLabels,
      completed: [hasAddress, hasCarrier, hasPayment],
      currentIndex: _isStepped ? _step : null,
    );
  }

  void _trackStepCompletion(bool hasAddress, bool hasCarrier, bool hasPayment) {
    final done = {
      AnalyticsService.stepAddress: hasAddress,
      AnalyticsService.stepShipping: hasCarrier,
      AnalyticsService.stepPayment: hasPayment,
    };
    for (final entry in done.entries) {
      if (entry.value && _completedSteps.add(entry.key)) {
        _analytics.logCheckoutStepComplete(entry.key);
      }
    }
  }

  void _handleBackButton() {
    if (_isStepped && _step > 0) {
      _goBack();
    } else {
      Navigator.pop(context);
    }
  }

  void _goBack() {
    setState(() {
      _validationMessage = null;
      _step--;
    });
    _scrollToTop();
  }

  void _scrollToTop() {
    if (_scrollController.hasClients) _scrollController.jumpTo(0);
  }

  List<String> _stepMissingLabels(int step, bool isGuest) {
    switch (step) {
      case 0:
        return isGuest ? _guest.missingLabels() : (_selectedAddress == null ? ['adresu dostawy'] : []);
      case 1:
        return _hasCarrierOptions && _selectedCarrier == null ? ['metody dostawy'] : [];
      default:
        return [];
    }
  }

  void _goToNextStep(bool isGuest) {
    final missing = _stepMissingLabels(_step, isGuest);
    if (missing.isNotEmpty) {
      if (isGuest && _step == 0) _guestFormKey.currentState?.validate();
      final message = FormValidation.formatMissingFields(missing);
      _analytics.logCheckoutValidationError('missing_fields', fieldCount: missing.length);
      setState(() => _validationMessage = message);
      showValidationSnackBar(context, message);
      return;
    }
    setState(() {
      _validationMessage = null;
      _step++;
    });
    _scrollToTop();
  }

  Widget _buildAnimatedAddressSection(UserProvider userProvider) {
    if (userProvider.isLoggedIn) {
      return AnimatedSwitcher(
        duration: PharosLayout.motionNormal,
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(animation),
            child: child,
          ),
        ),
        child: _buildAddressCard(context, userProvider),
      );
    }

    return Column(
      key: const ValueKey('guest_checkout'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildGuestLoginPrompt(),
        const SizedBox(height: AppSpacing.s16),
        _buildGuestForm(),
      ],
    );
  }

  Widget _buildGuestForm() {
    return CheckoutGuestForm(
      formKey: _guestFormKey,
      controller: _guest,
      createAccount: _createAccount,
      onCreateAccountChanged: (value) => setState(() => _createAccount = value),
      onFieldChanged: () => setState(() {}),
      onAddressChanged: _onAddressChanged,
      addressSuggestions: _addressSuggestions.isNotEmpty ? _buildAddressSuggestions() : null,
    );
  }

  Widget _buildGuestLoginPrompt() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(PharosLayout.radiusLg),
        border: Border.all(color: AppColors.accent.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Masz już konto?',
            style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 6),
          Text(
            'Zaloguj się, aby użyć zapisanych adresów i szybciej dokończyć zamówienie.',
            style: TextStyle(color: AppColors.text.withOpacity(0.55), fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: AppSpacing.s16),
          OutlinedButton.icon(
            onPressed: _openLoginFromCheckout,
            icon: const Icon(Icons.login_rounded, size: 18),
            label: const Text('ZALOGUJ SIĘ'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.accentText,
              side: BorderSide(color: AppColors.accent.withOpacity(0.6)),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(PharosLayout.radiusMd)),
            ),
          ),
          const SizedBox(height: AppSpacing.s16),
          Row(
            children: [
              Expanded(child: Divider(color: AppColors.text.withOpacity(0.08))),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'LUB KONTYNUUJ JAKO GOŚĆ',
                  style: TextStyle(
                    color: AppColors.text.withOpacity(0.35),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
              Expanded(child: Divider(color: AppColors.text.withOpacity(0.08))),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _openLoginFromCheckout() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );

    if (!mounted) {
      return;
    }

    final userProvider = context.read<UserProvider>();
    if (!userProvider.isLoggedIn) {
      return;
    }

    if (userProvider.addresses.isEmpty) {
      await userProvider.fetchAddresses();
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _validationMessage = null;
      if (userProvider.addresses.isNotEmpty) {
        _selectedAddress = userProvider.addresses.first;
      }
    });

    if (_selectedAddress != null) {
      await _updateShippingCost();
    }
  }


  Widget _buildAddressCard(BuildContext context, UserProvider userProvider) {
    final bool hasAddresses = userProvider.addresses.isNotEmpty;

    return InkWell(
      key: const ValueKey('address_card'),
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AddressSelectionScreen(selectedAddress: _selectedAddress)),
        );
        if (result != null && result is AddressModel) {
          setState(() => _selectedAddress = result);
          _updateShippingCost();
        }
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(PharosLayout.radiusLg),
          border: Border.all(color: _selectedAddress == null ? AppColors.error.withOpacity(0.5) : AppColors.text.withOpacity(0.05)),
          boxShadow: [BoxShadow(color: AppColors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Expanded(
              child: _selectedAddress != null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${_selectedAddress!.firstname} ${_selectedAddress!.lastname}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.text, fontSize: 16)),
                        const SizedBox(height: 6),
                        Text(_selectedAddress!.address1, style: TextStyle(color: AppColors.text.withOpacity(0.6))),
                        Text('${_selectedAddress!.postcode} ${_selectedAddress!.city}', style: TextStyle(color: AppColors.text.withOpacity(0.6))),
                        if (_selectedAddress!.phone != null && _selectedAddress!.phone!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(_selectedAddress!.phone!, style: const TextStyle(color: AppColors.accentText, fontSize: 13, fontWeight: FontWeight.w700)),
                          ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Gdzie mamy wysłać paczkę?', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: AppSpacing.s4),
                        Text(hasAddresses ? 'Kliknij, aby wybrać adres' : 'Kliknij, aby dodać dane do wysyłki', style: TextStyle(color: AppColors.text.withOpacity(0.4), fontSize: 13)),
                      ],
                    ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.accentText),
          ],
        ),
      ),
    );
  }


  Future<void> _applyVoucher() async {
    final code = _voucherController.text.trim();
    if (code.isEmpty) {
      showValidationSnackBar(context, 'Wpisz kod rabatowy.');
      return;
    }

    if (context.read<CartProvider>().idCart == null) {
      showValidationSnackBar(context, 'Dodaj produkty do koszyka, zanim użyjesz kodu rabatowego.');
      return;
    }

    setState(() => _isApplyingVoucher = true);
    final error = await context.read<CartProvider>().applyVoucher(code);
    
    if (mounted) {
      setState(() => _isApplyingVoucher = false);
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: AppColors.error, behavior: SnackBarBehavior.floating),
        );
      } else {
        _voucherController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kod rabatowy został pomyślnie naliczony!'), backgroundColor: AppColors.success, behavior: SnackBarBehavior.floating),
        );
      }
    }
  }


  void _onAddressChanged(String query) {
    if (_placesDebounce?.isActive ?? false) _placesDebounce!.cancel();
    _placesDebounce = Timer(const Duration(milliseconds: 500), () async {
      if (query.length < 3) {
        setState(() => _addressSuggestions = []);
        return;
      }
      final suggestions = await _placesService?.getSuggestions(query);
      if (mounted) {
        setState(() => _addressSuggestions = suggestions ?? []);
      }
    });
  }

  Widget _buildAddressSuggestions() {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF222222),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.text.withOpacity(0.05)),
      ),
      child: Column(
        children: _addressSuggestions.map((s) => ListTile(
          dense: true,
          title: Text(s['description'] ?? '', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          onTap: () => _selectAddressSuggestion(s),
        )).toList(),
      ),
    );
  }

  Future<void> _selectAddressSuggestion(dynamic suggestion) async {
    final String? placeId = suggestion['place_id'];
    if (placeId == null) return;

    setState(() {
      _guest.address.text = suggestion['description']?.split(',').first ?? '';
      _addressSuggestions = [];
    });

    final details = await _placesService?.getPlaceDetails(placeId);
    if (details != null && mounted) {
      String? street;
      String? houseNumber;
      String? city;
      String? postcode;

      final components = details['address_components'] as List;
      for (var component in components) {
        final types = component['types'] as List;
        if (types.contains('route')) street = component['long_name'];
        if (types.contains('street_number')) houseNumber = component['long_name'];
        if (types.contains('locality')) city = component['long_name'];
        if (types.contains('postal_code')) postcode = component['long_name'];
      }

      setState(() {
        if (street != null) {
          _guest.address.text = '$street ${houseNumber ?? ''}'.trim();
        }
        if (city != null) _guest.city.text = city;
        if (postcode != null) _guest.postcode.text = postcode;
      });
    }
  }

  Widget _buildBottomBar(CartProvider cart, double total, String formattedTotal) {
    final userProvider = context.read<UserProvider>();
    final bool isGuest = !userProvider.isLoggedIn;
    final bool isFinalAction = !_isStepped || _step == _lastStep;

    final String buttonText = isFinalAction
        ? _finalButtonText(cart, isGuest, formattedTotal)
        : _nextButtonText(isGuest);

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.text.withOpacity(0.05))),
        boxShadow: [BoxShadow(color: AppColors.black.withOpacity(0.5), blurRadius: 20, offset: const Offset(0, -8))],
      ),
      child: SafeArea(
        child: PharosButton(
          label: buttonText,
          isLoading: _isProcessing,
          onPressed: _isProcessing
              ? null
              : () => isFinalAction ? _handleCheckoutAction(total) : _goToNextStep(isGuest),
        ),
      ),
    );
  }

  String _nextButtonText(bool isGuest) {
    if (_step == 0) {
      if (!isGuest && _selectedAddress == null) return 'WYBIERZ ADRES';
      if (isGuest && !_guest.isValid) return 'UZUPEŁNIJ DANE';
      return 'DALEJ: DOSTAWA';
    }
    if (_hasCarrierOptions && _selectedCarrier == null) return 'WYBIERZ DOSTAWĘ';
    return 'DALEJ: PŁATNOŚĆ';
  }

  String _finalButtonText(CartProvider cart, bool isGuest, String formattedTotal) {
    if (!isGuest && _selectedAddress == null) return 'WYBIERZ ADRES';
    if (isGuest && _collectCheckoutMissingLabels(isGuest: isGuest, cart: cart).isNotEmpty) return 'UZUPEŁNIJ DANE';
    if (_hasCarrierOptions && _selectedCarrier == null) return 'WYBIERZ DOSTAWĘ';
    if (_hasPaymentOptions && _selectedPayment == null) return 'WYBIERZ PŁATNOŚĆ';
    return 'ZAPŁAĆ $formattedTotal';
  }

  List<String> _collectCheckoutMissingLabels({required bool isGuest, required CartProvider cart}) {
    final missingLabels = <String>[];

    if (cart.items.isEmpty) {
      missingLabels.add('produktów w koszyku');
    } else if (cart.idCart == null) {
      missingLabels.add('zsynchronizowanego koszyka');
    }

    if (isGuest) {
      missingLabels.addAll(_guest.missingLabels());
    } else if (_selectedAddress == null) {
      missingLabels.add('adresu dostawy');
    }

    if (_hasCarrierOptions && _selectedCarrier == null) {
      missingLabels.add('metody dostawy');
    }
    if (_hasPaymentOptions && _selectedPayment == null) {
      missingLabels.add('metody płatności');
    }

    return missingLabels;
  }

  Future<void> _handleCheckoutAction(double totalAmount) async {
    final cart = context.read<CartProvider>();
    final isGuest = !context.read<UserProvider>().isLoggedIn;
    if (isGuest) _guestFormKey.currentState?.validate();

    final missingLabels = _collectCheckoutMissingLabels(isGuest: isGuest, cart: cart);
    if (missingLabels.isNotEmpty) {
      final validationMessage = FormValidation.formatMissingFields(missingLabels);
      _analytics.logCheckoutValidationError('missing_fields', fieldCount: missingLabels.length);
      setState(() => _validationMessage = validationMessage);
      showValidationSnackBar(context, validationMessage);
      return;
    }

    setState(() => _validationMessage = null);
    await _placeOrder(totalAmount);
  }

  Future<void> _placeOrder(double totalAmount) async {
    final cart = context.read<CartProvider>();
    final loc = context.read<LocalizationProvider>();
    final user = context.read<UserProvider>().user;

    setState(() => _isProcessing = true);

    try {
      if (user != null) {
        final authenticated = await context.read<UserProvider>().authenticateBiometrically();
        if (!authenticated) {
          setState(() => _isProcessing = false);
          showValidationSnackBar(context, 'Anulowano weryfikację tożsamości. Zamówienie nie zostało złożone.');
          return;
        }
      }

      _checkoutNotifier.selectAddress(_selectedAddress);
      _checkoutNotifier.selectCarrier(_selectedCarrier);
      _checkoutNotifier.selectPayment(_selectedPayment);

      final guestAddressValid = user != null || _guest.isValid;

      final prepared = await _checkoutNotifier.prepareOrder(
        cart: cart,
        guestAddressValid: guestAddressValid,
        currencyIso: loc.currentCurrency?.isoCode ?? 'PLN',
        customerId: user?.id,
      );

      if (prepared == null) {
        throw Exception(_checkoutNotifier.errorMessage ?? 'Nie udało się zweryfikować koszyka.');
      }

      if (cart.idCart == null) {
        throw Exception('Koszyk nie został zsynchronizowany z serwerem.');
      }

      final orderPayload = <String, dynamic>{
        'id_cart': cart.idCart,
        'id_customer': user?.id,
        'id_address_delivery': _selectedAddress?.id,
        'id_address_invoice': _selectedAddress?.id,
        'payment_module': _selectedPayment?.id ?? 'ps_wirepayment',
        'id_currency': loc.currentCurrency?.id,
        'id_lang': loc.currentLanguage?.id,
      };

      if (user == null) {
        orderPayload['guest'] = _guest.toPayload(createAccount: _createAccount);
      }

      if (_carriers != null && _carriers!.isNotEmpty && _selectedCarrier != null) {
        orderPayload['id_carrier'] = _selectedCarrier!.id;
      }

      final result = await _checkoutRepository.createOrder(orderPayload);

      await result.fold(
        (failure) async => throw Exception(failure.message),
        (data) async {
          if (data['success'] == true) {
            await context.read<UserProvider>().logisticsAutomation(
              orderId: data['reference'] ?? 'PH-${DateTime.now().millisecondsSinceEpoch}',
              amount: totalAmount,
            );
            final orderReference = (data['reference'] ?? '').toString();
            _analytics.logPurchase(
              orderReference,
              totalAmount,
              currency: loc.currentCurrency?.isoCode ?? 'PLN',
              isGuest: user == null,
            );
            if (user == null && _createAccount) _analytics.logAccountCreatedAfterPurchase(orderReference);
            cart.clear();
            if (mounted) {
              HapticFeedback.heavyImpact();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => OrderConfirmationScreen(
                    orderReference: data['reference'] ?? 'Zamówienie',
                    totalAmount: totalAmount,
                  ),
                ),
                (route) => false,
              );
            }
          } else {
            throw Exception(data['message'] ?? 'Serwer odrzucił zamówienie.');
          }
        },
      );
    } catch (e) {
      _analytics.logCheckoutValidationError('order_rejected');
      if (mounted) {
        final message = FormValidation.cleanErrorMessage(e);
        setState(() => _validationMessage = message);
        showValidationSnackBar(context, message);
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }
}

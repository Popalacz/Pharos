import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pharos/core/api/api_config.dart';
import 'package:pharos/core/theme/app_colors.dart';
import 'package:pharos/core/providers/checkout_notifier.dart';
import 'package:pharos/core/network/api_service.dart';
import 'package:pharos/core/providers/cart_provider.dart';
import 'package:pharos/data/repositories/checkout_repository.dart';
import 'package:pharos/data/models/checkout_models.dart';
import 'package:pharos/data/models/address_model.dart';
import 'package:pharos/core/providers/user_provider.dart';
import 'package:pharos/core/providers/localization_provider.dart';
import 'package:pharos/core/constants/pharos_layout.dart';
import 'package:pharos/core/services/google_places_service.dart';
import 'package:pharos/ui/screens/order_confirmation_screen.dart';
import 'package:pharos/ui/screens/address_selection_screen.dart';
import 'package:pharos/ui/widgets/list_shimmer.dart';
import 'package:pharos/ui/widgets/network_error_state.dart';
import 'package:pharos/ui/widgets/pharos_button.dart';
import 'package:pharos/l10n/app_localizations.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  CarrierModel? _selectedCarrier;
  PaymentMethodModel? _selectedPayment;
  AddressModel? _selectedAddress;
  bool _isProcessing = false;
  bool _createAccount = false;

  final _emailController = TextEditingController();
  final _firstnameController = TextEditingController();
  final _lastnameController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _postcodeController = TextEditingController();
  final _phoneController = TextEditingController();
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

  @override
  void initState() {
    super.initState();
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
      if (userProvider.addresses.isNotEmpty) {
        setState(() => _selectedAddress = userProvider.addresses.first);
        _updateShippingCost();
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _firstnameController.dispose();
    _lastnameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _postcodeController.dispose();
    _phoneController.dispose();
    _voucherController.dispose();
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

    // Final total calculation: Trust the server combined total if available,
    // otherwise sum products total with current shipping cost.
    final double total = cart.totalAmount;
    final String formattedTotal = loc.formatPrice(total);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Finalizacja zamówienia', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: PharosLayout.spaceLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: PharosLayout.spaceMd),
                  _buildStepProgress(),
                  const SizedBox(height: PharosLayout.spaceLg),
                  _buildSectionHeader('Adres dostawy', Icons.location_on_rounded),
                  _buildAnimatedAddressSection(userProvider),
                  const SizedBox(height: 32),
                  if (_carriersError || (_carriers?.isNotEmpty ?? false)) ...[
                    _buildSectionHeader('Metoda dostawy', Icons.local_shipping_rounded),
                    _buildCarrierList(loc),
                    const SizedBox(height: 32),
                  ],
                  if (_paymentsError || (_payments?.isNotEmpty ?? false)) ...[
                    _buildSectionHeader('Płatność', Icons.account_balance_wallet_rounded),
                    _buildPaymentList(),
                    const SizedBox(height: 32),
                  ],
                  _buildVoucherSection(),
                  const SizedBox(height: 24),
                  _buildOrderSummary(cart, _resolvedShippingCost, total, loc),
                  const SizedBox(height: 140),
                ],
              ),
            ),
          ),
          if (_isProcessing)
            Container(
              color: Colors.black.withOpacity(0.85),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: AppColors.accent),
                    SizedBox(height: 24),
                    Text('Przetwarzanie zamówienia...', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                    SizedBox(height: 8),
                    Text('Proszę nie zamykać aplikacji', style: TextStyle(color: Colors.white60, fontSize: 14)),
                  ],
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(cart, total, formattedTotal),
    );
  }

  Widget _buildStepProgress() {
    bool hasAddress = context.read<UserProvider>().isLoggedIn ? _selectedAddress != null : _emailController.text.isNotEmpty;
    bool hasCarrier = _selectedCarrier != null;
    bool hasPayment = _selectedPayment != null;

    return Row(
      children: [
        _stepIcon(Icons.person_pin_circle_rounded, hasAddress),
        _stepLine(hasAddress),
        _stepIcon(Icons.local_shipping_rounded, hasCarrier),
        _stepLine(hasCarrier),
        _stepIcon(Icons.payment_rounded, hasPayment),
      ],
    );
  }

  Widget _stepIcon(IconData icon, bool active) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: active ? AppColors.accent : Colors.white.withOpacity(0.05),
        shape: BoxShape.circle,
        boxShadow: active ? [BoxShadow(color: AppColors.accent.withOpacity(0.3), blurRadius: 10, spreadRadius: 1)] : null,
      ),
      child: Icon(icon, size: 18, color: active ? Colors.white : Colors.white24),
    );
  }

  Widget _stepLine(bool active) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        color: active ? AppColors.accent.withOpacity(0.5) : Colors.white.withOpacity(0.05),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: AppColors.accent.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, size: 16, color: AppColors.accent),
          ),
          const SizedBox(width: 12),
          Text(title.toUpperCase(), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.2)),
          const SizedBox(width: 12),
          Expanded(child: Divider(color: Colors.white.withOpacity(0.05), thickness: 1)),
        ],
      ),
    );
  }

  Widget _buildAnimatedAddressSection(UserProvider userProvider) {
    return AnimatedSwitcher(
      duration: PharosLayout.motionNormal,
      transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: SlideTransition(position: Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(animation), child: child)),
      child: (!userProvider.isLoggedIn && _selectedAddress == null) ? _buildGuestForm() : _buildAddressCard(context, userProvider),
    );
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
          border: Border.all(color: _selectedAddress == null ? Colors.red.withOpacity(0.5) : Colors.white.withOpacity(0.05)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Expanded(
              child: _selectedAddress != null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${_selectedAddress!.firstname} ${_selectedAddress!.lastname}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
                        const SizedBox(height: 6),
                        Text(_selectedAddress!.address1, style: TextStyle(color: Colors.white.withOpacity(0.6))),
                        Text('${_selectedAddress!.postcode} ${_selectedAddress!.city}', style: TextStyle(color: Colors.white.withOpacity(0.6))),
                        if (_selectedAddress!.phone != null && _selectedAddress!.phone!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(_selectedAddress!.phone!, style: const TextStyle(color: AppColors.accent, fontSize: 13, fontWeight: FontWeight.w700)),
                          ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Gdzie mamy wysłać paczkę?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 4),
                        Text(hasAddresses ? 'Kliknij, aby wybrać adres' : 'Kliknij, aby dodać dane do wysyłki', style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13)),
                      ],
                    ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.accent),
          ],
        ),
      ),
    );
  }

  Widget _buildVoucherSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(PharosLayout.radiusMd),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('KOD RABATOWY', style: TextStyle(color: Colors.white24, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1.2)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _voucherController,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Wpisz kod...',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.2)),
                    filled: true,
                    fillColor: Colors.black.withOpacity(0.1),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _isApplyingVoucher
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accent))
                  : ElevatedButton(
                      onPressed: _applyVoucher,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent.withOpacity(0.2),
                        foregroundColor: AppColors.accent,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('UŻYJ', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _applyVoucher() async {
    final code = _voucherController.text.trim();
    if (code.isEmpty) return;

    setState(() => _isApplyingVoucher = true);
    final error = await context.read<CartProvider>().applyVoucher(code);
    
    if (mounted) {
      setState(() => _isApplyingVoucher = false);
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating),
        );
      } else {
        _voucherController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kod rabatowy został pomyślnie naliczony!'), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating),
        );
      }
    }
  }

  Widget _buildGuestForm() {
    return Container(
      key: const ValueKey('guest_form'),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(PharosLayout.radiusLg),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          _guestField(_emailController, 'Adres e-mail', Icons.alternate_email_rounded, keyboardType: TextInputType.emailAddress),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _guestField(_firstnameController, 'Imię', Icons.person_outline_rounded)),
              const SizedBox(width: 12),
              Expanded(child: _guestField(_lastnameController, 'Nazwisko', Icons.person_outline_rounded)),
            ],
          ),
          const SizedBox(height: 12),
          _guestField(
            _addressController, 
            'Ulica i numer', 
            Icons.home_work_outlined,
            onChanged: _onAddressChanged,
          ),
          if (_addressSuggestions.isNotEmpty) _buildAddressSuggestions(),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _guestField(_postcodeController, 'Kod', Icons.map_outlined)),
              const SizedBox(width: 12),
              Expanded(child: _guestField(_cityController, 'Miasto', Icons.location_city_rounded)),
            ],
          ),
          const SizedBox(height: 12),
          _guestField(_phoneController, 'Numer telefonu', Icons.phone_android_rounded, keyboardType: TextInputType.phone),
          const SizedBox(height: 16),
          Theme(
            data: ThemeData(unselectedWidgetColor: Colors.white24),
            child: CheckboxListTile(
              value: _createAccount,
              onChanged: (val) => setState(() => _createAccount = val ?? false),
              title: const Text('Chcę założyć konto dla szybszych zakupów', style: TextStyle(color: Colors.white70, fontSize: 13)),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              activeColor: AppColors.accent,
              dense: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _guestField(
    TextEditingController controller, 
    String hint, 
    IconData icon, {
    TextInputType? keyboardType,
    ValueChanged<String>? onChanged,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      cursorColor: AppColors.accent,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.2)),
        prefixIcon: Icon(icon, size: 18, color: AppColors.accent.withOpacity(0.5)),
        filled: true,
        fillColor: Colors.black.withOpacity(0.1),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(PharosLayout.radiusMd), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(PharosLayout.radiusMd), borderSide: BorderSide(color: AppColors.accent.withOpacity(0.3))),
      ),
      onChanged: (val) {
        if (onChanged != null) onChanged(val);
        setState(() {});
      },
    );
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
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: _addressSuggestions.map((s) => ListTile(
          dense: true,
          title: Text(s['description'] ?? '', style: const TextStyle(color: Colors.white70, fontSize: 13)),
          onTap: () => _selectAddressSuggestion(s),
        )).toList(),
      ),
    );
  }

  Future<void> _selectAddressSuggestion(dynamic suggestion) async {
    final String? placeId = suggestion['place_id'];
    if (placeId == null) return;

    setState(() {
      _addressController.text = suggestion['description']?.split(',').first ?? '';
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
          _addressController.text = '$street ${houseNumber ?? ''}'.trim();
        }
        if (city != null) _cityController.text = city;
        if (postcode != null) _postcodeController.text = postcode;
      });
    }
  }

  Widget _buildCarrierList(LocalizationProvider loc) {
    if (_carriers == null) return const ListShimmer(itemCount: 2);
    if (_carriersError) return NetworkErrorState(message: 'Nie udało się pobrać metod dostawy.', onRetry: _refreshCheckoutData);
    if (_carriers!.isEmpty) return const SizedBox.shrink();

    return Column(
      children: _carriers!.map((carrier) {
        final isSelected = _selectedCarrier?.id == carrier.id;
        return AnimatedContainer(
          duration: PharosLayout.motionFast,
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(PharosLayout.radiusMd),
            border: Border.all(color: isSelected ? AppColors.accent : Colors.white.withOpacity(0.05), width: isSelected ? 2 : 1),
            boxShadow: isSelected ? [BoxShadow(color: AppColors.accent.withOpacity(0.15), blurRadius: 12, spreadRadius: 2)] : null,
          ),
          child: Material(
            color: Colors.transparent,
            clipBehavior: Clip.antiAlias,
            borderRadius: BorderRadius.circular(PharosLayout.radiusMd),
            child: RadioListTile<CarrierModel>(
              value: carrier,
              groupValue: _selectedCarrier,
              activeColor: AppColors.accent,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              title: Text(carrier.name, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(carrier.delay, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(
                    carrier.price == 0 ? 'GRATIS' : loc.formatPrice(isSelected ? _resolvedShippingCost : carrier.price),
                    style: TextStyle(fontWeight: FontWeight.w900, color: carrier.price == 0 ? Colors.green : Colors.white, fontSize: 14),
                  ),
                ],
              ),
              secondary: carrier.imageUrl != null
                  ? Container(
                      width: 48,
                      height: 48,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                      child: CachedNetworkImage(
                        imageUrl: carrier.imageUrl!,
                        fit: BoxFit.contain,
                        errorWidget: (context, url, error) => const Icon(Icons.local_shipping_rounded, color: Colors.grey),
                      ),
                    )
                  : const Icon(Icons.local_shipping_rounded, color: Colors.white24, size: 28),
              onChanged: (val) {
                HapticFeedback.selectionClick();
                setState(() => _selectedCarrier = val);
                _updateShippingCost();
              },
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPaymentList() {
    if (_payments == null) return const ListShimmer(itemCount: 2);
    if (_paymentsError) return NetworkErrorState(message: 'Nie udało się pobrać metod płatności.', onRetry: _refreshCheckoutData);
    if (_payments!.isEmpty) return const SizedBox.shrink();

    return Column(
      children: _payments!.map((method) {
        final isSelected = _selectedPayment?.id == method.id;
        return AnimatedContainer(
          duration: PharosLayout.motionFast,
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(PharosLayout.radiusMd),
            border: Border.all(color: isSelected ? AppColors.accent : Colors.white.withOpacity(0.05), width: isSelected ? 2 : 1),
            boxShadow: isSelected ? [BoxShadow(color: AppColors.accent.withOpacity(0.15), blurRadius: 12, spreadRadius: 2)] : null,
          ),
          child: Material(
            color: Colors.transparent,
            clipBehavior: Clip.antiAlias,
            borderRadius: BorderRadius.circular(PharosLayout.radiusMd),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.accent.withOpacity(0.1) : Colors.white.withOpacity(0.03),
                  shape: BoxShape.circle,
                ),
                child: method.iconUrl != null
                    ? CachedNetworkImage(
                        imageUrl: method.iconUrl!,
                        width: 24,
                        height: 24,
                        errorWidget: (context, url, error) => Icon(
                          method.id.contains('blik') ? Icons.phonelink_ring_rounded : Icons.credit_card_rounded,
                          color: isSelected ? AppColors.accent : Colors.white24,
                          size: 20,
                        ),
                      )
                    : Icon(
                        method.id.contains('blik') ? Icons.phonelink_ring_rounded : Icons.credit_card_rounded,
                        color: isSelected ? AppColors.accent : Colors.white24,
                        size: 20,
                      ),
              ),
              title: Text(method.name, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              subtitle: Text(method.description ?? '', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11)),
              trailing: isSelected ? const Icon(Icons.check_circle_rounded, color: AppColors.accent, size: 22) : Icon(Icons.circle_outlined, color: Colors.white.withOpacity(0.1), size: 22),
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _selectedPayment = method);
              },
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildOrderSummary(CartProvider cart, double shipping, double total, LocalizationProvider loc) {
    final l10n = AppLocalizations.of(context)!;
    final double calculatedTotal = cart.subtotalAmount + shipping;
    final double discount = (calculatedTotal - total).clamp(0.0, double.infinity);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        borderRadius: BorderRadius.circular(PharosLayout.radiusLg),
        border: Border.all(color: Colors.white.withOpacity(0.03)),
      ),
      child: Column(
        children: [
          _summaryRow(l10n.productsTotal, loc.formatPrice(cart.subtotalAmount)),
          const SizedBox(height: 12),
          _summaryRow(l10n.shipping, shipping == 0 ? 'GRATIS' : loc.formatPrice(shipping), color: shipping == 0 ? Colors.green : null),
          if (discount > 0.05) ...[
             const SizedBox(height: 12),
             _summaryRow(l10n.discount, '- ${loc.formatPrice(discount)}', color: Colors.green),
          ],
          const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(color: Colors.white10)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.total.toUpperCase(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.5)),
              Text(loc.formatPrice(total), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.accent)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.4))),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color ?? Colors.white70)),
      ],
    );
  }

  Widget _buildBottomBar(CartProvider cart, double total, String formattedTotal) {
    final userProvider = context.read<UserProvider>();
    final bool isGuest = !userProvider.isLoggedIn;
    
    bool hasValidGuestInfo = false;
    if (isGuest) {
      hasValidGuestInfo = _emailController.text.contains('@') &&
          _firstnameController.text.length >= 2 &&
          _lastnameController.text.length >= 2 &&
          _addressController.text.length >= 5 &&
          _postcodeController.text.isNotEmpty &&
          _cityController.text.length >= 2;
    }

    final bool canPlaceOrder = (isGuest ? hasValidGuestInfo : _selectedAddress != null) &&
        cart.idCart != null &&
        (_carriers == null || _carriers!.isEmpty || _selectedCarrier != null) &&
        (_payments == null || _payments!.isEmpty || _selectedPayment != null);

    String buttonText = 'ZAPŁAĆ $formattedTotal';
    if (!isGuest && _selectedAddress == null) {
      buttonText = 'WYBIERZ ADRES';
    } else if (isGuest && !hasValidGuestInfo) {
      buttonText = 'UZUPEŁNIJ DANE';
    } else if (_carriers != null && _carriers!.isNotEmpty && _selectedCarrier == null) {
      buttonText = 'WYBIERZ DOSTAWĘ';
    } else if (_payments != null && _payments!.isNotEmpty && _selectedPayment == null) {
      buttonText = 'WYBIERZ PŁATNOŚĆ';
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 20, offset: const Offset(0, -8))],
      ),
      child: SafeArea(
        child: PharosButton(
          label: buttonText,
          isLoading: _isProcessing,
          onPressed: canPlaceOrder ? () => _placeOrder(total) : null,
        ),
      ),
    );
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
          return;
        }
      }

      _checkoutNotifier.selectAddress(_selectedAddress);
      _checkoutNotifier.selectCarrier(_selectedCarrier);
      _checkoutNotifier.selectPayment(_selectedPayment);

      final guestAddressValid = user != null ||
          (_emailController.text.isNotEmpty &&
              _firstnameController.text.isNotEmpty &&
              _addressController.text.isNotEmpty &&
              _cityController.text.isNotEmpty &&
              _postcodeController.text.isNotEmpty);

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
        orderPayload['guest'] = {
          'email': _emailController.text,
          'firstname': _firstnameController.text,
          'lastname': _lastnameController.text,
          'address1': _addressController.text,
          'postcode': _postcodeController.text,
          'city': _cityController.text,
          'phone': _phoneController.text,
          'create_account': _createAccount,
        };
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Błąd: ${e.toString().replaceAll('Exception:', '')}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }
}

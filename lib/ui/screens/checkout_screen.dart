import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:pharos/core/api/api_config.dart';
import 'package:pharos/core/network/api_service.dart';
import 'package:pharos/core/providers/cart_provider.dart';
import 'package:pharos/data/repositories/checkout_repository.dart';
import 'package:pharos/data/models/checkout_models.dart';
import 'package:pharos/data/models/address_model.dart';
import 'package:pharos/core/services/payment_service.dart';
import 'package:pharos/core/providers/user_provider.dart';
import 'package:pharos/core/providers/localization_provider.dart';
import 'package:pharos/ui/screens/order_confirmation_screen.dart';
import 'package:pharos/ui/screens/address_selection_screen.dart';
import 'package:pharos/ui/widgets/list_shimmer.dart';
import 'package:pharos/ui/widgets/network_error_state.dart';

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

  List<CarrierModel>? _carriers;
  List<PaymentMethodModel>? _payments;
  bool _carriersError = false;
  bool _paymentsError = false;
  double? _shippingCost;

  late CheckoutRepository _checkoutRepository;

  @override
  void initState() {
    super.initState();
    _checkoutRepository = CheckoutRepository(
      apiService: context.read<ApiService>(),
      useMockData: ApiConfig.forceMockData,
    );
    _refreshCheckoutData();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = context.read<UserProvider>();
      if (userProvider.addresses.isNotEmpty) {
        setState(() => _selectedAddress = userProvider.addresses.first);
        _updateShippingCost();
      }
    });
  }

  Future<void> _refreshCheckoutData() async {
    setState(() {
      _carriers = null;
      _payments = null;
      _carriersError = false;
      _paymentsError = false;
    });

    final carriersResult = await _checkoutRepository.getCarriers();
    final paymentsResult = await _checkoutRepository.getPaymentMethods();

    if (!mounted) return;

    carriersResult.fold(
      (_) => setState(() => _carriersError = true),
      (carriers) => setState(() {
        _carriers = carriers;
        _carriersError = false;
        if (carriers.length == 1) _selectedCarrier = carriers.first;
      }),
    );

    paymentsResult.fold(
      (_) => setState(() => _paymentsError = true),
      (payments) => setState(() {
        _payments = payments;
        _paymentsError = false;
        if (payments.length == 1) _selectedPayment = payments.first;
      }),
    );

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
          setState(() {
            _shippingCost = (data['shipping_cost'] as num?)?.toDouble() ?? _selectedCarrier?.price;
          });
        }
      },
    );
  }

  double get _resolvedShippingCost => _shippingCost ?? _selectedCarrier?.price ?? 0.0;

  bool get _requiresCarrier => (_carriers?.isNotEmpty ?? false);
  bool get _requiresPayment => (_payments?.isNotEmpty ?? false);

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final loc = context.watch<LocalizationProvider>();
    final userProvider = context.watch<UserProvider>();

    final double total = cart.subtotalAmount + _resolvedShippingCost;
    final String formattedTotal = loc.formatPrice(total);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        title: const Text('Finalizacja zamówienia', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('1. Adres dostawy', Icons.location_on_outlined),
                  _buildAddressCard(context, userProvider),
                  if (_carriersError || (_carriers?.isNotEmpty ?? false)) ...[
                    const SizedBox(height: 32),
                    _buildSectionHeader('2. Metoda dostawy', Icons.local_shipping_outlined),
                    _buildCarrierList(loc),
                  ],
                  if (_paymentsError || (_payments?.isNotEmpty ?? false)) ...[
                    const SizedBox(height: 32),
                    _buildSectionHeader('3. Płatność', Icons.payment_outlined),
                    _buildPaymentList(),
                  ],
                  const SizedBox(height: 40),
                  _buildOrderSummary(cart, _resolvedShippingCost, total, loc),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
          if (_isProcessing)
            Container(
              color: Colors.black.withOpacity(0.8),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.orange),
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

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.orange),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildAddressCard(BuildContext context, UserProvider userProvider) {
    final bool hasAddresses = userProvider.addresses.isNotEmpty;

    return InkWell(
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
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _selectedAddress == null ? Colors.red.withOpacity(0.5) : Colors.white.withOpacity(0.05)),
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
                            child: Text(_selectedAddress!.phone!, style: const TextStyle(color: Colors.orange, fontSize: 13, fontWeight: FontWeight.w500)),
                          ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(hasAddresses ? 'Wybierz adres dostawy' : 'Brak zapisanego adresu', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 4),
                        Text(hasAddresses ? 'Kliknij, aby wybrać z listy' : 'Kliknij, aby dodać pierwszy adres', style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13)),
                      ],
                    ),
            ),
            const Icon(Icons.chevron_right, color: Colors.orange),
          ],
        ),
      ),
    );
  }

  Widget _buildCarrierList(LocalizationProvider loc) {
    if (_carriers == null) return const ListShimmer(itemCount: 2);
    if (_carriersError) {
      return NetworkErrorState(message: 'Nie udało się pobrać metod dostawy.', onRetry: _refreshCheckoutData);
    }
    if (_carriers!.isEmpty) return const SizedBox.shrink();

    return Column(
      children: _carriers!.map((carrier) {
        final isSelected = _selectedCarrier?.id == carrier.id;
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: Material(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(16),
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: isSelected ? Colors.orange : Colors.white.withOpacity(0.05)),
            ),
            child: RadioListTile<CarrierModel>(
              value: carrier,
              groupValue: _selectedCarrier,
              activeColor: Colors.orange,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              title: Text(carrier.name, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              subtitle: Text(carrier.delay, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
              secondary: Text(
                carrier.price == 0 ? 'GRATIS' : loc.formatPrice(isSelected ? _resolvedShippingCost : carrier.price),
                style: TextStyle(fontWeight: FontWeight.bold, color: carrier.price == 0 ? Colors.green : Colors.orange, fontSize: 16),
              ),
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
    if (_paymentsError) {
      return NetworkErrorState(message: 'Nie udało się pobrać metod płatności.', onRetry: _refreshCheckoutData);
    }
    if (_payments!.isEmpty) return const SizedBox.shrink();

    return Column(
      children: _payments!.map((method) {
        final isSelected = _selectedPayment?.id == method.id;
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: Material(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(16),
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: isSelected ? Colors.orange : Colors.white.withOpacity(0.05)),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              leading: CircleAvatar(
                backgroundColor: isSelected ? Colors.orange.withOpacity(0.1) : Colors.white.withOpacity(0.05),
                child: Icon(
                  method.id.contains('blik') ? Icons.phonelink_ring : Icons.account_balance_wallet_outlined,
                  color: isSelected ? Colors.orange : Colors.white38,
                ),
              ),
              title: Text(method.name, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              subtitle: Text(method.description ?? '', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
              trailing: Radio<String>(
                value: method.id,
                groupValue: _selectedPayment?.id,
                activeColor: Colors.orange,
                onChanged: (_) {
                  HapticFeedback.selectionClick();
                  setState(() => _selectedPayment = method);
                },
              ),
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
    return Column(
      children: [
        _summaryRow('Wartość produktów', loc.formatPrice(cart.subtotalAmount)),
        const SizedBox(height: 8),
        _summaryRow('Koszt dostawy', shipping == 0 ? 'GRATIS' : loc.formatPrice(shipping)),
        const Divider(height: 32, color: Colors.white10),
        _summaryRow('ŁĄCZNIE', loc.formatPrice(total), isTotal: true),
      ],
    );
  }

  Widget _summaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(
          fontSize: isTotal ? 18 : 14,
          fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          color: isTotal ? Colors.white : Colors.white.withOpacity(0.5),
        )),
        Text(value, style: TextStyle(
          fontSize: isTotal ? 22 : 14,
          fontWeight: FontWeight.w900,
          color: isTotal ? Colors.orange : Colors.white,
        )),
      ],
    );
  }

  Widget _buildBottomBar(CartProvider cart, double total, String formattedTotal) {
    final bool canPlaceOrder = _selectedAddress != null &&
        cart.idCart != null &&
        (!_requiresCarrier || _selectedCarrier != null) &&
        (!_requiresPayment || _selectedPayment != null);

    String buttonText = 'ZAPŁAĆ $formattedTotal';
    if (_selectedAddress == null) {
      buttonText = 'WYBIERZ ADRES';
    } else if (_requiresCarrier && _selectedCarrier == null) {
      buttonText = 'WYBIERZ DOSTAWĘ';
    } else if (_requiresPayment && _selectedPayment == null) {
      buttonText = 'WYBIERZ PŁATNOŚĆ';
    } else if (cart.idCart == null) {
      buttonText = 'SYNCHRONIZACJA...';
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F0F),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 10, offset: const Offset(0, -4))],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: canPlaceOrder ? () => _placeOrder(total) : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              disabledBackgroundColor: Colors.white.withOpacity(0.05),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: Text(buttonText, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.2)),
          ),
        ),
      ),
    );
  }

  Future<void> _placeOrder(double totalAmount) async {
    final cart = context.read<CartProvider>();
    final loc = context.read<LocalizationProvider>();
    final user = context.read<UserProvider>().user;

    if (ApiConfig.forceMockData) {
      bool paymentSuccess = true;
      if (_selectedPayment?.id == 'blik') {
        paymentSuccess = await PaymentService.processBlik(context, totalAmount);
      } else if (_selectedPayment?.id == 'google_pay') {
        paymentSuccess = await PaymentService.processGooglePay(context, totalAmount);
      }
      if (!paymentSuccess) return;
    }

    setState(() => _isProcessing = true);

    try {
      final orderPayload = <String, dynamic>{
        'id_cart': cart.idCart,
        'id_customer': user?.id,
        'id_address_delivery': _selectedAddress!.id,
        'id_address_invoice': _selectedAddress!.id,
        'payment_module': _selectedPayment?.id ?? 'ps_wirepayment',
        'id_currency': loc.currentCurrency?.id,
        'id_lang': loc.currentLanguage?.id,
      };
      if (_requiresCarrier && _selectedCarrier != null) {
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

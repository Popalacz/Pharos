import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pharos/core/providers/cart_provider.dart';
import 'package:pharos/data/repositories/checkout_repository.dart';
import 'package:pharos/data/models/checkout_models.dart';
import 'package:pharos/data/models/address_model.dart';
import 'package:pharos/core/services/payment_service.dart';
import 'package:pharos/core/providers/user_provider.dart';
import 'package:pharos/core/providers/localization_provider.dart';
import 'package:pharos/ui/screens/address_selection_screen.dart';

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
  
  late Future<List<CarrierModel>> _carriersFuture;
  late Future<List<PaymentMethodModel>> _paymentsFuture;

  @override
  void initState() {
    super.initState();
    final repo = CheckoutRepository(useMockData: true);
    _carriersFuture = repo.getCarriers();
    _paymentsFuture = repo.getPaymentMethods();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = context.read<UserProvider>();
      if (userProvider.addresses.isNotEmpty) {
        setState(() {
          _selectedAddress = userProvider.addresses.first;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final loc = context.watch<LocalizationProvider>();
    final double shippingCost = _selectedCarrier?.price ?? 0.0;
    final double total = cart.totalAmount + shippingCost;
    final String formattedTotal = loc.formatPrice(total);

    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            title: const Text('Finalizacja zamówienia', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            backgroundColor: Colors.white,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.black),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('1. Adres dostawy', Icons.location_on_outlined),
                _buildAddressCard(context),
                
                const SizedBox(height: 32),
                _buildSectionHeader('2. Metoda dostawy', Icons.local_shipping_outlined),
                _buildCarrierList(loc),
                
                const SizedBox(height: 32),
                _buildSectionHeader('3. Płatność', Icons.payment_outlined),
                _buildPaymentList(),
                
                const SizedBox(height: 40),
                _buildOrderSummary(cart, shippingCost, total, loc),
                const SizedBox(height: 100),
              ],
            ),
          ),
          bottomSheet: _buildBottomBar(total, formattedTotal),
        ),
        if (_isProcessing)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.orange),
                  SizedBox(height: 16),
                  Text('Przetwarzanie zamówienia...', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, decoration: TextDecoration.none, fontSize: 16)),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.orange),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildAddressCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Expanded(
            child: _selectedAddress != null 
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${_selectedAddress!.firstname} ${_selectedAddress!.lastname}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(_selectedAddress!.address1, style: const TextStyle(color: Colors.grey)),
                    Text('${_selectedAddress!.postcode} ${_selectedAddress!.city}', style: const TextStyle(color: Colors.grey)),
                  ],
                )
              : const Text('Brak wybranego adresu', style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddressSelectionScreen(selectedAddress: _selectedAddress)),
              );
              if (result != null && result is AddressModel) {
                setState(() {
                  _selectedAddress = result;
                });
              }
            }, 
            child: const Text('Zmień', style: TextStyle(color: Colors.orange)),
          ),
        ],
      ),
    );
  }

  Widget _buildCarrierList(LocalizationProvider loc) {
    return FutureBuilder<List<CarrierModel>>(
      future: _carriersFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();
        return Column(
          children: snapshot.data!.map((carrier) => RadioListTile<CarrierModel>(
            value: carrier,
            groupValue: _selectedCarrier,
            title: Text(carrier.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(carrier.delay),
            secondary: Text(loc.formatPrice(carrier.price), style: const TextStyle(fontWeight: FontWeight.bold)),
            activeColor: Colors.orange,
            onChanged: (val) => setState(() => _selectedCarrier = val),
            contentPadding: EdgeInsets.zero,
          )).toList(),
        );
      },
    );
  }

  Widget _buildPaymentList() {
    return FutureBuilder<List<PaymentMethodModel>>(
      future: _paymentsFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();
        return Column(
          children: snapshot.data!.map((method) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _selectedPayment?.id == method.id ? Colors.orange : Colors.grey[200]!),
            ),
            child: ListTile(
              leading: const Icon(Icons.account_balance_wallet_outlined),
              title: Text(method.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(method.description ?? ''),
              trailing: Radio<String>(
                value: method.id,
                groupValue: _selectedPayment?.id,
                activeColor: Colors.orange,
                onChanged: (val) => setState(() => _selectedPayment = method),
              ),
              onTap: () => setState(() => _selectedPayment = method),
            ),
          )).toList(),
        );
      },
    );
  }

  Widget _buildOrderSummary(CartProvider cart, double shipping, double total, LocalizationProvider loc) {
    return Column(
      children: [
        _summaryRow('Wartość produktów', loc.formatPrice(cart.totalAmount)),
        const SizedBox(height: 8),
        _summaryRow('Koszt dostawy', shipping == 0 ? 'GRATIS' : loc.formatPrice(shipping)),
        const Divider(height: 32),
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
          color: isTotal ? Colors.black : Colors.grey,
        )),
        Text(value, style: TextStyle(
          fontSize: isTotal ? 22 : 14, 
          fontWeight: FontWeight.w900,
          color: isTotal ? Colors.orange : Colors.black,
        )),
      ],
    );
  }

  Widget _buildBottomBar(double total, String formattedTotal) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: (_selectedCarrier != null && _selectedPayment != null && _selectedAddress != null)
              ? () => _placeOrder(total) 
              : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              disabledBackgroundColor: Colors.grey[300],
            ),
            child: Text('ZAPŁAĆ $formattedTotal', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ),
      ),
    );
  }

  void _placeOrder(double totalAmount) async {
    final cart = context.read<CartProvider>();
    final loc = context.read<LocalizationProvider>();

    bool paymentSuccess = false;

    if (_selectedPayment?.id == 'blik') {
      paymentSuccess = await PaymentService.processBlik(context, totalAmount);
    } else if (_selectedPayment?.id == 'google_pay') {
      paymentSuccess = await PaymentService.processGooglePay(context, totalAmount);
    } else {
      paymentSuccess = true;
    }

    if (!paymentSuccess) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      await CheckoutRepository(useMockData: true).createOrder({
        'id_carrier': _selectedCarrier!.id,
        'id_address': _selectedAddress!.id,
        'payment_module': _selectedPayment!.id,
        'id_currency': loc.currentCurrency?.id,
        'id_lang': loc.currentLanguage?.id,
        'cart': cart.items.values.map((e) => {'id': e.product.id, 'qty': e.quantity}).toList(),
      });

      await context.read<UserProvider>().logisticsAutomation(
        orderId: 'PH-${DateTime.now().millisecondsSinceEpoch}',
        amount: totalAmount,
      );

      cart.clear();

import 'package:lottie/lottie.dart';

// ... (in _placeOrder method)
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Lottie.network(
                    'https://raw.githubusercontent.com/xvrh/lottie-flutter/master/example/assets/LottieLogo1.json', // Placeholder, tu wrzuć sukces
                    height: 150,
                    repeat: false,
                  ),
                  const SizedBox(height: 16),
                  const Text('SUKCES!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 2)),
                  const SizedBox(height: 8),
                  const Text('Zamówienie zostało złożone poprawnie.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      child: const Text('OK', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Błąd składania zamówienia: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }
}

import 'package:flutter/material.dart';
import 'package:pharos/core/services/deeplink/deeplink_service.dart';

class PaymentService {
  static Future<bool> processBlik(BuildContext context, double amount) async {
    String blikCode = '';

    final bool? result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.payment, color: Colors.black),
            SizedBox(width: 12),
            Text('Płatność BLIK'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Do zapłaty: ${amount.toStringAsFixed(2)} PLN'),
            const SizedBox(height: 20),
            TextField(
              autofocus: true,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, letterSpacing: 8, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                hintText: '000000',
                counterText: '',
                border: OutlineInputBorder(),
              ),
              onChanged: (val) => blikCode = val,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('ANULUJ')),
          ElevatedButton(
            onPressed: () {
              if (blikCode.length == 6) {
                Navigator.pop(context, true);
              }
            },
            child: const Text('POTWIERDŹ'),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  static Future<bool> processBlikWithDeepLink({
    required String orderReference,
    required double amount,
  }) async {
    final deeplink = DeepLinkService();
    await deeplink.handlePaymentReturn(
      uri: Uri.parse('pharos://payment/blik?order=$orderReference&amount=$amount&status=pending'),
    );
    return true;
  }

  static Future<bool> processGooglePay(BuildContext context, double amount) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Material(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Google Pay', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                ],
              ),
              Text('${amount.toStringAsFixed(2)} PLN'),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('ZAPŁAĆ TERAZ'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    return true;
  }

  static Future<bool> processApplePay(BuildContext context, double amount) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.apple, color: Colors.white, size: 32),
            const SizedBox(height: 12),
            Text('Apple Pay • ${amount.toStringAsFixed(2)} PLN', style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Autoryzuj'),
            ),
          ],
        ),
      ),
    );
    return true;
  }
}

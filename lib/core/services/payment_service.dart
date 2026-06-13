import 'package:flutter/material.dart';

class PaymentService {
  static Future<bool> processBlik(BuildContext context, double amount) async {
    String blikCode = '';
    
    final bool? result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Image.network('https://upload.wikimedia.org/wikipedia/commons/thumb/b/b5/BLIK_logo.svg/1200px-BLIK_logo.svg.png', height: 24),
            const SizedBox(width: 12),
            const Text('Płatność BLIK'),
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
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('ANULUJ', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () async {
              if (blikCode.length == 6) {
                // Symulacja komunikacji z bankiem
                Navigator.pop(context, true);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
            child: const Text('POTWIERDŹ', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    
    return result ?? false;
  }

  static Future<bool> processGooglePay(BuildContext context, double amount) async {
    // Symulacja natywnego arkusza Google Pay
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
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
            const Divider(),
            ListTile(
              leading: const Icon(Icons.credit_card),
              title: const Text('Visa •••• 1234'),
              subtitle: const Text('jan.kowalski@gmail.com'),
              trailing: const Text('ZMIEŃ', style: TextStyle(color: Colors.blue)),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Łącznie', style: TextStyle(fontSize: 16)),
                Text('${amount.toStringAsFixed(2)} PLN', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  // Symulacja autoryzacji biometrycznej
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.fingerprint, color: Colors.white),
                    SizedBox(width: 12),
                    Text('ZAPŁAĆ TERAZ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
    return true; // Sukces po zamknięciu arkusza
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:pharos/main.dart';

class OrderConfirmationScreen extends StatefulWidget {
  final String orderReference;
  final double totalAmount;

  const OrderConfirmationScreen({
    super.key, 
    required this.orderReference, 
    required this.totalAmount
  });

  @override
  State<OrderConfirmationScreen> createState() => _OrderConfirmationScreenState();
}

class _OrderConfirmationScreenState extends State<OrderConfirmationScreen> {
  @override
  void initState() {
    super.initState();
    HapticFeedback.heavyImpact();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Lottie.network(
                'https://assets10.lottiefiles.com/packages/lf20_ye6m86df.json',
                height: 250,
                repeat: false,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.check_circle_outline, size: 120, color: Colors.green),
              ),
              const SizedBox(height: 32),
              const Text(
                'ZAMÓWIENIE PRZYJĘTE!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Twoje zamówienie #${widget.orderReference} trafiło do realizacji. Potwierdzenie wysłaliśmy na Twój e-mail.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.white.withOpacity(0.5),
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 48),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('KWOTA DO ZAPŁATY', style: TextStyle(color: Colors.white30, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1)),
                    Text(
                      '${widget.totalAmount.toStringAsFixed(2)} PLN', 
                      style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.w900, fontSize: 22)
                    ),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const MainNavigation()),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: const Text('WRÓĆ DO SKLEPU', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

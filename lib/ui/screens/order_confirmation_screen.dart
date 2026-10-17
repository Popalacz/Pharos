import 'package:flutter/material.dart';
import 'package:pharos/core/theme/app_spacing.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:pharos/main.dart';
import 'package:pharos/core/theme/app_colors.dart';
import 'package:pharos/core/constants/pharos_layout.dart';
import 'package:pharos/core/services/analytics_service.dart';
import 'package:pharos/core/providers/localization_provider.dart';

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

class _OrderConfirmationScreenState extends State<OrderConfirmationScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    HapticFeedback.heavyImpact();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currency = context.read<LocalizationProvider>().currentCurrency?.isoCode ?? 'PLN';
      AnalyticsService().logPurchase(widget.orderReference, widget.totalAmount, currency: currency);
    });
    
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocalizationProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background Gradient for depth
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topCenter,
                  radius: 1.5,
                  colors: [
                    AppColors.accent.withOpacity(0.1),
                    AppColors.background,
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  
                  // Success Animation with Glow
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accent.withOpacity(0.2),
                              blurRadius: 60,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                      ),
                      Lottie.network(
                        'https://assets10.lottiefiles.com/packages/lf20_ye6m86df.json',
                        height: 280,
                        repeat: false,
                        errorBuilder: (context, error, stackTrace) => 
                          const Icon(Icons.check_circle_rounded, size: 100, color: Colors.green),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: AppSpacing.s40),
                  
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        const Text(
                          'SUKCES!',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 4,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.s8),
                        Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.s24),
                        Text(
                          'Twoje zamówienie #${widget.orderReference} zostało przyjęte do realizacji.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.7),
                            height: 1.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.s8),
                        Text(
                          'Potwierdzenie wysłaliśmy na Twój adres e-mail.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.4),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.s48),

                  // Order Card
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(PharosLayout.radiusLg),
                        border: Border.all(color: Colors.white.withOpacity(0.05)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'WARTOŚĆ ZAMÓWIENIA', 
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.3), 
                                  fontWeight: FontWeight.w800, 
                                  fontSize: 12, 
                                  letterSpacing: 1.2
                                )
                              ),
                              const Icon(Icons.receipt_long_rounded, size: 16, color: Colors.white24),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.s8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                loc.formatPrice(widget.totalAmount),
                                style: const TextStyle(
                                  color: AppColors.accentText, 
                                  fontWeight: FontWeight.w900, 
                                  fontSize: 32,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.only(bottom: 6),
                                child: Text(
                                  'OPŁACONE',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Action Button
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => const MainNavigation()),
                          (route) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(PharosLayout.radiusMd),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'KONTYNUUJ ZAKUPY', 
                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

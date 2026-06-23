import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pharos/core/providers/cart_provider.dart';
import 'package:pharos/core/providers/settings_provider.dart';
import 'package:pharos/core/providers/localization_provider.dart';
import 'package:pharos/core/providers/user_provider.dart';
import 'package:pharos/ui/screens/checkout_screen.dart';
import 'package:pharos/ui/screens/login_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lottie/lottie.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final items = cart.items.values.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Twój Koszyk', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          if (cart.isSyncing)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: SizedBox(
                width: 20, height: 20, 
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.orange)
              ),
            )
        ],
      ),
      body: items.isEmpty 
        ? _buildEmptyCart(context)
        : Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return _CartItemTile(item: item);
                  },
                ),
              ),
              _buildSummary(context, cart),
            ],
          ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.network(
              'https://assets5.lottiefiles.com/packages/lf20_qh5z2fdq.json', 
              height: 200,
              repeat: true,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.shopping_basket_outlined, size: 100, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            const Text('Twój koszyk jest pusty', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const Text(
              'Wygląda na to, że jeszcze nic nie wybrałeś. Twoje wymarzone produkty czekają!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  // Senior Fix: Zamiast pop (który wywala czarny ekran), 
                  // przełączamy index w głównym nawigatorze na Home (0)
                  final state = context.findAncestorStateOfType<State<StatefulWidget>>();
                  if (state != null && state.toString().contains('MainNavigation')) {
                    // Próba dostania się do MainNavigationState
                    try {
                      (state as dynamic).setState(() {
                        (state as dynamic)._selectedIndex = 0;
                      });
                    } catch (e) {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    }
                  } else {
                     Navigator.of(context).popUntil((route) => route.isFirst);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('ZACZNIJ ZAKUPY', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSummary(BuildContext context, CartProvider cart) {
    final settings = context.watch<SettingsProvider>().settings;
    final loc = context.watch<LocalizationProvider>();
    final userProvider = context.watch<UserProvider>();

    final double? threshold = settings.freeShippingThreshold;
    final double current = cart.subtotalAmount;
    final double progress = threshold != null && threshold > 0 ? (current / threshold).clamp(0.0, 1.0) : 0.0;
    final double remaining = threshold != null ? threshold - current : 0.0;
    final bool showFreeShipping = settings.hasFreeShippingProgress;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, -10))],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (settings.vouchersEnabled) const _VoucherInput(),
            if (showFreeShipping) ...[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.local_shipping_outlined,
                          color: progress >= 1.0 ? Colors.green : Colors.orange, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          progress >= 1.0
                              ? 'Darmowa dostawa odblokowana!'
                              : 'Brakuje Ci ${loc.formatPrice(remaining)} do darmowej dostawy',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: progress >= 1.0 ? Colors.green : Colors.white,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.white.withOpacity(0.05),
                      valueColor: AlwaysStoppedAnimation<Color>(
                          progress >= 1.0 ? Colors.green : Colors.orange),
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Suma częściowa', style: TextStyle(color: Colors.grey)),
                Text(loc.formatPrice(cart.subtotalAmount), style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Dostawa', style: TextStyle(color: Colors.grey)),
                Text(
                  (showFreeShipping && cart.subtotalAmount >= threshold!) || cart.shippingAmount == 0
                      ? 'GRATIS'
                      : loc.formatPrice(cart.shippingAmount),
                  style: TextStyle(
                    color: (showFreeShipping && cart.subtotalAmount >= threshold!) || cart.shippingAmount == 0
                        ? Colors.green
                        : Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('RAZEM', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(loc.formatPrice(cart.totalAmount),
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.orange)),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  if (userProvider.isLoggedIn) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CheckoutScreen()),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Zaloguj się, aby złożyć zamówienie.'),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: Colors.orange,
                      ),
                    );
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange, 
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                ),
                child: Text(
                  userProvider.isLoggedIn ? 'PRZEJDŹ DO KASY' : 'ZALOGUJ SIĘ, ABY KUPIĆ', 
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _CartItemTile extends StatelessWidget {
  final CartItem item;
  const _CartItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: item.product.imageUrl.isEmpty
                ? Container(width: 80, height: 80, color: Colors.white.withOpacity(0.05))
                : CachedNetworkImage(
              imageUrl: item.product.imageUrl,
              width: 80, height: 80, fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.product.name, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white), maxLines: 1),
                const SizedBox(height: 4),
                Text(context.read<LocalizationProvider>().formatPrice(item.product.price), style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _QtyBtn(
                      icon: Icons.remove, 
                      onTap: () => context.read<CartProvider>().updateQuantity(item.key, -1)
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                    _QtyBtn(
                      icon: Icons.add, 
                      onTap: () => context.read<CartProvider>().updateQuantity(item.key, 1)
                    ),
                  ],
                )
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () {
              context.read<CartProvider>().removeItem(item.key);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Usunięto z koszyka'),
                  duration: Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          )
        ],
      ),
    );
  }
}

class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _QtyBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white.withOpacity(0.1)),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(icon, size: 16, color: Colors.white),
      ),
    );
  }
}

class _VoucherInput extends StatefulWidget {
  const _VoucherInput();

  @override
  State<_VoucherInput> createState() => _VoucherInputState();
}

class _VoucherInputState extends State<_VoucherInput> {
  final _controller = TextEditingController();
  bool _isApplying = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _apply() async {
    if (_isApplying) return;
    setState(() => _isApplying = true);
    final error = await context.read<CartProvider>().applyVoucher(_controller.text);
    if (!mounted) return;
    setState(() => _isApplying = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error ?? 'Kod rabatowy zastosowany'),
        backgroundColor: error == null ? Colors.green : Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
    if (error == null) _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Kod rabatowy',
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ),
          const SizedBox(width: 8),
          _isApplying
              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
              : IconButton(
                  onPressed: _apply,
                  icon: const Icon(Icons.check_circle_outline, color: Colors.orange),
                ),
        ],
      ),
    );
  }
}

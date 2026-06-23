import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pharos/core/providers/wishlist_provider.dart';
import 'package:pharos/ui/widgets/product_shimmer.dart';
import 'package:pharos/ui/widgets/pharos_product_card.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final wishlistProvider = context.watch<WishlistProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('ULUBIONE', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2, color: Colors.white)),
        centerTitle: true,
      ),
      body: wishlistProvider.isLoading
          ? const ProductShimmer()
          : wishlistProvider.wishlistProducts.isEmpty
              ? _buildEmptyState(context)
              : RefreshIndicator(
                  onRefresh: () => wishlistProvider.fetchWishlist(),
                  color: Colors.orange,
                  backgroundColor: const Color(0xFF1A1A1A),
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    physics: const BouncingScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.65,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: wishlistProvider.wishlistProducts.length,
                    itemBuilder: (context, index) {
                      final product = wishlistProvider.wishlistProducts[index];
                      // Senior Fix: Używamy zunifikowanej karty produktu dla zachowania spójności UI i logiki
                      return PharosProductCard(product: product, heroTagPrefix: 'wishlist');
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.03),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.favorite_border, size: 80, color: Colors.white.withOpacity(0.1)),
            ),
            const SizedBox(height: 32),
            const Text('Twoja lista jest pusta', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 12),
            Text(
              'Zapisuj produkty, które Ci się podobają, aby wrócić do nich w dowolnym momencie.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 15, height: 1.5),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  // Powrót do zakupów jest realizowany przez nawigację dolną (tab 0)
                  // ale możemy tu dodać akcję nawigacyjną jeśli ekran jest w stosie
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text('ZACZNIJ ODKRYWAĆ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

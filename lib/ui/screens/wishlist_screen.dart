import 'package:flutter/material.dart';
import 'package:pharos/core/theme/app_spacing.dart';
import 'package:provider/provider.dart';
import 'package:pharos/core/providers/wishlist_provider.dart';
import 'package:pharos/ui/widgets/product_shimmer.dart';
import 'package:pharos/ui/widgets/pharos_product_card.dart';
import 'package:pharos/ui/widgets/pharos_button.dart';
import 'package:lottie/lottie.dart';
import 'package:pharos/l10n/app_localizations.dart';

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
        title: Text(AppLocalizations.of(context)!.wishlistTitle, style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2, color: Colors.white)),
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
                      childAspectRatio: 0.55,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: wishlistProvider.wishlistProducts.length,
                    itemBuilder: (context, index) {
                      final product = wishlistProvider.wishlistProducts[index];
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
            Lottie.network(
              'https://assets1.lottiefiles.com/packages/lf20_v7v9z8zv.json',
              height: 200,
              repeat: true,
              errorBuilder: (context, error, stackTrace) => Icon(Icons.favorite_border, size: 80, color: Colors.white.withOpacity(0.1)),
            ),
            const SizedBox(height: AppSpacing.s32),
            Text(AppLocalizations.of(context)!.wishlistEmpty, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1)),
            const SizedBox(height: AppSpacing.s12),
            Text(
              'Zapisuj produkty, które Ci się podobają, aby wrócić do nich w dowolnym momencie.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 15, height: 1.5),
            ),
            const SizedBox(height: AppSpacing.s40),
            PharosButton(
              label: AppLocalizations.of(context)!.startDiscovering,
              onPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

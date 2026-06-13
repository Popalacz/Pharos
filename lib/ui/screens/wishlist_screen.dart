import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pharos/core/providers/wishlist_provider.dart';
import 'package:pharos/ui/widgets/product_shimmer.dart';
import 'package:pharos/ui/screens/product_details_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final wishlistProvider = context.watch<WishlistProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('ULUBIONE', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, letterSpacing: 2)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: wishlistProvider.isLoading
          ? const ProductShimmer()
          : wishlistProvider.wishlistProducts.isEmpty
              ? _buildEmptyState(context)
              : _buildWishlistGrid(context, wishlistProvider),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 100, color: Colors.grey[200]),
            const SizedBox(height: 24),
            const Text('Twoja lista życzeń jest pusta', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const Text(
              'Zapisuj produkty, które Ci się podobają, aby wrócić do nich później.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  // Powrót do zakupów (np. zmiana taba w MainNavigation)
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('ODKRYWAJ PRODUKTY', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWishlistGrid(BuildContext context, WishlistProvider provider) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: provider.wishlistProducts.length,
      itemBuilder: (context, index) {
        final product = provider.wishlistProducts[index];
        return _WishlistProductCard(product: product);
      },
    );
  }
}

class _WishlistProductCard extends StatelessWidget {
  final dynamic product;
  const _WishlistProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProductDetailsScreen(product: product)),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  Hero(
                    tag: 'wishlist_${product.id}',
                    child: CachedNetworkImage(
                      imageUrl: product.imageUrl,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 8, right: 8,
                    child: GestureDetector(
                      onTap: () => context.read<WishlistProvider>().toggleWishlist(product),
                      child: const CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 16,
                        child: Icon(Icons.favorite, size: 18, color: Colors.red),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(product.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text('${product.price.toStringAsFixed(2)} PLN', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
        ],
      ),
    );
  }
}

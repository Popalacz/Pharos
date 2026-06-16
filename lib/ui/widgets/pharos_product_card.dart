import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:pharos/data/models/product_model.dart';
import 'package:pharos/core/providers/wishlist_provider.dart';
import 'package:pharos/core/providers/localization_provider.dart';
import 'package:pharos/ui/screens/product_details_screen.dart';

class PharosProductCard extends StatelessWidget {
  final ProductModel product;
  final String heroTagPrefix;

  const PharosProductCard({
    super.key, 
    required this.product, 
    this.heroTagPrefix = 'product'
  });

  @override
  Widget build(BuildContext context) {
    // Senior Performance: RepaintBoundary izoluje renderowanie karty
    return RepaintBoundary(
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => ProductDetailsScreen(product: product),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  children: [
                    Hero(
                      tag: '${heroTagPrefix}_${product.id}',
                      child: CachedNetworkImage(
                        imageUrl: product.imageUrl,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        // RAM Optimization: Nie dekoduj obrazu większego niż potrzebujemy
                        memCacheWidth: 500, 
                        placeholder: (context, url) => Container(color: Colors.white.withOpacity(0.03)),
                        errorWidget: (context, url, error) => const Icon(Icons.broken_image, color: Colors.white10),
                      ),
                    ),
                    _buildWishlistButton(),
                    if (!product.isAvailable) _buildStatusBadge('BRAK', Colors.red)
                    else if (product.isOnOrder) _buildStatusBadge('NA ZAMÓWIENIE', Colors.blue)
                    else if (product.isLowStock) _buildStatusBadge('OSTATNIE', Colors.orange),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            _buildProductInfo(context),
          ],
        ),
      ),
    );
  }

  Widget _buildWishlistButton() {
    return Positioned(
      top: 10, right: 10,
      child: Consumer<WishlistProvider>(
        builder: (context, wishlist, child) {
          final isFav = wishlist.isFavorite(product.id);
          return GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              final bool willBeFavorite = !wishlist.isFavorite(product.id);
              wishlist.toggleWishlist(product);
              
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(willBeFavorite ? 'Dodano do ulubionych' : 'Usunięto z ulubionych'),
                  duration: const Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: willBeFavorite ? Colors.orange : Colors.grey.shade800,
                ),
              );
            },
            child: CircleAvatar(
              backgroundColor: Colors.black45,
              radius: 16,
              child: Icon(
                isFav ? Icons.favorite : Icons.favorite_border,
                size: 18,
                color: isFav ? Colors.red : Colors.white,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusBadge(String text, Color color) {
    return Positioned(
      bottom: 10, left: 10,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildProductInfo(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Consumer<LocalizationProvider>(
            builder: (context, loc, child) => Text(
              loc.formatPrice(product.price),
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.orange),
            ),
          ),
        ],
      ),
    );
  }
}

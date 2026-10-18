import 'package:pharos/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:pharos/core/theme/app_spacing.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:provider/provider.dart';
import 'package:pharos/data/models/product_model.dart';
import 'package:pharos/core/providers/wishlist_provider.dart';
import 'package:pharos/core/providers/localization_provider.dart';
import 'package:pharos/core/providers/cart_provider.dart';
import 'package:pharos/core/providers/ui_feedback_provider.dart';
import 'package:pharos/ui/screens/product_details_screen.dart';
import 'package:pharos/ui/screens/cart_screen.dart';
import 'package:pharos/l10n/app_localizations.dart';

class PharosProductCard extends StatefulWidget {
  final ProductModel product;
  final String heroTagPrefix;

  const PharosProductCard({
    super.key, 
    required this.product, 
    this.heroTagPrefix = 'product'
  });

  @override
  State<PharosProductCard> createState() => _PharosProductCardState();
}

class _PharosProductCardState extends State<PharosProductCard> {
  final GlobalKey _imageKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => ProductDetailsScreen(product: widget.product),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildImageArea()),
            const SizedBox(height: AppSpacing.s8),
            _buildProductInfo(context),
          ],
        ),
      ),
    );
  }

  Widget _buildImageArea() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Hero(
            tag: '${widget.heroTagPrefix}_${widget.product.id}',
            child: Container(
              key: _imageKey,
              child: widget.product.imageUrl.isEmpty
                  ? ColoredBox(
                      color: AppColors.text.withOpacity(0.05),
                      child: const Icon(Icons.image_not_supported_outlined, color: AppColors.border),
                    )
                  : CachedNetworkImage(
                      imageUrl: widget.product.getSizedImageUrl('home_default'),
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      memCacheWidth: 400,
                      placeholder: (context, url) => Container(
                        color: AppColors.text.withOpacity(0.03),
                        child: Shimmer.fromColors(
                          baseColor: AppColors.text.withOpacity(0.05),
                          highlightColor: AppColors.text.withOpacity(0.1),
                          child: Container(color: AppColors.text),
                        ),
                      ),
                      errorWidget: (context, url, error) => const Icon(Icons.broken_image, color: AppColors.divider),
                    ),
            ),
          ),
          _buildWishlistButton(),
          if (!widget.product.isAvailable) _buildStatusBadge('BRAK', AppColors.error)
          else if (widget.product.isOnOrder) _buildStatusBadge('NA ZAMÓWIENIE', AppColors.info)
          else if (widget.product.isLowStock) _buildStatusBadge('OSTATNIE', AppColors.accentText),
          _buildQuickAddButton(context),
        ],
      ),
    );
  }
// Fly to cart animation section
  Widget _buildQuickAddButton(BuildContext context) {
    if (!widget.product.canBeAddedToCart) return const SizedBox.shrink();

    return Positioned(
      bottom: 4, right: 4,
      child: Semantics(
        button: true,
        label: AppLocalizations.of(context)!.addToCart,
        child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          HapticFeedback.heavyImpact();
          context.read<CartProvider>().addItem(widget.product);
          context.read<UiFeedbackProvider>().triggerFlyToCart(_imageKey);
          
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.addedProduct(widget.product.name)),
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              backgroundColor: AppColors.accent,
              action: SnackBarAction(
                label: AppLocalizations.of(context)!.cartUpper,
                textColor: AppColors.text,
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen())),
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.accentText,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: AppColors.black.withOpacity(0.3), blurRadius: 8)],
          ),
          child: const Icon(Icons.add_shopping_cart, size: 20, color: AppColors.text),
        ),
        ),
        ),
      ),
    );
  }

  Widget _buildWishlistButton() {
    return Positioned(
      top: 2, right: 2,
      child: Consumer<WishlistProvider>(
        builder: (context, wishlist, child) {
          final isFav = wishlist.isFavorite(widget.product.id);
          return Semantics(
            button: true,
            toggled: isFav,
            label: isFav ? AppLocalizations.of(context)!.a11yRemoveFromFavorites : AppLocalizations.of(context)!.a11yAddToFavorites,
            child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              HapticFeedback.mediumImpact();
              final bool willBeFavorite = !wishlist.isFavorite(widget.product.id);
              wishlist.toggleWishlist(widget.product);
              
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(willBeFavorite ? AppLocalizations.of(context)!.favoritesAdded : AppLocalizations.of(context)!.favoritesRemoved),
                  duration: const Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: willBeFavorite ? AppColors.accentText : AppColors.surface,
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: CircleAvatar(
                backgroundColor: AppColors.black.withOpacity(0.45),
                radius: 16,
                child: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  size: 18,
                  color: isFav ? AppColors.error : AppColors.text,
                ),
              ),
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
          style: const TextStyle(color: AppColors.text, fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildProductInfo(BuildContext context) {
    final loc = context.read<LocalizationProvider>();
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.product.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.text),
          ),
          const SizedBox(height: AppSpacing.s4),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            children: [
              Text(
                loc.formatPrice(widget.product.price),
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.accentText),
              ),
              if (widget.product.hasDiscount && widget.product.priceOld != null)
                Text(
                  loc.formatPrice(widget.product.priceOld!),
                  style: TextStyle(
                    fontWeight: FontWeight.w500, 
                    fontSize: 12, 
                    color: AppColors.text.withOpacity(0.3),
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

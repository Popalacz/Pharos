import 'package:flutter/material.dart';
import 'package:pharos/core/theme/app_spacing.dart';
import 'package:fpdart/fpdart.dart' hide State;
import 'package:pharos/data/models/product_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:pharos/core/providers/cart_provider.dart';
import 'package:pharos/core/providers/wishlist_provider.dart';
import 'package:pharos/core/providers/recently_viewed_provider.dart';
import 'package:pharos/data/models/review_model.dart';
import 'package:pharos/data/repositories/review_repository.dart';
import 'package:pharos/data/repositories/product_repository.dart';
import 'package:pharos/core/providers/localization_provider.dart';
import 'package:pharos/ui/widgets/pharos_product_card.dart';

import 'package:pharos/ui/screens/review_form_screen.dart';
import 'package:pharos/core/providers/user_provider.dart';
import 'package:pharos/ui/screens/cart_screen.dart';
import 'package:pharos/core/error/failures.dart';
import 'package:shimmer/shimmer.dart';
import 'package:pharos/ui/widgets/pharos_button.dart';

class ProductDetailsScreen extends StatefulWidget {
  final ProductModel product;
  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  late Future<Either<Failure, List<ReviewModel>>> _reviewsFuture;
  late Future<Either<Failure, List<ProductModel>>> _relatedFuture;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _reviewsFuture = ReviewRepository(useMockData: false).getProductReviews(widget.product.id);
    _relatedFuture = context.read<IProductRepository>().getRelatedProducts(widget.product.id);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<RecentlyViewedProvider>().addProduct(widget.product);
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocalizationProvider>();

    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _buildImageGallery(),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(loc),
                      const SizedBox(height: AppSpacing.s24),
                      _buildBadges(),
                      const SizedBox(height: AppSpacing.s32),
                      _buildSectionTitle('OPIS PRODUKTU'),
                      const SizedBox(height: AppSpacing.s12),
                      Text(
                        widget.product.description,
                        style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.7), height: 1.6)
                      ),
                      const SizedBox(height: AppSpacing.s32),
                      _buildTechnicalDetails(),
                      const SizedBox(height: AppSpacing.s48),
                      _buildSectionTitle('PODOBNE PRODUKTY'),
                      const SizedBox(height: AppSpacing.s16),
                      _buildRelatedProducts(),
                      const Divider(height: 64, color: Colors.white10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildSectionTitle('OPINIE KLIENTÓW'),
                          if (context.watch<UserProvider>().isLoggedIn)
                            TextButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ReviewFormScreen(
                                      productId: widget.product.id,
                                      title: 'Oceń produkt',
                                    ),
                                  ),
                                ).then((_) {
                                  setState(() {
                                    _reviewsFuture = ReviewRepository(useMockData: false).getProductReviews(widget.product.id);
                                  });
                                });
                              },
                              icon: const Icon(Icons.add, size: 18, color: Colors.orange),
                              label: const Text('DODAJ', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                            ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.s16),
                      _buildReviewsList(),
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ),
            ],
          ),
          _buildBottomAction(context),
          _buildBackButton(),
        ],
      ),
    );
  }

  Widget _buildImageGallery() {
    final sizedImages = widget.product.getSizedImages('large_default');

    return SliverAppBar(
      expandedHeight: 450,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            PageView.builder(
              itemCount: sizedImages.length,
              onPageChanged: (index) => setState(() => _currentImageIndex = index),
              itemBuilder: (context, index) => CachedNetworkImage(
                imageUrl: sizedImages[index],
                fit: BoxFit.cover,
                placeholder: (context, url) => Shimmer.fromColors(
                  baseColor: Colors.white.withOpacity(0.05),
                  highlightColor: Colors.white.withOpacity(0.1),
                  child: Container(color: Colors.black),
                ),
                errorWidget: (context, url, error) => const Center(child: Icon(Icons.broken_image, color: Colors.white10, size: 40)),
              ),
            ),
            if (sizedImages.length > 1)
              Positioned(
                bottom: 20,
                left: 0, right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: sizedImages.asMap().entries.map((entry) {
                    return Container(
                      width: 8, height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentImageIndex == entry.key ? Colors.orange : Colors.white24,
                      ),
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(LocalizationProvider loc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.product.manufacturerName.isNotEmpty)
          Text(
            widget.product.manufacturerName.toUpperCase(),
            style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, letterSpacing: 1.5, fontSize: 12)
          ),
        const SizedBox(height: AppSpacing.s8),
        // Fix for bottom overflow: Product name now wrapped in a Flexible/FittedBox and uses maxLines
        LayoutBuilder(
          builder: (context, constraints) => ConstrainedBox(
            constraints: BoxConstraints(maxWidth: constraints.maxWidth),
            child: Text(
              widget.product.name,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.s12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(loc.formatPrice(widget.product.price), style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.orange)),
            if (widget.product.hasDiscount && widget.product.priceOld != null) ...[
              const SizedBox(width: AppSpacing.s12),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  loc.formatPrice(widget.product.priceOld!),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withOpacity(0.3),
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.s12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                margin: const EdgeInsets.only(bottom: 4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '-${widget.product.discountPercentage ?? (((1 - widget.product.price / widget.product.priceOld!) * 100).round())}%',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildBadges() {
    return Row(
      children: [
        _badge(Icons.verified_user_outlined, 'Oryginalny'),
        const SizedBox(width: AppSpacing.s12),
        _badge(Icons.local_shipping_outlined, 'Szybka wysyłka'),
        const SizedBox(width: AppSpacing.s12),
        if (widget.product.isLowStock) _badge(Icons.flash_on, 'Ostatnie sztuki', color: Colors.red),
      ],
    );
  }

  Widget _badge(IconData icon, String label, {Color color = Colors.white24}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: color.withOpacity(0.2))),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color == Colors.white24 ? Colors.white70 : color),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 12, color: color == Colors.white24 ? Colors.white70 : color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildTechnicalDetails() {
    return Column(
      children: [
        _detailRow('Nr referencyjny', widget.product.reference),
        _detailRow('Dostępność', widget.product.isAvailable ? 'W magazynie' : (widget.product.availableLaterLabel.isNotEmpty ? widget.product.availableLaterLabel : 'Na zamówienie')),
        _detailRow('Minimalna ilość', widget.product.minimalQuantity.toString()),
      ],
    );
  }

  Widget _detailRow(String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.white.withOpacity(0.4))),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 2, color: Colors.white30));
  }

  Widget _buildRelatedProducts() {
    return FutureBuilder<Either<Failure, List<ProductModel>>>(
      future: _relatedFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox(height: 100);

        return snapshot.data!.fold(
          (_) => const SizedBox.shrink(),
          (products) {
            if (products.isEmpty) return const SizedBox.shrink();
            return SizedBox(
              height: 260,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: products.length,
                itemBuilder: (context, index) {
                  return Container(
                    width: 160,
                    margin: const EdgeInsets.only(right: 16),
                    child: PharosProductCard(product: products[index], heroTagPrefix: 'related'),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildReviewsList() {
    return FutureBuilder<Either<Failure, List<ReviewModel>>>(
      future: _reviewsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const LinearProgressIndicator(color: Colors.orange);
        if (snapshot.hasError || !snapshot.hasData) {
          return Text('Błąd podczas ładowania opinii.', style: TextStyle(color: Colors.white.withOpacity(0.3)));
        }

        return snapshot.data!.fold(
          (failure) => Text('Nie udało się pobrać opinii.', style: TextStyle(color: Colors.white.withOpacity(0.3))),
          (reviews) {
            if (reviews.isEmpty) {
              return Text('Brak opinii o tym produkcie.', style: TextStyle(color: Colors.white.withOpacity(0.3)));
            }
            return Column(
              children: reviews.map((review) => Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.03), borderRadius: BorderRadius.circular(16)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(review.customerName, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                        Row(children: List.generate(5, (i) => Icon(Icons.star, size: 14, color: i < review.rating ? Colors.amber : Colors.white10))),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.s8),
                    Text(review.comment, style: const TextStyle(fontSize: 14, color: Colors.white70)),
                  ],
                ),
              )).toList(),
            );
          },
        );
      },
    );
  }

  Widget _buildBottomAction(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
        ),
        child: SafeArea(
          child: Row(
            children: [
              Consumer<WishlistProvider>(
                builder: (context, wishlist, child) {
                  final isFav = wishlist.isFavorite(widget.product.id);
                  return IconButton(
                    icon: Icon(isFav ? Icons.favorite : Icons.favorite_border, color: isFav ? Colors.red : Colors.white),
                    onPressed: () => wishlist.toggleWishlist(widget.product),
                  );
                },
              ),
              const SizedBox(width: AppSpacing.s16),
              Expanded(
                child: widget.product.canBeAddedToCart
                    ? PharosButton(
                  label: widget.product.isOnOrder ? 'KUP NA ZAMÓWIENIE' : 'DODAJ DO KOSZYKA',
                  onPressed: () {
                    context.read<CartProvider>().addItem(widget.product);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(widget.product.isOnOrder ? 'Dodano produkt (Na zamówienie)' : 'Dodano do koszyka'),
                        backgroundColor: Colors.green,
                        action: SnackBarAction(
                          label: 'KOSZYK',
                          textColor: Colors.white,
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen()));
                          },
                        ),
                      ),
                    );
                  },
                )
                    : widget.product.shouldShowNotifyMe
                    ? PharosButton(
                  style: PharosButtonStyle.outline,
                  label: 'POWIADOM O DOSTĘPNOŚCI',
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Zapisano Cię na powiadomienie o dostępności!'), backgroundColor: Colors.blue),
                    );
                  },
                )
                    : Container(
                  height: 60,
                  alignment: Alignment.center,
                  child: const Text('PRODUKT NIEDOSTĘPNY', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return Positioned(
      top: 50, left: 20,
      child: CircleAvatar(
        backgroundColor: Colors.black.withOpacity(0.5),
        child: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
      ),
    );
  }
}

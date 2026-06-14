import 'package:flutter/material.dart';
import 'package:pharos/data/models/product_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:pharos/core/providers/cart_provider.dart';
import 'package:pharos/core/providers/wishlist_provider.dart';
import 'package:pharos/core/providers/recently_viewed_provider.dart';
import 'package:pharos/data/models/review_model.dart';
import 'package:pharos/data/repositories/review_repository.dart';
import 'package:pharos/core/providers/localization_provider.dart';

class ProductDetailsScreen extends StatefulWidget {
  final ProductModel product;
  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  late Future<List<ReviewModel>> _reviewsFuture;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _reviewsFuture = ReviewRepository(useMockData: true).getProductReviews(widget.product.id);
    
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
                      const SizedBox(height: 24),
                      _buildBadges(),
                      const SizedBox(height: 32),
                      _buildSectionTitle('OPIS PRODUKTU'),
                      const SizedBox(height: 12),
                      Text(
                        widget.product.description, 
                        style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.7), height: 1.6)
                      ),
                      const SizedBox(height: 32),
                      _buildTechnicalDetails(),
                      const Divider(height: 64, color: Colors.white10),
                      _buildSectionTitle('OPINIE KLIENTÓW'),
                      const SizedBox(height: 16),
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
    return SliverAppBar(
      expandedHeight: 450,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            PageView.builder(
              itemCount: widget.product.images.length,
              onPageChanged: (index) => setState(() => _currentImageIndex = index),
              itemBuilder: (context, index) => CachedNetworkImage(
                imageUrl: widget.product.images[index],
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(color: Colors.white.withOpacity(0.05)),
              ),
            ),
            if (widget.product.images.length > 1)
              Positioned(
                bottom: 20,
                left: 0, right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: widget.product.images.asMap().entries.map((entry) {
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
          Text(widget.product.manufacturerName.toUpperCase(), 
            style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, letterSpacing: 1.5, fontSize: 12)),
        const SizedBox(height: 8),
        Text(widget.product.name, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white)),
        const SizedBox(height: 12),
        Text(loc.formatPrice(widget.product.price), style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.orange)),
      ],
    );
  }

  Widget _buildBadges() {
    return Row(
      children: [
        _badge(Icons.verified_user_outlined, 'Oryginalny'),
        const SizedBox(width: 12),
        _badge(Icons.local_shipping_outlined, 'Szybka wysyłka'),
        const SizedBox(width: 12),
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
          Text(label, style: TextStyle(fontSize: 11, color: color == Colors.white24 ? Colors.white70 : color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildTechnicalDetails() {
    return Column(
      children: [
        _detailRow('Nr referencyjny', widget.product.reference),
        _detailRow('Dostępność', widget.product.isAvailable ? 'W magazynie' : 'Na zamówienie'),
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

  Widget _buildReviewsList() {
    return FutureBuilder<List<ReviewModel>>(
      future: _reviewsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const LinearProgressIndicator(color: Colors.orange);
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
           return Text('Brak opinii o tym produkcie.', style: TextStyle(color: Colors.white.withOpacity(0.3)));
        }
        return Column(
          children: snapshot.data!.map((review) => Container(
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
                const SizedBox(height: 8),
                Text(review.comment, style: const TextStyle(fontSize: 14, color: Colors.white70)),
              ],
            ),
          )).toList(),
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
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    minimumSize: const Size(double.infinity, 60),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: widget.product.isAvailable ? () {
                    context.read<CartProvider>().addItem(widget.product);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Dodano ${widget.product.name}'), backgroundColor: Colors.green));
                  } : null,
                  child: Text(widget.product.isAvailable ? 'DODAJ DO KOSZYKA' : 'NIEDOSTĘPNY', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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

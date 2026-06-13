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

import 'package:pharos/core/providers/recently_viewed_provider.dart';

class ProductDetailsScreen extends StatefulWidget {
// ... inside _ProductDetailsScreenState
  @override
  void initState() {
    super.initState();
    _reviewsFuture = ReviewRepository(useMockData: true).getProductReviews(widget.product.id);
    
    // Growth Guideline: Logowanie ostatnio oglądanych
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RecentlyViewedProvider>().addProduct(widget.product);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 400,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Hero(
                    tag: 'product_${widget.product.id}',
                    child: CachedNetworkImage(
                      imageUrl: widget.product.imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              widget.product.name,
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Consumer<LocalizationProvider>(
                            builder: (context, loc, child) => Text(
                              loc.formatPrice(widget.product.price),
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.orange),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Text('Opis produktu', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(widget.product.description, style: TextStyle(fontSize: 16, color: Colors.grey[700], height: 1.5)),
                      
                      const Divider(height: 48),
                      const Text('Opinie klientów', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      _buildReviewsList(),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
          _buildBottomAction(context),
        ],
      ),
    );
  }

  Widget _buildReviewsList() {
    return FutureBuilder<List<ReviewModel>>(
      future: _reviewsFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        if (snapshot.data!.isEmpty) return const Text('Brak opinii o tym produkcie.');
        
        return Column(
          children: snapshot.data!.map((review) => Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(review.customerName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Row(children: List.generate(5, (i) => Icon(Icons.star, size: 14, color: i < review.rating ? Colors.amber : Colors.grey[300]))),
                  ],
                ),
                const SizedBox(height: 8),
                Text(review.comment, style: const TextStyle(fontSize: 14)),
                const SizedBox(height: 4),
                Text(review.date, style: TextStyle(color: Colors.grey, fontSize: 12)),
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
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Consumer<WishlistProvider>(
                builder: (context, wishlist, child) {
                  final isFav = wishlist.isFavorite(widget.product.id);
                  return Container(
                    decoration: BoxDecoration(border: Border.all(color: isFav ? Colors.red : Colors.grey[300]!), borderRadius: BorderRadius.circular(12)),
                    child: IconButton(
                      icon: Icon(isFav ? Icons.favorite : Icons.favorite_border, color: isFav ? Colors.red : Colors.black),
                      onPressed: () => wishlist.toggleWishlist(widget.product),
                    ),
                  );
                },
              ),
              const SizedBox(width: 16),
              Expanded(
                child: widget.product.isAvailable
                  ? ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        context.read<CartProvider>().addItem(widget.product);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Dodano ${widget.product.name} do koszyka!'),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                      child: const Text('DODAJ DO KOSZYKA', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    )
                  : OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black,
                        minimumSize: const Size(double.infinity, 56),
                        side: const BorderSide(color: Colors.black),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        // Logika zapisu na powiadomienie (moduł ps_emailalerts)
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Powiadomimy Cię, gdy produkt wróci do sprzedaży!'), backgroundColor: Colors.blue),
                        );
                      },
                      child: const Text('POWIADOM MNIE O DOSTĘPNOŚCI', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pharos/core/providers/search_provider.dart';
import 'package:pharos/ui/screens/product_details_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pharos/core/providers/wishlist_provider.dart';

import 'package:pharos/ui/widgets/search_filter_drawer.dart';

import 'package:pharos/core/providers/settings_provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>().settings;
    
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      endDrawer: const SearchFilterDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: TextField(
          controller: _controller,
          autofocus: true,
          onChanged: (val) => context.read<SearchProvider>().onQueryChanged(val),
          decoration: InputDecoration(
            hintText: 'Szukaj w ${settings.storeName}...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.grey[400]),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune, color: Colors.black),
            onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
          ),
          if (_controller.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close, color: Colors.black),
              onPressed: () {
                _controller.clear();
                context.read<SearchProvider>().clearSearch();
              },
            ),
        ],
      ),
      body: Consumer<SearchProvider>(
        builder: (context, searchProvider, child) {
          if (searchProvider.isSearching) {
            return const Center(child: CircularProgressIndicator(color: Colors.orange));
          }

          if (searchProvider.query.isEmpty) {
            return _buildEmptyState('Zacznij pisać, aby znaleźć produkty');
          }

          if (searchProvider.searchResults.isEmpty) {
            return _buildEmptyState('Nie znaleźliśmy produktów pasujących do "${searchProvider.query}"');
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.65,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: searchProvider.searchResults.length,
            itemBuilder: (context, index) {
              final product = searchProvider.searchResults[index];
              return _SearchProductCard(product: product);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 80, color: Colors.grey[200]),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchProductCard extends StatelessWidget {
  final dynamic product;
  const _SearchProductCard({required this.product});

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
                  CachedNetworkImage(
                    imageUrl: product.imageUrl,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    top: 8, right: 8,
                    child: Consumer<WishlistProvider>(
                      builder: (context, wishlist, child) {
                        final isFav = wishlist.isFavorite(product.id);
                        return CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 16,
                          child: Icon(
                            isFav ? Icons.favorite : Icons.favorite_border,
                            size: 18,
                            color: isFav ? Colors.red : Colors.grey[800],
                          ),
                        );
                      },
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

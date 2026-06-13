import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pharos/data/repositories/product_repository.dart';
import 'package:pharos/data/models/product_model.dart';
import 'package:pharos/data/models/home_config_model.dart';
import 'package:pharos/ui/widgets/product_shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pharos/ui/screens/product_details_screen.dart';
import 'package:pharos/ui/screens/search_screen.dart';
import 'package:pharos/core/providers/cart_provider.dart';
import 'package:pharos/core/providers/wishlist_provider.dart';
import 'package:pharos/core/providers/recently_viewed_provider.dart';
import 'package:pharos/core/providers/settings_provider.dart';
import 'package:lottie/lottie.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<Map<String, dynamic>> _homeDataFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    // W Senior UX ładujemy wszystko jednym rzutem, aby uniknąć skoków UI
    _homeDataFuture = _fetchFullHomeData();
  }

  Future<Map<String, dynamic>> _fetchFullHomeData() async {
    try {
      final response = await context.read<SettingsProvider>().apiService.dio.get('/module/pharos_api/config');
      
      // Dodatkowo pobieramy produkty jeśli nie są zawarte w configu
      final productsResponse = await context.read<IProductRepository>().getProducts();
      
      return {
        'home_config': response.data['home_config'] ?? [],
        'products': productsResponse, // Lista obiektów ProductModel
      };
    } catch (e) {
      debugPrint('Home Data Fetch Error: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<Map<String, dynamic>>(
        future: _homeDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const ProductShimmer(); // Możemy dopracować shimmer dla bannerów
          }

          if (snapshot.hasError) {
            return _buildErrorState();
          }

          final sectionsJson = snapshot.data!['home_config'] as List;
          final sections = sectionsJson.map((s) => HomeSection.fromJson(s)).toList();
          final List<ProductModel> products = snapshot.data!['products'] as List<ProductModel>;

          return RefreshIndicator(
            onRefresh: () async => setState(() => _loadData()),
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(), // Premium iOS feel
              slivers: [
                _buildAppBar(context),
                _buildCartRecoveryBanner(context),
                for (var section in sections) _buildSliverSection(section, products),
                _buildRecentlyViewedSection(),
                const SliverToBoxAdapter(child: SizedBox(height: 32)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        final settings = settingsProvider.settings;
        return SliverAppBar(
          floating: true,
          pinned: true,
          expandedHeight: 120,
          backgroundColor: Colors.white,
          elevation: 0,
          flexibleSpace: FlexibleSpaceBar(
            titlePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (settings.logoUrl != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: CachedNetworkImage(
                      imageUrl: settings.logoUrl!,
                      height: 24,
                      errorWidget: (context, url, error) => const SizedBox.shrink(),
                    ),
                  ),
                Text(
                  settings.storeName.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            centerTitle: false,
          ),
import 'package:pharos/ui/screens/scanner_screen.dart';

// ... (wewnątrz _buildAppBar actions)
          actions: [
            IconButton(
              icon: const Icon(Icons.qr_code_scanner, color: Colors.black),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ScannerScreen()),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.search, color: Colors.black),
// ...

            Consumer<CartProvider>(
              builder: (context, cart, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.shopping_bag_outlined, color: Colors.black),
                      onPressed: () {
                        // Przejście do koszyka
                      },
                    ),
                    if (cart.itemCount > 0)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                          child: Text(
                            '${cart.itemCount}',
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildSliverSection(HomeSection section, List<ProductModel> products) {
    switch (section.type) {
      case HomeSectionType.BANNER_SLIDER:
        return SliverToBoxAdapter(
          child: _BannerSlider(data: section.data),
        );
      case HomeSectionType.CATEGORY_CHIPS:
        return SliverToBoxAdapter(
          child: _CategoryList(data: section.data),
        );
      case HomeSectionType.SECTION_HEADER:
        return SliverToBoxAdapter(
          child: _SectionHeader(title: section.data['title']),
        );
      case HomeSectionType.PRODUCT_GRID:
        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.65,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) => _ProductCard(product: products[index]),
              childCount: products.length,
            ),
          ),
        );
    }
  }

  Widget _buildCartRecoveryBanner(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final settings = context.watch<SettingsProvider>().settings;
    
    if (!settings.cartRecoveryEnabled || cart.itemCount == 0) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange.shade200),
        ),
        child: Row(
          children: [
            const Icon(Icons.shopping_cart_checkout, color: Colors.orange),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Dokończ zakupy!', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('W Twoim koszyku czekają produkty o wartości ${context.read<LocalizationProvider>().formatPrice(cart.totalAmount)}', 
                    style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Nawigacja do koszyka (zakładając że MainNavigation obsłuży zmianę indexu)
                // W tym przypadku prościej przekierować do CartScreen jako push dla demonstracji
                Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              child: const Text('KOSZYK'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentlyViewedSection() {
    return Consumer<RecentlyViewedProvider>(
      builder: (context, recentProvider, child) {
        if (recentProvider.recentProducts.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());
        
        return SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionHeader(title: 'Ostatnio oglądane'),
              SizedBox(
                height: 250,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: recentProvider.recentProducts.length,
                  itemBuilder: (context, index) {
                    final product = recentProvider.recentProducts[index];
                    return Container(
                      width: 160,
                      margin: const EdgeInsets.only(right: 16),
                      child: _ProductCard(product: product),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.network(
            'https://assets9.lottiefiles.com/packages/lf20_ghp9v6m3.json',
            height: 200,
          ),
          const SizedBox(height: 16),
          const Text('Błąd synchronizacji z Pharos API', 
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          const Text('Sprawdź połączenie z internetem i spróbuj ponownie.', 
            textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => setState(() => _loadData()),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('SPRÓBUJ PONOWNIE', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// --- Komponenty pomocnicze UI ---

class _BannerSlider extends StatelessWidget {
  final dynamic data;
  const _BannerSlider({required this.data});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: PageView.builder(
        itemCount: (data as List).length,
        itemBuilder: (context, index) {
          final item = data[index];
          return Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              image: DecorationImage(image: NetworkImage(item['image']), fit: BoxFit.cover),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                ),
              ),
              padding: const EdgeInsets.all(20),
              alignment: Alignment.bottomLeft,
              child: Text(item['title'], style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            ),
          );
        },
      ),
    );
  }
}

class _CategoryList extends StatelessWidget {
  final dynamic data;
  const _CategoryList({required this.data});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: (data as List).length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            child: Chip(
              label: Text(data[index]['name']),
              backgroundColor: Colors.grey[100],
              side: BorderSide.none,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const Text('Zobacz wszystko', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final ProductModel product;
  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailsScreen(product: product),
            ),
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
                      tag: 'product_${product.id}',
                      child: CachedNetworkImage(
                        imageUrl: product.imageUrl,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        memCacheWidth: 400, // Optymalizacja pamięci RAM dla miniatur
                        placeholder: (context, url) => Container(color: Colors.grey[200]),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[100],
                          child: const Icon(Icons.broken_image, color: Colors.grey),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8, right: 8,
                      child: Consumer<WishlistProvider>(
                        builder: (context, wishlist, child) {
                          final isFav = wishlist.isFavorite(product.id);
                          return GestureDetector(
                            onTap: () => wishlist.toggleWishlist(product),
                            child: CircleAvatar(
                              backgroundColor: Colors.white.withOpacity(0.9),
                              radius: 16,
                              child: Icon(
                                isFav ? Icons.favorite : Icons.favorite_border,
                                size: 18,
                                color: isFav ? Colors.red : Colors.grey[800],
                              ),
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
            Text(
              product.name, 
              maxLines: 1, 
              overflow: TextOverflow.ellipsis, 
              style: const TextStyle(fontWeight: FontWeight.w600)
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Consumer<LocalizationProvider>(
                  builder: (context, loc, child) => Text(
                    loc.formatPrice(product.price),
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                  ),
                ),
                if (!product.isAvailable)
                  const Text('BRAK', style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold))
                else if (product.isLowStock)
                  const Text('OSTATNIE SZTUKI', style: TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

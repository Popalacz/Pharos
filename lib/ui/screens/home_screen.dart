import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pharos/data/repositories/product_repository.dart';
import 'package:pharos/data/models/product_model.dart';
import 'package:pharos/data/models/home_config_model.dart';
import 'package:pharos/ui/widgets/product_shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pharos/ui/screens/product_details_screen.dart';
import 'package:pharos/ui/screens/search_screen.dart';
import 'package:pharos/ui/screens/scanner_screen.dart';
import 'package:pharos/ui/screens/cart_screen.dart';
import 'package:pharos/data/repositories/category_repository.dart';
import 'package:pharos/data/models/category_model.dart';
import 'package:pharos/core/providers/cart_provider.dart';
import 'package:pharos/core/providers/wishlist_provider.dart';
import 'package:pharos/core/providers/recently_viewed_provider.dart';
import 'package:pharos/core/providers/settings_provider.dart';
import 'package:pharos/core/providers/localization_provider.dart';
import 'package:pharos/ui/widgets/pharos_product_card.dart';
import 'package:pharos/ui/widgets/pharos_navigation_drawer.dart';
import 'package:pharos/ui/widgets/localization_selector.dart';
import 'package:pharos/core/network/api_service.dart';
import 'package:pharos/ui/widgets/network_error_state.dart';
import 'package:pharos/ui/screens/catalog_screen.dart';
import 'package:lottie/lottie.dart';
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<Map<String, dynamic>> _homeDataFuture;
  int? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _homeDataFuture = _fetchFullHomeData();
  }

  Future<Map<String, dynamic>> _fetchFullHomeData() async {
    final settingsProvider = context.read<SettingsProvider>();

    final response = await settingsProvider.apiService.getSafe(
      '/index.php',
      queryParameters: {
        'fc': 'module',
        'module': 'pharosapi',
        'controller': 'home',
      },
      mapper: (json) => json,
    );

    return response.fold(
      (failure) => {'error': failure.message, 'sections': <dynamic>[]},
      (data) {
        if (data is Map && data['status'] == 'success') {
          return {
            'sections': data['sections'] ?? [],
            'cart_count': data['cart_count'] ?? 0,
          };
        }
        return {'sections': <dynamic>[]};
      },
    );
  }

  void _onCategorySelected(int? id) {
    setState(() {
      _selectedCategoryId = id;
      _loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: PharosNavigationDrawer(onRefreshCatalog: _loadData),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _homeDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const ProductShimmer();
          }

          if (snapshot.hasError) {
            return _buildErrorState();
          }

          final data = snapshot.data ?? {};
          if (data['error'] != null) {
            return NetworkErrorState(
              message: data['error'].toString(),
              onRetry: () => setState(() => _loadData()),
            );
          }

          final List sectionsData = data['sections'] ?? [];

          return RefreshIndicator(
            onRefresh: () async => setState(() => _loadData()),
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildAppBar(context),
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: LocalizationSelector(),
                  ),
                ),
                _buildCartRecoveryBanner(context),
                
                if (sectionsData.isNotEmpty)
                  for (final sectionMap in sectionsData)
                    _buildUnifiedSection(sectionMap as Map<String, dynamic>),

                _buildRecentlyViewedSection(),
                const SliverToBoxAdapter(child: SizedBox(height: 32)),
              ],
            ),
          );
        },
      ),
    );
  }

  List<HomeSection> _getLegacySections(List<ProductModel> products, List<CategoryModel> categories) {
    // Prosty mapper dla starego formatu danych
    return [
      HomeSection(type: HomeSectionType.BANNER_SLIDER, data: []),
      HomeSection(type: HomeSectionType.CATEGORY_CHIPS, data: null),
      HomeSection(type: HomeSectionType.SECTION_HEADER, data: {'title': 'Produkty'}),
      HomeSection(type: HomeSectionType.PRODUCT_GRID, data: null),
    ];
  }

  Widget _buildUnifiedSection(Map<String, dynamic> sectionMap) {
    final typeStr = sectionMap['type'] as String;
    final HomeSectionType type = HomeSectionType.values.firstWhere(
      (e) => e.name == typeStr,
      orElse: () => HomeSectionType.SECTION_HEADER,
    );

    final items = sectionMap['items'] ?? [];
    if (items is List && items.isEmpty && type != HomeSectionType.SECTION_HEADER) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    switch (type) {
      case HomeSectionType.BANNER_SLIDER:
        return SliverToBoxAdapter(child: _BannerSlider(data: items));
      case HomeSectionType.CATEGORY_CHIPS:
        final categories = (items as List).map((i) => CategoryModel(id: i['id'], name: i['name'])).toList();
        return SliverToBoxAdapter(
          child: _CategoryList(
            categories: categories,
            selectedId: _selectedCategoryId,
            onSelected: _onCategorySelected,
          ),
        );
      case HomeSectionType.SECTION_HEADER:
        return SliverToBoxAdapter(child: _SectionHeader(title: sectionMap['title'] ?? 'Sekcja'));
      case HomeSectionType.PRODUCT_GRID:
        final products = (items as List).map((i) => ProductModel.fromJson(i)).toList();
        
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
              (context, index) => PharosProductCard(product: products[index], heroTagPrefix: 'home'),
              childCount: products.length,
            ),
          ),
        );
    }
  }

  Widget _buildAppBar(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        final settings = settingsProvider.settings;
        return SliverAppBar(
          floating: true,
          pinned: true,
          expandedHeight: 120,
          leading: IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
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
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            centerTitle: false,
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.qr_code_scanner),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ScannerScreen()),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SearchScreen()),
                );
              },
            ),
            Consumer<CartProvider>(
              builder: (context, cart, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.shopping_bag_outlined),
                      onPressed: () {
                         Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen()));
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

  Widget _buildSliverSection(HomeSection section, List<ProductModel> products, List<CategoryModel> categories) {
    if (section.data == null && section.type != HomeSectionType.PRODUCT_GRID && section.type != HomeSectionType.CATEGORY_CHIPS) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    switch (section.type) {
      case HomeSectionType.BANNER_SLIDER:
        return SliverToBoxAdapter(
          child: _BannerSlider(data: section.data ?? []),
        );
      case HomeSectionType.CATEGORY_CHIPS:
        return SliverToBoxAdapter(
          child: _CategoryList(
            categories: categories, 
            selectedId: _selectedCategoryId,
            onSelected: _onCategorySelected,
          ),
        );
      case HomeSectionType.SECTION_HEADER:
        final String title = (section.data is Map) ? (section.data['title'] ?? '') : 'Sekcja';
        return SliverToBoxAdapter(
          child: _SectionHeader(
            title: title,
            onSeeAll: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CatalogScreen(
                    title: title,
                    categoryId: _selectedCategoryId,
                  ),
                ),
              );
            },
          ),
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
              (context, index) => PharosProductCard(product: products[index], heroTagPrefix: 'home'),
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
          color: Colors.orange.shade900.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange.shade800),
        ),
        child: Row(
          children: [
            const Icon(Icons.shopping_cart_checkout, color: Colors.orange),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Dokończ zakupy!', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  Text('W Twoim koszyku czekają produkty o wartości ${context.read<LocalizationProvider>().formatPrice(cart.totalAmount)}', 
                    style: const TextStyle(fontSize: 12, color: Colors.white70)),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
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
                      child: PharosProductCard(product: product, heroTagPrefix: 'recent'),
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
            errorBuilder: (context, error, stackTrace) => const Icon(Icons.wifi_off_rounded, size: 80, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          const Text('Błąd synchronizacji z Pharos API', 
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
          const SizedBox(height: 8),
          const Text('Sprawdź połączenie z internetem i spróbuj ponownie.', 
            textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => setState(() => _loadData()),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('SPRÓBUJ PONOWNIE', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _BannerSlider extends StatelessWidget {
  final dynamic data;
  const _BannerSlider({required this.data});

  @override
  Widget build(BuildContext context) {
    if ((data as List).isEmpty) return const SizedBox.shrink();
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
  final List<CategoryModel> categories;
  final int? selectedId;
  final Function(int?) onSelected;

  const _CategoryList({
    required this.categories, 
    this.selectedId, 
    required this.onSelected
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: categories.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildChip('Wszystko', null);
          }
          final category = categories[index - 1];
          return _buildChip(category.name, category.id);
        },
      ),
    );
  }

  Widget _buildChip(String label, int? id) {
    final isSelected = selectedId == id;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) => onSelected(id),
        selectedColor: Colors.orange,
        backgroundColor: Colors.white.withOpacity(0.05),
        labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.white70, fontWeight: FontWeight.bold),
        showCheckmark: false,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide.none),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;
  const _SectionHeader({required this.title, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
          InkWell(
            onTap: onSeeAll,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Text('Zobacz wszystko', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}


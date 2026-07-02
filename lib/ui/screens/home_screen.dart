import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pharos/data/repositories/product_repository.dart';
import 'package:pharos/data/models/product_model.dart';
import 'package:pharos/ui/sdui/sdui_mapper.dart';
import 'package:pharos/ui/sdui/sdui_sections.dart';
import 'package:pharos/ui/widgets/banner_shimmer.dart';
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
  final SduiMapper _sduiMapper = const SduiMapper();

  @override
  void initState() {
    super.initState();
    _loadData();
    _checkPromoPopup();
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

  void _checkPromoPopup() {
    final settings = context.read<SettingsProvider>().settings;
    if (settings.promoPopupImageUrl != null && settings.promoPopupImageUrl!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showPromoDialog(settings.promoPopupImageUrl!);
      });
    }
  }

  void _showPromoDialog(String imageUrl) {
    final settings = context.read<SettingsProvider>().settings;
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.contain,
              ),
            ),
            if (settings.appOnlyDiscountCode != null)
              Container(
                margin: const EdgeInsets.only(top: 16),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Text('TWÓJ KOD RABATOWY:', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(settings.appOnlyDiscountCode!, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 2)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: PharosNavigationDrawer(onRefreshCatalog: _loadData),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _homeDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CustomScrollView(
              slivers: [
                _buildAppBar(context),
                const SliverToBoxAdapter(child: BannerShimmer()),
                const SliverToBoxAdapter(child: ProductShimmer()),
              ],
            );
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
            onRefresh: () async {
              await context.read<LocalizationProvider>().reload();
              setState(() => _loadData());
            },
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
                    _sduiMapper.mapSectionAsSliver(
                      context,
                      sectionMap as Map<String, dynamic>,
                      selectedCategoryId: _selectedCategoryId,
                      onCategorySelected: _onCategorySelected,
                    ),

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
          leading: IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
          flexibleSpace: LayoutBuilder(
            builder: (context, constraints) {
              final isCollapsed = constraints.biggest.height <= kToolbarHeight + 30;
              final showLogo = settings.brandingEnabled && settings.logoUrl != null && !isCollapsed;

              return FlexibleSpaceBar(
                titlePadding: EdgeInsets.only(
                  left: isCollapsed ? 56 : 16,
                  right: 16,
                  bottom: 12,
                ),
                title: Text(
                  settings.storeName.toUpperCase(),
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    fontSize: 18,
                  ),
                ),
                centerTitle: false,
                background: showLogo
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 24),
                          child: CachedNetworkImage(
                            imageUrl: settings.logoUrl!,
                            height: 48,
                            errorWidget: (context, url, error) => const SizedBox.shrink(),
                          ),
                        ),
                      )
                    : null,
              );
            },
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
              const SectionHeaderWidget(data: {'title': 'Ostatnio oglądane'}),
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

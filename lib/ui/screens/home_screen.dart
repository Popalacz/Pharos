import 'package:pharos/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:pharos/core/theme/app_spacing.dart';
import 'package:provider/provider.dart';
import 'package:fpdart/fpdart.dart' hide State;
import 'package:pharos/data/repositories/product_repository.dart';
import 'package:pharos/core/error/failures.dart';
import 'package:pharos/data/models/product_model.dart';
import 'package:pharos/ui/sdui/sdui_mapper.dart';
import 'package:pharos/ui/sdui/sdui_sections.dart';
import 'package:pharos/ui/widgets/banner_shimmer.dart';
import 'package:pharos/ui/widgets/product_shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pharos/ui/screens/search_screen.dart';
import 'package:pharos/core/providers/search_provider.dart';
import 'package:pharos/core/utils/product_list_filters.dart';
import 'package:pharos/ui/widgets/search_filter_drawer.dart';
import 'package:pharos/ui/widgets/catalog_empty_state.dart';
import 'package:pharos/ui/screens/scanner_screen.dart';
import 'package:pharos/ui/screens/cart_screen.dart';
import 'package:pharos/core/providers/cart_provider.dart';
import 'package:pharos/core/providers/recently_viewed_provider.dart';
import 'package:pharos/core/providers/settings_provider.dart';
import 'package:pharos/core/providers/localization_provider.dart';
import 'package:pharos/ui/widgets/pharos_product_card.dart';
import 'package:pharos/ui/widgets/pharos_navigation_drawer.dart';
import 'package:pharos/ui/widgets/localization_selector.dart';
import 'package:pharos/ui/widgets/network_error_state.dart';
import 'package:lottie/lottie.dart';
import 'package:pharos/l10n/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late Future<Map<String, dynamic>> _homeDataFuture;
  late Future<Either<Failure, List<ProductModel>>> _fallbackProductsFuture;
  int? _selectedCategoryId;
  int _lastFilterRevision = -1;
  bool _initialLoadDone = false;
  final SduiMapper _sduiMapper = const SduiMapper();

  @override
  void initState() {
    super.initState();
    _checkPromoPopup();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialLoadDone) {
      _initialLoadDone = true;
      _loadData();
    }
  }

  void _loadData() {
    final searchProvider = context.read<SearchProvider>();
    _lastFilterRevision = searchProvider.filterRevision;

    final listQuery = ProductListFilters.buildQuery(
      selectedFilters: searchProvider.getSelectedFilters(),
      catalogCategoryId: _selectedCategoryId,
    );

    _homeDataFuture = _fetchFullHomeData(categoryId: listQuery.categoryId);
    _fallbackProductsFuture = context.read<IProductRepository>().getProducts(
          categoryId: listQuery.categoryId,
          filters: searchProvider.getSelectedFilters(),
        );
  }

  Future<Map<String, dynamic>> _fetchFullHomeData({int? categoryId}) async {
    final settingsProvider = context.read<SettingsProvider>();

    final response = await settingsProvider.apiService.getSafe(
      '/index.php',
      queryParameters: {
        'fc': 'module',
        'module': 'pharosapi',
        'controller': 'home',
        if (categoryId != null) 'id_category': categoryId.toString(),
      },
      mapper: (json) => json,
    );

    return response.fold(
      (failure) => {'error': failure.message, 'sections': <dynamic>[]},
      (data) {
        if (data is Map && (data['status'] == 'success' || data['success'] == true)) {
          List sections = [];
          final rawSections = data['sections'] ?? (data['home_config'] is Map ? data['home_config']['sections'] : data['home_config']);
          
          if (rawSections is List) {
            sections = rawSections;
          }

          return {
            'sections': sections,
            'cart_count': data['cart_count'] ?? 0,
          };
        }
        return {
          'error': data is Map ? (data['message'] ?? 'Błąd pobierania danych') : 'Błędny format odpowiedzi',
          'sections': <dynamic>[]
        };
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
    final l10n = AppLocalizations.of(context)!;
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
                tooltip: AppLocalizations.of(context)!.a11yClose,
                icon: const Icon(Icons.close, color: AppColors.text),
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
                  color: AppColors.accentText,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(l10n.yourPromoCode, style: const TextStyle(color: AppColors.text, fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: AppSpacing.s4),
                    Text(settings.appOnlyDiscountCode!, style: const TextStyle(color: AppColors.text, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 2)),
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
    final searchProvider = context.watch<SearchProvider>();

    if (searchProvider.filterRevision != _lastFilterRevision) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(_loadData);
      });
    }

    return Scaffold(
      key: _scaffoldKey,
      drawer: PharosNavigationDrawer(onRefreshCatalog: _loadData),
      endDrawer: const SearchFilterDrawer(),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _homeDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CustomScrollView(
              slivers: [
                _buildAppBar(context, searchProvider),
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
          final hasActiveFilters = searchProvider.hasActiveProductFilters;
          final visibleSections = _resolveVisibleSections(sectionsData, hasActiveFilters);
          
          return RefreshIndicator(
            onRefresh: () async {
              await context.read<LocalizationProvider>().reload();
              setState(_loadData);
            },
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildAppBar(context, searchProvider),
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: LocalizationSelector(),
                  ),
                ),
                _buildCartRecoveryBanner(context),
                
                if (visibleSections.isNotEmpty)
                  for (final sectionMap in visibleSections)
                    _sduiMapper.mapSectionAsSliver(
                      context,
                      sectionMap,
                      selectedCategoryId: _selectedCategoryId,
                      onCategorySelected: _onCategorySelected,
                    ),

                if (hasActiveFilters)
                  _buildFilteredProductsSection()
                else if (!_sectionsIncludeProducts(visibleSections))
                  _buildProductGridFallback(),

                _buildRecentlyViewedSection(),
                const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.s32)),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Map<String, dynamic>> _resolveVisibleSections(
    List sectionsData,
    bool hasActiveFilters,
  ) {
    final visibleSections = _sduiMapper.filterVisibleSections(sectionsData);
    if (!hasActiveFilters) {
      return visibleSections;
    }

    return visibleSections.where((section) {
      final type = section['type']?.toString();
      return type != 'PRODUCT_GRID' && type != 'RECOMMENDATIONS';
    }).toList();
  }

  Widget _buildAppBar(BuildContext context, SearchProvider searchProvider) {
    final settings = context.watch<SettingsProvider>().settings;
    return SliverAppBar(
      floating: true,
      pinned: true,
      expandedHeight: 120,
      leading: IconButton(
        tooltip: AppLocalizations.of(context)!.a11yOpenMenu,
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
          tooltip: AppLocalizations.of(context)!.a11yScanBarcode,
          icon: const Icon(Icons.qr_code_scanner),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ScannerScreen()),
            );
          },
        ),
        IconButton(
          tooltip: AppLocalizations.of(context)!.a11yFilters,
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.tune),
              if (searchProvider.activeFilterCount > 0)
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.accentText,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      '${searchProvider.activeFilterCount}',
                      style: const TextStyle(color: AppColors.text, fontSize: 12, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
        ),
        IconButton(
          tooltip: AppLocalizations.of(context)!.search,
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
                  tooltip: AppLocalizations.of(context)!.cart,
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
                        color: AppColors.accentText,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text(
                        '${cart.itemCount}',
                        style: const TextStyle(color: AppColors.text, fontSize: 12, fontWeight: FontWeight.bold),
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
  }

  Widget _buildCartRecoveryBanner(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final settings = context.watch<SettingsProvider>().settings;
    final l10n = AppLocalizations.of(context)!;
    final loc = context.read<LocalizationProvider>();
    
    if (!settings.cartRecoveryEnabled || cart.itemCount == 0) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.accent.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.accent),
        ),
        child: Row(
          children: [
            const Icon(Icons.shopping_cart_checkout, color: AppColors.accentText),
            const SizedBox(width: AppSpacing.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.finishShopping, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.text)),
                  Text(l10n.cartRecoveryMessage(loc.formatPrice(cart.totalAmount)), 
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.text,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              child: Text(l10n.cart.toUpperCase()),
            ),
          ],
        ),
      ),
    );
  }

  bool _sectionsIncludeProducts(List sectionsData) {
    for (final rawSection in sectionsData) {
      if (rawSection is! Map) continue;

      final type = rawSection['type']?.toString();
      if (type != 'PRODUCT_GRID' && type != 'RECOMMENDATIONS') continue;

      final data = rawSection['data'];
      if (data is Map && (data['items'] as List?)?.isNotEmpty == true) {
        return true;
      }
    }
    return false;
  }

  Widget _buildFilteredProductsSection() {
    return SliverToBoxAdapter(
      child: FutureBuilder<Either<Failure, List<ProductModel>>>(
        future: _fallbackProductsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const ProductShimmer();
          }

          if (!snapshot.hasData) {
            return const SizedBox.shrink();
          }

          return snapshot.data!.fold(
            (_) => const SizedBox.shrink(),
            (products) {
              if (products.isEmpty) {
                return const CatalogEmptyState();
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeaderWidget(data: {'title': 'Przefiltrowane produkty'}),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.55,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        return PharosProductCard(
                          product: products[index],
                          heroTagPrefix: 'home_filtered',
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildProductGridFallback() {
    return SliverToBoxAdapter(
      child: FutureBuilder<Either<Failure, List<ProductModel>>>(
        future: _fallbackProductsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const ProductShimmer();
          }

          if (!snapshot.hasData) {
            return const SizedBox.shrink();
          }

          return snapshot.data!.fold(
            (_) => const SizedBox.shrink(),
            (products) {
              if (products.isEmpty) {
                return const SizedBox.shrink();
              }

              return ProductGridSection(
                data: {
                  'items': products.map((product) => product.toJson()).toList(),
                },
                heroTagPrefix: 'home_fallback',
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildRecentlyViewedSection() {
    final l10n = AppLocalizations.of(context)!;
    final recentProducts = context.watch<RecentlyViewedProvider>().recentProducts;

    if (recentProducts.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeaderWidget(data: {'title': l10n.recentlyViewed}),
          SizedBox(
            height: 250,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: recentProducts.length,
              itemBuilder: (context, index) {
                final product = recentProducts[index];
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
  }

  Widget _buildErrorState() {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.network(
            'https://assets9.lottiefiles.com/packages/lf20_ghp9v6m3.json',
            height: 200,
            errorBuilder: (context, error, stackTrace) => const Icon(Icons.wifi_off_rounded, size: 80, color: AppColors.textMuted),
          ),
          const SizedBox(height: AppSpacing.s16),
          Text(l10n.syncErrorTitle, 
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.text)),
          const SizedBox(height: AppSpacing.s8),
          Text(l10n.syncErrorMessage, 
            textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textMuted)),
          const SizedBox(height: AppSpacing.s24),
          ElevatedButton(
            onPressed: () => setState(() => _loadData()),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(l10n.tryAgain, style: const TextStyle(color: AppColors.text)),
          ),
        ],
      ),
    );
  }
}

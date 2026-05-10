import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/constants/pharos_layout.dart';
import '../../core/theme/app_colors.dart';
import '../../models/product_model.dart';
import '../../providers/product_provider.dart';
import '../sheets/cart_preview_sheet.dart';
import '../widgets/catalog_empty_state.dart';
import '../widgets/catalog_search_bar.dart';
import '../widgets/network_error_state.dart';
import '../widgets/pharos_header_actions.dart';
import '../widgets/pharos_navigation_drawer.dart';
import '../widgets/product_card.dart';
import '../widgets/product_catalog_skeleton.dart';
import '../widgets/store_brand_title.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  Timer? _searchDebounce;
  String _filterLower = '';
  bool _showScrollToTop = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
  }

  void _handleScroll() {
    final bool next = _scrollController.offset > 240;

    if (next == _showScrollToTop) {
      return;
    }

    setState(() => _showScrollToTop = next);
  }

  void _scheduleSearchRecompute() {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(PharosLayout.motionNormal, () {
      if (!mounted) {
        return;
      }

      final String next = _searchController.text.trim().toLowerCase();

      if (next == _filterLower) {
        return;
      }

      setState(() => _filterLower = next);
    });
  }

  void _clearCatalogSearch() {
    HapticFeedback.selectionClick();
    _searchDebounce?.cancel();
    _searchController.clear();
    setState(() => _filterLower = '');
  }

  List<Product> _visibleProducts(List<Product> products) {
    if (_filterLower.isEmpty) {
      return products;
    }

    return products
        .where((Product product) => product.name.toLowerCase().contains(_filterLower))
        .toList();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ProductProvider productProvider = context.watch<ProductProvider>();

    return Scaffold(
      drawer: PharosNavigationDrawer(
        onRefreshCatalog: () {
          productProvider.fetchAllProducts();
          Navigator.of(context).pop();
        },
      ),
      appBar: AppBar(
        leading: Builder(
          builder: (BuildContext menuContext) {
            return IconButton(
              tooltip: 'Menu',
              icon: const Icon(Icons.menu_rounded),
              onPressed: () => Scaffold.of(menuContext).openDrawer(),
            );
          },
        ),
        title: const StoreBrandTitle(),
        actions: [
          PharosHeaderActions(
            onCartPressed: () => showCartPreviewSheet(context),
          ),
        ],
      ),
      floatingActionButton: _buildScrollToTopFab(productProvider),
      body: _buildBody(context, productProvider),
    );
  }

  Widget? _buildScrollToTopFab(ProductProvider productProvider) {
    if (!_showScrollToTop) {
      return null;
    }

    if (productProvider.isLoading || productProvider.errorMessage.isNotEmpty) {
      return null;
    }

    if (productProvider.products.isEmpty) {
      return null;
    }

    final List<Product> visibleProducts = _visibleProducts(productProvider.products);

    if (visibleProducts.isEmpty) {
      return null;
    }

    return FloatingActionButton.small(
      tooltip: 'Do góry',
      onPressed: () {
        HapticFeedback.lightImpact();
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 520),
          curve: Curves.easeOutCubic,
        );
      },
      child: const Icon(Icons.keyboard_arrow_up_rounded),
    );
  }

  Widget _buildBody(BuildContext context, ProductProvider productProvider) {
    if (productProvider.isLoading && productProvider.products.isEmpty) {
      return const Center(
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: ProductCatalogSkeleton(),
        ),
      );
    }

    if (productProvider.errorMessage.isNotEmpty) {
      return NetworkErrorState(
        message: productProvider.errorMessage,
        onRetry: () => productProvider.fetchAllProducts(),
      );
    }

    if (productProvider.products.isEmpty) {
      return const CatalogEmptyState();
    }

    final List<Product> visibleProducts = _visibleProducts(productProvider.products);
    final bool showSearchEmpty = visibleProducts.isEmpty && _filterLower.isNotEmpty;

    return Stack(
      alignment: Alignment.topCenter,
      children: [
        RefreshIndicator(
          color: AppColors.accent,
          onRefresh: () async {
            HapticFeedback.mediumImpact();
            await productProvider.fetchAllProducts();
          },
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              SliverToBoxAdapter(
                child: CatalogSearchBar(
                  controller: _searchController,
                  onTextChanged: _scheduleSearchRecompute,
                ),
              ),
              if (showSearchEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: CatalogNoSearchResults(
                    query: _searchController.text.trim(),
                    onClearQuery: _clearCatalogSearch,
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    PharosLayout.spaceSm,
                    0,
                    PharosLayout.spaceSm,
                    PharosLayout.spaceLg,
                  ),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: PharosLayout.spaceSm,
                      mainAxisSpacing: PharosLayout.spaceSm,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        final Product product = visibleProducts[index];

                        return ProductCard(product: product);
                      },
                      childCount: visibleProducts.length,
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (productProvider.isLoading && productProvider.products.isNotEmpty)
          const LinearProgressIndicator(minHeight: 2),
      ],
    );
  }
}

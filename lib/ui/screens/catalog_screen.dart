import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pharos/ui/widgets/search_filter_drawer.dart';
import 'package:pharos/core/providers/search_provider.dart';
import 'package:pharos/data/models/product_model.dart';
import 'package:pharos/data/repositories/product_repository.dart';
import 'package:pharos/ui/widgets/pharos_product_card.dart';
import 'package:pharos/ui/widgets/product_shimmer.dart';

class CatalogScreen extends StatefulWidget {
  final String title;
  final int? categoryId;

  const CatalogScreen({
    super.key, 
    this.title = 'Katalog produktów', 
    this.categoryId
  });

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late Future<List<ProductModel>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  void _loadProducts() {
    final filters = context.read<SearchProvider>().getSelectedFilters();
    _productsFuture = context.read<IProductRepository>().getProducts(
      categoryId: widget.categoryId,
      filters: filters,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      endDrawer: const SearchFilterDrawer(),
      appBar: AppBar(
        title: Text(widget.title.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
          ),
        ],
      ),
      body: Consumer<SearchProvider>(
        builder: (context, search, child) {
          return FutureBuilder<List<ProductModel>>(
            future: context.read<IProductRepository>().getProducts(
              categoryId: widget.categoryId,
              filters: search.getSelectedFilters(),
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const ProductShimmer();
              }

              if (snapshot.hasError) {
                return _buildErrorState();
              }

              final products = snapshot.data ?? [];

              if (products.isEmpty) {
                return _buildEmptyState();
              }

              return RefreshIndicator(
                onRefresh: () async {
                  setState(() {
                    _loadProducts();
                  });
                },
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.65,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    return PharosProductCard(product: products[index], heroTagPrefix: 'catalog');
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 80, color: Colors.white.withOpacity(0.1)),
          const SizedBox(height: 16),
          const Text('Brak produktów w tej kategorii', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 60, color: Colors.red),
          const SizedBox(height: 16),
          const Text('Nie udało się pobrać produktów'),
          TextButton(onPressed: () => setState(() => _loadProducts()), child: const Text('SPRÓBUJ PONOWNIE')),
        ],
      ),
    );
  }
}

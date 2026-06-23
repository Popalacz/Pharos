import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart' hide State;
import 'package:provider/provider.dart';
import 'package:pharos/ui/widgets/search_filter_drawer.dart';
import 'package:pharos/core/providers/search_provider.dart';
import 'package:pharos/data/models/product_model.dart';
import 'package:pharos/data/repositories/product_repository.dart';
import 'package:pharos/ui/widgets/pharos_product_card.dart';
import 'package:pharos/ui/widgets/product_shimmer.dart';
import 'package:pharos/core/error/failures.dart';
import 'package:pharos/ui/widgets/network_error_state.dart';
import 'package:pharos/ui/widgets/catalog_empty_state.dart';

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
  late Future<Either<Failure, List<ProductModel>>> _productsFuture;

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
          return FutureBuilder<Either<Failure, List<ProductModel>>>(
            future: context.read<IProductRepository>().getProducts(
              categoryId: widget.categoryId,
              filters: search.getSelectedFilters(),
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const ProductShimmer();
              }

              if (snapshot.hasError || !snapshot.hasData) {
                return _buildErrorState();
              }

              return snapshot.data!.fold(
                (failure) => _buildErrorState(message: failure.message),
                (products) {
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
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return const CatalogEmptyState();
  }

  Widget _buildErrorState({String? message}) {
    return NetworkErrorState(
      message: message ?? 'Nie udało się pobrać produktów.',
      onRetry: () => setState(() => _loadProducts()),
    );
  }
}

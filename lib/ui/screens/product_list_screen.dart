import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../widgets/product_card.dart';

class ProductListScreen extends StatelessWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pharos Store'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => productProvider.fetchAllProducts(),
          ),
        ],
      ),
      body: _buildBody(productProvider),
    );
  }

  Widget _buildBody(ProductProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.errorMessage.isNotEmpty) {
      return Center(child: Text(provider.errorMessage, style: const TextStyle(color: Colors.red)));
    }

    if (provider.products.isEmpty) {
      return const Center(child: Text('Brak produktów w Twojej Preście.'));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: provider.products.length,
      itemBuilder: (context, index) {
        final product = provider.products[index];

        return ProductCard(product: product);
      },
    );
  }
}
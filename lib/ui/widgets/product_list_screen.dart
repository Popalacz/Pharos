import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../../models/product_model.dart';

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
        return ProductCard(product: provider.products[index]);
      },
    );
  }
}

class ProductCard extends StatelessWidget {
  final Product product;
  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                image: product.idImage != null 
                  ? DecorationImage(
                      image: NetworkImage(product.imageUrl),
                      fit: BoxFit.cover,
                    )
                  : null,
              ),
              child: product.idImage == null 
                ? const Icon(Icons.image_not_supported) 
                : null,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1),
                Text('${product.price} PLN', style: const TextStyle(color: Colors.green)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
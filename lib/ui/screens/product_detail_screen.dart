import 'package:flutter/material.dart';
import '../../models/product_model.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
 
      appBar: AppBar(
        title: Text(product.name),
        backgroundColor: Colors.white.withOpacity(0.9),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: 'product_image_${product.id}',
              child: _buildDetailImage(),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          style: const TextStyle(
                            fontSize: 26, 
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${product.price} PLN',
                    style: const TextStyle(
                      fontSize: 24, 
                      color: Colors.green, 
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const Divider(height: 40),
                  const Text(
                    "Opis produktu",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    product.description ?? "Ten produkt nie posiada jeszcze opisu w systemie PrestaShop.",
                    style: const TextStyle(
                      fontSize: 16, 
                      color: Colors.black87,
                      height: 1.5, 
                    ),
                  ),
                  const SizedBox(height: 100), 
                ],
              ),
            ),
          ],
        ),
      ),
   
      bottomSheet: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(0, -4),
              blurRadius: 10,
            ),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 55),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Dodano ${product.name} do koszyka!'),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shopping_cart_checkout),
                SizedBox(width: 12),
                Text("DODAJ DO KOSZYKA", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailImage() {
    if (!product.hasImageUrl) {
      return Container(
        width: double.infinity,
        height: 400,
        color: Colors.grey[200],
        child: const Icon(Icons.image_not_supported, size: 100),
      );
    }

    return CachedNetworkImage(
      imageUrl: product.imageUrl,
      width: double.infinity,
      height: 400,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        height: 400,
        color: Colors.grey[200],
        child: const Center(child: CircularProgressIndicator()),
      ),
      errorWidget: (context, url, error) => Container(
        height: 400,
        color: Colors.grey[200],
        child: const Icon(Icons.error, size: 100, color: Colors.red),
      ),
    );
  }
}
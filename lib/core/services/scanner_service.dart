import 'package:flutter/material.dart';
import 'package:pharos/data/repositories/product_repository.dart';
import 'package:pharos/ui/screens/product_details_screen.dart';

class ScannerService {
  static Future<void> handleBarcode(BuildContext context, String code) async {
    // Symulacja szukania produktu po kodzie EAN w PrestaShop
    debugPrint('Skanowanie kodu: $code');
    
    // W prawdziwej wersji: 
    // final product = await ProductRepository().getProductByEan(code);
    
    // Dla testów bierzemy pierwszy produkt z repo
    final products = await ProductRepository(useMockData: true).getProducts();
    if (products.isNotEmpty) {
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ProductDetailsScreen(product: products.first)),
        );
      }
    }
  }
}

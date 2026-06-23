import 'package:flutter/material.dart';
import 'package:pharos/data/repositories/product_repository.dart';
import 'package:pharos/ui/screens/product_details_screen.dart';

import 'package:pharos/core/network/api_service.dart';
import 'package:provider/provider.dart';

class ScannerService {
  static Future<void> handleBarcode(BuildContext context, String code) async {
    // ...
    final apiService = context.read<ApiService>();
    final result = await ProductRepository(apiService: apiService, useMockData: true).getProducts();
    
    result.fold(
      (failure) => debugPrint('Scanner Search Failure: $failure'),
      (products) {
        if (products.isNotEmpty) {
          if (context.mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ProductDetailsScreen(product: products.first)),
            );
          }
        }
      },
    );
  }
}

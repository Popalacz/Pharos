import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:pharos/main.dart';
import 'package:pharos/data/repositories/product_repository.dart';
import 'package:pharos/data/models/product_model.dart';
import 'package:pharos/ui/screens/product_details_screen.dart';
import 'package:provider/provider.dart';

class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();
  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;

  factory DeepLinkService() => _instance;
  DeepLinkService._internal();

  void initialize(BuildContext context) {
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      _handleDeepLink(uri, context);
    });

    // Check for initial link
    _appLinks.getInitialLink().then((uri) {
      if (uri != null) _handleDeepLink(uri, context);
    });
  }

  void _handleDeepLink(Uri uri, BuildContext context) async {
    debugPrint('Deep Link received: $uri');

    if (uri.host == 'payment' || uri.pathSegments.contains('payment')) {
      await handlePaymentReturn(uri: uri);
      return;
    }
    
    // Example: pharos://product/123 or https://pharos-api.tech/product/123
    if (uri.pathSegments.contains('product')) {
      final productIdStr = uri.pathSegments.last;
      final productId = int.tryParse(productIdStr);
      
      if (productId != null) {
        final repository = context.read<IProductRepository>();
        final result = await repository.getProductDetails(productId);
        
        result.fold(
          (failure) => debugPrint('Deep Link Error: $failure'),
          (ProductModel product) {
            navigatorKey.currentState?.push(
              MaterialPageRoute(builder: (_) => ProductDetailsScreen(product: product)),
            );
          },
        );
      }
    }
  }

  Future<void> handlePaymentReturn({required Uri uri}) async {
    debugPrint('Payment deep link: $uri');
    final status = uri.queryParameters['status'] ?? 'unknown';
    final orderReference = uri.queryParameters['order'] ?? '';
    debugPrint('BLIK payment status=$status order=$orderReference');
  }

  void dispose() {
    _linkSubscription?.cancel();
  }
}

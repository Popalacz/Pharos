import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app/pharos_app.dart';
import 'providers/cart_stub_provider.dart';
import 'providers/product_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ProductProvider>(
          create: (_) => ProductProvider(),
        ),
        ChangeNotifierProvider<CartStubProvider>(
          create: (_) => CartStubProvider(),
        ),
      ],
      child: const PharosApp(),
    ),
  );
}

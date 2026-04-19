import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/product_provider.dart';
import 'ui/screens/product_list_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ProductProvider()..fetchAllProducts(),
      child: const PharosApp(),
    ),
  );
}

class PharosApp extends StatelessWidget {
  const PharosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pharos E-commerce',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.light,
      ),
      home: const ProductListScreen(),
    );
  }
}
import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../ui/screens/product_list_screen.dart';

class PharosApp extends StatelessWidget {
  const PharosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pharos',
      theme: AppTheme.dark,
      home: const ProductListScreen(),
    );
  }
}

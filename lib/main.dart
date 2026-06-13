import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../ui/screens/calendar_test_screen.dart';

void main() {
  runApp(const PharosApp());
}

class PharosApp extends StatelessWidget {
  const PharosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pharos',
      theme: AppTheme.dark,
      home: const CalendarTestScreen(),
    );
  }
}
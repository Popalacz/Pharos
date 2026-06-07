import 'package:flutter/material.dart';
import 'package:pharos/ui/screens/calendar_test_screen.dart'; // Import nowego ekranu UI

class PharosApp extends StatelessWidget {
  const PharosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pharos App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.orange,
        useMaterial3: true,
      ),
      home: const CalendarTestScreen(), // Podpięcie ekranu jako domyślnego
    );
  }
}
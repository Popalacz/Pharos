import 'package:flutter/material.dart';
// 1. Dodaj import do nowo stworzonego widoku kalendarza:
import 'ui/screens/calendar_test_screen.dart'; 

class PharosApp extends StatelessWidget {
  const PharosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pharos App',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: const CalendarTestScreen(), 
    );
  }
}
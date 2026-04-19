import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'dart:convert';

void main() {
  runApp(const PharosApp());
}

class PharosApp extends StatelessWidget {
  const PharosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pharos E-commerce',
      theme: ThemeData(primarySwatch: Colors.indigo, useMaterial3: true),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _message = "Czekam na dane z PrestaShop...";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _connectToPresta();
  }

  Future<void> _connectToPresta() async {
    final dio = Dio();
    
    const String apiKey = 'NVDCB76VU3UTJFY5GMXPFE7RGIFZ8LNS'; // <--- WKLEJ TUTAJ SWÓJ KLUCZ!
    const String url = 'http://localhost:8111/api/products';
    
    final String auth = 'Basic ${base64Encode(utf8.encode('$apiKey:'))}';

    try {
      final response = await dio.get(
        url,
        queryParameters: {'output_format': 'JSON', 'display': 'full'},
        options: Options(headers: {'Authorization': auth}),
      );

      final products = response.data['products'];

      setState(() {
        if (products != null && products is List) {
          _message = "Sukces! Pharos połączył się z Prestą.\nZnaleziono produktów: ${products.length}";
        } else {
          _message = "Połączono, ale brak produktów w bazie.";
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _message = "Błąd połączenia: $e";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pharos E-commerce Engine')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: _isLoading 
            ? const CircularProgressIndicator() 
            : Text(_message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18)),
        ),
      ),
    );
  }
}
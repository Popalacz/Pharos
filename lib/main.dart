import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pharos/data/repositories/product_repository.dart';
import 'package:pharos/core/providers/cart_provider.dart';
import 'package:pharos/core/providers/user_provider.dart';
import 'package:pharos/core/providers/settings_provider.dart';
import 'package:pharos/core/theme/app_theme.dart';
import 'package:pharos/ui/screens/home_screen.dart';
import 'package:pharos/ui/screens/profile_screen.dart';
import 'package:pharos/ui/screens/cart_screen.dart';
import 'package:pharos/ui/screens/wishlist_screen.dart';
import 'package:pharos/core/providers/wishlist_provider.dart';
import 'package:pharos/core/providers/search_provider.dart';

import 'package:pharos/core/services/notification_service.dart';

import 'package:pharos/core/providers/localization_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Zapobieganie migotaniu przy ładowaniu ustawień
  final settingsProvider = SettingsProvider();
  
  // Globalna obsługa błędów (Senior Standard)
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint('GLOBAL ERROR: ${details.exception}');
  };

  // Inicjalizacja Powiadomień Push
  try {
    await NotificationService().initialize();
  } catch (e) {
    debugPrint('FCM Init Error: $e');
  }
  
  runApp(
    MultiProvider(
      providers: [
        Provider<IProductRepository>(
          create: (_) => ProductRepository(useMockData: true),
        ),
        ChangeNotifierProvider.value(value: settingsProvider),
        ChangeNotifierProvider(create: (_) => LocalizationProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => WishlistProvider()),
        ChangeNotifierProvider(
          create: (context) => SearchProvider(context.read<IProductRepository>()),
        ),
      ],
      child: const PharosApp(),
    ),
  );
}

class PharosApp extends StatelessWidget {
  const PharosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: settingsProvider.settings.storeName,
          theme: AppTheme.dark,
          home: const MainNavigation(),
        );
      },
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;
  
  final List<Widget> _screens = [
    const HomeScreen(),
    const WishlistScreen(),
    const CartScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          selectedItemColor: Colors.orange,
          unselectedItemColor: Colors.grey,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Sklep'),
            BottomNavigationBarItem(icon: Icon(Icons.favorite_outline), activeIcon: Icon(Icons.favorite), label: 'Ulubione'),
            BottomNavigationBarItem(icon: Icon(Icons.shopping_bag_outlined), activeIcon: Icon(Icons.shopping_bag), label: 'Koszyk'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profil'),
          ],
        ),
      ),
    );
  }
}

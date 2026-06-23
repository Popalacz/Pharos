import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pharos/data/repositories/product_repository.dart';
import 'package:pharos/data/repositories/category_repository.dart';
import 'package:pharos/data/repositories/system_repository.dart';
import 'package:pharos/core/providers/cart_provider.dart';
import 'package:pharos/core/providers/user_provider.dart';
import 'package:pharos/core/providers/settings_provider.dart';
import 'package:pharos/core/theme/app_theme.dart';
import 'package:pharos/ui/screens/home_screen.dart';
import 'package:pharos/ui/screens/profile_screen.dart';
import 'package:pharos/ui/screens/cart_screen.dart';
import 'package:pharos/ui/screens/wishlist_screen.dart';
import 'package:pharos/core/providers/wishlist_provider.dart';
import 'package:pharos/core/providers/recently_viewed_provider.dart';
import 'package:pharos/core/providers/search_provider.dart';
import 'package:pharos/core/services/notification_service.dart';
import 'package:pharos/core/providers/localization_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:pharos/core/api/api_config.dart';
import 'package:pharos/core/network/api_service.dart';
import 'package:pharos/data/repositories/cart_repository.dart';
import 'package:pharos/data/repositories/user_repository.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  if (kDebugMode) {
    HttpOverrides.global = MyHttpOverrides();
  }
  
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase Init Error: $e');
  }
  
  // Singleton / Shared instance
  final apiService = ApiService();
  final settingsProvider = SettingsProvider(apiService: apiService);
  
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
  };

  // Uruchamiamy usługi w tle, aby nie blokować startu UI
  NotificationService().initialize();
  
  runApp(
    MultiProvider(
      providers: [
        Provider<ApiService>.value(value: apiService),
        ChangeNotifierProvider.value(value: settingsProvider),
        Provider<ISystemRepository>(
          create: (_) => SystemRepository(apiService: apiService),
        ),
        ProxyProvider<SettingsProvider, IProductRepository>(
          update: (_, settings, __) => ProductRepository(
            apiService: apiService,
            useMockData: ApiConfig.forceMockData || settings.settings.useMockData
          ),
        ),
        Provider<ICategoryRepository>(
          create: (_) => CategoryRepository(apiService: apiService),
        ),
        ChangeNotifierProvider(create: (_) => LocalizationProvider()),
        ChangeNotifierProvider(
          create: (_) => UserProvider(
            apiService: apiService,
            repository: UserRepository(
              apiService: apiService,
              useMockData: ApiConfig.forceMockData
            )
          )
        ),
        ChangeNotifierProxyProvider<UserProvider, CartProvider>(
          create: (_) => CartProvider(
            repository: CartRepository(
              apiService: apiService,
              useMockData: ApiConfig.forceMockData
            )
          ),
          update: (_, user, cart) => cart!..updateUser(user),
        ),
        ChangeNotifierProxyProvider<UserProvider, WishlistProvider>(
          create: (_) => WishlistProvider(apiService: apiService),
          update: (_, user, wishlist) => wishlist!..updateUser(user),
        ),
        ChangeNotifierProvider(create: (_) => RecentlyViewedProvider()),
        ChangeNotifierProvider(
          create: (context) => SearchProvider(context.read<IProductRepository>()),
        ),
      ],
      child: const PharosApp(),
    ),
  );
}


final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class PharosApp extends StatelessWidget {
  const PharosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        if (settingsProvider.settings.appDebug) {
          ErrorWidget.builder = (details) => Scaffold(
            body: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'DEBUG ERROR:\n\n${details.exception}\n\nSTACK:\n${details.stack}',
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
            ),
          );
        } else {
          ErrorWidget.builder = (details) => const Scaffold(
            body: Center(child: Text('Wystąpił nieoczekiwany błąd. Spróbuj ponownie później.')),
          );
        }

        return MaterialApp(
          navigatorKey: navigatorKey,
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

class _MainNavigationState extends State<MainNavigation> with WidgetsBindingObserver {
  int _selectedIndex = 0;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<IProductRepository>().getProducts();
      final userProvider = context.read<UserProvider>();
      if (userProvider.isLoggedIn) {
        context.read<WishlistProvider>().fetchWishlist();
        userProvider.fetchAddresses();
      }
    }
  }

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

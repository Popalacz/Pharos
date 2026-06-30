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
import 'package:pharos/ui/screens/contact_screen.dart';
import 'package:pharos/core/providers/wishlist_provider.dart';
import 'package:add_to_cart_animation/add_to_cart_animation.dart';
import 'package:pharos/core/providers/recently_viewed_provider.dart';
import 'package:pharos/core/providers/search_provider.dart';
import 'package:pharos/core/providers/ui_feedback_provider.dart';
import 'package:pharos/core/services/notification_service.dart';
import 'package:pharos/core/services/deeplink/deeplink_service.dart';
import 'package:pharos/core/providers/localization_provider.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:pharos/core/api/api_config.dart';
import 'package:pharos/core/network/api_service.dart';
import 'package:pharos/data/repositories/cart_repository.dart';
import 'package:pharos/data/repositories/user_repository.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:version/version.dart' as v;
import 'package:url_launcher/url_launcher.dart';

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
  
  final apiService = ApiService();
  final settingsProvider = SettingsProvider(apiService: apiService);
  
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    FirebaseCrashlytics.instance.recordFlutterError(details);
  };

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
            ),
            apiService: apiService,
          ),
          update: (_, user, cart) => cart!..updateUser(user),
        ),
        ChangeNotifierProxyProvider<UserProvider, WishlistProvider>(
          create: (_) => WishlistProvider(apiService: apiService),
          update: (_, user, wishlist) => wishlist!..updateUser(user),
        ),
        ChangeNotifierProvider(create: (_) => RecentlyViewedProvider()),
        ChangeNotifierProvider(create: (_) => UiFeedbackProvider()),
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
          home: const UpdateCheckWrapper(child: MainNavigation()),
        );
      },
    );
  }
}

class UpdateCheckWrapper extends StatefulWidget {
  final Widget child;
  const UpdateCheckWrapper({super.key, required this.child});

  @override
  State<UpdateCheckWrapper> createState() => _UpdateCheckWrapperState();
}

class _UpdateCheckWrapperState extends State<UpdateCheckWrapper> {
  bool _isChecking = true;
  bool _needsUpdate = false;
  bool _isMaintenance = false;

  @override
  void initState() {
    super.initState();
    _performChecks();
  }

  Future<void> _performChecks() async {
    final settings = context.read<SettingsProvider>().settings;
    
    // 1. Check Maintenance Mode
    if (settings.maintenanceMode) {
      setState(() {
        _isMaintenance = true;
        _isChecking = false;
      });
      return;
    }

    // 2. Check Force Update
    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = v.Version.parse(packageInfo.version);
      final minVersion = v.Version.parse(settings.forceUpdateVersion);

      if (currentVersion < minVersion) {
        setState(() {
          _needsUpdate = true;
          _isChecking = false;
        });
        return;
      }
    } catch (e) {
      debugPrint('Update check error: $e');
    }

    setState(() => _isChecking = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_isMaintenance) {
      return _buildMaintenanceScreen();
    }

    if (_needsUpdate) {
      return _buildUpdateScreen();
    }

    return widget.child;
  }

  Widget _buildMaintenanceScreen() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.settings_suggest_rounded, size: 80, color: Colors.orange),
              const SizedBox(height: 24),
              const Text('PRZERWA TECHNICZNA', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 2)),
              const SizedBox(height: 16),
              const Text(
                'Właśnie ulepszamy nasz sklep, aby zakupy były jeszcze przyjemniejsze. Wróć do nas za chwilę!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white60, height: 1.5),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _performChecks,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                child: const Text('SPRAWDŹ PONOWNIE', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUpdateScreen() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.system_update_rounded, size: 80, color: Colors.blue),
              const SizedBox(height: 24),
              const Text('WYMAGANA AKTUALIZACJA', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
              const SizedBox(height: 16),
              const Text(
                'Twoja wersja aplikacji jest nieaktualna. Aby kontynuować zakupy, pobierz najnowszą wersję z oficjalnego sklepu.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white60, height: 1.5),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => launchUrl(Uri.parse('https://pharos.pl/app')),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  child: const Text('POBIERZ AKTUALIZACJĘ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
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
  GlobalKey<CartIconKey> cartKey = GlobalKey<CartIconKey>();
  late Function(GlobalKey) runAddToCartAnimation;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    DeepLinkService().initialize(context);
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
    const ContactScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocalizationProvider>();
    
    return AddToCartAnimation(
      cartKey: cartKey,
      height: 30, width: 30,
      opacity: 0.85,
      dragAnimation: const DragToCartAnimationOptions(rotation: true),
      jumpAnimation: const JumpAnimationOptions(),
      createAddToCartAnimation: (runAnimation) {
        runAddToCartAnimation = runAnimation;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.read<UiFeedbackProvider>().setAddToCartAnimation(runAnimation);
        });
      },
      child: Scaffold(
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
            items: [
              BottomNavigationBarItem(icon: const Icon(Icons.home_outlined), activeIcon: const Icon(Icons.home), label: loc.translate('home')),
              BottomNavigationBarItem(icon: const Icon(Icons.favorite_outline), activeIcon: const Icon(Icons.favorite), label: loc.translate('wishlist')),
              BottomNavigationBarItem(
                icon: AddToCartIcon(
                  key: cartKey,
                  icon: const Icon(Icons.shopping_bag_outlined),
                  badgeOptions: const BadgeOptions(active: false),
                ),
                activeIcon: const Icon(Icons.shopping_bag),
                label: loc.translate('cart')
              ),
              BottomNavigationBarItem(icon: const Icon(Icons.contact_support_outlined), activeIcon: const Icon(Icons.contact_support), label: loc.translate('contact')),
              BottomNavigationBarItem(icon: const Icon(Icons.person_outline), activeIcon: const Icon(Icons.person), label: loc.translate('account')),
            ],
          ),
        ),
      ),
    );
  }
}

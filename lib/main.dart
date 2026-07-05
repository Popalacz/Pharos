import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
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
import 'package:pharos/core/providers/orders_provider.dart';
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
import 'package:pharos/data/repositories/order_repository.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:version/version.dart' as v;
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:pharos/core/config/google_config.dart';
import 'package:pharos/l10n/app_localizations.dart';

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
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
    if (!GoogleConfig.hasServerClientId) {
      debugPrint(
        'Google Sign-In: brak GOOGLE_SERVER_CLIENT_ID. '
        'Dodaj SHA-1 w Firebase, pobierz google-services.json '
        'i uruchom z --dart-define=GOOGLE_SERVER_CLIENT_ID=...',
      );
    }
  } catch (e) {
    debugPrint('Firebase Init Error: $e');
  }

  final apiService = ApiService();
  final settingsProvider = SettingsProvider(apiService: apiService);

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  FirebaseAnalytics.instance.logAppOpen();

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
        ChangeNotifierProvider(create: (_) => LocalizationProvider(apiService: apiService)),
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
        ChangeNotifierProxyProvider<UserProvider, OrdersProvider>(
          create: (_) => OrdersProvider(
            repository: OrderRepository(apiService: apiService),
          ),
          update: (_, user, orders) => orders!..updateUser(user),
        ),
        ChangeNotifierProvider(create: (_) => RecentlyViewedProvider()),
        ChangeNotifierProvider(create: (_) => UiFeedbackProvider()),
        ChangeNotifierProvider(
          create: (context) => SearchProvider(
            context.read<IProductRepository>(),
            categoryRepository: context.read<ICategoryRepository>(),
          ),
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
    return Consumer2<SettingsProvider, LocalizationProvider>(
      builder: (context, settingsProvider, localizationProvider, child) {
        final l10n = AppLocalizations.of(context);

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
          ErrorWidget.builder = (details) => Scaffold(
            body: Center(child: Text(l10n?.unexpectedError ?? 'Unexpected error')),
          );
        }

        return MaterialApp(
          navigatorKey: navigatorKey,
          debugShowCheckedModeBanner: false,
          title: settingsProvider.settings.storeName,
          theme: AppTheme.dark,
          locale: localizationProvider.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
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
    final l10n = AppLocalizations.of(context)!;

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
              Text(
                l10n.maintenanceTitle,
                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 2),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.maintenanceMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white60, height: 1.5),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _performChecks,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                child: Text(l10n.checkAgain, style: const TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUpdateScreen() {
    final l10n = AppLocalizations.of(context)!;

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
              Text(
                l10n.updateRequiredTitle,
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1.5),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.updateRequiredMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white60, height: 1.5),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => launchUrl(Uri.parse('https://pharos.pl/app')),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  child: Text(l10n.downloadUpdate, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncNotificationLanguage());
  }

  Future<void> _syncNotificationLanguage() async {
    if (!mounted) return;
    final localizationProvider = context.read<LocalizationProvider>();
    final userProvider = context.read<UserProvider>();
    await NotificationService().resyncCurrentToken(
      customerId: userProvider.isLoggedIn ? userProvider.user?.id : null,
      languageId: localizationProvider.currentLanguage?.id,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  static const int profileTabIndex = 4;

  void _refreshOrdersIfLoggedIn() {
    if (!mounted) return;
    final userProvider = context.read<UserProvider>();
    if (userProvider.isLoggedIn) {
      context.read<OrdersProvider>().fetchOrders();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<IProductRepository>().getProducts();
      final userProvider = context.read<UserProvider>();
      if (userProvider.isLoggedIn) {
        context.read<WishlistProvider>().fetchWishlist();
        userProvider.fetchAddresses();
        context.read<OrdersProvider>().fetchOrders();
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
    final l10n = AppLocalizations.of(context)!;
    
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
            onTap: (index) {
              setState(() => _selectedIndex = index);
              if (index == profileTabIndex) {
                _refreshOrdersIfLoggedIn();
              }
            },
            selectedItemColor: Colors.orange,
            unselectedItemColor: Colors.grey,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            elevation: 0,
            items: [
              BottomNavigationBarItem(icon: const Icon(Icons.home_outlined), activeIcon: const Icon(Icons.home), label: l10n.home),
              BottomNavigationBarItem(icon: const Icon(Icons.favorite_outline), activeIcon: const Icon(Icons.favorite), label: l10n.wishlist),
              BottomNavigationBarItem(
                icon: AddToCartIcon(
                  key: cartKey,
                  icon: const Icon(Icons.shopping_bag_outlined),
                  badgeOptions: const BadgeOptions(active: false),
                ),
                activeIcon: const Icon(Icons.shopping_bag),
                label: l10n.cart
              ),
              BottomNavigationBarItem(icon: const Icon(Icons.contact_support_outlined), activeIcon: const Icon(Icons.contact_support), label: l10n.contact),
              BottomNavigationBarItem(icon: const Icon(Icons.person_outline), activeIcon: const Icon(Icons.person), label: l10n.account),
            ],
          ),
        ),
      ),
    );
  }
}

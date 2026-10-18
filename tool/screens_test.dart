// Renderuje pelne ekrany checkoutu (390x844 @2x) z prawdziwego CheckoutScreen na danych mock.
// Wymaga lokalnie ApiConfig.forceMockData = true. Uruchom: SHOT_OUT=inzynierka/images flutter test tool/screens_test.dart
// To nie jest zrzut z urzadzenia ani test aplikacji.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pharos/core/network/api_service.dart';
import 'package:pharos/core/providers/cart_provider.dart';
import 'package:pharos/core/providers/localization_provider.dart';
import 'package:pharos/core/providers/user_provider.dart';
import 'package:pharos/core/theme/app_theme.dart';
import 'package:pharos/data/models/product_model.dart';
import 'package:pharos/data/repositories/cart_repository.dart';
import 'package:pharos/data/repositories/user_repository.dart';
import 'package:pharos/l10n/app_localizations.dart';
import 'package:pharos/ui/screens/checkout/checkout_variant.dart';
import 'package:pharos/ui/screens/checkout_screen.dart';
import 'package:provider/provider.dart';

final _out = Platform.environment['SHOT_OUT'] ?? 'out';
const _fonts = '/home/patka/flutter/bin/cache/artifacts/material_fonts';

Future<void> _loadFonts() async {
  Future<ByteData> read(String n) async => ByteData.sublistView(await File('$_fonts/$n').readAsBytes());
  await (FontLoader('Roboto')
        ..addFont(read('Roboto-Regular.ttf'))
        ..addFont(read('Roboto-Medium.ttf'))
        ..addFont(read('Roboto-Bold.ttf')))
      .load();
  await (FontLoader('MaterialIcons')..addFont(read('MaterialIcons-Regular.otf'))).load();
}

final _key = GlobalKey();

Future<void> _snap(WidgetTester t, String name) async {
  await t.runAsync(() async {
    final b = _key.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final img = await b.toImage(pixelRatio: 2);
    final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
    await File('$_out/$name.png').writeAsBytes(bytes!.buffer.asUint8List());
  });
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(_loadFonts);

  Future<void> pump(WidgetTester t, CheckoutVariant v, {double h = 844}) async {
    t.view.physicalSize = Size(780, h * 2);
    t.view.devicePixelRatio = 2;
    addTearDown(t.view.reset);
    final api = ApiService();
    final cart = CartProvider(repository: CartRepository(apiService: api, useMockData: true), apiService: api);
    cart.addItem(const ProductModel(id: 1, name: 'Zegarek Pharos Classic', price: 249.0, stockQuantity: 10, allowOutOfStockOrders: true));
    final user = UserProvider(apiService: api, repository: UserRepository(apiService: api, useMockData: true));
    await t.pumpWidget(MultiProvider(
      providers: [
        Provider<ApiService>.value(value: api),
        ChangeNotifierProvider.value(value: cart),
        ChangeNotifierProvider.value(value: user),
        ChangeNotifierProvider(create: (_) => LocalizationProvider(apiService: api)),
      ],
      child: RepaintBoundary(
        key: _key,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.dark.copyWith(textTheme: AppTheme.dark.textTheme.apply(fontFamily: 'Roboto')),
          locale: const Locale('pl'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: CheckoutScreen(variant: v),
        ),
      ),
    ));
    await t.runAsync(() => Future.delayed(const Duration(seconds: 1)));
    await t.pump(const Duration(seconds: 1));
  }

  for (final v in CheckoutVariant.values) {
    testWidgets('checkout ${v.name}', (t) async {
      await pump(t, v);
      await _snap(t, 'checkout-${v.name}-1-pusty');
      await t.tap(find.byWidgetPredicate((w) => w is Text && (w.data ?? '').toLowerCase().contains('uzupełnij')).last);
      await t.pump(const Duration(milliseconds: 600)); await t.pump(const Duration(seconds: 2));
      await _snap(t, 'checkout-${v.name}-2-bledy');
    });
    testWidgets('checkout ${v.name} wysoki', (t) async {
      await pump(t, v, h: 1500);
      await t.tap(find.byWidgetPredicate((w) => w is Text && (w.data ?? '').toLowerCase().contains('uzupełnij')).last);
      await t.pump(const Duration(milliseconds: 600)); await t.pump(const Duration(seconds: 2));
      await _snap(t, 'checkout-${v.name}-3-caly-formularz');
    });
  }
}

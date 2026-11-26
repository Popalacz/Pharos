// Simulates guest checkout on two phone sizes (Pixel 7, iPhone 13) for both checkout variants.
// Drives the real CheckoutScreen on mock data, counts the user's actions and saves screenshots and a JSON summary.
// Requires locally ApiConfig.forceMockData = true.
// Run: SHOT_OUT=out FLUTTER_FONTS=<flutter>/bin/cache/artifacts/material_fonts flutter test tool/phones_test.dart
// This is a widget-test simulation, not a recording from a device.
import 'dart:convert';
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

final String _outputDirectory = Platform.environment['SHOT_OUT'] ?? 'out';
final String _fontsDirectory = Platform.environment['FLUTTER_FONTS'] ?? '';

class _Phone {
  const _Phone(this.name, this.width, this.height);

  final String name;
  final double width;
  final double height;
}

const List<_Phone> _phones = [
  _Phone('pixel7', 412, 915),
  _Phone('iphone13', 390, 844),
];

const List<String> _guestValues = [
  'jan.testowy@example.com',
  'Jan',
  'Testowy',
  'Testowa 1',
  '30-001',
  'Kraków',
  '500100200',
];

final GlobalKey _repaintKey = GlobalKey();
final List<Map<String, Object>> _results = [];

Future<void> _loadFonts() async {
  Future<ByteData> read(String name) async => ByteData.sublistView(await File('$_fontsDirectory/$name').readAsBytes());

  await (FontLoader('Roboto')
        ..addFont(read('Roboto-Regular.ttf'))
        ..addFont(read('Roboto-Medium.ttf'))
        ..addFont(read('Roboto-Bold.ttf')))
      .load();
  await (FontLoader('MaterialIcons')..addFont(read('MaterialIcons-Regular.otf'))).load();
}

Future<void> _snapshot(WidgetTester tester, String name) async {
  await tester.runAsync(() async {
    final boundary = _repaintKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 2);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);

    await File('$_outputDirectory/$name.png').writeAsBytes(bytes!.buffer.asUint8List());
  });
}

Future<void> _settle(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 600));
  await tester.pump(const Duration(seconds: 1));
}

Future<void> _pumpCheckout(WidgetTester tester, _Phone phone, CheckoutVariant variant) async {
  tester.view.physicalSize = Size(phone.width * 2, phone.height * 2);
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);

  final api = ApiService();
  final cart = CartProvider(repository: CartRepository(apiService: api, useMockData: true), apiService: api);
  cart.addItem(const ProductModel(id: 1, name: 'Zegarek Pharos Classic', price: 249.0, stockQuantity: 10, allowOutOfStockOrders: true));
  final user = UserProvider(apiService: api, repository: UserRepository(apiService: api, useMockData: true));

  await tester.pumpWidget(MultiProvider(
    providers: [
      Provider<ApiService>.value(value: api),
      ChangeNotifierProvider.value(value: cart),
      ChangeNotifierProvider.value(value: user),
      ChangeNotifierProvider(create: (_) => LocalizationProvider(apiService: api)),
    ],
    child: RepaintBoundary(
      key: _repaintKey,
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
        home: CheckoutScreen(variant: variant),
      ),
    ),
  ));

  await tester.runAsync(() => Future.delayed(const Duration(seconds: 1)));
  await tester.pump(const Duration(seconds: 1));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(_loadFonts);
  tearDownAll(() async {
    await File('$_outputDirectory/summary.json').writeAsString(const JsonEncoder.withIndent('  ').convert(_results));
  });

  for (final phone in _phones) {
    for (final variant in CheckoutVariant.values) {
      testWidgets('guest checkout ${variant.name} on ${phone.name}', (tester) async {
        Directory(_outputDirectory).createSync(recursive: true);
        await _pumpCheckout(tester, phone, variant);

        int taps = 0;
        int typedCharacters = 0;
        int screens = 1;
        final prefix = '${phone.name}-${variant.name}';

        Future<void> tapText(String text) async {
          final finder = find.textContaining(text).last;
          await tester.ensureVisible(finder);
          await tester.tap(finder);
          taps++;
          await _settle(tester);
        }

        await _snapshot(tester, '$prefix-1-start');

        final fields = find.byType(TextFormField);
        expect(fields, findsNWidgets(_guestValues.length));

        for (int index = 0; index < _guestValues.length; index++) {
          await tester.ensureVisible(fields.at(index));
          await tester.tap(fields.at(index));
          taps++;
          await tester.enterText(fields.at(index), _guestValues[index]);
          typedCharacters += _guestValues[index].length;
          await tester.pump(const Duration(milliseconds: 200));
        }

        await _snapshot(tester, '$prefix-2-form-filled');

        if (variant == CheckoutVariant.stepped) {
          await tapText('DALEJ: DOSTAWA');
          screens++;
          await _snapshot(tester, '$prefix-3-delivery');
          await tapText('Google Express');
          await tapText('DALEJ: PŁATNOŚĆ');
          screens++;
          await _snapshot(tester, '$prefix-4-payment');
          await tapText('BLIK');
        } else {
          await tapText('Google Express');
          await tapText('BLIK');
        }

        expect(find.textContaining('ZAMAWIAM I PŁACĘ'), findsOneWidget);
        await _snapshot(tester, '$prefix-5-ready-to-order');

        _results.add({
          'phone': phone.name,
          'viewport': '${phone.width.toInt()}x${phone.height.toInt()}',
          'variant': variant.code,
          'screens': screens,
          'fields': _guestValues.length,
          'taps': taps,
          'typedCharacters': typedCharacters,
          'finalButtonShown': true,
        });
      });
    }
  }
}

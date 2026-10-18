// Generuje PNG widżetów checkoutu z prawdziwego kodu (motyw ciemny Pharos).
// Uruchom: flutter test tool/render_screens_test.dart
// Wynik: inzynierka/images/render-*.png. To nie test aplikacji i nie jest częścią `flutter test`.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pharos/core/theme/app_colors.dart';
import 'package:pharos/core/theme/app_theme.dart';
import 'package:pharos/ui/screens/checkout/checkout_guest_form.dart';
import 'package:pharos/ui/screens/checkout/checkout_step_indicator.dart';

const _out = 'inzynierka/images';
const _fonts = '/home/patka/flutter/bin/cache/artifacts/material_fonts';

Future<void> _loadFonts() async {
  final dir = Directory(Platform.environment['FLUTTER_FONTS'] ?? _fonts);
  Future<ByteData> read(String n) async =>
      ByteData.sublistView(await File('${dir.path}/$n').readAsBytes());

  final roboto = FontLoader('Roboto')
    ..addFont(read('Roboto-Regular.ttf'))
    ..addFont(read('Roboto-Medium.ttf'))
    ..addFont(read('Roboto-Bold.ttf'));
  await roboto.load();

  final icons = FontLoader('MaterialIcons')..addFont(read('MaterialIcons-Regular.otf'));
  await icons.load();
}

Future<void> _shot(WidgetTester tester, String name, Widget child, {double w = 390, double h = 420, VoidCallback? after}) async {
  final key = GlobalKey();
  tester.view.physicalSize = Size(w * 2, h * 2);
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(RepaintBoundary(
    key: key,
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark.copyWith(
        textTheme: AppTheme.dark.textTheme.apply(fontFamily: 'Roboto'),
      ),
      home: Scaffold(
        backgroundColor: AppColors.background,
        body: SingleChildScrollView(child: Padding(padding: const EdgeInsets.all(16), child: child)),
      ),
    ),
  ));
  after?.call();
  await tester.pumpAndSettle();

  await tester.runAsync(() async {
    final boundary = key.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 2);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    await File('$_out/$name.png').writeAsBytes(bytes!.buffer.asUint8List());
  });
}

Widget _steps(int current, List<bool> done) => CheckoutStepIndicator(
      labels: const ['Adres', 'Dostawa', 'Płatność'],
      completed: done,
      currentIndex: current,
    );

Widget _form(GuestFormController c, GlobalKey<FormState> k) => CheckoutGuestForm(
      formKey: k,
      controller: c,
      createAccount: false,
      onCreateAccountChanged: (_) {},
      onFieldChanged: () {},
      onAddressChanged: (_) {},
    );

void main() {
  setUpAll(_loadFonts);

  testWidgets('render', (tester) async {
    await _shot(tester, 'render-pasek-krok1', _steps(0, [false, false, false]), h: 120);
    await _shot(tester, 'render-pasek-krok2', _steps(1, [true, false, false]), h: 120);
    await _shot(tester, 'render-pasek-krok3', _steps(2, [true, true, false]), h: 120);

    final empty = GuestFormController();
    await _shot(tester, 'render-formularz-pusty', _form(empty, GlobalKey<FormState>()), h: 540);

    final key = GlobalKey<FormState>();
    final bad = GuestFormController()..email.text = 'nie-email';
    await _shot(tester, 'render-formularz-bledy', _form(bad, key), h: 540, after: () => key.currentState!.validate());
  });
}

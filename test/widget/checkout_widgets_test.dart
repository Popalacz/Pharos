import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pharos/core/services/analytics_service.dart';
import 'package:pharos/data/models/checkout_models.dart';
import 'package:pharos/l10n/app_localizations.dart';
import 'package:pharos/ui/screens/checkout/checkout_guest_form.dart';
import 'package:pharos/ui/screens/checkout/checkout_option_cards.dart';
import 'package:pharos/ui/screens/checkout/checkout_step_indicator.dart';
import 'package:pharos/ui/screens/checkout/checkout_variant.dart';

Widget _wrap(Widget child) => MaterialApp(
      locale: const Locale('pl'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: SingleChildScrollView(child: child)));

void _fillValid(GuestFormController c) {
  c.email.text = 'jan.kowalski@example.com';
  c.firstname.text = 'Jan';
  c.lastname.text = 'Kowalski';
  c.address.text = 'Długa 5';
  c.postcode.text = '00-001';
  c.city.text = 'Warszawa';
  c.phone.text = '500100200';
}

void main() {
  group('CheckoutVariant', () {
    tearDown(() => AnalyticsService.checkoutVariant = 'A');

    test('maps codes to variants, unknown falls back to A', () {
      expect(CheckoutVariant.fromCode('A'), CheckoutVariant.single);
      expect(CheckoutVariant.fromCode('b'), CheckoutVariant.stepped);
      expect(CheckoutVariant.fromCode('x'), CheckoutVariant.single);
      expect(CheckoutVariant.stepped.code, 'B');
    });

    test('current follows AnalyticsService.checkoutVariant', () {
      AnalyticsService.checkoutVariant = 'B';
      expect(CheckoutVariant.current, CheckoutVariant.stepped);
    });
  });

  group('CheckoutStepIndicator', () {
    testWidgets('shows labels and a check for completed steps', (tester) async {
      await tester.pumpWidget(_wrap(const CheckoutStepIndicator(
        labels: ['Adres', 'Dostawa', 'Płatność'],
        completed: [true, false, false],
        currentIndex: 1,
      )));

      expect(find.text('Adres'), findsOneWidget);
      expect(find.text('Dostawa'), findsOneWidget);
      expect(find.text('Płatność'), findsOneWidget);
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('exposes step state to screen readers', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_wrap(const CheckoutStepIndicator(
        labels: ['Adres', 'Dostawa', 'Płatność'],
        completed: [true, false, false],
        currentIndex: 1,
      )));

      expect(find.bySemanticsLabel('Krok 1 z 3: Adres, ukończony'), findsOneWidget);
      expect(find.bySemanticsLabel('Krok 2 z 3: Dostawa, bieżący'), findsOneWidget);
      expect(find.bySemanticsLabel('Krok 3 z 3: Płatność, do wykonania'), findsOneWidget);
      handle.dispose();
    });
  });

  group('GuestFormController', () {
    test('empty form reports every field as missing', () {
      final c = GuestFormController();
      expect(c.missingLabels(lookupAppLocalizations(const Locale('pl'))).length, 7);
      expect(c.isValid, isFalse);
      c.dispose();
    });

    test('valid data passes and builds payload', () {
      final c = GuestFormController();
      _fillValid(c);
      expect(c.missingLabels(lookupAppLocalizations(const Locale('pl'))), isEmpty);
      expect(c.isValid, isTrue);
      final payload = c.toPayload(createAccount: true);
      expect(payload['email'], 'jan.kowalski@example.com');
      expect(payload['create_account'], true);
      c.dispose();
    });

    test('invalid email is reported', () {
      final c = GuestFormController();
      _fillValid(c);
      c.email.text = 'nie-email';
      expect(c.missingLabels(lookupAppLocalizations(const Locale('pl'))), contains('adres e-mail'));
      c.dispose();
    });
  });

  group('CheckoutGuestForm', () {
    Future<GuestFormController> pumpForm(WidgetTester tester, GlobalKey<FormState> key) async {
      final controller = GuestFormController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(_wrap(CheckoutGuestForm(
        formKey: key,
        controller: controller,
        createAccount: false,
        onCreateAccountChanged: (_) {},
        onFieldChanged: () {},
        onAddressChanged: (_) {},
      )));
      return controller;
    }

    testWidgets('fields declare autofill hints and keyboard actions', (tester) async {
      await pumpForm(tester, GlobalKey<FormState>());

      final fields = tester.widgetList<TextField>(find.byType(TextField)).toList();
      expect(fields.length, 7);

      final hints = fields.map((f) => f.autofillHints?.first).toList();
      expect(hints, [
        'email',
        'givenName',
        'familyName',
        'streetAddressLine1',
        'postalCode',
        'addressCity',
        'telephoneNumber',
      ]);

      expect(fields.first.keyboardType, TextInputType.emailAddress);
      expect(fields.last.keyboardType, TextInputType.phone);
      expect(fields.take(6).every((f) => f.textInputAction == TextInputAction.next), isTrue);
      expect(fields.last.textInputAction, TextInputAction.done);
      expect(find.byType(AutofillGroup), findsOneWidget);
    });

    testWidgets('validate shows errors for empty form', (tester) async {
      final key = GlobalKey<FormState>();
      await pumpForm(tester, key);

      expect(key.currentState!.validate(), isFalse);
      await tester.pump();
      expect(find.byType(Text).evaluate().length, greaterThan(8));
    });

    testWidgets('validate passes for valid data', (tester) async {
      final key = GlobalKey<FormState>();
      final controller = await pumpForm(tester, key);
      _fillValid(controller);

      expect(key.currentState!.validate(), isTrue);
    });
  });

  group('Option cards', () {
    testWidgets('payment list reports selection', (tester) async {
      PaymentMethodModel? picked;
      await tester.pumpWidget(_wrap(CheckoutPaymentList(
        payments: [PaymentMethodModel(id: 'blik', name: 'BLIK')],
        hasError: false,
        selected: null,
        onSelect: (m) => picked = m,
        onRetry: () {},
      )));

      await tester.tap(find.text('BLIK'));
      expect(picked?.id, 'blik');
    });
  });
}

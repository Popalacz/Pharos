import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:pharos/core/providers/consent_provider.dart';
import 'package:pharos/l10n/app_localizations.dart';
import 'package:pharos/ui/screens/checkout/checkout_legal_notice.dart';
import 'package:pharos/ui/widgets/consent_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _wrap(Widget child) => MaterialApp(
      locale: const Locale('pl'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    );

void main() {
  group('CheckoutLegalNotice', () {
    testWidgets('shows the withdrawal period and no links when no URLs are configured', (tester) async {
      await tester.pumpWidget(_wrap(const CheckoutLegalNotice()));

      expect(find.textContaining('14 dni'), findsOneWidget);
      expect(find.byType(TextButton), findsNothing);
    });
  });

  group('ConsentProvider', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('has no decision until the user answers', () async {
      final provider = ConsentProvider();
      await provider.load();

      expect(provider.isLoaded, isTrue);
      expect(provider.hasDecided, isFalse);
      expect(provider.isGranted, isFalse);
    });

    test('remembers the answer', () async {
      final provider = ConsentProvider();
      await provider.load();
      await provider.setGranted(true);

      final reloaded = ConsentProvider();
      await reloaded.load();

      expect(reloaded.hasDecided, isTrue);
      expect(reloaded.isGranted, isTrue);
    });
  });

  group('ConsentGate', () {
    testWidgets('asks once on first launch and both answers are offered', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final provider = ConsentProvider();
      await provider.load();

      await tester.pumpWidget(
        ChangeNotifierProvider<ConsentProvider>.value(
          value: provider,
          child: _wrap(const ConsentGate(child: Text('app'))),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Zgadzam się'), findsOneWidget);
      expect(find.text('Nie zgadzam się'), findsOneWidget);

      await tester.tap(find.text('Nie zgadzam się'));
      await tester.pumpAndSettle();

      expect(provider.hasDecided, isTrue);
      expect(provider.isGranted, isFalse);
      expect(find.text('Zgadzam się'), findsNothing);
    });
  });
}

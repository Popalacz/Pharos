import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:pharos/core/utils/form_validation.dart';
import 'package:pharos/l10n/app_localizations.dart';

void main() {
  tearDown(() => FormValidation.l10n = null);

  group('FormValidation (pl)', () {
    setUp(() => FormValidation.l10n = lookupAppLocalizations(const Locale('pl')));

    test('required and format messages', () {
      expect(FormValidation.emailField(''), 'Adres e-mail jest wymagane');
      expect(FormValidation.emailField('abc'), 'Wprowadź poprawny adres e-mail');
      expect(FormValidation.postcodeField('1234'), 'Kod pocztowy musi być w formacie 00-000');
      expect(FormValidation.phoneField('123'), 'Numer telefonu musi zawierać co najmniej 9 cyfr');
    });

    test('polish plural of znak', () {
      expect(FormValidation.nameField('A', 'Imię'), 'Imię musi mieć co najmniej 2 znaki');
      expect(FormValidation.passwordField('abc'), 'Hasło musi mieć co najmniej 5 znaków');
    });

    test('valid values return null', () {
      expect(FormValidation.emailField('ala@example.com'), isNull);
      expect(FormValidation.postcodeField('00-950'), isNull);
    });
  });

  group('FormValidation (en)', () {
    setUp(() => FormValidation.l10n = lookupAppLocalizations(const Locale('en')));

    test('messages follow the app language', () {
      expect(FormValidation.emailField(''), 'Email address is required');
      expect(FormValidation.nameField('A', 'First name'), 'First name must have at least 2 characters');
      expect(FormValidation.formatMissingFields(['a', 'b']), 'Missing: a, b.');
    });
  });
}

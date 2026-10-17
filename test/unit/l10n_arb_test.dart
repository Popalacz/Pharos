import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _load(String lang) =>
    jsonDecode(File('lib/l10n/app_$lang.arb').readAsStringSync()) as Map<String, dynamic>;

Set<String> _messageKeys(Map<String, dynamic> arb) =>
    arb.keys.where((k) => !k.startsWith('@')).toSet();

void main() {
  final en = _load('en');
  final pl = _load('pl');

  test('app_en.arb i app_pl.arb mają te same klucze', () {
    expect(_messageKeys(pl), _messageKeys(en));
  });

  test('żaden tekst w ARB nie jest pusty', () {
    for (final arb in [en, pl]) {
      for (final key in _messageKeys(arb)) {
        if (key.startsWith('@@')) continue;
        expect((arb[key] as String).trim(), isNotEmpty, reason: key);
      }
    }
  });

  test('teksty z parametrami mają te same placeholdery w obu językach', () {
    final placeholder = RegExp(r'\{(\w+)\}');
    for (final key in _messageKeys(en).where((k) => !k.startsWith('@@'))) {
      final fromEn = placeholder.allMatches(en[key] as String).map((m) => m.group(1)).toSet();
      final fromPl = placeholder.allMatches(pl[key] as String).map((m) => m.group(1)).toSet();
      expect(fromPl, fromEn, reason: key);
    }
  });

  test('etykiety dostępności istnieją dla ikon', () {
    for (final key in ['a11yBack', 'a11yClose', 'a11yFilters', 'a11yAddToFavorites', 'a11yShowPassword']) {
      expect(en.containsKey(key), isTrue, reason: key);
    }
  });
}

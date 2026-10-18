import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// Logger z poziomami. W wydaniu (release) nic nie wypisuje.
class AppLog {
  AppLog._();

  static const int _info = 800;
  static const int _warning = 900;
  static const int _error = 1000;

  static void d(String message) => _log(message, _info);

  static void w(String message) => _log(message, _warning);

  static void e(String message, [Object? error]) =>
      _log(message, _error, error);

  static void _log(String message, int level, [Object? error]) {
    if (!kDebugMode) return;

    developer.log(message, name: 'pharos', level: level, error: error);
  }
}

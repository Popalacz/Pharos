import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:pharos/core/utils/app_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Stores the user's choice about analytics and crash reports and applies it to Firebase.
///
/// Nothing is collected until the user agrees.
class ConsentProvider extends ChangeNotifier {
  static const String _storageKey = 'analytics_consent';

  bool _isLoaded = false;
  bool? _isGranted;

  bool get isLoaded => _isLoaded;

  bool get hasDecided => _isGranted != null;

  bool get isGranted => _isGranted ?? false;

  Future<void> load() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      _isGranted = preferences.getBool(_storageKey);
    } catch (error) {
      AppLog.e('Consent load failed: $error');
    }

    await _applyToFirebase(isGranted);
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> setGranted(bool isGranted) async {
    _isGranted = isGranted;

    try {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setBool(_storageKey, isGranted);
    } catch (error) {
      AppLog.e('Consent save failed: $error');
    }

    await _applyToFirebase(isGranted);
    notifyListeners();
  }

  Future<void> _applyToFirebase(bool isGranted) async {
    try {
      await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(isGranted);
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(isGranted);

      if (isGranted) {
        await FirebaseAnalytics.instance.logAppOpen();
      }
    } catch (error) {
      AppLog.e('Consent apply failed: $error');
    }
  }
}

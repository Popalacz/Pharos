import 'dart:ui' show Locale;

import 'package:pharos/l10n/app_localizations.dart';

class FormValidation {
  /// Set from `MaterialApp.builder` so messages follow the app language. Falls back to Polish before the first build.
  static AppLocalizations? l10n;

  static AppLocalizations get _l => l10n ?? lookupAppLocalizations(const Locale('pl'));

  static final RegExp _emailPattern = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
  static final RegExp _namePattern = RegExp(r'^[^0-9!<>,;?=+()@#"°*!$^_]+$');
  static final RegExp _postcodePattern = RegExp(r'^\d{2}-\d{3}$');
  static final RegExp _phonePattern = RegExp(r'^[+0-9. ()-]*$');

  static String formatMissingFields(List<String> fieldLabels) {
    if (fieldLabels.isEmpty) {
      return '';
    }
    if (fieldLabels.length == 1) {
      return _l.missingFieldsMessage(fieldLabels.first);
    }
    return _l.missingFieldsMessage(fieldLabels.join(', '));
  }

  static String cleanErrorMessage(Object error) {
    return error
        .toString()
        .replaceFirst(RegExp(r'^Exception:\s*'), '')
        .replaceFirst(RegExp(r'^Błąd:\s*'), '')
        .trim();
  }

  static String? requiredField(String? value, String fieldLabel) {
    if (value == null || value.trim().isEmpty) {
      return _l.validationRequired(fieldLabel);
    }
    return null;
  }

  static String? emailField(String? value, {String? fieldLabel}) {
    final label = fieldLabel ?? _l.guestEmailLabel;
    final requiredError = requiredField(value, label);
    if (requiredError != null) {
      return requiredError;
    }
    if (!_emailPattern.hasMatch(value!.trim())) {
      return _l.validationEmailInvalid;
    }
    return null;
  }

  static String? nameField(String? value, String fieldLabel) {
    final requiredError = requiredField(value, fieldLabel);
    if (requiredError != null) {
      return requiredError;
    }
    final normalizedValue = value!.trim();
    if (normalizedValue.length < 2) {
      return _l.validationMinChars(fieldLabel, 2);
    }
    if (!_namePattern.hasMatch(normalizedValue)) {
      return _l.validationInvalidChars(fieldLabel);
    }
    return null;
  }

  static String? addressField(String? value, {String? fieldLabel}) {
    final label = fieldLabel ?? _l.guestStreetLabel;
    final requiredError = requiredField(value, label);
    if (requiredError != null) {
      return requiredError;
    }
    if (value!.trim().length < 3) {
      return _l.validationTooShort(label);
    }
    return null;
  }

  static String? cityField(String? value, {String? fieldLabel}) {
    final label = fieldLabel ?? _l.guestCityLabel;
    final requiredError = requiredField(value, label);
    if (requiredError != null) {
      return requiredError;
    }
    if (value!.trim().length < 2) {
      return _l.validationMinChars(label, 2);
    }
    return null;
  }

  static String? postcodeField(String? value, {String? fieldLabel}) {
    final label = fieldLabel ?? _l.guestPostcodeLabel;
    final requiredError = requiredField(value, label);
    if (requiredError != null) {
      return requiredError;
    }
    if (!_postcodePattern.hasMatch(value!.trim())) {
      return _l.validationPostcodeFormat(label);
    }
    return null;
  }

  static String? phoneField(String? value, {String? fieldLabel}) {
    final label = fieldLabel ?? _l.guestPhoneLabel;
    final requiredError = requiredField(value, label);
    if (requiredError != null) {
      return requiredError;
    }
    final normalizedValue = value!.trim();
    if (!_phonePattern.hasMatch(normalizedValue)) {
      return _l.validationPhoneFormat(label);
    }
    if (normalizedValue.replaceAll(RegExp(r'[^0-9]'), '').length < 9) {
      return _l.validationPhoneDigits(label);
    }
    return null;
  }

  static String? passwordField(String? value, {String? fieldLabel, int minLength = 5}) {
    final label = fieldLabel ?? _l.password;
    final requiredError = requiredField(value, label);
    if (requiredError != null) {
      return requiredError;
    }
    if (value!.length < minLength) {
      return _l.validationMinChars(label, minLength);
    }
    return null;
  }

  static String? commentField(String? value, {String? fieldLabel, int minLength = 10}) {
    final label = fieldLabel ?? _l.reviewCommentLabel;
    final requiredError = requiredField(value, label);
    if (requiredError != null) {
      return requiredError;
    }
    if (value!.trim().length < minLength) {
      return _l.validationMinChars(label, minLength);
    }
    return null;
  }

  /// Returns user-facing labels for fields that failed validation.
  static List<String> collectMissingLabels(Map<String, String?> fieldResults) {
    final missingLabels = <String>[];
    fieldResults.forEach((fieldLabel, errorMessage) {
      if (errorMessage != null) {
        missingLabels.add(fieldLabel);
      }
    });
    return missingLabels;
  }
}

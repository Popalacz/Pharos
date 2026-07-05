class FormValidation {
  static final RegExp _emailPattern = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
  static final RegExp _namePattern = RegExp(r'^[^0-9!<>,;?=+()@#"°*!$^_]+$');
  static final RegExp _postcodePattern = RegExp(r'^\d{2}-\d{3}$');
  static final RegExp _phonePattern = RegExp(r'^[+0-9. ()-]*$');

  static String formatMissingFields(List<String> fieldLabels) {
    if (fieldLabels.isEmpty) {
      return '';
    }
    if (fieldLabels.length == 1) {
      return 'Brakuje: ${fieldLabels.first}.';
    }
    return 'Brakuje: ${fieldLabels.join(', ')}.';
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
      return '$fieldLabel jest wymagane';
    }
    return null;
  }

  static String? emailField(String? value, {String fieldLabel = 'Adres e-mail'}) {
    final requiredError = requiredField(value, fieldLabel);
    if (requiredError != null) {
      return requiredError;
    }
    if (!_emailPattern.hasMatch(value!.trim())) {
      return 'Wprowadź poprawny adres e-mail';
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
      return '$fieldLabel musi mieć co najmniej 2 znaki';
    }
    if (!_namePattern.hasMatch(normalizedValue)) {
      return '$fieldLabel zawiera niedozwolone znaki';
    }
    return null;
  }

  static String? addressField(String? value, {String fieldLabel = 'Ulica i numer'}) {
    final requiredError = requiredField(value, fieldLabel);
    if (requiredError != null) {
      return requiredError;
    }
    if (value!.trim().length < 3) {
      return '$fieldLabel jest za krótkie';
    }
    return null;
  }

  static String? cityField(String? value, {String fieldLabel = 'Miasto'}) {
    final requiredError = requiredField(value, fieldLabel);
    if (requiredError != null) {
      return requiredError;
    }
    if (value!.trim().length < 2) {
      return '$fieldLabel musi mieć co najmniej 2 znaki';
    }
    return null;
  }

  static String? postcodeField(String? value, {String fieldLabel = 'Kod pocztowy'}) {
    final requiredError = requiredField(value, fieldLabel);
    if (requiredError != null) {
      return requiredError;
    }
    if (!_postcodePattern.hasMatch(value!.trim())) {
      return '$fieldLabel musi być w formacie 00-000';
    }
    return null;
  }

  static String? phoneField(String? value, {String fieldLabel = 'Numer telefonu'}) {
    final requiredError = requiredField(value, fieldLabel);
    if (requiredError != null) {
      return requiredError;
    }
    final normalizedValue = value!.trim();
    if (!_phonePattern.hasMatch(normalizedValue)) {
      return '$fieldLabel ma nieprawidłowy format';
    }
    if (normalizedValue.replaceAll(RegExp(r'[^0-9]'), '').length < 9) {
      return '$fieldLabel musi zawierać co najmniej 9 cyfr';
    }
    return null;
  }

  static String? passwordField(String? value, {String fieldLabel = 'Hasło', int minLength = 5}) {
    final requiredError = requiredField(value, fieldLabel);
    if (requiredError != null) {
      return requiredError;
    }
    if (value!.length < minLength) {
      return '$fieldLabel musi mieć co najmniej $minLength znaków';
    }
    return null;
  }

  static String? commentField(String? value, {String fieldLabel = 'Treść opinii', int minLength = 10}) {
    final requiredError = requiredField(value, fieldLabel);
    if (requiredError != null) {
      return requiredError;
    }
    if (value!.trim().length < minLength) {
      return '$fieldLabel musi mieć co najmniej $minLength znaków';
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

import 'package:flutter/foundation.dart';

/// Demo cart lines for UI (badge, bottom sheet) until a real checkout flow exists.
class CartStubProvider extends ChangeNotifier {
  final List<String> _productNames = <String>[];

  List<String> get productNames => List<String>.unmodifiable(_productNames);

  int get lineCount => _productNames.length;

  /// Returns index of the inserted line (for undo UX).
  int addLine(String productName) {
    _productNames.add(productName);
    notifyListeners();

    return _productNames.length - 1;
  }

  void removeAt(int index) {
    if (index < 0 || index >= _productNames.length) {
      return;
    }

    _productNames.removeAt(index);
    notifyListeners();
  }

  void clear() {
    if (_productNames.isEmpty) {
      return;
    }

    _productNames.clear();
    notifyListeners();
  }
}

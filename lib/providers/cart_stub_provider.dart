import 'package:flutter/foundation.dart';

import '../models/cart_stub_line.dart';

/// Demo cart lines for UI (badge, bottom sheet) until a real checkout flow exists.
class CartStubProvider extends ChangeNotifier {
  final List<CartStubLine> _lines = <CartStubLine>[];

  List<CartStubLine> get lines => List<CartStubLine>.unmodifiable(_lines);

  int get lineCount => _lines.length;

  /// Returns index of the inserted line (for undo UX).
  int addLine(CartStubLine line) {
    _lines.add(line);
    notifyListeners();

    return _lines.length - 1;
  }

  void removeAt(int index) {
    if (index < 0 || index >= _lines.length) {
      return;
    }

    _lines.removeAt(index);
    notifyListeners();
  }

  void clear() {
    if (_lines.isEmpty) {
      return;
    }

    _lines.clear();
    notifyListeners();
  }
}

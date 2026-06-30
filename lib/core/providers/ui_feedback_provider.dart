import 'package:flutter/material.dart';

class UiFeedbackProvider extends ChangeNotifier {
  Function(GlobalKey)? _addToCartAnimation;

  void setAddToCartAnimation(Function(GlobalKey) anim) {
    _addToCartAnimation = anim;
  }

  void triggerFlyToCart(GlobalKey widgetKey) {
    if (_addToCartAnimation != null) {
      _addToCartAnimation!(widgetKey);
    }
  }
}

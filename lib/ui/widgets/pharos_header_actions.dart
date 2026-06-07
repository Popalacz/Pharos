import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../providers/cart_stub_provider.dart';
import '../feedback/placeholder_feedback.dart';
import '../sheets/cart_preview_sheet.dart';

/// Right-side [AppBar] actions: cart + account (e‑commerce convention).
class PharosHeaderActions extends StatelessWidget {
  const PharosHeaderActions({
    super.key,
    this.onCartPressed,
    this.onAccountPressed,
  });

  final VoidCallback? onCartPressed;
  final VoidCallback? onAccountPressed;

  @override
  Widget build(BuildContext context) {
    return IconTheme(
      data: const IconThemeData(color: AppColors.text),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Consumer<CartStubProvider>(
            builder: (BuildContext context, CartStubProvider cart, Widget? _) {
              final VoidCallback openCart = onCartPressed ?? () => showCartPreviewSheet(context);

              final Widget cartButton = IconButton(
                tooltip: 'Koszyk',
                onPressed: openCart,
                icon: const Icon(Icons.shopping_cart_outlined),
              );

              if (cart.lineCount <= 0) {
                return cartButton;
              }

              return Badge(
                label: Text('${cart.lineCount}'),
                textColor: AppColors.text,
                backgroundColor: AppColors.accent,
                child: cartButton,
              );
            },
          ),
          IconButton(
            tooltip: 'Konto',
            onPressed: onAccountPressed ?? () => showComingSoonSnackBar(context),
            icon: const Icon(Icons.person_outline_rounded),
          ),
        ],
      ),
    );
  }
}

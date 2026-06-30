import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:pharos/core/providers/cart_provider.dart';
import 'package:pharos/core/theme/app_colors.dart';
import 'package:pharos/ui/sheets/cart_preview_sheet.dart';

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
          Consumer<CartProvider>(
            builder: (BuildContext context, CartProvider cart, Widget? _) {
              final VoidCallback openCart = onCartPressed ?? () => showCartPreviewSheet(context);

              final Widget cartButton = IconButton(
                tooltip: 'Koszyk',
                onPressed: openCart,
                icon: const Icon(Icons.shopping_cart_outlined),
              );

              if (cart.itemCount <= 0) {
                return cartButton;
              }

              return Badge(
                label: Text('${cart.itemCount}'),
                child: cartButton,
              );
            },
          ),
          IconButton(
            tooltip: 'Konto',
            onPressed: onAccountPressed,
            icon: const Icon(Icons.person_outline),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/constants/pharos_layout.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/cart_stub_provider.dart';

Future<void> showCartPreviewSheet(BuildContext context) {
  HapticFeedback.lightImpact();

  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    backgroundColor: AppColors.surface,
    isScrollControlled: true,
    builder: (BuildContext sheetContext) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            PharosLayout.spaceMd,
            PharosLayout.spaceSm,
            PharosLayout.spaceMd,
            PharosLayout.spaceMd,
          ),
          child: Consumer<CartStubProvider>(
            builder: (BuildContext context, CartStubProvider cart, Widget? _) {
              if (cart.lineCount == 0) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: PharosLayout.spaceSm),
                    Icon(
                      Icons.shopping_bag_outlined,
                      size: 56,
                      color: AppColors.text.withOpacity(0.35),
                    ),
                    const SizedBox(height: PharosLayout.spaceMd),
                    Text(
                      'Koszyk jest pusty',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.text,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: PharosLayout.spaceXs),
                    Text(
                      'Dodaj produkt ze strony szczegółów — licznik na ikonie zaktualizuje się automatycznie.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.text.withOpacity(0.72),
                            height: 1.35,
                          ),
                    ),
                    const SizedBox(height: PharosLayout.spaceMd),
                  ],
                );
              }

              final double maxListHeight = (MediaQuery.sizeOf(context).height * 0.45).clamp(160.0, 420.0);

              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Koszyk (demo)',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.text,
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const SizedBox(height: PharosLayout.spaceSm),
                  ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: maxListHeight),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: cart.lineCount,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (BuildContext context, int index) {
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            cart.productNames[index],
                            style: const TextStyle(color: AppColors.text),
                          ),
                          trailing: IconButton(
                            tooltip: 'Usuń',
                            onPressed: () {
                              HapticFeedback.selectionClick();
                              cart.removeAt(index);
                            },
                            icon: const Icon(Icons.delete_outline, color: AppColors.text),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: PharosLayout.spaceSm),
                  TextButton(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      cart.clear();
                    },
                    child: const Text('Wyczyść koszyk'),
                  ),
                ],
              );
            },
          ),
        ),
      );
    },
  );
}

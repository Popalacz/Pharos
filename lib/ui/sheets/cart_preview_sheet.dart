import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:pharos/core/constants/pharos_layout.dart';
import 'package:pharos/core/providers/cart_provider.dart';
import 'package:pharos/core/providers/localization_provider.dart';
import 'package:pharos/core/theme/app_colors.dart';
import 'package:pharos/data/models/cart_model.dart';

Future<void> showCartPreviewSheet(BuildContext context) {
  HapticFeedback.lightImpact();

  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    backgroundColor: AppColors.surface,
    isScrollControlled: true,
    builder: (BuildContext sheetContext) {
      return Semantics(
        label: 'Podgląd koszyka',
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              PharosLayout.spaceMd,
              PharosLayout.spaceSm,
              PharosLayout.spaceMd,
              PharosLayout.spaceMd,
            ),
            child: Consumer<CartProvider>(
              builder: (BuildContext context, CartProvider cart, Widget? _) {
                final items = cart.items.values.toList();

                if (items.isEmpty) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.shopping_bag_outlined,
                        size: 56,
                        color: AppColors.text.withValues(alpha: 0.35),
                      ),
                      const SizedBox(height: PharosLayout.spaceMd),
                      Text(
                        'Koszyk jest pusty',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppColors.text,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ],
                  );
                }

                final loc = context.watch<LocalizationProvider>();
                final maxListHeight = (MediaQuery.sizeOf(context).height * 0.45).clamp(160.0, 420.0);

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Koszyk',
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
                        itemCount: items.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (BuildContext context, int index) {
                          final CartItemModel line = items[index];

                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: _CartLineThumbnail(imageUrl: line.product.imageUrl),
                            title: Text(
                              line.product.name,
                              style: const TextStyle(
                                color: AppColors.text,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              loc.formatPrice(line.product.price),
                              style: TextStyle(
                                color: AppColors.accent.withValues(alpha: 0.95),
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            trailing: IconButton(
                              tooltip: 'Usuń',
                              onPressed: () {
                                HapticFeedback.selectionClick();
                                cart.removeItem(line.key);
                              },
                              icon: const Icon(Icons.delete_outline, color: AppColors.text),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );
    },
  );
}

class _CartLineThumbnail extends StatelessWidget {
  const _CartLineThumbnail({required this.imageUrl});

  final String imageUrl;

  static const double _size = 56;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(PharosLayout.radiusSm),
      child: SizedBox(
        width: _size,
        height: _size,
        child: imageUrl.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
              )
            : ColoredBox(
                color: AppColors.background,
                child: Icon(
                  Icons.image_not_supported_outlined,
                  color: AppColors.text.withValues(alpha: 0.35),
                ),
              ),
      ),
    );
  }
}

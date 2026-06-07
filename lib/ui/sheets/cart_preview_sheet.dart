import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/constants/pharos_layout.dart';
import '../../core/theme/app_colors.dart';
import '../../models/cart_stub_line.dart';
import '../../providers/cart_stub_provider.dart';

Future<void> showCartPreviewSheet(BuildContext context) {
  HapticFeedback.lightImpact();

  // showDragHandle: Material 3 grab rail (no "px" label). A "px" readout usually comes
  // from Flutter Inspector / IDE layout overlays while debugging, not from this sheet.
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
                        'Nie posiadasz produktów w koszyku.',
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
                          final CartStubLine line = cart.lines[index];

                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: _CartLineThumbnail(line: line),
                            title: Text(
                              line.productName,
                              style: const TextStyle(
                                color: AppColors.text,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              '${line.unitPrice} PLN',
                              style: TextStyle(
                                color: AppColors.accent.withOpacity(0.95),
                                fontWeight: FontWeight.w800,
                              ),
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
        ),
      );
    },
  );
}

class _CartLineThumbnail extends StatelessWidget {
  const _CartLineThumbnail({required this.line});

  final CartStubLine line;

  static const double _size = 56;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(PharosLayout.radiusSm),
      child: SizedBox(
        width: _size,
        height: _size,
        child: line.hasThumbnail
            ? CachedNetworkImage(
                imageUrl: line.imageUrl,
                fit: BoxFit.cover,
                memCacheWidth: (_size * MediaQuery.devicePixelRatioOf(context)).round(),
                placeholder: (BuildContext context, String url) => ColoredBox(
                  color: AppColors.background,
                  child: const Center(
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ),
                errorWidget: (BuildContext context, String url, Object error) {
                  return ColoredBox(
                    color: AppColors.background,
                    child: Icon(
                      Icons.broken_image_outlined,
                      color: AppColors.text.withOpacity(0.45),
                    ),
                  );
                },
              )
            : ColoredBox(
                color: AppColors.background,
                child: Icon(
                  Icons.image_not_supported_outlined,
                  color: AppColors.text.withOpacity(0.35),
                ),
              ),
      ),
    );
  }
}

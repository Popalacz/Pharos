import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../models/product_model.dart';
import '../../navigation/catalog_navigation.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product, this.onTap});

  final Product product;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap ??
            () {
              HapticFeedback.selectionClick();
              CatalogNavigation.openProductDetail(context, product);
            },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Hero(
                tag: 'product_image_${product.id}',
                child: _buildImage(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.text,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${product.price} PLN',
                    style: const TextStyle(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (!product.hasImageUrl) {
      return ColoredBox(
        color: AppColors.background,
        child: Center(
          child: Icon(
            Icons.image_not_supported,
            size: 50,
            color: AppColors.text.withValues(alpha: 0.35),
          ),
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: product.imageUrl,
      width: double.infinity,
      fit: BoxFit.cover,
      placeholder: (BuildContext context, String url) => ColoredBox(
        color: AppColors.background,
        child: const Center(child: CircularProgressIndicator()),
      ),
      errorWidget: (BuildContext context, String url, Object error) => ColoredBox(
        color: AppColors.background,
        child: Icon(Icons.error, color: AppColors.accent),
      ),
    );
  }
}

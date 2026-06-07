import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/pharos_layout.dart';
import '../../core/theme/app_colors.dart';
import '../../models/product_model.dart';

/// Swipeable product images with optional thumbnail strip (PrestaShop `associations.images`).
class ProductImageGallery extends StatefulWidget {
  const ProductImageGallery({
    super.key,
    required this.product,
    this.heroTag,
  });

  final Product product;
  final Object? heroTag;

  @override
  State<ProductImageGallery> createState() => _ProductImageGalleryState();
}

class _ProductImageGalleryState extends State<ProductImageGallery> {
  late final PageController _pageController;
  int _currentIndex = 0;

  Product get _product => widget.product;

  List<String> get _imageIds => _product.resolvedGalleryImageIds;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage(int index) {
    if (index == _currentIndex) {
      return;
    }

    HapticFeedback.selectionClick();
    _pageController.animateToPage(
      index,
      duration: PharosLayout.motionNormal,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_imageIds.isEmpty) {
      return ColoredBox(
        color: AppColors.surface,
        child: Icon(
          Icons.image_not_supported,
          size: 100,
          color: AppColors.text.withValues(alpha: 0.35),
        ),
      );
    }

    final bool showThumbnails = _product.hasMultipleGalleryImages;

    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        PageView.builder(
          controller: _pageController,
          itemCount: _imageIds.length,
          onPageChanged: (int index) {
            setState(() => _currentIndex = index);
          },
          itemBuilder: (BuildContext context, int index) {
            final String imageUrl = _product.imageUrlForImageId(_imageIds[index]);
            final Widget image = CachedNetworkImage(
              imageUrl: imageUrl,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              placeholder: (BuildContext context, String url) => ColoredBox(
                color: AppColors.surface,
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (BuildContext context, String url, Object error) => ColoredBox(
                color: AppColors.surface,
                child: Icon(Icons.error, size: 100, color: AppColors.accent),
              ),
            );

            if (widget.heroTag != null && index == 0) {
              return Hero(
                tag: widget.heroTag!,
                child: image,
              );
            }

            return image;
          },
        ),
        if (showThumbnails)
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                PharosLayout.spaceSm,
                0,
                PharosLayout.spaceSm,
                PharosLayout.spaceMd,
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.black.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(PharosLayout.radiusMd),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(PharosLayout.spaceXs),
                  child: SizedBox(
                    height: 56,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      itemCount: _imageIds.length,
                      separatorBuilder: (BuildContext context, int index) {
                        return const SizedBox(width: PharosLayout.spaceXs);
                      },
                      itemBuilder: (BuildContext context, int index) {
                        final bool isSelected = index == _currentIndex;
                        final String thumbUrl = _product.imageUrlForImageId(_imageIds[index]);

                        return Semantics(
                          button: true,
                          label: 'Zdjęcie ${index + 1} z ${_imageIds.length}',
                          selected: isSelected,
                          child: GestureDetector(
                            onTap: () => _goToPage(index),
                            child: AnimatedContainer(
                              duration: PharosLayout.motionFast,
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(PharosLayout.radiusSm),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.accent
                                      : AppColors.text.withValues(alpha: 0.35),
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: CachedNetworkImage(
                                imageUrl: thumbUrl,
                                fit: BoxFit.cover,
                                placeholder: (BuildContext context, String url) => ColoredBox(
                                  color: AppColors.surface,
                                  child: Icon(
                                    Icons.image_rounded,
                                    size: 22,
                                    color: AppColors.text.withValues(alpha: 0.25),
                                  ),
                                ),
                                errorWidget: (BuildContext context, String url, Object error) =>
                                    Icon(Icons.broken_image_outlined, color: AppColors.accent),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

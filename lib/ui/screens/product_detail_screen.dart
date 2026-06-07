import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/constants/pharos_layout.dart';
import '../../core/theme/app_colors.dart';
import '../../models/product_model.dart';
import '../../models/cart_stub_line.dart';
import '../../providers/cart_stub_provider.dart';
import '../sheets/cart_preview_sheet.dart';
import '../widgets/pharos_header_actions.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key, required this.product});

  final Product product;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  bool _isFavorite = false;

  Product get _product => widget.product;

  Future<void> _copySummaryToClipboard(BuildContext context) async {
    HapticFeedback.lightImpact();
    final String text = 'Pharos • ${_product.name} — ${_product.price} PLN';
    await Clipboard.setData(ClipboardData(text: text));

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Skopiowano podsumowanie do schowka.')),
    );
  }

  void _toggleFavorite() {
    HapticFeedback.selectionClick();
    setState(() => _isFavorite = !_isFavorite);
  }

  void _addToCart(BuildContext context) {
    HapticFeedback.mediumImpact();
    final CartStubProvider cart = context.read<CartStubProvider>();
    final int lineIndex = cart.addLine(CartStubLine.fromProduct(_product));

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Dodano do koszyka: ${_product.name}'),
        action: SnackBarAction(
          label: 'Cofnij',
          onPressed: () => cart.removeAt(lineIndex),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              pinned: true,
              stretch: true,
              expandedHeight: 360,
              actions: [
                IconButton(
                  tooltip: _isFavorite ? 'Usuń z ulubionych' : 'Dodaj do ulubionych',
                  onPressed: _toggleFavorite,
                  icon: Icon(
                    _isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    color: _isFavorite ? AppColors.accent : AppColors.text,
                  ),
                ),
                IconButton(
                  tooltip: 'Skopiuj podsumowanie',
                  onPressed: () => _copySummaryToClipboard(context),
                  icon: const Icon(Icons.share_rounded),
                ),
                PharosHeaderActions(
                  onCartPressed: () => showCartPreviewSheet(context),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                stretchModes: const <StretchMode>[
                  StretchMode.zoomBackground,
                ],
                titlePadding: const EdgeInsetsDirectional.only(start: 16, bottom: 14),
                title: Text(
                  _product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppColors.text,
                    fontWeight: FontWeight.w900,
                    shadows: const <Shadow>[
                      Shadow(blurRadius: 10, color: Colors.black54, offset: Offset(0, 1)),
                    ],
                  ),
                ),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Hero(
                      tag: 'product_image_${_product.id}',
                      child: _buildDetailImage(),
                    ),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: <Color>[
                            AppColors.black.withOpacity(0.05),
                            AppColors.black.withOpacity(0.55),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ];
        },
        body: ListView(
          padding: const EdgeInsets.fromLTRB(
            PharosLayout.spaceLg,
            PharosLayout.spaceMd,
            PharosLayout.spaceLg,
            120,
          ),
          physics: const BouncingScrollPhysics(),
          children: [
            Text(
              _product.name,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: AppColors.text,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: PharosLayout.spaceSm),
            Text(
              '${_product.price} PLN',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: AppColors.accent,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: PharosLayout.spaceMd),
            const Divider(height: 1),
            const SizedBox(height: PharosLayout.spaceMd),
            Text(
              'Opis produktu',
              style: theme.textTheme.titleMedium?.copyWith(
                color: AppColors.text,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: PharosLayout.spaceSm),
            SelectableText(
              _product.description ??
                  'Ten produkt nie posiada jeszcze opisu w systemie PrestaShop.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: AppColors.text.withOpacity(0.88),
                height: 1.55,
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(PharosLayout.spaceLg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(
            top: BorderSide(color: AppColors.black.withOpacity(0.35)),
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: AppColors.black.withOpacity(0.25),
              offset: const Offset(0, -4),
              blurRadius: 12,
            ),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(PharosLayout.radiusMd),
              ),
              backgroundColor: AppColors.accent,
              foregroundColor: AppColors.text,
              elevation: 0,
            ),
            onPressed: () => _addToCart(context),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shopping_cart_checkout),
                SizedBox(width: 12),
                Text(
                  'DODAJ DO KOSZYKA',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailImage() {
    if (!_product.hasImageUrl) {
      return ColoredBox(
        color: AppColors.surface,
        child: Icon(
          Icons.image_not_supported,
          size: 100,
          color: AppColors.text.withOpacity(0.35),
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: _product.imageUrl,
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
  }
}

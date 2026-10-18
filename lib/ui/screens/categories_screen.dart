import 'package:pharos/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart' hide State;
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pharos/data/models/category_model.dart';
import 'package:pharos/data/repositories/category_repository.dart';
import 'package:pharos/ui/screens/catalog_screen.dart';
import 'package:pharos/core/error/failures.dart';
import 'package:pharos/ui/widgets/list_shimmer.dart';
import 'package:pharos/ui/widgets/network_error_state.dart';
import 'package:pharos/l10n/app_localizations.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  late Future<Either<Failure, List<CategoryModel>>> _categoriesFuture;
  bool _initialLoadDone = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialLoadDone) {
      _initialLoadDone = true;
      _loadCategories();
    }
  }

  void _loadCategories() {
    _categoriesFuture = context.read<ICategoryRepository>().getCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          AppLocalizations.of(context)!.categoriesTitle,
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2, color: AppColors.text),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<Either<Failure, List<CategoryModel>>>(
        future: _categoriesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Padding(padding: EdgeInsets.all(16), child: ListShimmer(itemCount: 6));
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return NetworkErrorState(
              message: 'Nie udało się pobrać kategorii.',
              onRetry: () => setState(_loadCategories),
            );
          }

          return snapshot.data!.fold(
            (failure) => NetworkErrorState(
              message: failure.message,
              onRetry: () => setState(_loadCategories),
            ),
            (categories) {
              if (categories.isEmpty) {
                return const Center(
                  child: Text(
                    'Brak kategorii do wyświetlenia.',
                    style: TextStyle(color: AppColors.textDisabled),
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async => setState(_loadCategories),
                color: AppColors.accentText,
                backgroundColor: const Color(0xFF1A1A1A),
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.85,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: categories.length,
                  itemBuilder: (context, index) => _CategoryCard(category: categories[index]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final CategoryModel category;

  const _CategoryCard({required this.category});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.text.withValues(alpha: 0.05),
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CatalogScreen(
                title: category.name,
                categoryId: category.id,
              ),
            ),
          );
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (category.imageUrl.isNotEmpty)
              CachedNetworkImage(
                imageUrl: category.imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => ColoredBox(
                  color: AppColors.text.withValues(alpha: 0.04),
                  child: const Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accentText)),
                ),
                errorWidget: (context, url, error) => _buildPlaceholder(),
              )
            else
              _buildPlaceholder(),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    AppColors.black.withValues(alpha: 0.85),
                    AppColors.black.withValues(alpha: 0.15),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  category.name.toUpperCase(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return ColoredBox(
      color: AppColors.text.withValues(alpha: 0.04),
      child: Center(
        child: Icon(Icons.category_outlined, size: 48, color: AppColors.text.withValues(alpha: 0.15)),
      ),
    );
  }
}

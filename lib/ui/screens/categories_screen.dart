import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart' hide State;
import 'package:provider/provider.dart';
import 'package:pharos/data/models/category_model.dart';
import 'package:pharos/data/repositories/category_repository.dart';
import 'package:pharos/ui/screens/catalog_screen.dart';
import 'package:pharos/core/error/failures.dart';
import 'package:pharos/ui/widgets/list_shimmer.dart';
import 'package:pharos/ui/widgets/network_error_state.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  late Future<Either<Failure, List<CategoryModel>>> _categoriesFuture;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  void _loadCategories() {
    _categoriesFuture = context.read<ICategoryRepository>().getCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KATEGORIE', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2)),
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
                return const SizedBox.shrink();
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: categories.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) => _CategoryTile(category: categories[index]),
              );
            },
          );
        },
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final CategoryModel category;
  const _CategoryTile({required this.category});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.05),
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Colors.white10),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        title: Text(
          category.name.toUpperCase(),
          style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.orange),
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
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:pharos/core/utils/product_list_filters.dart';
import 'package:pharos/data/models/product_model.dart';
import 'package:pharos/data/repositories/product_repository.dart';
import 'package:pharos/data/models/filter_model.dart';
import 'package:pharos/data/repositories/category_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchProvider extends ChangeNotifier {
  SearchProvider(
    this._repository, {
    ICategoryRepository? categoryRepository,
  }) : _categoryRepository = categoryRepository {
    _initializeFilters();
    _loadRecentSearches();
  }

  final IProductRepository _repository;
  final ICategoryRepository? _categoryRepository;

  String _query = '';
  List<ProductModel> _searchResults = [];
  List<ProductModel> _suggestions = [];
  List<String> _recentSearches = [];
  List<FilterGroup> _availableFilters = [];
  bool _isSearching = false;
  bool _isSuggesting = false;
  int _filterRevision = 0;
  Timer? _debounce;

  String get query => _query;
  List<ProductModel> get searchResults => _searchResults;
  List<ProductModel> get suggestions => _suggestions;
  List<String> get recentSearches => _recentSearches;
  List<FilterGroup> get availableFilters => _availableFilters;
  bool get isSearching => _isSearching;
  bool get isSuggesting => _isSuggesting;
  int get filterRevision => _filterRevision;

  Future<void> _initializeFilters() async {
    _availableFilters = [
      FilterGroup(
        id: ProductListFilters.sortGroupId,
        name: 'Sortowanie',
        allowMultiple: false,
        values: [
          FilterValue(id: ProductSortOption.recommended.name, name: 'Polecane'),
          FilterValue(id: ProductSortOption.priceAsc.name, name: 'Cena: od najniższej'),
          FilterValue(id: ProductSortOption.priceDesc.name, name: 'Cena: od najwyższej'),
          FilterValue(id: ProductSortOption.nameAsc.name, name: 'Nazwa: A-Z'),
          FilterValue(id: ProductSortOption.newest.name, name: 'Najnowsze'),
        ],
      ),
      FilterGroup(id: ProductListFilters.categoryGroupId, name: 'Kategoria', values: []),
      FilterGroup(
        id: ProductListFilters.priceGroupId,
        name: 'Cena',
        allowMultiple: false,
        values: [
          FilterValue(id: 'p1', name: '0 - 100 PLN'),
          FilterValue(id: 'p2', name: '100 - 500 PLN'),
          FilterValue(id: 'p3', name: 'Powyżej 500 PLN'),
        ],
      ),
    ];

    _availableFilters
        .firstWhere((group) => group.id == ProductListFilters.sortGroupId)
        .values
        .first
        .isSelected = true;

    await _loadCategoryFilters();
    notifyListeners();
  }

  Future<void> _loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    _recentSearches = prefs.getStringList('recent_searches') ?? [];
    notifyListeners();
  }

  Future<void> _loadCategoryFilters() async {
    final categoryRepository = _categoryRepository;
    if (categoryRepository == null) {
      return;
    }

    final categoriesResult = await categoryRepository.getCategories();
    categoriesResult.fold(
      (_) {},
      (categories) {
        final categoryGroup = _availableFilters.firstWhere(
          (group) => group.id == ProductListFilters.categoryGroupId,
        );
        categoryGroup.values
          ..clear()
          ..addAll(
            categories.map(
              (category) => FilterValue(
                id: category.id.toString(),
                name: category.name,
              ),
            ),
          );
      },
    );
  }

  Future<void> _saveRecentSearch(String query) async {
    if (query.trim().isEmpty) return;

    _recentSearches.remove(query);
    _recentSearches.insert(0, query);

    if (_recentSearches.length > 10) {
      _recentSearches = _recentSearches.sublist(0, 10);
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('recent_searches', _recentSearches);
    notifyListeners();
  }

  Future<void> removeRecentSearch(String query) async {
    _recentSearches.remove(query);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('recent_searches', _recentSearches);
    notifyListeners();
  }

  Future<void> clearRecentSearches() async {
    _recentSearches.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('recent_searches');
    notifyListeners();
  }

  void toggleFilter(String groupId, String valueId) {
    final group = _availableFilters.firstWhere((groupItem) => groupItem.id == groupId);
    final value = group.values.firstWhere((filterValue) => filterValue.id == valueId);

    if (group.allowMultiple) {
      value.isSelected = !value.isSelected;
    } else {
      for (final filterValue in group.values) {
        filterValue.isSelected = filterValue.id == valueId;
      }
    }

    _notifyFiltersChanged(reloadSearch: _query.isNotEmpty);
  }

  void clearFilters() {
    for (final group in _availableFilters) {
      for (final value in group.values) {
        value.isSelected = false;
      }
    }

    final sortGroup = _availableFilters.firstWhere(
      (group) => group.id == ProductListFilters.sortGroupId,
    );
    if (sortGroup.values.isNotEmpty) {
      sortGroup.values.first.isSelected = true;
    }

    _notifyFiltersChanged(reloadSearch: _query.isNotEmpty);
  }

  void _notifyFiltersChanged({required bool reloadSearch}) {
    _filterRevision++;
    notifyListeners();

    if (reloadSearch) {
      _isSearching = true;
      notifyListeners();
      _performSearch(_query);
    }
  }

  void onQueryChanged(String newQuery) {
    _query = newQuery;
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    if (newQuery.isEmpty) {
      _searchResults = [];
      _suggestions = [];
      _isSearching = false;
      _isSuggesting = false;
      notifyListeners();
      return;
    }

    if (newQuery.length < 3) {
      _suggestions = [];
      _isSuggesting = false;
      notifyListeners();
      return;
    }

    _isSuggesting = true;
    notifyListeners();

    _debounce = Timer(const Duration(milliseconds: 300), () => _loadSuggestions(newQuery));
  }

  Future<void> _loadSuggestions(String query) async {
    final result = await _repository.searchProducts(query);

    result.fold(
      (_) => _suggestions = [],
      (products) => _suggestions = products.take(5).toList(),
    );

    _isSuggesting = false;
    notifyListeners();
  }

  Map<String, List<String>> getSelectedFilters() {
    final Map<String, List<String>> selected = {};
    for (final group in _availableFilters) {
      final selectedValues = group.values
          .where((value) => value.isSelected)
          .map((value) => value.id)
          .toList();
      if (selectedValues.isNotEmpty) {
        selected[group.id] = selectedValues;
      }
    }
    return selected;
  }

  void performFullSearch() {
    if (_query.isEmpty) return;

    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _isSearching = true;
    _suggestions = [];
    _saveRecentSearch(_query);
    notifyListeners();

    _performSearch(_query);
  }

  Future<void> _performSearch(String query) async {
    final filters = getSelectedFilters();
    final result = await _repository.searchProducts(query, filters: filters);

    result.fold(
      (_) => _searchResults = [],
      (products) => _searchResults = products,
    );

    _isSearching = false;
    _isSuggesting = false;
    notifyListeners();
  }

  void clearSearch() {
    _query = '';
    _searchResults = [];
    _suggestions = [];
    _isSearching = false;
    _isSuggesting = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}

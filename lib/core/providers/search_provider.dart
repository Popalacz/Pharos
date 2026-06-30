import 'package:flutter/material.dart';
import 'dart:async';
import 'package:pharos/data/models/product_model.dart';
import 'package:pharos/data/repositories/product_repository.dart';

import 'package:pharos/data/models/filter_model.dart';

import 'package:shared_preferences/shared_preferences.dart';

class SearchProvider extends ChangeNotifier {
  final IProductRepository _repository;
  
  String _query = '';
  List<ProductModel> _searchResults = [];
  List<ProductModel> _suggestions = [];
  List<String> _recentSearches = [];
  List<FilterGroup> _availableFilters = [];
  bool _isSearching = false;
  bool _isSuggesting = false;
  Timer? _debounce;

  SearchProvider(this._repository) {
    _loadAvailableFilters();
    _loadRecentSearches();
  }

  String get query => _query;
  List<ProductModel> get searchResults => _searchResults;
  List<ProductModel> get suggestions => _suggestions;
  List<String> get recentSearches => _recentSearches;
  List<FilterGroup> get availableFilters => _availableFilters;
  bool get isSearching => _isSearching;
  bool get isSuggesting => _isSuggesting;

  Future<void> _loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    _recentSearches = prefs.getStringList('recent_searches') ?? [];
    notifyListeners();
  }

  Future<void> _saveRecentSearch(String query) async {
    if (query.trim().isEmpty) return;
    
    _recentSearches.remove(query); // Remove if already exists to move to top
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

  void _loadAvailableFilters() async {
    // Symulacja pobrania dostępnych filtrów z PrestaShop Faceted Search
    await Future.delayed(const Duration(milliseconds: 300));
    _availableFilters = [
      FilterGroup(id: 'category', name: 'Kategoria', values: [
        FilterValue(id: '1', name: 'Oświetlenie'),
        FilterValue(id: '2', name: 'Smart Home'),
      ]),
      FilterGroup(id: 'price', name: 'Cena', values: [
        FilterValue(id: 'p1', name: '0 - 100 PLN'),
        FilterValue(id: 'p2', name: '100 - 500 PLN'),
        FilterValue(id: 'p3', name: 'Powyżej 500 PLN'),
      ]),
      FilterGroup(id: 'color', name: 'Kolor', values: [
        FilterValue(id: 'c1', name: 'Czarny', colorHex: '#000000'),
        FilterValue(id: 'c2', name: 'Biały', colorHex: '#FFFFFF'),
        FilterValue(id: 'c3', name: 'Pomarańczowy', colorHex: '#FF9800'),
      ]),
    ];
    notifyListeners();
  }

  void toggleFilter(String groupId, String valueId) {
    final group = _availableFilters.firstWhere((g) => g.id == groupId);
    final value = group.values.firstWhere((v) => v.id == valueId);
    value.isSelected = !value.isSelected;
    
    // Po każdej zmianie filtra odświeżamy wyniki
    _isSearching = true;
    notifyListeners();
    _performSearch(_query);
  }

  void clearFilters() {
    for (var group in _availableFilters) {
      for (var value in group.values) {
        value.isSelected = false;
      }
    }
    _isSearching = true;
    notifyListeners();
    _performSearch(_query);
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

    // Fast debounce for autocomplete suggestions
    _debounce = Timer(const Duration(milliseconds: 300), () => _loadSuggestions(newQuery));
  }

  Future<void> _loadSuggestions(String query) async {
    final result = await _repository.searchProducts(query);
    
    result.fold(
      (failure) {
        _suggestions = [];
      },
      (products) {
        _suggestions = products.take(5).toList(); // Show top 5 suggestions
      },
    );

    _isSuggesting = false;
    notifyListeners();
  }

  Map<String, List<String>> getSelectedFilters() {
    final Map<String, List<String>> selected = {};
    for (var group in _availableFilters) {
      final selectedValues = group.values
          .where((v) => v.isSelected)
          .map((v) => v.id)
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
      (failure) {
        _searchResults = [];
      },
      (products) {
        _searchResults = products;
      },
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

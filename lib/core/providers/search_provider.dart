import 'package:flutter/material.dart';
import 'dart:async';
import 'package:pharos/data/models/product_model.dart';
import 'package:pharos/data/repositories/product_repository.dart';

import 'package:pharos/data/models/filter_model.dart';

class SearchProvider extends ChangeNotifier {
  final IProductRepository _repository;
  
  String _query = '';
  List<ProductModel> _searchResults = [];
  List<FilterGroup> _availableFilters = [];
  bool _isSearching = false;
  Timer? _debounce;

  SearchProvider(this._repository) {
    _loadAvailableFilters();
  }

  String get query => _query;
  List<ProductModel> get searchResults => _searchResults;
  List<FilterGroup> get availableFilters => _availableFilters;
  bool get isSearching => _isSearching;

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
      _isSearching = false;
      notifyListeners();
      return;
    }

    _isSearching = true;
    notifyListeners();

    _debounce = Timer(const Duration(milliseconds: 500), () => _performSearch(newQuery));
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

  Future<void> _performSearch(String query) async {
    final filters = getSelectedFilters();
    _searchResults = await _repository.searchProducts(query, filters: filters);
    _isSearching = false;
    notifyListeners();
  }

  void clearSearch() {
    _query = '';
    _searchResults = [];
    _isSearching = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}

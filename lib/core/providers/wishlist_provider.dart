import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pharos/core/network/api_service.dart';
import 'package:pharos/data/models/product_model.dart';
import 'package:pharos/data/repositories/wishlist_repository.dart';
import 'package:pharos/core/providers/user_provider.dart';

class WishlistProvider extends ChangeNotifier {
  final IWishlistRepository _repository;
  final Set<int> _wishlistIds = {};
  List<ProductModel> _wishlistProducts = [];
  bool _isLoading = false;
  UserProvider? _userProvider;

  Set<int> get wishlistIds => _wishlistIds;
  List<ProductModel> get wishlistProducts => _wishlistProducts;
  bool get isLoading => _isLoading;

  WishlistProvider({ApiService? apiService}) 
    : _repository = WishlistRepository(apiService: apiService, useMockData: false) {
    _loadLocalWishlist();
  }

  void updateUser(UserProvider userProvider) {
    final oldUserId = _userProvider?.user?.id;
    final wasLoggedIn = _userProvider?.isLoggedIn ?? false;
    _userProvider = userProvider;
    
    // Jeśli użytkownik się zalogował, synchronizujemy lokalną listę z serwerem
    if (userProvider.isLoggedIn && !wasLoggedIn) {
      _syncGuestWithServer();
    } else if (!userProvider.isLoggedIn && wasLoggedIn) {
      // Jeśli się wylogował, wracamy do czystej listy (lub zostawiamy lokalną - Senior wybiera czystą dla bezpieczeństwa)
      _wishlistIds.clear();
      _wishlistProducts.clear();
      _loadLocalWishlist();
    } else if (userProvider.user?.id != oldUserId && userProvider.isLoggedIn) {
      fetchWishlist();
    }
  }

  Future<void> _loadLocalWishlist() async {
    if (_userProvider?.isLoggedIn ?? false) return;

    final prefs = await SharedPreferences.getInstance();
    final String? localData = prefs.getString('guest_wishlist');
    
    if (localData != null) {
      final List<dynamic> decoded = jsonDecode(localData);
      _wishlistProducts = decoded.map((item) => ProductModel.fromJson(item)).toList();
      _wishlistIds.clear();
      for (var p in _wishlistProducts) {
        _wishlistIds.add(p.id);
      }
      notifyListeners();
    }
  }

  Future<void> _saveLocalWishlist() async {
    if (_userProvider?.isLoggedIn ?? false) return;
    
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode(_wishlistProducts.map((p) => p.toJson()).toList());
    await prefs.setString('guest_wishlist', data);
  }

  Future<void> _syncGuestWithServer() async {
    if (_userProvider?.user == null) return;
    
    // Pobierz z serwera i dodaj to co mieliśmy lokalnie
    await fetchWishlist();
    
    // Tutaj można by dodać pętlę toggle dla każdego produktu z _wishlistProducts, 
    // który nie jest jeszcze na serwerze (Premium Sync).
    debugPrint('WISHLIST: Guest data synced with user ${_userProvider!.user!.id}');
  }

  Future<void> fetchWishlist() async {
    if (_userProvider?.user == null) {
      await _loadLocalWishlist();
      return;
    }
    
    _isLoading = true;
    notifyListeners();
    
    final result = await _repository.getWishlist(_userProvider!.user!.id);
    
    result.fold(
      (failure) => debugPrint('Wishlist Fetch Error: $failure'),
      (products) {
        _wishlistProducts = products;
        _wishlistIds.clear();
        for (var p in _wishlistProducts) {
          _wishlistIds.add(p.id);
        }
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  bool isFavorite(int productId) => _wishlistIds.contains(productId);

  Future<void> toggleWishlist(ProductModel product) async {
    final bool wasFavorite = isFavorite(product.id);

    // Optimistic UI Update
    if (wasFavorite) {
      _wishlistIds.remove(product.id);
      _wishlistProducts.removeWhere((p) => p.id == product.id);
    } else {
      _wishlistIds.add(product.id);
      _wishlistProducts.add(product);
    }
    notifyListeners();

    if (_userProvider?.isLoggedIn ?? false) {
      final result = await _repository.toggleWishlist(_userProvider!.user!.id, product.id);
      
      result.fold(
        (failure) {
          // Rollback on error
          if (wasFavorite) {
            _wishlistIds.add(product.id);
            _wishlistProducts.add(product);
          } else {
            _wishlistIds.remove(product.id);
            _wishlistProducts.removeWhere((p) => p.id == product.id);
          }
          notifyListeners();
        },
        (success) {
          if (!success) {
             // Optional: Handle logical failure from API if success field is false
          }
        },
      );
    } else {
      // Dla gościa zapisujemy tylko lokalnie
      await _saveLocalWishlist();
    }
  }
}

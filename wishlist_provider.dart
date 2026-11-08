import 'package:flutter/material.dart';
import '../data/models/product.dart';
import 'local_storage.dart';

class WishlistProvider extends ChangeNotifier {
  List<Product> _items = [];

  List<Product> get items => _items;
  int get count => _items.length;

  WishlistProvider() {
    _load();
  }

  Future<void> _load() async {
    _items = await LocalStorageService.loadWishlist();
    notifyListeners();
  }

  bool contains(int productId) => _items.any((p) => p.id == productId);

  void toggle(Product product) {
    if (contains(product.id)) {
      _items.removeWhere((p) => p.id == product.id);
    } else {
      _items.add(product);
    }
    notifyListeners();
    LocalStorageService.saveWishlist(_items);
  }

  int remove(int productId) {
    final idx = _items.indexWhere((p) => p.id == productId);
    if (idx != -1) {
      _items.removeAt(idx);
      notifyListeners();
      LocalStorageService.saveWishlist(_items);
    }
    return idx;
  }

  void restore(Product product, int index) {
    if (index >= 0 && index <= _items.length) {
      _items.insert(index, product);
    } else {
      _items.add(product);
    }
    notifyListeners();
    LocalStorageService.saveWishlist(_items);
  }
}

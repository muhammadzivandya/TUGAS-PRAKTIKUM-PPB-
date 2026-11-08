import 'dart:async';
import 'package:flutter/material.dart';
import '../data/api_service.dart';
import '../data/models/product.dart';
import '../ui/ui_types.dart';

enum LoadingStatus { initial, loading, loaded, loadingMore, error }

class ProductsProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Product> _items = [];
  int _total = 0;
  int _skip = 0;
  LoadingStatus _status = LoadingStatus.initial;
  String _errorMessage = '';

  String _query = '';
  String? _selectedCategory;
  SortOption _sort = SortOption.defaultSort;
  FilterOptions _filters = FilterOptions();
  List<String> _categorySlugs = [];

  Timer? _debounceTimer;

  List<Product> get items => _items;
  int get total => _total;
  LoadingStatus get status => _status;
  String get errorMessage => _errorMessage;
  String get query => _query;
  String? get selectedCategory => _selectedCategory;
  SortOption get sort => _sort;
  FilterOptions get filters => _filters;
  List<String> get categorySlugs => _categorySlugs;
  bool get hasMore => _items.length < _total && _selectedCategory == null && _query.isEmpty;

  ProductsProvider() {
    init();
  }

  Future<void> init() async {
    try {
      _categorySlugs = await _apiService.getCategoryList();
    } catch (_) {}
    loadProducts();
  }

  Future<void> loadProducts({bool isRefresh = false}) async {
    if (isRefresh) {
      _skip = 0;
      _items.clear();
    }
    _status = _items.isEmpty ? LoadingStatus.loading : LoadingStatus.loadingMore;
    notifyListeners();

    try {
      if (_query.isNotEmpty) {
        final results = await _apiService.searchProducts(_query);
        _items = _applySortAndFilter(results);
        _total = _items.length;
      } else if (_selectedCategory != null) {
        final results = await _apiService.getProductsByCategory(_selectedCategory!);
        _items = _applySortAndFilter(results);
        _total = _items.length;
      } else {
        String? apiSortBy;
        String? apiOrder;

        if (_sort == SortOption.priceLowHigh) {
          apiSortBy = 'price';
          apiOrder = 'asc';
        } else if (_sort == SortOption.priceHighLow) {
          apiSortBy = 'price';
          apiOrder = 'desc';
        }

        final res = await _apiService.getProducts(limit: 20, skip: _skip, sortBy: apiSortBy, order: apiOrder);
        final newItems = res['products'] as List<Product>;
        _total = res['total'] as int;
        if (isRefresh) {
          _items = newItems;
        } else {
          _items.addAll(newItems);
        }
        _items = _applySortAndFilter(_items);
      }
      _status = LoadingStatus.loaded;
    } catch (e) {
      _errorMessage = e.toString();
      _status = LoadingStatus.error;
    }
    notifyListeners();
  }

  void loadMore() {
    if (hasMore && _status != LoadingStatus.loadingMore) {
      _skip += 20;
      loadProducts();
    }
  }

  void setQuery(String q) {
    _query = q;
    if (q.isNotEmpty) _selectedCategory = null;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      loadProducts(isRefresh: true);
    });
  }

  void selectCategory(String? slug) {
    _selectedCategory = slug;
    if (slug != null) _query = '';
    loadProducts(isRefresh: true);
  }

  void setSort(SortOption option) {
    _sort = option;
    loadProducts(isRefresh: true);
  }

  void setFilters(FilterOptions opts) {
    _filters = opts;
    loadProducts(isRefresh: true);
  }

  List<Product> _applySortAndFilter(List<Product> list) {
    var result = List<Product>.from(list);
    if (_filters.onlyInStock) {
      result = result.where((p) => p.stock > 0).toList();
    }
    if (_filters.minRating > 0) {
      result = result.where((p) => p.rating >= _filters.minRating).toList();
    }

    if (_sort == SortOption.ratingHigh) {
      result.sort((a, b) => b.rating.compareTo(a.rating));
    } else if (_sort == SortOption.nameAZ) {
      result.sort((a, b) => a.title.compareTo(b.title));
    }
    return result;
  }
}

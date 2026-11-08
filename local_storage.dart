import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/product.dart';

class LocalStorageService {
  static const _wishlistKey = 'zoymart.wishlist.v1';
  static const _cartKey = 'zoymart.cart.v1';

  static Future<void> saveWishlist(List<Product> items) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = items.map((e) => e.toStorageJson()).toList();
    await prefs.setString(_wishlistKey, jsonEncode(jsonList));
  }

  static Future<List<Product>> loadWishlist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString(_wishlistKey);
      if (data == null) return [];
      final List decoded = jsonDecode(data);
      return decoded.map((e) => Product.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveCart(List<Map<String, dynamic>> lines, String? voucherCode) async {
    final prefs = await SharedPreferences.getInstance();
    final data = {
      'lines': lines.map((l) => {
        'product': (l['product'] as Product).toStorageJson(),
        'qty': l['qty'],
        'selected': l['selected'],
      }).toList(),
      'voucherCode': voucherCode,
    };
    await prefs.setString(_cartKey, jsonEncode(data));
  }

  static Future<Map<String, dynamic>> loadCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString(_cartKey);
      if (data == null) return {'lines': [], 'voucherCode': null};
      final decoded = jsonDecode(data);
      final List linesRaw = decoded['lines'] ?? [];
      final lines = linesRaw.map<Map<String, dynamic>>((l) => {
        'product': Product.fromJson(l['product']),
        'qty': l['qty'] as int,
        'selected': l['selected'] as bool,
      }).toList();
      return {'lines': lines, 'voucherCode': decoded['voucherCode']};
    } catch (_) {
      return {'lines': [], 'voucherCode': null};
    }
  }
}

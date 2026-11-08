import 'package:flutter/material.dart';
import '../data/models/product.dart';
import '../ui/format/formatters.dart';
import '../ui/ui_types.dart';
import 'local_storage.dart';

class CartLine {
  final Product product;
  int qty;
  bool selected;

  CartLine({required this.product, required this.qty, this.selected = true});
}

class CartProvider extends ChangeNotifier {
  List<CartLine> _lines = [];
  String? _voucherCode;

  List<CartLine> get lines => _lines;
  int get badgeCount => _lines.length;
  String? get voucherCode => _voucherCode;

  CartProvider() {
    _load();
  }

  Future<void> _load() async {
    final data = await LocalStorageService.loadCart();
    final loadedLines = (data['lines'] as List).map((l) => CartLine(
      product: l['product'],
      qty: l['qty'],
      selected: l['selected'],
    )).toList();
    _lines = loadedLines;
    _voucherCode = data['voucherCode'];
    notifyListeners();
  }

  void _save() {
    final rawLines = _lines.map((l) => {
      'product': l.product,
      'qty': l.qty,
      'selected': l.selected,
    }).toList();
    LocalStorageService.saveCart(rawLines, _voucherCode);
  }

  bool add(Product product, int qty) {
    if (product.stock == 0) return false;

    final idx = _lines.indexWhere((l) => l.product.id == product.id);
    if (idx != -1) {
      final current = _lines[idx].qty;
      final newQty = (current + qty).clamp(1, product.stock);
      _lines[idx].qty = newQty;
    } else {
      _lines.add(CartLine(product: product, qty: qty.clamp(1, product.stock)));
    }
    notifyListeners();
    _save();
    return true;
  }

  void setQty(int productId, int qty) {
    final idx = _lines.indexWhere((l) => l.product.id == productId);
    if (idx != -1) {
      _lines[idx].qty = qty.clamp(1, _lines[idx].product.stock);
      notifyListeners();
      _save();
    }
  }

  void remove(int productId) {
    final idx = _lines.indexWhere((l) => l.product.id == productId);
    if (idx != -1) {
      _lines.removeAt(idx);
      notifyListeners();
      _save();
    }
  }

  void toggleSelected(int productId) {
    final idx = _lines.indexWhere((l) => l.product.id == productId);
    if (idx != -1) {
      _lines[idx].selected = !_lines[idx].selected;
      notifyListeners();
      _save();
    }
  }

  void selectAll(bool selected) {
    for (var l in _lines) {
      l.selected = selected;
    }
    notifyListeners();
    _save();
  }

  void removeSelected() {
    _lines.removeWhere((l) => l.selected);
    notifyListeners();
    _save();
  }

  CartSummary get summary {
    double subtotal = 0;
    double savings = 0;

    for (var line in _lines.where((l) => l.selected)) {
      final price = Formatters.discountedPrice(line.product);
      subtotal += price * line.qty;
      savings += (line.product.price - price) * line.qty;
    }

    double voucherDiscount = 0;
    if (_voucherCode == 'ZOYPASTEL' && subtotal >= 50.0) {
      voucherDiscount = 10.0;
    }

    subtotal = double.parse(subtotal.toStringAsFixed(2));
    savings = double.parse(savings.toStringAsFixed(2));
    final total = double.parse((subtotal - voucherDiscount).clamp(0.0, double.infinity).toStringAsFixed(2));

    return CartSummary(
      subtotal: subtotal,
      productSavings: savings,
      voucherDiscount: voucherDiscount,
      shipping: 0.0,
      total: total,
    );
  }

  String applyVoucher(String code) {
    final cleanCode = code.trim().toUpperCase();
    if (cleanCode != 'ZOYPASTEL') return 'KODE_SALAH';
    if (summary.subtotal < 50.0) return 'MINIMUM_KURANG';
    _voucherCode = cleanCode;
    notifyListeners();
    _save();
    return 'SUKSES';
  }

  Future<void> checkout() async {
    await Future.delayed(const Duration(milliseconds: 1200));
    removeSelected();
  }
}

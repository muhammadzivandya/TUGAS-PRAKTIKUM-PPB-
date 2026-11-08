import '../../data/models/product.dart';

class Formatters {
  static double discountedPrice(Product p) {
    final raw = p.price * (1.0 - (p.discountPercentage / 100.0));
    return double.parse(raw.toStringAsFixed(2));
  }

  static String badgeType(double rating) {
    if (rating >= 4.8) return 'Best Seller';
    if (rating >= 4.5) return 'Populer';
    return '';
  }

  static String stockStatusText(int stock) {
    if (stock == 0) return 'Habis';
    if (stock <= 5) return 'Sisa $stock';
    if (stock <= 15) return 'Tersedia';
    return 'Stok Aman';
  }

  static String returnPolicyText(String policy) {
    if (policy.toLowerCase().contains('no return')) {
      return 'Tanpa Pengembalian';
    }
    final match = RegExp(r'\d+').firstMatch(policy);
    if (match != null) {
      return 'Bebas Pengembalian (\${match.group(0)} hari)';
    }
    return 'Bebas Pengembalian';
  }
}

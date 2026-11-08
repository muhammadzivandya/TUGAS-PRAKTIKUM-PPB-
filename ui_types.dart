enum SortOption { defaultSort, priceLowHigh, priceHighLow, ratingHigh, nameAZ }

class FilterOptions {
  final double minRating;
  final bool onlyInStock;

  FilterOptions({this.minRating = 0, this.onlyInStock = false});

  FilterOptions copyWith({double? minRating, bool? onlyInStock}) {
    return FilterOptions(
      minRating: minRating ?? this.minRating,
      onlyInStock: onlyInStock ?? this.onlyInStock,
    );
  }
}

class CartSummary {
  final double subtotal;
  final double productSavings;
  final double voucherDiscount;
  final double shipping;
  final double total;

  CartSummary({
    required this.subtotal,
    required this.productSavings,
    required this.voucherDiscount,
    required this.shipping,
    required this.total,
  });
}

class CartItem {
  final String productId;
  final String productName;
  final int quantity;
  final double unitPrice;
  final double? overriddenPrice;
  final String? overrideReason;

  CartItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    this.overriddenPrice,
    this.overrideReason,
  });

  double get effectivePrice => overriddenPrice ?? unitPrice;
  double get total => effectivePrice * quantity;

  CartItem copyWith({
    String? productId,
    String? productName,
    int? quantity,
    double? unitPrice,
    double? overriddenPrice,
    String? overrideReason,
  }) {
    return CartItem(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      overriddenPrice: overriddenPrice ?? this.overriddenPrice,
      overrideReason: overrideReason ?? this.overrideReason,
    );
  }
}

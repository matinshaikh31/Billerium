class BillItemModel {
  final String productId;
  final String productName;
  final String? categoryId; // Nullable for backward compatibility
  final String? categoryName; // Nullable for backward compatibility
  final double price;
  final int quantity;
  final double discountPercent; 
  final double discountAmount;
  final double itemTotal; // Total after discount

  const BillItemModel({
    required this.productId,
    required this.productName,
    this.categoryId,
    this.categoryName,
    required this.price,
    required this.quantity,
    required this.discountPercent,
    required this.discountAmount,
    required this.itemTotal,
  });

  /// Get display name with category
  String get displayName {
    if (categoryName != null && categoryName!.isNotEmpty) {
      return '$productName ($categoryName)';
    }
    return productName;
  }

  factory BillItemModel.fromJson(Map<String, dynamic> json) {
    return BillItemModel(
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      categoryId: json['categoryId'] as String?,
      categoryName: json['categoryName'] as String?,
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'] as int,
      discountPercent: (json['discountPercent'] as num).toDouble(),
      discountAmount: (json['discountAmount'] as num).toDouble(),
      itemTotal: (json['itemTotal'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'price': price,
      'quantity': quantity,
      'discountPercent': discountPercent,
      'discountAmount': discountAmount,
      'itemTotal': itemTotal,
    };
  }

  BillItemModel copyWith({
    String? productId,
    String? productName,
    String? categoryId,
    String? categoryName,
    double? price,
    int? quantity,
    double? discountPercent,
    double? discountAmount,
    double? itemTotal,
  }) {
    return BillItemModel(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      discountPercent: discountPercent ?? this.discountPercent,
      discountAmount: discountAmount ?? this.discountAmount,
      itemTotal: itemTotal ?? this.itemTotal,
    );
  }
}

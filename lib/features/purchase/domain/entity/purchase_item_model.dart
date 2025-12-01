class PurchaseItemModel {
  final String productId;
  final String productName;
  final int quantity;
  final double purchasePrice;
  final double total;

  const PurchaseItemModel({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.purchasePrice,
    required this.total,
  });

  factory PurchaseItemModel.fromJson(Map<String, dynamic> json) {
    return PurchaseItemModel(
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      quantity: json['quantity'] as int,
      purchasePrice: (json['purchasePrice'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'purchasePrice': purchasePrice,
      'total': total,
    };
  }
}


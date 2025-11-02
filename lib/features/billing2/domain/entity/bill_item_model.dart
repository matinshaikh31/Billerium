class BillItemModel {
  final String productId;
  final String productName;
  final double price;
  final int quantity;
  final double discountPercent;
  final double discountAmount;
  final double itemTotal;

  const BillItemModel({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.discountPercent,
    required this.discountAmount,
    required this.itemTotal,
  });

  factory BillItemModel.fromJson(Map<String, dynamic> json) {
    return BillItemModel(
      productId: json['productId'] as String,
      productName: json['productName'] as String,
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
      'price': price,
      'quantity': quantity,
      'discountPercent': discountPercent,
      'discountAmount': discountAmount,
      'itemTotal': itemTotal,
    };
  }
}

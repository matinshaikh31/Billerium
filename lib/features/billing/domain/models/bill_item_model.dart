import 'package:equatable/equatable.dart';

class BillItemModel extends Equatable {
  final String productId;
  final String productName;
  final double price;
  final int quantity;
  final double discountPercent;
  final double taxPercent;

  const BillItemModel({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.discountPercent,
    required this.taxPercent,
  });

  double get subtotal => price * quantity;

  double get discountAmount => subtotal * (discountPercent / 100);

  double get afterDiscount => subtotal - discountAmount;

  double get taxAmount => afterDiscount * (taxPercent / 100);

  double get total => afterDiscount + taxAmount;

  BillItemModel copyWith({
    String? productId,
    String? productName,
    double? price,
    int? quantity,
    double? discountPercent,
    double? taxPercent,
  }) {
    return BillItemModel(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      discountPercent: discountPercent ?? this.discountPercent,
      taxPercent: taxPercent ?? this.taxPercent,
    );
  }

  @override
  List<Object?> get props => [
        productId,
        productName,
        price,
        quantity,
        discountPercent,
        taxPercent,
      ];
}


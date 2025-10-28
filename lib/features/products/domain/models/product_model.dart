import 'package:equatable/equatable.dart';

class ProductModel extends Equatable {
  final String id;
  final String name;
  final String categoryId;
  final double price;
  final double costPrice;
  final double? discountPercent;
  final double taxPercent;
  final String? sku;
  final String? imageUrl;
  final int stockQty;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProductModel({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.price,
    required this.costPrice,
    this.discountPercent,
    required this.taxPercent,
    this.sku,
    this.imageUrl,
    required this.stockQty,
    required this.createdAt,
    required this.updatedAt,
  });

  ProductModel copyWith({
    String? id,
    String? name,
    String? categoryId,
    double? price,
    double? costPrice,
    double? discountPercent,
    double? taxPercent,
    String? sku,
    String? imageUrl,
    int? stockQty,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      categoryId: categoryId ?? this.categoryId,
      price: price ?? this.price,
      costPrice: costPrice ?? this.costPrice,
      discountPercent: discountPercent ?? this.discountPercent,
      taxPercent: taxPercent ?? this.taxPercent,
      sku: sku ?? this.sku,
      imageUrl: imageUrl ?? this.imageUrl,
      stockQty: stockQty ?? this.stockQty,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  double getEffectiveDiscount(double? categoryDiscount) {
    // Product discount overrides category discount
    return discountPercent ?? categoryDiscount ?? 0.0;
  }

  double getDiscountedPrice(double? categoryDiscount) {
    final discount = getEffectiveDiscount(categoryDiscount);
    return price * (1 - discount / 100);
  }

  double getPriceWithTax(double? categoryDiscount) {
    final discountedPrice = getDiscountedPrice(categoryDiscount);
    return discountedPrice * (1 + taxPercent / 100);
  }

  bool get isLowStock => stockQty < 10;

  @override
  List<Object?> get props => [
        id,
        name,
        categoryId,
        price,
        costPrice,
        discountPercent,
        taxPercent,
        sku,
        imageUrl,
        stockQty,
        createdAt,
        updatedAt,
      ];
}


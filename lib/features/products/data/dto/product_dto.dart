import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/product_model.dart';

class ProductDto {
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
  final Timestamp createdAt;
  final Timestamp updatedAt;

  ProductDto({
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

  factory ProductDto.fromJson(Map<String, dynamic> json, String id) {
    return ProductDto(
      id: id,
      name: json['name'] as String,
      categoryId: json['categoryId'] as String,
      price: (json['price'] as num).toDouble(),
      costPrice: (json['costPrice'] as num).toDouble(),
      discountPercent: json['discountPercent'] != null
          ? (json['discountPercent'] as num).toDouble()
          : null,
      taxPercent: (json['taxPercent'] as num).toDouble(),
      sku: json['sku'] as String?,
      imageUrl: json['imageUrl'] as String?,
      stockQty: json['stockQty'] as int,
      createdAt: json['createdAt'] as Timestamp,
      updatedAt: json['updatedAt'] as Timestamp,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'categoryId': categoryId,
      'price': price,
      'costPrice': costPrice,
      'discountPercent': discountPercent,
      'taxPercent': taxPercent,
      'sku': sku,
      'imageUrl': imageUrl,
      'stockQty': stockQty,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  ProductModel toModel() {
    return ProductModel(
      id: id,
      name: name,
      categoryId: categoryId,
      price: price,
      costPrice: costPrice,
      discountPercent: discountPercent,
      taxPercent: taxPercent,
      sku: sku,
      imageUrl: imageUrl,
      stockQty: stockQty,
      createdAt: createdAt.toDate(),
      updatedAt: updatedAt.toDate(),
    );
  }

  factory ProductDto.fromModel(ProductModel model) {
    return ProductDto(
      id: model.id,
      name: model.name,
      categoryId: model.categoryId,
      price: model.price,
      costPrice: model.costPrice,
      discountPercent: model.discountPercent,
      taxPercent: model.taxPercent,
      sku: model.sku,
      imageUrl: model.imageUrl,
      stockQty: model.stockQty,
      createdAt: Timestamp.fromDate(model.createdAt),
      updatedAt: Timestamp.fromDate(model.updatedAt),
    );
  }
}


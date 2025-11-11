import 'package:billing_software/features/categories/domain/antity/category_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id;
  final String name;
  final String categoryId;
  final double price;
  final double? discountPercent;
  final String? sku;
  final int stockQty;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  ProductModel({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.price,
    this.discountPercent,
    this.sku,
    required this.stockQty,
    required this.createdAt,
    required this.updatedAt,
  });
  // Helper method to get category name from list of categories
  String getCategoryName(List<CategoryModel> categories) {
    try {
      final category = categories.firstWhere(
        (cat) => cat.id == categoryId,
        orElse: () => CategoryModel(
          id: '',
          name: 'Uncategorized',
          defaultDiscountPercent: 0,
          createdAt: Timestamp.now(),
          updatedAt: Timestamp.now(),
        ),
      );
      return category.name;
    } catch (e) {
      return 'Uncategorized';
    }
  }

  factory ProductModel.fromJson(Map<String, dynamic> json, String id) {
    return ProductModel(
      id: id,
      name: json['name'] as String,
      categoryId: json['categoryId'] as String,
      price: (json['price'] as num).toDouble(),
      discountPercent: json['discountPercent'] != null
          ? (json['discountPercent'] as num).toDouble()
          : null,
      sku: json['sku'] as String?,
      stockQty: json['stockQty'] as int,
      createdAt: json['createdAt'] as Timestamp,
      updatedAt: json['updatedAt'] as Timestamp,
    );
  }

  factory ProductModel.fromDocSnap(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    return ProductModel.fromJson(doc.data(), doc.id);
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'categoryId': categoryId,
      'price': price,
      'discountPercent': discountPercent,
      'sku': sku,
      'stockQty': stockQty,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  // Calculate final price with discount
  double get finalPrice {
    if (discountPercent != null && discountPercent! > 0) {
      return price - (price * discountPercent! / 100);
    }
    return price;
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryModel {
  final String id;
  final String name;
  final double defaultDiscountPercent;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  CategoryModel({
    required this.id,
    required this.name,
    required this.defaultDiscountPercent,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json, String id) {
    return CategoryModel(
      id: id,
      name: json['name'] as String,
      defaultDiscountPercent: (json['defaultDiscountPercent'] as num)
          .toDouble(),
      createdAt: json['createdAt'] as Timestamp,
      updatedAt: json['updatedAt'] as Timestamp,
    );
  }

  factory CategoryModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CategoryModel.fromJson(data, doc.id);
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'defaultDiscountPercent': defaultDiscountPercent,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

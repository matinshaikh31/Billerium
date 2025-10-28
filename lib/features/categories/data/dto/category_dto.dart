import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/category_model.dart';

class CategoryDto {
  final String id;
  final String name;
  final double defaultDiscountPercent;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  CategoryDto({
    required this.id,
    required this.name,
    required this.defaultDiscountPercent,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CategoryDto.fromJson(Map<String, dynamic> json, String id) {
    return CategoryDto(
      id: id,
      name: json['name'] as String,
      defaultDiscountPercent: (json['defaultDiscountPercent'] as num).toDouble(),
      createdAt: json['createdAt'] as Timestamp,
      updatedAt: json['updatedAt'] as Timestamp,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'defaultDiscountPercent': defaultDiscountPercent,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  CategoryModel toModel() {
    return CategoryModel(
      id: id,
      name: name,
      defaultDiscountPercent: defaultDiscountPercent,
      createdAt: createdAt.toDate(),
      updatedAt: updatedAt.toDate(),
    );
  }

  factory CategoryDto.fromModel(CategoryModel model) {
    return CategoryDto(
      id: model.id,
      name: model.name,
      defaultDiscountPercent: model.defaultDiscountPercent,
      createdAt: Timestamp.fromDate(model.createdAt),
      updatedAt: Timestamp.fromDate(model.updatedAt),
    );
  }
}


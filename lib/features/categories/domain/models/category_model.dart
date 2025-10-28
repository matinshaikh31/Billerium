import 'package:equatable/equatable.dart';

class CategoryModel extends Equatable {
  final String id;
  final String name;
  final double defaultDiscountPercent;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.defaultDiscountPercent,
    required this.createdAt,
    required this.updatedAt,
  });

  CategoryModel copyWith({
    String? id,
    String? name,
    double? defaultDiscountPercent,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      defaultDiscountPercent:
          defaultDiscountPercent ?? this.defaultDiscountPercent,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props =>
      [id, name, defaultDiscountPercent, createdAt, updatedAt];
}


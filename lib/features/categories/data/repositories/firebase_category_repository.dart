import 'package:billing_software/core/services/firebase.dart';
import 'package:billing_software/features/categories/domain/antity/category_model.dart';
import 'package:billing_software/features/categories/domain/repositories/category_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseCategoryRepository extends CategoryRepository {
  final categoriesCollectionRef = FBFireStore.categories;

  @override
  Future<String> createCategory(CategoryModel category) async {
    try {
      final docRef = categoriesCollectionRef.doc();
      final now = Timestamp.now();

      final newCategory = CategoryModel(
        id: docRef.id,
        name: category.name,
        defaultDiscountPercent: category.defaultDiscountPercent,
        createdAt: now,
        updatedAt: now,
      );

      await docRef.set(newCategory.toJson());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create category: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteCategory(String id) async {
    try {
      await categoriesCollectionRef.doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete category: ${e.toString()}');
    }
  }

  @override
  Stream<List<CategoryModel>> getAllCategories() {
    try {
      return categoriesCollectionRef.snapshots().map((querySnapshot) {
        return querySnapshot.docs
            .map((doc) => CategoryModel.fromSnapshot(doc))
            .toList();
      });
    } catch (e) {
      throw Exception('Failed to fetch categories: ${e.toString()}');
    }
  }

  @override
  Future<void> updateCategory(CategoryModel category) async {
    try {
      final updatedCategory = CategoryModel(
        id: category.id,
        name: category.name,
        defaultDiscountPercent: category.defaultDiscountPercent,
        createdAt: category.createdAt,
        updatedAt: Timestamp.now(),
      );

      await categoriesCollectionRef
          .doc(category.id)
          .update(updatedCategory.toJson());
    } catch (e) {
      throw Exception('Failed to update category: ${e.toString()}');
    }
  }
}

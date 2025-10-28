import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/models/category_model.dart';
import '../../domain/repositories/category_repository.dart';
import '../dto/category_dto.dart';

class FirebaseCategoryRepository implements CategoryRepository {
  final FirebaseFirestore _firestore;

  FirebaseCategoryRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference get _categoriesCollection =>
      _firestore.collection(AppConstants.categoriesCollection);

  @override
  Future<List<CategoryModel>> getAllCategories() async {
    try {
      final snapshot = await _categoriesCollection
          .orderBy('name')
          .get();

      return snapshot.docs
          .map((doc) => CategoryDto.fromJson(
                doc.data() as Map<String, dynamic>,
                doc.id,
              ).toModel())
          .toList();
    } catch (e) {
      throw Exception('Failed to get categories: ${e.toString()}');
    }
  }

  @override
  Future<CategoryModel> getCategoryById(String id) async {
    try {
      final doc = await _categoriesCollection.doc(id).get();

      if (!doc.exists) {
        throw Exception('Category not found');
      }

      return CategoryDto.fromJson(
        doc.data() as Map<String, dynamic>,
        doc.id,
      ).toModel();
    } catch (e) {
      throw Exception('Failed to get category: ${e.toString()}');
    }
  }

  @override
  Future<String> createCategory(CategoryModel category) async {
    try {
      final now = Timestamp.now();
      final dto = CategoryDto(
        id: '',
        name: category.name,
        defaultDiscountPercent: category.defaultDiscountPercent,
        createdAt: now,
        updatedAt: now,
      );

      final docRef = await _categoriesCollection.add(dto.toJson());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create category: ${e.toString()}');
    }
  }

  @override
  Future<void> updateCategory(CategoryModel category) async {
    try {
      final dto = CategoryDto.fromModel(category);
      final data = dto.toJson();
      data['updatedAt'] = Timestamp.now();

      await _categoriesCollection.doc(category.id).update(data);
    } catch (e) {
      throw Exception('Failed to update category: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteCategory(String id) async {
    try {
      // Check if any products use this category
      final productsSnapshot = await _firestore
          .collection(AppConstants.productsCollection)
          .where('categoryId', isEqualTo: id)
          .limit(1)
          .get();

      if (productsSnapshot.docs.isNotEmpty) {
        throw Exception(
            'Cannot delete category. Products are using this category.');
      }

      await _categoriesCollection.doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete category: ${e.toString()}');
    }
  }

  @override
  Stream<List<CategoryModel>> watchCategories() {
    return _categoriesCollection
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => CategoryDto.fromJson(
                doc.data() as Map<String, dynamic>,
                doc.id,
              ).toModel())
          .toList();
    });
  }
}


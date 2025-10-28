import '../models/category_model.dart';

abstract class CategoryRepository {
  Future<List<CategoryModel>> getAllCategories();
  Future<CategoryModel> getCategoryById(String id);
  Future<String> createCategory(CategoryModel category);
  Future<void> updateCategory(CategoryModel category);
  Future<void> deleteCategory(String id);
  Stream<List<CategoryModel>> watchCategories();
}


import 'package:billing_software/features/categories/domain/antity/category_model.dart';

abstract class CategoryRepository {
  Stream<List<CategoryModel>> getAllCategories();
  Future<String> createCategory(CategoryModel category);
  Future<void> updateCategory(CategoryModel category);
  Future<void> deleteCategory(String id);
}

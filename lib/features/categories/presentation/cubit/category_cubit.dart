import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/models/category_model.dart';
import '../../domain/repositories/category_repository.dart';

part 'category_state.dart';

class CategoryCubit extends Cubit<CategoryState> {
  final CategoryRepository _repository;

  CategoryCubit(this._repository) : super(CategoryState.initial());

  Future<void> loadCategories() async {
    try {
      emit(CategoryState.loading());
      final categories = await _repository.getAllCategories();
      emit(CategoryState.loaded(categories));
    } catch (e) {
      emit(CategoryState.error(e.toString()));
    }
  }

  Future<void> createCategory(String name, double discountPercent) async {
    try {
      final category = CategoryModel(
        id: '',
        name: name,
        defaultDiscountPercent: discountPercent,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _repository.createCategory(category);
      final categories = await _repository.getAllCategories();
      emit(CategoryState.success('Category created successfully', categories));
    } catch (e) {
      emit(CategoryState.error(e.toString()));
      await loadCategories();
    }
  }

  Future<void> updateCategory(CategoryModel category) async {
    try {
      await _repository.updateCategory(category);
      final categories = await _repository.getAllCategories();
      emit(CategoryState.success('Category updated successfully', categories));
    } catch (e) {
      emit(CategoryState.error(e.toString()));
      await loadCategories();
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      await _repository.deleteCategory(id);
      final categories = await _repository.getAllCategories();
      emit(CategoryState.success('Category deleted successfully', categories));
    } catch (e) {
      emit(CategoryState.error(e.toString()));
      await loadCategories();
    }
  }
}

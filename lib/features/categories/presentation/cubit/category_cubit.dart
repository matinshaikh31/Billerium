import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/models/category_model.dart';
import '../../domain/repositories/category_repository.dart';

part 'category_state.dart';

class CategoryCubit extends Cubit<CategoryState> {
  final CategoryRepository _repository;

  CategoryCubit(this._repository) : super(CategoryInitial());

  Future<void> loadCategories() async {
    try {
      emit(CategoryLoading());
      final categories = await _repository.getAllCategories();
      emit(CategoryLoaded(categories));
    } catch (e) {
      emit(CategoryError(e.toString()));
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
      emit(CategoryOperationSuccess('Category created successfully'));
      await loadCategories();
    } catch (e) {
      emit(CategoryError(e.toString()));
      await loadCategories();
    }
  }

  Future<void> updateCategory(CategoryModel category) async {
    try {
      await _repository.updateCategory(category);
      emit(CategoryOperationSuccess('Category updated successfully'));
      await loadCategories();
    } catch (e) {
      emit(CategoryError(e.toString()));
      await loadCategories();
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      await _repository.deleteCategory(id);
      emit(CategoryOperationSuccess('Category deleted successfully'));
      await loadCategories();
    } catch (e) {
      emit(CategoryError(e.toString()));
      await loadCategories();
    }
  }
}


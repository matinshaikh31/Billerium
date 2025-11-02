import 'dart:async';

import 'package:billing_software/features/categories/domain/antity/category_model.dart';
import 'package:billing_software/features/categories/domain/repositories/category_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'category_state.dart';

class CategoryCubit extends Cubit<CategoryState> {
  final CategoryRepository categoryRepository;

  CategoryCubit({required this.categoryRepository})
    : super(CategoryState.initial());

  StreamSubscription<List<CategoryModel>>? categoriesStream;

  Future<void> fetchCategories() async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    categoriesStream?.cancel();
    try {
      categoriesStream = categoryRepository.getAllCategories().listen((
        categories,
      ) {
        emit(
          state.copyWith(
            categories: categories,
            isLoading: false,
            errorMessage: null,
          ),
        );
      });
    } catch (e) {
      print('Error fetching master hotels: $e');
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      emit(state.copyWith(isLoading: true, errorMessage: null));
      await categoryRepository.deleteCategory(id);

      // Remove from local list
      final updatedCategories = state.categories
          .where((category) => category.id != id)
          .toList();

      emit(
        state.copyWith(
          categories: updatedCategories,
          isLoading: false,
          successMessage: 'Category deleted successfully',
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  void clearMessages() {
    emit(state.copyWith(errorMessage: null, successMessage: null));
  }
}

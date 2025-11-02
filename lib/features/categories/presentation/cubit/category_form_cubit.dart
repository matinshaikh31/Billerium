import 'package:billing_software/features/categories/domain/antity/category_model.dart';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:billing_software/features/categories/domain/repositories/category_repository.dart';

part 'category_form_state.dart';

class CategoryFormCubit extends Cubit<CategoryFormState> {
  final CategoryRepository categoryRepository;
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final discountController = TextEditingController();

  CategoryFormCubit({required this.categoryRepository})
    : super(CategoryFormState.initial());

  void setEditingCategory(CategoryModel category) {
    nameController.text = category.name;
    discountController.text = category.defaultDiscountPercent.toString();
    emit(state.copyWith(editingCategory: category));
  }

  void clearForm() {
    nameController.clear();
    discountController.clear();
    emit(state.copyWith(clearEditingCategory: true));
  }

  Future<void> createCategory() async {
    if (formKey.currentState?.validate() ?? false) {
      try {
        emit(state.copyWith(isLoading: true, errorMessage: null));

        final category = CategoryModel(
          id: '',
          name: nameController.text.trim(),
          defaultDiscountPercent: double.parse(discountController.text.trim()),
          createdAt: Timestamp.now(),
          updatedAt: Timestamp.now(),
        );

        await categoryRepository.createCategory(category);

        emit(
          state.copyWith(
            isLoading: false,
            successMessage: 'Category created successfully',
          ),
        );

        clearForm();
      } catch (e) {
        emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
      }
    }
  }

  Future<void> updateCategory() async {
    if (formKey.currentState?.validate() ?? false) {
      if (state.editingCategory == null) return;

      try {
        emit(state.copyWith(isLoading: true, errorMessage: null));

        final updatedCategory = CategoryModel(
          id: state.editingCategory!.id,
          name: nameController.text.trim(),
          defaultDiscountPercent: double.parse(discountController.text.trim()),
          createdAt: state.editingCategory!.createdAt,
          updatedAt: Timestamp.now(),
        );

        await categoryRepository.updateCategory(updatedCategory);

        emit(
          state.copyWith(
            isLoading: false,
            successMessage: 'Category updated successfully',
          ),
        );

        clearForm();
      } catch (e) {
        emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
      }
    }
  }

  void clearMessages() {
    emit(state.copyWith(errorMessage: null, successMessage: null));
  }

  @override
  Future<void> close() {
    nameController.dispose();
    discountController.dispose();
    return super.close();
  }
}

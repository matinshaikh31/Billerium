

// ============================================
// 4. CATEGORY FORM STATE
// ============================================
// File: category_form_state.dart

part of 'category_form_cubit.dart';

class CategoryFormState extends Equatable {
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;
  final CategoryModel? editingCategory;

  const CategoryFormState({
    required this.isLoading,
    this.errorMessage,
    this.successMessage,
    this.editingCategory,
  });

  factory CategoryFormState.initial() {
    return const CategoryFormState(
      isLoading: false,
      errorMessage: null,
      successMessage: null,
      editingCategory: null,
    );
  }

  CategoryFormState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
    CategoryModel? editingCategory,
    bool clearEditingCategory = false,
  }) {
    return CategoryFormState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      successMessage: successMessage,
      editingCategory: clearEditingCategory ? null : (editingCategory ?? this.editingCategory),
    );
  }

  @override
  List<Object?> get props => [isLoading, errorMessage, successMessage, editingCategory];
}

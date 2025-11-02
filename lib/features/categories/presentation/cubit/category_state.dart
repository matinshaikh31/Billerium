part of 'category_cubit.dart';

class CategoryState {
  final List<CategoryModel> categories;
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;

  const CategoryState({
    required this.categories,
    required this.isLoading,
    this.errorMessage,
    this.successMessage,
  });

  factory CategoryState.initial() {
    return const CategoryState(
      categories: [],
      isLoading: false,
      errorMessage: null,
      successMessage: null,
    );
  }

  CategoryState copyWith({
    List<CategoryModel>? categories,
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
  }) {
    return CategoryState(
      categories: categories ?? this.categories,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }
}
